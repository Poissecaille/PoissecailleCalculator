from uuid import uuid4

from sqlalchemy import select
from backend.models.evaluation import Evaluation
from backend.models.expression import Expression


def test_get_evaluation(client, db_session):
    expression = Expression(id=str(uuid4()), value="3 5 +", is_rpn=True)
    print(" Avant insertion - Expression:", expression)
    db_session.add(expression)
    db_session.commit()
    db_session.refresh(expression)

    expr_check = db_session.exec(
        select(Expression).where(Expression.id == expression.id)
    ).first()
    print("Expression trouvée en base:", expr_check)

    evaluation = Evaluation(id=str(uuid4()), expressionId=expression.id, value=8.0)
    print(" Avant insertion - Evaluation:", evaluation)
    db_session.add(evaluation)
    db_session.commit()
    db_session.refresh(evaluation)

    expression_evaluation = db_session.exec(
        select(Evaluation, Expression)
        .join(Expression, Evaluation.expressionId == Expression.id)
        .where(Evaluation.id == evaluation.id)
    ).first()
    print(" Résultat de la requête SQL:", expression_evaluation)

    response = client.get(f"/evaluation/{evaluation.id}")
    print(" API Response:", response.json())

    assert response.status_code == 200
    response_data = response.json()
    assert response_data["data"]["evaluation"]["value"] == 8.0
    assert response_data["data"]["expression"]["value"] == "3 5 +"
