targetScope = 'resourceGroup'
param location string = resourceGroup().location
param prefix string = 'bpdev'
param tags object = { environment: 'dev' pattern: 'private-storage' }
var storageName = take(toLower(replace('${prefix}${uniqueString(resourceGroup().id)}', '-', '')), 24)
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
 name: '${prefix}-private-vnet'
 location: location
 tags: tags
 properties: { addressSpace: { addressPrefixes: [ '10.42.0.0/16' ] }
 subnets: [ { name: 'endpoints' properties: { addressPrefix: '10.42.1.0/24' } } ] }
}
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
 name: storageName
 location: location
 tags: tags
 sku: { name: 'Standard_LRS' }
 kind: 'StorageV2'
 properties: { publicNetworkAccess: 'Disabled' allowBlobPublicAccess: false minimumTlsVersion: 'TLS1_2' supportsHttpsTrafficOnly: true }
}
resource dns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
 name: 'privatelink.blob.core.windows.net'
 location: 'global'
 tags: tags
}
resource dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
 parent: dns
 name: '${prefix}-vnet-link'
 location: 'global'
 properties: { virtualNetwork: { id: vnet.id } registrationEnabled: false }
}
resource endpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
 name: '${prefix}-blob-pe'
 location: location
 tags: tags
 properties: {
 subnet: { id: '${vnet.id}/subnets/endpoints' }
 privateLinkServiceConnections: [ { name: 'blob' properties: { privateLinkServiceId: storage.id groupIds: [ 'blob' ] } } ]
 }
}
resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
 parent: endpoint
 name: 'default'
 properties: { privateDnsZoneConfigs: [ { name: 'blob' properties: { privateDnsZoneId: dns.id } } ] }
}
output storageAccountName string = storage.name
