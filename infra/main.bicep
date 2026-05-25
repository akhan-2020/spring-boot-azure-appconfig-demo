@description('Location for all resources')
param location string = resourceGroup().location

@description('App Configuration store name')
param appConfigName string = 'appconfig-${uniqueString(resourceGroup().id)}'

@description('Key Vault name')
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'

@description('Current user object ID for Key Vault access')
param userObjectId string

// Azure App Configuration
resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appConfigName
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    enablePurgeProtection: false
  }
}

// Azure Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
  }
}

// Role: Key Vault Secrets User for current user
resource kvSecretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, userObjectId, 'Key Vault Secrets User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: userObjectId
    principalType: 'User'
  }
}

// Role: App Configuration Data Reader for current user
resource appConfigReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appConfiguration
  name: guid(appConfiguration.id, userObjectId, 'App Configuration Data Reader')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')
    principalId: userObjectId
    principalType: 'User'
  }
}

// Sample configuration key in App Configuration
resource configKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: appConfiguration
  name: 'app.message'
  properties: {
    value: 'Hello from Azure App Configuration!'
    contentType: 'text/plain'
  }
}

// Sample secret in Key Vault (referenced from App Configuration)
resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'database-password'
  properties: {
    value: 'P@ssw0rd-from-KeyVault-12345'
  }
}

output appConfigurationEndpoint string = appConfiguration.properties.endpoint
output keyVaultUri string = keyVault.properties.vaultUri
