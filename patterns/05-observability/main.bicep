targetScope = 'resourceGroup'
param location string = resourceGroup().location
param prefix string = 'bpdev'
resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
 name: '${prefix}-law'
 location: location
 properties: { sku: { name: 'PerGB2018' } retentionInDays: 30 }
}
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
 name: take(toLower('${prefix}${uniqueString(resourceGroup().id)}'), 24)
 location: location
 sku: { name: 'Standard_LRS' }
 kind: 'StorageV2'
 properties: { allowBlobPublicAccess: false minimumTlsVersion: 'TLS1_2' }
}
resource diagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
 name: 'storage-to-law'
 scope: storage
 properties: { workspaceId: workspace.id metrics: [ { category: 'Transaction' enabled: true } ] }
}
output workspaceId string = workspace.id
