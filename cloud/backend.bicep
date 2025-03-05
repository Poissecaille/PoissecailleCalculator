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

// @secure()
// @description('The key of the storage account')
// param storageAccountKey string7
@description('Storage account id')
param storageAccountId string

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

// resource existingStorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
//   name: storageAccountName
// }

// resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
//   parent: existingStorageAccount
//   name: 'default'
// }

// resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
//   parent: fileService
//   name: fileShareName
//   properties: {
//     accessTier: 'TransactionOptimized'
//   }
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
          value: '/app/backend/db'
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
          mountPath: '/app/backend/db'
          accessKey: listKeys(storageAccountId, '2023-01-01').keys[0].value
        }
      }
    }
  }
}

// Outputs
output backendUrl string = 'https://${backendApp.properties.defaultHostName}'
output backendPrincipalId string = backendApp.identity.principalId
