from pydantic import field_validator
from sqlmodel import Field, SQLModel
from uuid import uuid4
from datetime import datetime


class Expression(SQLModel, table=True):
    id: str = Field(
        default=str(uuid4()),
        primary_key=True,
        description="Id technique de l'expression",
    )
    created_at: str = Field(
        default=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        description="Date de création de l'expression",
    )
    value: str = Field(..., description="Valeur de l'expression")
    is_rpn: bool = Field(
        default=True, description="Indique si l'expression est en notation polonaise"
    )

    @field_validator("value")
    def validate_expression(cls, v):
        if not v or not v.strip():
            raise ValueError("Expression cannot be empty")
        return v.strip()
