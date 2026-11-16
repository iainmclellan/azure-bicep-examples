targetScope = 'resourceGroup'
param location string = resourceGroup().location
param prefix string = 'bpdev'
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
 name: take(toLower('${prefix}${uniqueString(resourceGroup().id)}'), 24)
 location: location
 sku: { name: 'Standard_LRS' }
 kind: 'StorageV2'
 properties: { allowBlobPublicAccess: false minimumTlsVersion: 'TLS1_2' supportsHttpsTrafficOnly: true }
}
output storageName string = storage.name
