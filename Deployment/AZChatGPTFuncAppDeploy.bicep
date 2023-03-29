@description('The name of the function app that you wish to create.')
param appName string = 'FuncApp-${uniqueString(resourceGroup().id)}'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Location for Application Insights')
param appInsightsLocation string = location

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'node'

param azureOpenAIAPIKey string 

param azureOpenAIAPIBase string

param chatGPTDeployName string

param azureRedisHostName string = 'none'

param azureRedisAccessKey string = 'none'

param useCache string = 'none'
 

var functionAppName = appName
var hostingPlanName = appName
var applicationInsightsName = appName
var storageAccountName = uniqueString(resourceGroup().id)
var functionWorkerRuntime = runtime

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

resource hostingPlan2 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId:  hostingPlan2.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'AZURE_OPENAI_API_KEY'
          value: azureOpenAIAPIKey
        }
        {
          name: 'AZURE_OPENAI_API_BASE'
          value: azureOpenAIAPIBase
        }
        {
          name: 'CHATGPT_DEPLOY_NAME'
          value: chatGPTDeployName
        }
        {
          name: 'AZURE_CACHE_FOR_REDIS_HOST_NAME'
          value: azureRedisHostName
        }
        {
          name: 'AZURE_CACHE_FOR_REDIS_ACCESS_KEY'
          value: azureRedisAccessKey
        }
        {
          name: 'USE_CACHE'
          value: useCache
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
                        
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource functionAppName_web 'Microsoft.Web/sites/sourcecontrols@2018-11-01' = {
  parent: functionApp
  name: 'web'
  properties: {
    repoUrl: 'https://github.com/freistli/azchatgptfunc.git'
    branch: 'main'
    isManualIntegration: true
  }
}

output funcappname string = functionAppName
