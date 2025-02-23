def test_create_expression(client, db_session):
    test_data = {"value": "3 5 +", "is_rpn": True}

    response = client.post("/evaluate", json=test_data)

    assert response.status_code == 200
    assert response.json()["code"] == 201
    assert response.json()["data"] == 8.0
