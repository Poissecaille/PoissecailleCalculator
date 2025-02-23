from uuid import uuid4
from backend.models.evaluation import Evaluation
from backend.models.expression import Expression


def test_fetch_data(client, db_session):
    expression = Expression(id=str(uuid4()), value="3 5 +", is_rpn=True)
    db_session.add(expression)
    db_session.commit()
    db_session.refresh(expression)

    evaluation = Evaluation(id=str(uuid4()), expressionId=expression.id, value=8.0)
    db_session.add(evaluation)
    db_session.commit()
    db_session.refresh(evaluation)

    response = client.get("/fetchData")

    assert response.status_code == 200
    assert "text/csv" in response.headers["content-type"]
    assert "expression_id" in response.text
    assert "evaluation_value" in response.text
