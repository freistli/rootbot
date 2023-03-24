# Express Deployment

The script will help users setup all required resources by single command for Teams ChatGPT bot. 

Build environment is not required during express deployment. 

PowerShell and latest AZ CLI 2.46.0 are required.

It will take around 7~10 minutes. After completion, open the created bot service in resource group, and can open it in Teams Channel directly

## Clone Branch

```
git clone -b chatgptonly https://github.com/freistli/rootbot.git
cd .\rootbot\Deployment
```

## Deploy All Resources to single Azure Subscription, let you pick up which subscription neeeds to be used 

```powershell
.\deploy.ps1 -baseName <resource base name> -apiBase <Azure OpenAI Service Url> -apiKey <Azure OpenAI Key> -chatGPTDeployName <ChatGPT Model Deployment name> -sameSubscription $true -zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```

## Deploy All Resources to single Azure Subscription, choose subscription id directly

```powershell
.\deploy.ps1 -baseName <resource base name> -apiBase <Azure OpenAI Service Url> -apiKey <Azure OpenAI Key> -chatGPTDeployName <ChatGPT Model Deployment name> -aadSubscription <Bot App Registration Azure Subscription id> -sameSubscription $true -zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```

## Deploy Bot App Registration and Azure Resources to different Azure Subscription

```powershell
.\deploy.ps1 -baseName <resource base name> -apiBase <Azure OpenAI Service Url> -apiKey <Azure OpenAI Key> -chatGPTDeployName <ChatGPT Model Deployment name> -sameSubscription $false -zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```
