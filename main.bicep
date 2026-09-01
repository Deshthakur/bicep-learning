// ==========================================
// 1. PARAMETERS (Inputs)
// ==========================================
@description('The Azure Region where resources will be deployed')
param location string = resourceGroup().location

@description('Deployment Environment')
@allowed([
  'dev'
  'prod'
])
param environment string = 'dev'

@description('Prefix for the storage account name')
@minLength(3)
@maxLength(11)
param namePrefix string = 'learn'

// ==========================================
// 2. VARIABLES (Internal Calculations)
// ==========================================
// Storage Account names must be globally unique, 3-24 lowercase alphanumeric chars
var uniqueSuffix = uniqueString(resourceGroup().id)
var storageAccountName = toLower('${namePrefix}${environment}${take(uniqueSuffix, 8)}')
var storageSku = (environment == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

// ==========================================
// 3. RESOURCE (Storage Account)
// ==========================================
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
  tags: {
    Environment: environment
    ManagedBy: 'Bicep'
    Project: 'Bicep-Learning'
  }
}

// ==========================================
// 4. OUTPUTS (Returned data)
// ==========================================
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
