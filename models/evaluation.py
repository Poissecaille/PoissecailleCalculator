from sqlmodel import Field, SQLModel
from uuid import uuid4
from datetime import datetime


class Evaluation(SQLModel, table=True):
    id: str = Field(
        default=str(uuid4()),
        primary_key=True,
        description="Id technique evaluation de l'expression",
    )
    expressionId: str = Field(
        foreign_key="expression.id",
        nullable=False,
        description="Id technique table parente (expression) de l'évaluation",
    )
    created_at: str = Field(
        default=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        description="Date de création de l'évaluation",
    )
    value: float = Field(nullable=False, description="Valeur de l'évaluation")
