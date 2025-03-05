import azure.functions as func
import json
import logging

from responses.server_response import ResponseCode, ResponseText, ServerResponse
from utils import evaluate_rpn_expression, save_expression
from logger import logger
from uuid import uuid4
from database import (
    Evaluation,
    Expression,
    get_session,
    save_evaluation,
)

app = func.FunctionApp()


@app.function_name("evaluateExpression")
@app.route(route="evaluate", auth_level=func.AuthLevel.FUNCTION, methods=["POST"])
def evaluate_expression(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")
    req_body = req.get_json()
    logging.debug(f"Request body: {req_body}")
    expression = req_body.get("value")
    if not expression:
        return func.HttpResponse("Invalid request parameters", status_code=400)

    return func.HttpResponse(
        f"Expression {expression} evaluated successfully", status_code=200
    )


def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logger.info("Python HTTP trigger function processed a request.")

    req_body = req.get_json()
    try:
        expression = Expression(**req_body)
    except ValueError as err:
        logger.warning(f"Erreur d'évaluation RPN: {err}")
        expression.is_rpn = False
        return func.HttpResponse(
            body=json.dumps(
                ServerResponse(
                    code=ResponseCode.BAD_REQUEST.value,
                    value=ResponseText.BAD_REQUEST,
                )
            ),
            status_code=ResponseCode.POST_SUCCESS.value,
        )
    expression.id = str(uuid4())
    session = get_session()
    evaluation_value = evaluate_rpn_expression(expression.value)
    try:
        save_expression(session, expression)
        evaluation = Evaluation(
            id=str(uuid4()), expressionId=expression.id, value=evaluation_value
        )
        save_evaluation(session, evaluation)
        logger.info(f"Expression évaluée: {evaluation.value} (ID: {evaluation.id})")
        return func.HttpResponse(
            body=json.dumps(
                ServerResponse(
                    code=ResponseCode.POST_SUCCESS.value,
                    value=ResponseText.SUCCESS,
                    data=evaluation.value,
                )
            ),
            status_code=ResponseCode.POST_SUCCESS.value,
        )
    except Exception as db_err:
        logger.error(
            f"Erreur lors de l'enregistrement dans la base de données : {db_err}"
        )
        session.rollback()
        return func.HttpResponse(
            body=func.HttpResponse(
                body=json.dumps(
                    ServerResponse(
                        code=ResponseCode.INTERNAL_ERROR.value,
                        value=ResponseText.INTERNAL_ERROR,
                    )
                ),
                status_code=ResponseCode.INTERNAL_ERROR.value,
            )
        )
