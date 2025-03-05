// Paramètres
param location string
param appServicePlanName string

// Création de l'App Service Plan dans le groupe de ressources
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
output appServicePlanId string = appServicePlan.id
