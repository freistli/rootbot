# Index


This repository contains sample code to integrate AI services into Microsoft Teams as a bot.
Since chat is very common in Teams, this interface is very natural, and allows Microsoft 365 security, compliance and governance policies to be leveraged as a gateway for all conversations (just like a human chatting with a human).  

This is sample code -- it is not a product or a supported release.  Our intention is to give a starting point so that people can quickly connect AI services running via Azure or OpenAI, to Microsoft Teams.  Microsoft has announced a product line (Co-pilot and Business Chat) that takes this concept much further and is integrated with the Microsoft Graph for better fact checking and prompt enhancement with context.

But right now, you can use this sample code to experiment, learn and plan for the future, and it provides an interface to the ChatGPT expertienc but allowing monitoring and governance.

Want to get started with the simplest most common use case?  Use the Express Deployment Release.
[Express Deployment as Azure ChatGPT Teams Bot](#express-deployment-of-pre-built-chatgpt-teams-bot)

Want to understand how this bot works?
[Overview of the Teams AI Bot Lab](#welcome-to-the-ai-teams-bot-lab)


Want to experiment with more advanced features?
[Build More Features In Dev environment](#build-more-features-in-dev-environment)



# Express Deployment of pre-built ChatGPT Teams Bot.



<img width="357" alt="image" src="https://user-images.githubusercontent.com/8623897/227429491-1472099a-1006-40ea-b216-21b00331047f.png">

- Preparation is minimal - you need an Azure subscription, access to the Azure OpenAI API, and an endpoint for GPT3.5.

- The script will help users setup all other Azure resources using a single command.
- It will create a downloadable Teams App you can side-install.   
- No build environment is needed. 

- You can choose to use the Online Azure Shell, a local Azure CLI shell, or For Online Azure Shell, choose PowerShell option.

- For local environment, Windows, PowerShell and latest [AZ CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) 2.46.0 are required.

- Deployment will take around 7~10 minutes. 

- After completion, open the created bot service in resource group, and can open it in Teams Channel directly

### NOTE:


AZ CLI 2.4.6.0 has a bug that it reports ***[No section: 'bicep]*** when run bicep 
without configurations at first time: 

[https://github.com/Azure/azure-cli/issues/25710](https://github.com/Azure/azure-cli/issues/25710)

The script has handled this error inside using a retry method. In case you keep hitting this, please close the running PS window, and start second time with the 
same parameters, then it will work.


## Required Parameters of deploy.ps1

#### baseName
You give a name like "MyAIBot".  A resource group name will be created with {baseName}RG and all other services used will be inthat resource group. The bot app registration in Azure AD will be {baseName}.

#### apiBase
The Azure OpenAI Service Endpoint.  This is a URL that is generated when you setup OpenAI API in Azure.

#### apiKey
The Aure OpenAI Service Access Key.  This also gets generated when you setup the API.

#### chatGPTDeployName
The **gpt-35-turbo model** deployment name in your Azure OpenAI Service (whatever you called it). In this sample, it is 'chatgpt'

<img width="503" alt="image" src="https://user-images.githubusercontent.com/8623897/228241161-ea538dd6-c19e-495e-832b-94a2b9f87b30.png">

#### Other optional parameters
Run "get-help ./deploy.ps1", and refer to below sample commands.

## Option One: Online Azure Shell

### Deploy all resourses into the Azure Shell Subscription 

1. Open <a href="https://shell.azure.com" target="_blank">Azure Shell</a>
2. Choose PowerShell from the pull down menu.

<img width="294" alt="image" src="https://user-images.githubusercontent.com/8623897/228239966-78e3d070-1015-4c99-9b52-9ae77cf65917.png">

3. Run below command. Please be careful to keep a **blankspace** before the ` character in the Powershell command. 

```PowerShell

#Clone Branch to Azure Shell Cloud Drive
Get-CloudDrive | Select-Object -ExpandProperty MountPoint | set-location
git clone -b chatgptonly https://github.com/freistli/rootbot.git
set-location ./rootbot/Deployment

#Deployment
.\deployInAzureShell.ps1 -baseName <resource base name> `
-apiBase <Azure OpenAI Service Endpoint> `
-apiKey <Azure OpenAI Key> `
-chatGPTDeployName <gpt-35-turbo Model Deployment name> `
-zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```
Let it run for a while.  If you get an error message about bicep you should run it a second time.
It takes about 10 minutes to deploy all the services.


4. Click Manage File Share. Download the TeamsAIBot.zip to your local machine, and then you can side-load it to Teams.

<img width="315" alt="image" src="https://user-images.githubusercontent.com/8623897/228249096-820babb8-f215-4220-a12b-2028ae072188.png">

<img width="928" alt="image" src="https://user-images.githubusercontent.com/8623897/228249380-8c44f60f-5f66-4edb-a911-5a15f1c1bf07.png">


## Option Two: Local PowerShell & AZ CLI on Windows. 

Choose one of below commands, which will auto generate TeamsAIBot.App, open it in Explorer.exe for Teams App side load.

### Deploy All Resources to single Azure Subscription, let you pick up which subscription needs to be used 

```powershell
#Clone Branch to local folder 
git clone -b chatgptonly https://github.com/freistli/rootbot.git
cd .\rootbot\deployment

#Deployment
.\deploy.ps1 -baseName <resource base name> `
-apiBase <Azure OpenAI Service Endpoint> `
-apiKey <Azure OpenAI Key> `
-chatGPTDeployName <gpt-35-turbo Model Deployment name> `
-sameSubscription $true `
-zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```

### Deploy All Resources to single Azure Subscription, choose subscription id directly (if your Azure AD is different)

```powershell
#Clone Branch to local folder 
git clone -b chatgptonly https://github.com/freistli/rootbot.git
cd .\rootbot\deployment

#Deployment
.\deploy.ps1 -baseName <resource base name> `
-apiBase <Azure OpenAI Service Endpoint> `
-apiKey <Azure OpenAI Key> `
-chatGPTDeployName <gpt-35-turbo Model Deployment name> `
-aadSubscription <Bot App Registration Azure Subscription id> `
-sameSubscription $true `
-zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```

## Option Three: More Complex Deployments

### Deploy All Resources to single Azure Subscription, choose subscription id directly, use Azure Cache for Redis to host conversation flows for ChatGPT

```powershell
#Clone Branch to local folder 
git clone -b chatgptonly https://github.com/freistli/rootbot.git
cd .\rootbot\deployment

#Deployment
.\deploy.ps1 -baseName <resource base name> `
-apiBase <Azure OpenAI Service Endpoint> `
-apiKey <Azure OpenAI Key> `
-chatGPTDeployName <gpt-35-turbo Model Deployment name> `
-aadSubscription <Bot App Registration Azure Subscription id> `
-sameSubscription $true `
-zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
-useCache "AzureRedis" `
-azureCacheForRedisHostName "<your redis cache host>.redis.cache.windows.net" `
-azureCacheForRedisAccessKey "<your redis cache access key>"
```

### Deploy Bot App Registration and Azure Resources to different Azure Subscriptions

```powershell
#Clone Branch to local folder 
git clone -b chatgptonly https://github.com/freistli/rootbot.git
cd .\rootbot\deployment

#Deployment
.\deploy.ps1 -baseName <resource base name> `
-apiBase <Azure OpenAI Service Url> `
-apiKey <Azure OpenAI Key> `
-chatGPTDeployName <gpt-35-turbo Model Deployment name> `
-sameSubscription $false `
-zipUrl "https://github.com/freistli/rootbot/releases/download/Release/code_20230323-144829.zip"
```

# Welcome to the AI Teams bot lab

This bot project was created using the Bot Framework Composer using the Empty Bot template.  It therefore contains a minimal set of files necessary to have a working bot. We have then added certain triggers, dialogs and skills to integrate with LLM (Large Language Model) services, usually via the Azure OpenAI API.


   Added certain triggers, dialogs and skills to make the bot integrated with several LLMs services (ChatGPT can be from Azure OpenAI or OpenAI, GPT-3 from Azure OpenAI, DALL-E from OpenAI), working on Microsoft Teams Platform. You can configure the triggers in the project to use one or more LLMs services based on your needs. 

<img width="928" alt="image" src="https://user-images.githubusercontent.com/8623897/224331748-68fc3144-49cb-4d3f-91db-59819dffa397.png">

<img width="424" alt="image" src="https://user-images.githubusercontent.com/8623897/222939210-bcf24b28-36c0-4049-bded-a0e4745934cf.png">

## ChatGPT responses in Teams Conversation

<img width="958" alt="image" src="https://user-images.githubusercontent.com/8623897/221471351-0bebf072-ceb5-49ed-a3cb-2837916e0cbb.png">

<img width="807" alt="image" src="https://user-images.githubusercontent.com/8623897/221471644-ce9e1ead-7c19-4cda-8d3f-53a26927b581.png">

## Interactive in Teams Message Extension

<img width="321" alt="image" src="https://user-images.githubusercontent.com/8623897/221473432-b50434be-e103-4143-b89e-5e532af7aa77.png">

<img width="936" alt="image" src="https://user-images.githubusercontent.com/8623897/221473604-f5f16c53-d682-48db-bce2-4300232d168f.png">

## "Act As" ChatGPT with preset prompts in Adaptive Cards [experimental feature]

<img width="905" alt="image" src="https://user-images.githubusercontent.com/8623897/222938613-210d79f4-8f55-490b-8ac1-d7f29337cce7.png">

<img width="439" alt="image" src="https://user-images.githubusercontent.com/8623897/221474514-81ca299b-d417-42e8-8cea-359a754f52f1.png">

## DALLE in in Teams Message Extension

<img width="318" alt="image" src="https://user-images.githubusercontent.com/8623897/221493090-d2b3abab-6191-430a-b159-1c94c18be5c8.png">

<img width="918" alt="image" src="https://user-images.githubusercontent.com/8623897/221492795-fb8de08a-b7e8-4ff3-8e26-1d9c00ae1e68.png">

# Credits

 [ChatGPT API Pckages](https://github.com/transitive-bullshit/chatgpt-api) by [Travis Fischer](https://github.com/transitive-bullshit). Base on it, I implemented [Azure OpenAI ChatGPT API Package](https://www.npmjs.com/package/@freistli/azurechatgptapi)

 [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts) by [Fatih Kadir Akın](https://github.com/f). 
 
 [chatgpt-prompts package](https://github.com/pacholoamit/chatgpt-prompts) by [Pacholo Amit](https://github.com/pacholoamit). Based on it, I implemented [Azure OpenAI ChatGPT Prompts](https://www.npmjs.com/package/@freistli/azure-chatgpt-prompts)




# Build More Features In Dev environment

## Prerequests

1. [Install Bot Framework Composer](https://learn.microsoft.com/en-us/composer/install-composer)

2. Azure Subscription (able to create App Registration in AAD, Azure Bot, Azure function app, and Azure Web App resources)

3. OpenAI account if want to use ChatGPT and DALLE

4. Azure OpenAI account if want to use GPT-3

5. Teams Environment (Microsoft 365 Business Basic license & Microsoft Teams) if want to use in Teams Channel and Teams Message Extension)


## Steps

1. Clone the root bot from the main branch

   ```
   git clone https://github.com/freistli/rootbot.git
   ```

2. Open the folder in Bot Framework Composer
   
   Note: If BFC is not installed, please go through **Environment Preparation** of this article https://techcommunity.microsoft.com/t5/modern-work-app-consult-blog/create-a-weather-forecast-bot-with-azure-luis-and-maps-services/ba-p/3261135 on how to use Bot Framework Composer.
   
   Building this project requires expereinces on building and publishing Bot App to Teams Platform in Bot Framework Composer. If not quite certain, can refer to below articles to get quick ideas on important concepts and steps before bullding this project:
   
   https://techcommunity.microsoft.com/t5/modern-work-app-consult-blog/create-a-weather-forecast-bot-with-azure-luis-and-maps-services/ba-p/3261135
   
   https://techcommunity.microsoft.com/t5/modern-work-app-consult-blog/improve-the-weather-forecast-bot-app-using-language-generation/ba-p/3262350
   
   https://techcommunity.microsoft.com/t5/modern-work-app-consult-blog/publish-bot-app-to-teams-channel-with-bot-framework-composer-and/ba-p/3341876
   
   
3. After cloning the project, rename .\Empty\settings\appsettings.template.json as .\Empty\settings\appsettings.json
4. Open Bot Framework Composer, open the project folder in it to load the bot project.

5. Provision root bot in in Bot Framework Composer (setup publish profile). Don't need to choose Azure Luis Resource because the project uses Regex to handle user intents of the bot now. (refer to steps 5 - 12 in [this blog](https://techcommunity.microsoft.com/t5/modern-work-app-consult-blog/create-a-weather-forecast-bot-with-azure-luis-and-maps-services/ba-p/3261135) for more details)

6. Setup AppID/PWD (refer to steps 18~19 in [this blog](https://techcommunity.microsoft.com/t5/modern-work-app-consult-blog/create-a-weather-forecast-bot-with-azure-luis-and-maps-services/ba-p/3261135) for more details)
 
   <img width="318" alt="image" src="https://user-images.githubusercontent.com/8623897/221360529-b2154401-5853-46d9-8196-3ae26ddc4c60.png"></img>

7. Add necessary configuration keys in root bot configuration json

   Note: for test purpose, you don't have to put real values for all of them. Setup what you need. 

      1. GPT3Key & GPT3Url are for GPT3 feature

      1. prompterUrl is for Act As feature

      1. chatgptUrl is for ChatGpt feature

      1. openAIKey is for DALLE feature


     ```json
    "GPT3key": "Your Azure Open AI key for GPT-3",
    
    "GPT3Url" : "Your Azure Open AI Endpoint Url"
 
    "promoterUrl": "Azure Function Endpoint of Act As Prompoter",
  
    "chatgptUrl": "Azure Function Endpoint of Azure OpenAI or OpenAI ChatGPT Wrapper",
  
    "openAIKey": "Bearer sk-your OpenAI API Key"
    ```

     Note: 

     Prompter is optimized for Azure OpenAI specifically. Can use the same **azureprompter** function URL in promoterUrl and chatgptUrl.
     
     **promoterUrl** is the function url after publishing **azureprompter** / **prompter** Azure Function (Node.JS 18 LTS) from Visual Studio Code: 
     
         Azure OpenAI:
         https://github.com/freistli/chatgpt-api/tree/main/demos/demo-azure-chatgpt-function

         OpenAI:
         https://github.com/freistli/rootbot/tree/main/demo-azurefunction 
     
     **chatgptUrl** is the function url after publishing another **azureopenai** / **openai** Azure Function (Node.JS 18 LTS) from Visual Studio Code:
     
         Connect to offical Azure OpenAI Service (deploy your ChatGPT model on Azure OpenAI as a name 'chatpgt'):
         
         https://github.com/freistli/chatgpt-api/tree/main/demos/demo-azure-chatgpt-function
         
         Connect to offical OpenAI service:
         
         https://github.com/freistli/rootbot/tree/main/demo-azurefunction 
     
         
     If use OpenAI, need to configure your **OpenAI_API_Key** there after publishing the function apps:    
     
     https://github.com/freistli/chatgpt-api/blob/main/demos/demo-azurefunction/Readme.md
     
     <img width="341" alt="image" src="https://user-images.githubusercontent.com/8623897/222511333-a9aa7908-64a1-454a-9ea6-cb74bbcb5da0.png">

     If you use Azure OpenAI ChatGPT, need to configure below two keys in Application Settings:
     
      AZURE_OPENAI_API_KEY 
      
      AZURE_OPENAI_API_BASE

      CHATGPT_DEPLOY_NAME

     The BFC JSON configuration UI is similar to:
     
     ![image](https://user-images.githubusercontent.com/8623897/221360271-6ca877b4-ac93-4dea-aa08-5ed0f1126c6d.png)

8. Publish root bot. (If didn't use Bot composer before, refer to [this blog](https://techcommunity.microsoft.com/t5/modern-work-app-consult-blog/publish-bot-app-to-teams-channel-with-bot-framework-composer-and/ba-p/3341876) for more details)

9. Enalbe Teams Channel, create App Package for teams. The Teams App Manifest can refer to [\package\manifest.json](https://github.com/freistli/rootbot/blob/main/Empty/package/manifest.json)

## Host Bot App in other non-Azure environments 

1. The enviroment needs to have .net core 3.1 runtime setup by default. And after above steps you will have publictarget folder, run the command in this way:

"C:\BotComposerProject\Empty\Empty\bin\release\publishTarget\Empty.exe"  --port 3980 --urls http://0.0.0.0:3980 --MicrosoftAppPassword [the AAD bot app secret key] --luis:endpointKey "" --SkillHostEndpoint http://127.0.0.1:3980/api/skills'

2. The environment needs to have a reverse proxy, for example, ngrok:

ngrok http 3980 --host-header=localhost

3. Configure Azure Bot Service to use this endpoint:

Refer to: https://learn.microsoft.com/en-us/azure/bot-service/bot-service-debug-channel-ngrok?view=azure-bot-service-4.0

Note: If you don't use Bot Framework Composer to publish this bot, but want to get the release folder, can use Visual Studio 2022 to open empty.sln and build it as release. If you want it to run in .Net Core 6.0, can modify the project setting from <TargetFramework>netcoreapp3.1</TargetFramework>  to <TargetFramework>netcoreapp6.0</TargetFramework>


## Next steps

### Start building your bot

Composer can help guide you through getting started building your bot. From your bot settings page (the wrench icon on the left navigation rail), click on the rocket-ship icon on the top right for some quick navigation links.

Another great resource if you're just getting started is the **[guided tutorial](https://docs.microsoft.com/en-us/composer/tutorial/tutorial-introduction)** in our documentation.

### Connect with your users

Your bot comes pre-configured to connect to our Web Chat and DirectLine channels, but there are many more places you can connect your bot to - including Microsoft Teams, Telephony, DirectLine Speech, Slack, Facebook, Outlook and more. Check out all of the places you can connect to on the bot settings page.

### Publish your bot to Azure from Composer

Composer can help you provision the Azure resources necessary for your bot, and publish your bot to them. To get started, create a publishing profile from your bot settings page in Composer (the wrench icon on the left navigation rail). Make sure you only provision the optional Azure resources you need!

### Extend your bot with packages

From Package Manager in Composer you can find useful packages to help add additional pre-built functionality you can add to your bot - everything from simple dialogs & custom actions for working with specific scenarios to custom adapters for connecting your bot to users on clients like Facebook or Slack.

### Extend your bot with code

You can also extend your bot with code - simply open up the folder that was generated for you in the location you chose during the creation process with your favorite IDE (like Visual Studio). You can do things like create custom actions that can be used during dialog flows, create custom middleware to pre-process (or post-process) messages, and more. See [our documentation](https://aka.ms/bf-extend-with-code) for more information.
