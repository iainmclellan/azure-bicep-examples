targetScope = 'resourceGroup'
@description('Azure region for the deployment')
param location string = resourceGroup().location
param vnetName string
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.42.0.0/16'] }
    subnets: [
      { name: 'app', properties: { addressPrefix: '10.42.1.0/24' } }
      { name: 'data', properties: { addressPrefix: '10.42.2.0/24' } }
    ]
  }
}
output resourceId string = vnet.id
