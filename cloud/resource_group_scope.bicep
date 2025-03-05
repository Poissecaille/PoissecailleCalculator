targetScope = 'resourceGroup'
@description('The location for all resources')
param location string

@description('The name of the project')
param projectName string

@description('The environment (dev/test/prod)')
param environment string

@description('The name of the frontend app')
param frontendAppName string

@description('The name of the backend app')
param backendAppName string

@description('The name of the App Service Plan')
param appServicePlanName string

@description('The name of the Azure Files share')
param fileShareName string

@description('The name of the storage account for Azure Files')
param storageAccountName string

@description('The username of the Azure Container Registry')
param acrName string

@secure()
@description('The password of the Azure Container Registry')
param acrPassword string

// Azure Container Registry (ACR)
resource acr 'Microsoft.ContainerRegistry/registries@2024-11-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic' //TESTING != 'prod' ? 'PremiumV2' : 'Basic'
  }
  properties: {
    adminUserEnabled: true // Active l'accès admin pour push/pull des images
  }
}

// Plan App Service pour les fonctions (consommation)
resource functionAppServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: '${projectName}-${environment}-func-plan'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

// Création de l'App Service Plan dans le groupe de ressources  (consommation)
resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: 'B1' //TESTING != 'prod' ? 'P1v2' : 'B1'
    tier: 'Basic' //TESTING != 'prod' ? 'PremiumV2' : 'Basic'
  }
  properties: {
    reserved: true
  }
}

// Application Insights pour la télémétrie
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${projectName}-${environment}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    // publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
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

module backend 'backend.bicep' = {
  name: 'backend-deployment'
  scope: resourceGroup()
  params: {
    frontendAppName: frontendAppName
    backendAppName: backendAppName
    appServicePlanId: appServicePlan.id
    acrLoginServer: acr.properties.loginServer
    fileShareName: fileShareName
    storageAccountName: storageAccountName
    acrName: acrName
    acrPassword: acrPassword
    storageAccountId: storageAccount.id
  }
}

module frontend 'frontend.bicep' = {
  name: 'frontend-deployment'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    frontendAppName: frontendAppName
    appServicePlanId: appServicePlan.id
    acrLoginServer: acr.properties.loginServer
    acrName: acrName
    acrPassword: acrPassword
  }
}
// resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(backend.id, 'AcrPull')
//   scope: acr
//   properties: {
//     roleDefinitionId: subscriptionResourceId(
//       'Microsoft.Authorization/roleDefinitions',
//       '7f951dda-4ed3-4680-a7ca-43fe172d538d'
//     ) // ID du rôle AcrPull
//     principalId: backend.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }
// module acrRoleAssignment 'roleAssignment.bicep' = {
//   name: 'acr-role-assignment'
//   scope: resourceGroup()
//   // dependsOn: [backend, acr]
//   params: {
//     principalId: backend.outputs.backendPrincipalId
//     roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull role
//     acrName: acrName
//   }
// }
resource roleAssignmentBackend 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // Use a more unique GUID that includes a timestamp or unique string
  name: guid(acrName, backendAppName, 'AcrPull', uniqueString(deployment().name))
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    ) // AcrPull role
    principalId: backend.outputs.backendPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource roleAssignmentFrontend 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // Use a more unique GUID that includes a timestamp or unique string
  name: guid(acrName, frontendAppName, 'AcrPull', uniqueString(deployment().name))
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    ) // AcrPull role
    principalId: frontend.outputs.frontendPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(functionApp.name, 'StorageAccountContributor')
//   properties: {
//     roleDefinitionId: subscriptionResourceId(
//       'Microsoft.Authorization/roleDefinitions',
//       'b24988ac-6180-42a0-ab88-20f7382dd24c'
//     ) // Storage Account Contributor
//     principalId: functionApp.identity.principalId
//   }
// }

// resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
//   name: '${projectName}-${environment}-evaluate'
//   location: location
//   kind: 'functionapp'
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     serverFarmId: appServicePlan.id
//     siteConfig: {
//       linuxFxVersion: 'PYTHON|3.10'
//       appSettings: [
//         {
//           name: 'AzureWebJobsStorage'
//           value: storageAccount.properties.primaryEndpoints.blob
//         }
//         // {
//         //   name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
//         //   value: appInsights.properties.ConnectionString
//         // }
//         {
//           name: 'FUNCTIONS_EXTENSION_VERSION'
//           value: '~4'
//         }
//         {
//           name: 'FUNCTIONS_WORKER_RUNTIME'
//           value: 'python3.10'
//         }
//         {
//           name: 'WEBSITE_RUN_FROM_PACKAGE'
//           value: '${storageAccount.properties.primaryEndpoints.blob}functionzips/evaluate_function'
//         }
//       ]
//       azureStorageAccounts: {
//         sqlitevolume: {
//           type: 'AzureFiles'
//           accountName: storageAccount.name
//           shareName: fileShare.name
//           mountPath: '/mnt/sqlitevolume'
//           accessKey: storageAccount.listKeys().keys[0].value
//         }
//       }
//     }
//   }
// }

// Outputs globaux
output backendUrl string = backend.outputs.backendUrl
output frontendUrl string = frontend.outputs.frontendUrl
