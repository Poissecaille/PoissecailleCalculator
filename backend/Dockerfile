FROM python:3.12

WORKDIR /app

COPY backend /app/backend

RUN pip install --no-cache-dir -r backend/requirements.txt

# Donner les droits d'exécution au script
RUN chmod +x /app/backend/entrypoint.sh

# Utiliser le script comme point d'entrée
ENTRYPOINT ["/app/backend/entrypoint.sh"]

# Définir un volume pour la base de données et les logs
VOLUME ["/app/backend/volume/db", "/app/backend/volume/logs"]

EXPOSE 8000

# NOTE deja une commande dans le fichier compose
# CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
