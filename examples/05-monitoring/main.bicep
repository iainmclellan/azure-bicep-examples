targetScope = 'resourceGroup'
@description('Azure region for the deployment')
param location string = resourceGroup().location
param workspaceName string
resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: { retentionInDays: 30, features: { enableLogAccessUsingOnlyResourcePermissions: true } }
  sku: { name: 'PerGB2018' }
}
output workspaceId string = workspace.id
