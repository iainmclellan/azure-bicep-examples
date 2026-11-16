targetScope = 'resourceGroup'
@description('Azure region for the deployment')
param location string = resourceGroup().location
param vaultName string
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  properties: {
    tenantId: tenant().tenantId
    sku: { family: 'A', name: 'standard' }
    enableRbacAuthorization: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
  }
}
output resourceId string = vault.id
