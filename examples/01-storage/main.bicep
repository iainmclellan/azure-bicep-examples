targetScope = 'resourceGroup'
@description('Azure region for the deployment')
param location string = resourceGroup().location
@minLength(3)
@maxLength(24)
param storageAccountName string
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}
output resourceId string = storage.id
