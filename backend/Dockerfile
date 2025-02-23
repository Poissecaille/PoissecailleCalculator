FROM python:3.12

# Définir le répertoire de travail
WORKDIR /app

# Copier uniquement requirements.txt et installer les dépendances
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copier tout le contenu du projet dans /app
COPY . /app/

# Définir les volumes pour la base de données et les logs
VOLUME ["/app/db", "/app/logs"]

# Définir le PYTHONPATH pour que Python trouve bien les modules
ENV PYTHONPATH=/app

EXPOSE 8000

# Lancer l'application FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
