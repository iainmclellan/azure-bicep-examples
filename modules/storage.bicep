param name string
param location string
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
 name: name
 location: location
 sku: { name: 'Standard_LRS' }
 kind: 'StorageV2'
 properties: { supportsHttpsTrafficOnly: true, minimumTlsVersion: 'TLS1_2', allowBlobPublicAccess: false, publicNetworkAccess: 'Disabled' }
}
output id string = storage.id
