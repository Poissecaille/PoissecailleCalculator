#!/bin/bash

echo $acrName
az acr login --name $acrName

# Get ACR credentials
username=$(az acr credential show --name $acrName --query "username" -o tsv)
password=$(az acr credential show --name $acrName --query "passwords[0].value" -o tsv)

# Docker login
echo $password | docker login $acrName.azurecr.io -u $username --password-stdin

cd ..
docker build -t backend:latest -f backend/Dockerfile .
# docker build -t frontend:latest -f frontend/Dockerfile ./frontend

docker tag backend:latest ${acrName}.azurecr.io/backend:latest
# docker tag frontend:latest ${acrName}.azurecr.io/frontend:latest

docker push ${acrName}.azurecr.io/backend:latest
# docker push ${acrName}.azurecr.io/frontend:latest

# # check ACR repo existance 
# az acr show --name ${acrName} --query "loginServer"
# # check ACR images existance in repo
# az acr repository list --name ${acrName} --output table

# cd cloud
# az deployment sub create \
#   --location westeurope \
#   --template-file main.bicep \
#   --parameters .bicepparam
