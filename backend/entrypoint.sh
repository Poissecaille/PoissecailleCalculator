#!/bin/bash

# Créer les fichiers de base de données s'ils n'existent pas
mkdir -p /app/backend/db
mkdir -p /app/backend/logs

# Donner les permissions sur les bases de données SQLite
echo $TESTING
if [ "$TESTING" = "true" ]; then
    echo "Testing mode"
    touch /app/backend/db/test_database.db
    chmod 777 /app/backend/db/test_database.db
else
    echo "Production mode"
    touch /app/backend/db/database.db
    chmod 777 /app/backend/db/database.db
fi

# Lancer l'application
cd /app
exec "$@"