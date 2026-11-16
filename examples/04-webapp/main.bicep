targetScope = 'resourceGroup'
@description('Azure region for the deployment')
param location string = resourceGroup().location
param webAppName string
resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${webAppName}-plan'
  location: location
  sku: { name: 'B1', tier: 'Basic' }
  kind: 'linux'
  properties: { reserved: true }
}
resource app 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: { linuxFxVersion: 'NODE|20-lts', minTlsVersion: '1.2', ftpsState: 'Disabled' }
  }
}
output hostname string = app.properties.defaultHostName
