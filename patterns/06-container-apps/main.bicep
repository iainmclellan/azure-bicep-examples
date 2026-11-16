targetScope = 'resourceGroup'
param location string = resourceGroup().location
param prefix string = 'bpdev'
resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
 name: '${prefix}-containers-law'
 location: location
 properties: { sku: { name: 'PerGB2018' } retentionInDays: 30 }
}
resource env 'Microsoft.App/managedEnvironments@2024-03-01' = {
 name: '${prefix}-cae'
 location: location
 properties: { appLogsConfiguration: { destination: 'log-analytics' logAnalyticsConfiguration: { customerId: workspace.properties.customerId sharedKey: listKeys(workspace.id, workspace.apiVersion).primarySharedKey } } }
}
resource app 'Microsoft.App/containerApps@2024-03-01' = {
 name: '${prefix}-hello'
 location: location
 properties: { managedEnvironmentId: env.id configuration: { ingress: { external: false targetPort: 80 transport: 'auto' } } template: { containers: [ { name: 'hello' image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest' resources: { cpu: json('0.25') memory: '0.5Gi' } } ] scale: { minReplicas: 0 maxReplicas: 2 } } }
}
output containerAppName string = app.name
