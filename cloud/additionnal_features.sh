# implement later in bicep infra
# logging
# volume backend
az webapp log config   --name ${backendAppName}  --resource-group ${resourceGroupName}   --application-logging filesystem --docker-container-logging filesystem
az webapp log config   --name ${frontAppName}  --resource-group ${resourceGroupName}   --application-logging filesystem --docker-container-logging filesystem