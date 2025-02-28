@description('The location for deploying all resources')
param location string = resourceGroup().location

@description('The name of the project')
param projectName string

@description('The environment (dev/test/prod)')
param environment string

@description('The name of the frontend app')
param frontendAppName string

@description('The ID of the App Service Plan')
param appServicePlanId string

@description('The name of the Azure Container Registry')
param acrLoginServer string

@description('The username of the Azure Container Registry')
param acrName string

@secure()
@description('The password of the Azure Container Registry')
param acrPassword string

// Variables for naming convention
var prefix = '${projectName}-${environment}'
var backendAppName = '${prefix}-backend'

resource frontendApp 'Microsoft.Web/sites@2024-04-01' = {
  name: frontendAppName
  location: location
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      // linuxFxVersion: 'NODE|20-lts'
      // linuxFxVersion: 'DOCKER|myacr.azurecr.io/frontend:latest'
      linuxFxVersion: 'DOCKER|${acrLoginServer}/frontend:latest'
      alwaysOn: true
      appSettings: [
        {
          name: 'VITE_BACKEND_URL'
          value: 'https://${backendAppName}.azurewebsites.net'
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
      ]
    }
  }
}
output frontendUrl string = 'https://${frontendApp.properties.defaultHostName}'
