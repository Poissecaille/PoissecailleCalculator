from fastapi import FastAPI

from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Query
from fastapi.exceptions import ResponseValidationError
from sqlmodel import Session, SQLModel, create_engine

from models.evaluation import Evaluation
from models.expression import Expression
from responses.server_response import ResponseCode, ResponseText, ServerResponse
from utils import evaluate_rpn_expression, save_evaluation, save_expression
from fastapi.middleware.cors import CORSMiddleware

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

sqlite_file_name = "database.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"

connect_args = {"check_same_thread": False}
# Create an engine to communicate with DB
engine = create_engine(sqlite_url, connect_args=connect_args)


def create_db_and_tables():
    SQLModel.metadata.create_all(engine)


def destroy_db_and_tables():
    SQLModel.metadata.drop_all(engine)


def get_session():
    # One session per request
    with Session(engine) as session:
        yield session


SessionDep = Annotated[Session, Depends(get_session)]


@app.on_event("startup")
def on_startup():
    create_db_and_tables()


@app.on_event("shutdown")
def on_shutdown():
    destroy_db_and_tables()


@app.post("/evaluate")
def create_expression(expression: Expression, session: SessionDep) -> ServerResponse:
    try:
        try:
            # Calculate the evaluation of the expression
            print("expression: ", expression)
            evaluation_value = evaluate_rpn_expression(expression.value)
        except (ValueError, ResponseValidationError) as err:
            print(err)
            expression.is_rpn = False
            save_expression(session, expression)
            # return ServerResponse(
            #     code=ResponseCode.BAD_REQUEST, value=ResponseText.BAD_REQUEST
            # )
            return HTTPException(
                status_code=ResponseCode.BAD_REQUEST.value,
                detail=ResponseText.BAD_REQUEST.value,
            )

        try:
            # Save expression
            save_expression(session, expression)
            evaluation = Evaluation(expressionId=expression.id, value=evaluation_value)
            print("evaluation: ", evaluation)
            # Save expression evaluation
            save_evaluation(
                session,
                expression,
                evaluation,
            )
        except Exception as db_err:
            print("db_err: ", db_err)
            session.rollback()
            return HTTPException(
                status_code=ResponseCode.INTERNAL_ERROR.value,
                detail=ResponseText.INTERNAL_ERROR.value,
            )
            # return ServerResponse(
            #     code=ResponseCode.INTERNAL_ERROR,
            #     value=ResponseText.INTERNAL_ERROR,
            # )

        return ServerResponse(
            code=ResponseCode.POST_SUCCESS,
            value=ResponseText.SUCCESS,
            data=evaluation.value,
        )
    except Exception as err:
        print("err: ", err)
        return HTTPException(
            status_code=ResponseCode.INTERNAL_ERROR.value,
            detail=ResponseText.INTERNAL_ERROR.value,
        )
        # return ServerResponse(
        #     code=ResponseCode.INTERNAL_ERROR, value=ResponseText.INTERNAL_ERROR
        # )


@app.get("/evaluation/{expression_id}")
def get_evaluation(expression_id: str, session: SessionDep) -> ServerResponse:
    try:
        # Retrieve the expression related evaluation (FK relationship)
        evaluation = (
            session.query(Evaluation)
            .filter(Evaluation.expressionId == expression_id)
            .first()
        )

        print("evaluation: ", evaluation)
        if not evaluation:
            return ServerResponse(
                value=ResponseText.NOT_FOUND,
                code=ResponseCode.NOT_FOUND,
            )
        return ServerResponse(
            value=ResponseText.SUCCESS,
            code=ResponseCode.GET_SUCCESS,
            data=evaluation.value,
        )
    except Exception as err:
        print("err: ", err)
        return HTTPException(
            status_code=ResponseCode.INTERNAL_ERROR.value,
            detail=ResponseText.INTERNAL_ERROR.value,
        )
        # return ServerResponse(
        #     value=ResponseText.INTERNAL_ERROR,
        #     code=ResponseCode.INTERNAL_ERROR,
        # )
