@description('The location for deploying all resources')
param location string = resourceGroup().location

@description('The name of the frontend app')
param frontendAppName string

@description('The name of the backend app')
param backendAppName string

@description('The ID of the app service plan')
param appServicePlanId string

@description('The name of the Azure Container Registry')
param acrLoginServer string

@description('The storage account name')
param storageAccountName string

@description('The file share name')
param fileShareName string

@description('The storage account key')
param storageAccountKey string

// // App Service Plan (for both frontend and backend)
// resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
//   name: appServicePlanName
//   location: location
//   sku: {
//     name: 'B1' //TESTING != 'prod' ? 'P1v2' : 'B1'
//     tier: 'Basic' //TESTING != 'prod' ? 'PremiumV2' : 'Basic'
//   }
//   properties: {
//     reserved: true
//   }
//   kind: 'linux'
// }
// Backend Web App
resource backendApp 'Microsoft.Web/sites@2024-04-01' = {
  name: backendAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      // linuxFxVersion: 'PYTHON|3.12'
      // linuxFxVersion: 'DOCKER|myacr.azurecr.io/backend:latest'
      linuxFxVersion: 'DOCKER|${acrLoginServer}/backend:latest'
      alwaysOn: true
      cors: {
        allowedOrigins: [
          'https://${frontendAppName}.azurewebsites.net'
        ]
      }
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '8000'
        }
        {
          name: 'DATABASE_URL'
          value: '/app/db'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
      ]
      azureStorageAccounts: {
        sqlitevolume: {
          type: 'AzureFiles'
          accountName: storageAccountName
          shareName: fileShareName
          mountPath: '/app/db'
          accessKey: storageAccountKey
        }
      }
    }
  }
}

// Outputs
output backendUrl string = 'https://${backendApp.properties.defaultHostName}'
output backendPrincipalId string = backendApp.identity.principalId
