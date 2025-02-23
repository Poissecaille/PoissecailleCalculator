import pytest
import os

from fastapi.testclient import TestClient
from sqlmodel import SQLModel, Session, create_engine
from backend.main import app, SessionDep

DATABASE_URL = "sqlite:///./test_database.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})


@pytest.fixture(scope="function")
def db_session():
    """Crée une session SQLAlchemy réelle pour chaque test"""

    # Vérifie et ferme la connexion avant de supprimer la base
    if os.path.exists("test_database.db"):
        try:
            engine.dispose()  # 🔥 Ferme les connexions actives
            os.remove("test_database.db")  # Supprime proprement
        except PermissionError:
            print("⚠️ Impossible de supprimer test_database.db, il est encore utilisé !")

    SQLModel.metadata.create_all(engine)  # Crée les tables

    session = Session(engine)
    app.dependency_overrides[SessionDep] = lambda: session
    yield session

    session.close()  # Ferme la session proprement
    app.dependency_overrides.clear()


@pytest.fixture(scope="function")
def client():
    """Fixture qui fournit un client de test FastAPI"""
    return TestClient(app)
