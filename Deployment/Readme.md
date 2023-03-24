# Express Deployment as Azure ChatGPT Teams Bot

The script will help users setup all required resources by single command for quick verifying Teams ChatGPT bot (no other LLMs dependecies, simple and fast). 

<img width="357" alt="image" src="https://user-images.githubusercontent.com/8623897/227429491-1472099a-1006-40ea-b216-21b00331047f.png">

Build environment is not required during express deployment. 

Windows, PowerShell and latest [AZ CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) 2.46.0 are required.

It will take around 7~10 minutes. After completion, open the created bot service in resource group, and can open it in Teams Channel directly

## Clone Branch

```
git clone -b chatgptonly https://github.com/freistli/rootbot.git
cd .\rootbot\Deployment
```

## NOTE:

```
AZ CLI 2.4.6.0 has a bug that it reports [No section: 'bicep'] when run bicep without configurations at first time: 

https://github.com/Azure/azure-cli/issues/25710

If you hit this, please close the running PS window, and start second time with the same parameters, then it will work.
```

## Deploy All Resources to single Azure Subscription, let you pick up which subscription neeeds to be used 

```powershell
.\deploy.ps1 -baseName <resource base name> `
-apiBase <Azure OpenAI Service Url> `
-apiKey <Azure OpenAI Key> `
-chatGPTDeployName <ChatGPT Model Deployment name> `
-sameSubscription $true `
-zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```

## Deploy All Resources to single Azure Subscription, choose subscription id directly

```powershell
.\deploy.ps1 -baseName <resource base name> `
-apiBase <Azure OpenAI Service Url> `
-apiKey <Azure OpenAI Key> `
-chatGPTDeployName <ChatGPT Model Deployment name> `
-aadSubscription <Bot App Registration Azure Subscription id> `
-sameSubscription $true `
-zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```

## Deploy Bot App Registration and Azure Resources to different Azure Subscription

```powershell
.\deploy.ps1 -baseName <resource base name> `
-apiBase <Azure OpenAI Service Url> `
-apiKey <Azure OpenAI Key> `
-chatGPTDeployName <ChatGPT Model Deployment name> `
-sameSubscription $false `
-zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```
