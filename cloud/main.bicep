targetScope = 'subscription'
@description('The name of the resource group to create')
param resourceGroupName string

@description('The name of the App Service Plan')
param resourceAppPlanName string

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

module acr 'acr.bicep' = {
  name: acrName
  scope: resourceGroup
  params: {
    location: location
    acrName: acrName
  }
}

module appServicePlan 'appServicePlan.bicep' = {
  name: resourceAppPlanName
  scope: resourceGroup
  params: {
    location: location
    appServicePlanName: appServicePlanName
  }
}

module backend 'backend.bicep' = {
  name: 'backend-deployment'
  scope: resourceGroup
  params: {
    frontendAppName: frontendAppName
    backendAppName: backendAppName
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    acrLoginServer: acr.outputs.loginServer
    fileShareName: fileShareName
    storageAccountName: storageAccountName
    acrName: acrName
    acrPassword: acrPassword
  }
}

module frontend 'frontend.bicep' = {
  name: 'frontend-deployment'
  scope: resourceGroup
  params: {
    projectName: projectName
    environment: environment
    frontendAppName: frontendAppName
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    acrLoginServer: acr.outputs.loginServer
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
module acrRoleAssignment 'roleAssignment.bicep' = {
  name: 'acr-role-assignment'
  scope: resourceGroup
  // dependsOn: [backend, acr]
  params: {
    principalId: backend.outputs.backendPrincipalId
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull role
    acrName: acrName
  }
}

// Outputs globaux
output backendUrl string = backend.outputs.backendUrl
output frontendUrl string = frontend.outputs.frontendUrl
