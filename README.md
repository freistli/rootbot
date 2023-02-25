# Rootbot Setup Guide

1. Clone the root bot

2. Open in Bot Framework Composer (go through Environment Preparation of this article https://techcommunity.microsoft.com/t5/modern-work-app-consult-blog/create-a-weather-forecast-bot-with-azure-luis-and-maps-services/ba-p/3261135 on how to use Bot Framework Composer), it will promote Convert, confirm. After a while, it may give error about Null Reference, ignore it.
3. Add Teams Package to the root bot
4. Provision root bot (setup publish profile)
5. Set Azure Luis Authoring key, and AppID/PWD (refer to steps 15~19 of https://techcommunity.microsoft.com/t5/modern-work-app-consult-blog/create-a-weather-forecast-bot-with-azure-luis-and-maps-services/ba-p/3261135 for more details)
 
   ![image](https://user-images.githubusercontent.com/8623897/221360395-33faeba5-44f2-4b92-8584-db0b94e2d9c0.png)
   
   ![image](https://user-images.githubusercontent.com/8623897/221360529-b2154401-5853-46d9-8196-3ae26ddc4c60.png)

    
7. Remove unnecessary skills (based on the error hints). Keep required skills.
8. Connect to required bots
9. Add necessary configuration keys in root bot configuration json:

    "GPT3key": "Your Azure Open AI key for GPT-3",
 
    "promoterUrl": "Azure Function Endpoint of Prompoter",
  
    "chatgptUrl": "Azure Function Endpoint of OpenAI ChatGPT Wrapper",
  
    "openAIKey": "Bearer sk-xxxxxxxxx",
  
    "taskmoduleurl": "https://flstaticweb.azurewebsites.net/",
  

     Note: promoterUrl and chatgptUrl are the two endpoints after publishing the two Azure Functions from here: https://github.com/freistli/chatgpt-api/tree/main/demos/demo-azurefunction 

     The BFC JSON configuration UI is similar to:
     
     ![image](https://user-images.githubusercontent.com/8623897/221360271-6ca877b4-ac93-4dea-aa08-5ed0f1126c6d.png)

9. Publish root bot.
