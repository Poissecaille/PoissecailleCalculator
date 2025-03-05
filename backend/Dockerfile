FROM python:3.12

# Créer la structure du projet
WORKDIR /app
RUN mkdir -p /app/backend/db /app/backend/logs

# Copier les fichiers du projet
COPY . /app

# Installer les dépendances
RUN pip install --no-cache-dir -r backend/requirements.txt

# Permissions des répertoires de données
RUN chmod -R 777 /app/backend/db /app/backend/logs

# Make entrypoint executable
RUN chmod +x backend/entrypoint.sh

# Définir un volume pour la base de données et les logs
# VOLUME ["/app/backend/db", "/app/backend/logs"]

WORKDIR /app
ENTRYPOINT ["./backend/entrypoint.sh"]
CMD ["python", "-m", "uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]