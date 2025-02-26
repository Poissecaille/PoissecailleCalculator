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

@description('The name of the Azure Container Registry')
param acrName string

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
  }
}

// Outputs globaux
output backendUrl string = backend.outputs.backendUrl
output frontendUrl string = frontend.outputs.frontendUrl
