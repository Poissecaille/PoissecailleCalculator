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
docker build -t frontend:latest -f frontend/Dockerfile ./frontend

docker tag backend:latest ${acrName}.azurecr.io/backend:latest
docker tag frontend:latest ${acrName}.azurecr.io/frontend:latest

docker push ${acrName}.azurecr.io/backend:latest
docker push ${acrName}.azurecr.io/frontend:latest
# # correction image registry name
az webapp config container set --name poissecailleCalculator-backend --resource-group poissecaille-rg \
  --docker-custom-image-name poissecailleacr.azurecr.io/backend:latest
az webapp restart --name poissecailleCalculator-backend --resource-group poissecaille-rg
az webapp config container set --name poissecailleCalculator-frontend --resource-group poissecaille-rg \
  --docker-custom-image-name poissecailleacr.azurecr.io/frontend:latest
az webapp restart --name poissecailleCalculator-frontend --resource-group poissecaille-rg

# # update des droits admin sur ACR
az acr update --name poissecailleacr --admin-enabled true
az acr show --name poissecailleacr --query "adminUserEnabled"

# check ACR repo existance 
az acr show --name ${acrName} --query "loginServer"
# check ACR images existance in repo
az acr repository list --name ${acrName} --output table

# # assignement du role acr pull sur l'identité managée (principalID) de backendapp
# az webapp identity show --name $backendAppName --resource-group $resourceGroupName
# az role assignment list --scope $(az acr show --name $acrName --query "id" --output tsv) --output table
# az role assignment create \
#   --assignee b6165961-0a8c-412b-aa5f-e5bae30b2c62\
#   --role "AcrPull" \
#   --scope $(az acr show --name $acrName --query id -o tsv)


# cd cloud
# az deployment sub create \
#   --location westeurope \
#   --template-file main.bicep \
#   --parameters .bicepparam



# az deployment sub create   --location westeurope  --template-file subscription_scope.bicep   --parameters ./.bicepparam