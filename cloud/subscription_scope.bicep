targetScope = 'subscription'
@description('The name of the resource group to create')
param resourceGroupName string

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

// @description('The name of the storage account for Azure Files')
// param storageAccountName string = 'poissecaillestorage'

// @description('The name of the Azure Files share')
// param fileShareName string = 'sqlitevolume'

// Création du groupe de ressources (Scope: Subscription)
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
}

module deployment 'resource_group_scope.bicep' = {
  name: 'resource-group-deployment'
  scope: resourceGroup
  params: {
    location: location
    projectName: projectName
    environment: environment
    frontendAppName: frontendAppName
    backendAppName: backendAppName
    appServicePlanName: appServicePlanName
    fileShareName: fileShareName
    storageAccountName: storageAccountName
    acrName: acrName
    acrPassword: acrPassword
  }
}

// // Azure Container Registry (ACR)
// resource acr 'Microsoft.ContainerRegistry/registries@2024-11-01-preview' = {
//   name: acrName
//   location: location
//   sku: {
//     name: 'Basic' //TESTING != 'prod' ? 'PremiumV2' : 'Basic'
//   }
//   properties: {
//     adminUserEnabled: true // Active l'accès admin pour push/pull des images
//   }
// }

// // module acr 'acr.bicep' = {
// //   name: acrName
// //   scope: resourceGroup
// //   params: {
// //     location: location
// //     acrName: acrName
// //   }
// // }

// module appServicePlan 'appServicePlan.bicep' = {
//   name: resourceAppPlanName
//   scope: resourceGroup
//   params: {
//     location: location
//     appServicePlanName: appServicePlanName
//   }
// }

// module backend 'backend.bicep' = {
//   name: 'backend-deployment'
//   scope: resourceGroup
//   params: {
//     frontendAppName: frontendAppName
//     backendAppName: backendAppName
//     appServicePlanId: appServicePlan.outputs.appServicePlanId
//     acrLoginServer: acr.outputs.loginServer
//     fileShareName: fileShareName
//     storageAccountName: storageAccountName
//     acrName: acrName
//     acrPassword: acrPassword
//   }
// }

// module frontend 'frontend.bicep' = {
//   name: 'frontend-deployment'
//   scope: resourceGroup
//   params: {
//     projectName: projectName
//     environment: environment
//     frontendAppName: frontendAppName
//     appServicePlanId: appServicePlan.outputs.appServicePlanId
//     acrLoginServer: acr.outputs.loginServer
//     acrName: acrName
//     acrPassword: acrPassword
//   }
// }
// // resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
// //   name: guid(backend.id, 'AcrPull')
// //   scope: acr
// //   properties: {
// //     roleDefinitionId: subscriptionResourceId(
// //       'Microsoft.Authorization/roleDefinitions',
// //       '7f951dda-4ed3-4680-a7ca-43fe172d538d'
// //     ) // ID du rôle AcrPull
// //     principalId: backend.identity.principalId
// //     principalType: 'ServicePrincipal'
// //   }
// // }
// module acrRoleAssignment 'roleAssignment.bicep' = {
//   name: 'acr-role-assignment'
//   scope: resourceGroup
//   // dependsOn: [backend, acr]
//   params: {
//     principalId: backend.outputs.backendPrincipalId
//     roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull role
//     acrName: acrName
//   }
// }

// resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
//   name: 'poissecailleCalculatorEvaluate'
//   location: location
//   kind: 'functionapp'
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     serverFarmId: appServicePlan.id
//     siteConfig: {
//       linuxFxVersion: 'PYTHON|3.12'
//       appSettings: [
//         {
//           name: 'AzureWebJobsStorage'
//           value: storageAccount.properties.primaryEndpoints.blob
//         }
//         {
//           name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
//           value: appInsights.properties.ConnectionString
//         }
//         {
//           name: 'FUNCTIONS_EXTENSION_VERSION'
//           value: '~4'
//         }
//         {
//           name: 'FUNCTIONS_WORKER_RUNTIME'
//           value: 'dotnet' // Ajuste selon ton runtime
//         }
//         {
//           name: 'WEBSITE_RUN_FROM_PACKAGE'
//           value: functionZipUrl // URL du ZIP avec SAS Token si nécessaire
//         }
//       ]
//     }
//   }
// }

// // Outputs globaux
// output backendUrl string = backend.outputs.backendUrl
// output frontendUrl string = frontend.outputs.frontendUrl
// output resourceGroupId string = resourceGroup.id
// output resourceGroupName string = resourceGroup.name
