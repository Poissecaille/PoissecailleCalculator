#!/bin/bash

# Donner les permissions sur les bases de données SQLite
echo $TESTING
if ( $TESTING ); then
    echo "Testing mode"
    chmod 700 /app/db/database_test.db
else
    echo "Production mode"
    chmod 700 /app/db/database.db
fi

# Lancer l'application
exec "$@"
