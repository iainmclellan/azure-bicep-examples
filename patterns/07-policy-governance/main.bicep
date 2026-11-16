targetScope = 'subscription'
param location string = 'uksouth'
param prefix string = 'bpdev'
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
 name: '${prefix}-governed-rg'
 location: location
 tags: { environment: 'dev' managedBy: 'bicep' }
}
resource policy 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
 name: '${prefix}-require-env-tag'
 scope: rg
 properties: {
 displayName: 'Require environment tag on resources'
 policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99'
 parameters: { tagName: { value: 'environment' } }
 enforcementMode: 'Default'
 }
}
output resourceGroupName string = rg.name
