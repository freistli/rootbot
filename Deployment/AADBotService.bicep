param botServices_rootbot01_name string = 'RootBot-${uniqueString(resourceGroup().id)}'
param botAppId string

resource botServices_rootbot01_name_resource 'Microsoft.BotService/botServices@2022-09-15' = {
  name: botServices_rootbot01_name
  location: 'global'
  sku: {
    name: 'F0'
  }
  kind: 'azurebot'
  properties: {
    displayName: botServices_rootbot01_name
    iconUrl: 'https://docs.botframework.com/static/devportal/client/images/bot-framework-default.png'
    endpoint: 'https://${botServices_rootbot01_name}.azurewebsites.net/api/messages'
    msaAppId: botAppId
    luisAppIds: []
    isStreamingSupported: true
    schemaTransformationVersion: '1.3'
    isCmekEnabled: false
    openWithHint: 'bfcomposer://'
    disableLocalAuth: false
  }
}

resource botServices_rootbot01_name_MsTeamsChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = {
  parent: botServices_rootbot01_name_resource
  name: 'MsTeamsChannel'
  location: 'global'
  properties: {
    properties: {
      enableCalling: false
      incomingCallRoute: 'graphPma'
      isEnabled: true
      deploymentEnvironment: 'CommercialDeployment'
      acceptedTerms: true
    }
    etag: 'W/"bfd284d1a8e61ecf5c27ef9d858944e03/22/2023 4:53:17 AM"'
    channelName: 'MsTeamsChannel'
    location: 'global'
  }
}

resource botServices_rootbot01_name_WebChatChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = {
  parent: botServices_rootbot01_name_resource
  name: 'WebChatChannel'
  location: 'global'
  properties: {
    properties: {
      sites: [
        {
          siteName: 'Default Site'
          isEnabled: true
          isWebchatPreviewEnabled: true
          isBlockUserUploadEnabled: false
        }
      ]
    }
    etag: 'W/"d5f539cc16a4165e4d35e58d91d32ac83/22/2023 4:53:17 AM"'
    channelName: 'WebChatChannel'
    location: 'global'
  }
}
