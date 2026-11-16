targetScope = 'resourceGroup'
param location string = resourceGroup().location
param storageAccountName string
module storage '../../modules/storage.bicep' = {
 name: 'storage-deployment'
 params: { name: storageAccountName, location: location }
}
output storageId string = storage.outputs.id
