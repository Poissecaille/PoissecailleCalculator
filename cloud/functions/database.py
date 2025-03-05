from datetime import datetime
from pydantic import field_validator
from sqlmodel import Field, Session, SQLModel, create_engine
from logger import logger

# Définir le chemin de la base de données dans Azure File Share
SQLITE_DB_PATH = "/mnt/sqlitevolume/database.sqlite"

# Créer l'engine SQLAlchemy
engine = create_engine(f"sqlite:///{SQLITE_DB_PATH}", echo=True)


# Fonction pour obtenir une session
def get_session():
    with Session(engine) as session:
        yield session


class Evaluation(SQLModel, table=True):
    __table_args__ = {"extend_existing": True}
    id: str = Field(
        ...,
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


class Expression(SQLModel, table=True):
    __table_args__ = {"extend_existing": True}

    id: str = Field(
        ...,
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


def create_db_and_tables():
    logger.info("Base de données et tables créées")
    SQLModel.metadata.create_all(engine)


def save_expression(session: Session, expression: Expression) -> None:
    """Save an expression in the database."""
    session.add(expression)
    session.commit()
    session.refresh(expression)


def save_evaluation(session: Session, evaluation: Evaluation) -> None:
    """Save an expression related evaluation in the database."""
    session.add(evaluation)
    session.commit()
    session.refresh(evaluation)
