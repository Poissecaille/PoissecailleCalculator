@description('The name of the Azure Container Registry')
param acrName string

@description('The location for deploying all resources')
param location string

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

output loginServer string = acr.properties.loginServer
