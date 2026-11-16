targetScope = 'resourceGroup'
param location string = resourceGroup().location
param prefix string = 'bpdev'
param tags object = { environment: 'dev' pattern: 'hub-spoke' }
resource hub 'Microsoft.Network/virtualNetworks@2023-11-01' = {
 name: '${prefix}-hub-vnet'
 location: location
 tags: tags
 properties: { addressSpace: { addressPrefixes: [ '10.40.0.0/16' ] }
 subnets: [ { name: 'shared' properties: { addressPrefix: '10.40.1.0/24' } } ] }
}
resource spoke 'Microsoft.Network/virtualNetworks@2023-11-01' = {
 name: '${prefix}-spoke-vnet'
 location: location
 tags: tags
 properties: { addressSpace: { addressPrefixes: [ '10.41.0.0/16' ] }
 subnets: [ { name: 'workload' properties: { addressPrefix: '10.41.1.0/24' } } ] }
}
resource hubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
 parent: hub
 name: 'hub-to-spoke'
 properties: { remoteVirtualNetwork: { id: spoke.id } allowVirtualNetworkAccess: true allowForwardedTraffic: false }
}
resource spokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
 parent: spoke
 name: 'spoke-to-hub'
 properties: { remoteVirtualNetwork: { id: hub.id } allowVirtualNetworkAccess: true allowForwardedTraffic: false }
}
output hubId string = hub.id
output spokeId string = spoke.id
