#!/bin/bash

# Donner les permissions sur les bases de données SQLite
chmod 777 /app/db/database.db
chmod 777 /app/db/database_test.db

# Lancer l'application
exec "$@"
