#!/bin/bash

rm -rf evaluate.zip
zip -r evaluate.zip logs/ responses/ database.py function_app.py host.json local.settings.json logger.py requirements.txt utils.py

az storage container create \
    --name functionzips \
    --account-name poissecaillestorage \
    --auth-mode login

az storage blob upload \
    --account-name poissecaillestorage \
    --name evaluate_function \
    --container-name functionzips \
    --file evaluate.zip \
    --overwrite
