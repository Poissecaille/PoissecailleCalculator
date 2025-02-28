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

@description('The name of the storage account')
param storageAccountName string

@description('The name of the file share')
param fileShareName string

@description('The username of the Azure Container Registry')
param acrName string

@secure()
@description('The password of the Azure Container Registry')
param acrPassword string

// App Service Plan (for both frontend and backend)
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

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// Récupération des clés du compte de stockage
var storageAccountKey = storageAccount.listKeys().keys[0].value

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: fileService
  name: fileShareName
  properties: {
    accessTier: 'TransactionOptimized'
  }
}

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
          name: 'TESTING'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acrPassword
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'true'
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
