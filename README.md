# Rootbot Setup Guide

1. Clone the root bot

2. Open in Bot Framework Composer (go through https://github.com/freistli/rootbot/tree/main/Empty on how to use Bot Framework Composer), it will promote Convert, confirm. After a while, it may give error about Null Reference, ignore it.
3. Add Teams Package to the root bot
4. Provision root bot (setup publish profile)
5. Set Luis key, AppID/PWD
6. Remove unnecessary skills (based on the error hints). Keep required skills.
7. Connect to required bots
8. Add necessary configuration keys in root bot configuration json:

    "GPT3key": "Your Azure Open AI key for GPT-3",
 
    "promoterUrl": "Azure Function Endpoint of Prompoter",
  
    "chatgptUrl": "Azure Function Endpoint of OpenAI ChatGPT Wrapper",
  
    "openAIKey": "Bearer sk-xxxxxxxxx",
  
    "taskmoduleurl": "https://flstaticweb.azurewebsites.net/",
  

     Note: promoterUrl and chatgptUrl required to publish the two Azure Functions from here:

        https://github.com/freistli/chatgpt-api/tree/main/demos/demo-azurefunction 

9. Publish root bot.
