#!/bin/bash

# Push images to ACR
echo $acrName
az acr login --name $acrName
cd ..
docker build -t backend:latest -f backend/Dockerfile .
docker build -t frontend:latest -f frontend/Dockerfile ./frontend

docker tag backend:latest ${acrName}.azurecr.io/backend:latest
docker tag frontend:latest ${acrName}.azurecr.io/frontend:latest

docker push ${acrName}.azurecr.io/backend:latest
docker push ${acrName}.azurecr.io/frontend:latest
az deployment sub create \
  --location westeurope \
  --template-file cloud/main.bicep \
  --parameters cloud/.bicepparam

# check ACR repo existance 
az acr show --name ${acrName} --query "loginServer"
# check ACR images existance in repo
az acr repository list --name ${acrName} --output table
