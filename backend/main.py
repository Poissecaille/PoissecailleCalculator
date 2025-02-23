import io
import csv
import os
from uuid import uuid4
from typing import Annotated

from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, SQLModel, create_engine, select

from backend.models.evaluation import Evaluation
from backend.models.expression import Expression
from backend.responses.server_response import ResponseCode, ResponseText, ServerResponse
from backend.utils import evaluate_rpn_expression, save_evaluation, save_expression
from backend.logger import logger

origins = [
    "http://localhost:5173",
]

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


is_testing = os.getenv("TESTING", "false") == "true"

sqlite_file_name = "test_database.db" if is_testing else "database.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"
engine = create_engine(sqlite_url, connect_args={"check_same_thread": False})


def create_db_and_tables():
    logger.info("Base de données et tables créées")
    SQLModel.metadata.create_all(engine)


def destroy_db_and_tables():
    SQLModel.metadata.drop_all(engine)
    logger.warning("Suppression de toutes les tables")


def get_session():
    with Session(engine) as session:
        yield session


SessionDep = Annotated[Session, Depends(get_session)]


# @app.on_event("startup")
# def on_startup():
#     create_db_and_tables()


# @app.on_event("shutdown")
# def on_shutdown():
#     destroy_db_and_tables()


@app.post("/evaluate", response_model=ServerResponse)
def create_expression(expression: Expression, session: SessionDep):
    """Évalue une expression en notation polonaise inverse (RPN)"""
    logger.info(f"📥 Réception d'une nouvelle expression: {expression.value}")

    try:
        expression.id = str(uuid4())
        evaluation_value = evaluate_rpn_expression(expression.value)
    except ValueError as err:
        logger.warning(f"Erreur d'évaluation RPN: {err}")
        expression.is_rpn = False
        save_expression(session, expression)
        raise HTTPException(
            status_code=ResponseCode.BAD_REQUEST.value,
            detail=ResponseText.BAD_REQUEST.value,
        )

    try:
        save_expression(session, expression)
        evaluation = Evaluation(
            id=str(uuid4()), expressionId=expression.id, value=evaluation_value
        )
        save_evaluation(session, evaluation)
        logger.info(f"Expression évaluée: {evaluation.value} (ID: {evaluation.id})")
    except Exception as db_err:
        logger.exception("Erreur lors de l'enregistrement dans la base de données !")
        session.rollback()
        raise HTTPException(
            status_code=ResponseCode.INTERNAL_ERROR.value,
            detail=ResponseText.INTERNAL_ERROR.value,
        )

    return ServerResponse(
        code=ResponseCode.POST_SUCCESS,
        value=ResponseText.SUCCESS,
        data=evaluation.value,
    )


@app.get("/evaluation/{evaluation_id}", response_model=ServerResponse)
def get_evaluation(evaluation_id: str, session: SessionDep):
    """Récupère l'évaluation d'une expression par son ID"""
    logger.info(f"🔍 Recherche de l'évaluation ID: {evaluation_id}")
    try:
        expression_evaluation = session.exec(
            select(Evaluation, Expression)
            .join(Expression, Evaluation.expressionId == Expression.id)
            .where(Evaluation.id == evaluation_id)
        ).first()
    except Exception:
        logger.exception("Erreur lors de la récupération d'une évaluation !")
        raise HTTPException(
            status_code=ResponseCode.INTERNAL_ERROR.value,
            detail=ResponseText.INTERNAL_ERROR.value,
        )
    if not expression_evaluation:
        logger.warning(f"Évaluation introuvable pour ID: {evaluation_id}")
        return ServerResponse(
            value=ResponseText.NOT_FOUND,
            code=ResponseCode.NOT_FOUND,
        )

    evaluation, expression = expression_evaluation

    logger.info(f"Évaluation trouvée: {evaluation.value} pour {expression.value}")
    return ServerResponse(
        value=ResponseText.SUCCESS,
        code=ResponseCode.GET_SUCCESS,
        data={
            "evaluation": {
                "id": evaluation.id,
                "value": evaluation.value,
                "created_at": evaluation.created_at,
                "expressionId": evaluation.expressionId,
            },
            "expression": {
                "id": expression.id,
                "value": expression.value,
                "is_rpn": expression.is_rpn,
                "created_at": expression.created_at,
            },
        },
    )


@app.get("/fetchData")
def get_all_evaluations(session: SessionDep):
    """Export toutes les évaluations en CSV"""
    logger.info("📤 Export des données en CSV...")
    # NOTE possibilité de mettre un mécanisme de pagination pour gros volumes de données
    try:
        expression_evaluations = session.exec(
            select(Evaluation, Expression).join(
                Expression, Evaluation.expressionId == Expression.id
            )
        ).all()

        if not expression_evaluations:
            logger.warning("Aucun enregistrement trouvé dans la base !")
            raise HTTPException(
                status_code=ResponseCode.NOT_FOUND.value,
                detail=ResponseText.NOT_FOUND.value,
            )

        buffer = io.StringIO()
        writer = csv.writer(buffer)

        headers = [
            "expression_id",
            "expression_value",
            "is_rpn",
            "expression_created_at",
            "evaluation_id",
            "evaluation_value",
            "evaluation_created_at",
        ]
        writer.writerow(headers)

        for evaluation, expression in expression_evaluations:
            writer.writerow(
                [
                    expression.id,
                    expression.value,
                    expression.is_rpn,
                    expression.created_at,
                    evaluation.id,
                    evaluation.value,
                    evaluation.created_at,
                ]
            )

        buffer.seek(0)

        logger.info(f"CSV généré avec {len(expression_evaluations)} entrées")
        return StreamingResponse(
            buffer,
            media_type="text/csv",
            headers={
                "Content-Disposition": f'attachment; filename="evaluations_{uuid4()}.csv"'
            },
        )

    except Exception:
        logger.exception("Erreur lors de l'export des évaluations !")
        raise HTTPException(
            status_code=ResponseCode.INTERNAL_ERROR.value,
            detail=ResponseText.INTERNAL_ERROR.value,
        )
