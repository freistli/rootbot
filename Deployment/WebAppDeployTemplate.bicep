@description('The name of you Web Site.')
param siteName string = 'RootBot-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The pricing tier for the hosting plan.')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param sku string = 'F1'

@description('The instance size of the hosting plan (small, medium, or large).')
@allowed([
  0
  1
  2
])
param workerSize int = 1

@description('The URL for the GitHub repository that contains the project to deploy.')
param repoURL string = ''

@description('The branch of the GitHub repository to use.')
param branch string = 'main'

var hostingPlanName = siteName

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: sku
    capacity: workerSize
  }
}

resource site 'Microsoft.Web/sites@2022-03-01' = {
  name: siteName
  location: location
  
  properties: {
    
    serverFarmId: hostingPlan.id    
    siteConfig: {
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
   
  }
}


resource siteName_web 'Microsoft.Web/sites/sourcecontrols@2020-12-01' = if (!(empty(repoURL))) {
  parent: site
  name: 'web'
  properties: {
    repoUrl: repoURL
    branch: branch
    isManualIntegration: true
  }
}

output webappname string = siteName
