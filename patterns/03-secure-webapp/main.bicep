targetScope = 'resourceGroup'
param location string = resourceGroup().location
param prefix string = 'bpdev'
param tags object = { environment: 'dev' pattern: 'secure-webapp' }
var appName = toLower('${prefix}-app-${uniqueString(resourceGroup().id)}')
resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
 name: '${prefix}-asp'
 location: location
 tags: tags
 sku: { name: 'B1' tier: 'Basic' }
 properties: { reserved: true }
 kind: 'linux'
}
resource app 'Microsoft.Web/sites@2023-12-01' = {
 name: appName
 location: location
 tags: tags
 identity: { type: 'SystemAssigned' }
 properties: { serverFarmId: plan.id httpsOnly: true siteConfig: { linuxFxVersion: 'NODE|20-lts' minTlsVersion: '1.2' ftpsState: 'Disabled' } }
}
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
 name: take(toLower('${prefix}-kv-${uniqueString(resourceGroup().id)}'), 24)
 location: location
 tags: tags
 properties: { tenantId: subscription().tenantId sku: { family: 'A' name: 'standard' } enableRbacAuthorization: true publicNetworkAccess: 'Enabled' }
}
resource secretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
 name: guid(vault.id, app.id, 'secrets-user')
 scope: vault
 properties: { principalId: app.identity.principalId principalType: 'ServicePrincipal' roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') }
}
output appUrl string = 'https://${app.properties.defaultHostName}'
output vaultName string = vault.name
