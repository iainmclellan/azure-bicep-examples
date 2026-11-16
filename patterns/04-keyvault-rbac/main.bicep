targetScope = 'resourceGroup'
param location string = resourceGroup().location
param prefix string = 'bpdev'
@description('Microsoft Entra object ID of a user, group, or service principal')
param principalId string
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
 name: take(toLower('${prefix}-kv-${uniqueString(resourceGroup().id)}'), 24)
 location: location
 properties: { tenantId: subscription().tenantId sku: { family: 'A' name: 'standard' } enableRbacAuthorization: true enablePurgeProtection: true publicNetworkAccess: 'Enabled' }
}
resource reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
 name: guid(vault.id, principalId, 'kv-secrets-user')
 scope: vault
 properties: { principalId: principalId roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') }
}
output vaultName string = vault.name
