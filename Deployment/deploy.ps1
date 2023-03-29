<# 
.SYNOPSIS 
.DESCRIPTION
    Deploy Teams AI Bot app related resources to Azure
#>
[CmdletBinding()]
param(
        ## Base Name of Bot App Resources
        [Parameter(Mandatory,HelpMessage="Base Name of Bot App Resources")]        
        [string]$baseName,

        ## Resource Group Location, westsu, eastus,eastasia...
        [Parameter(HelpMessage="Resource Group Location, westsu, eastus,eastasia...")]
        [string]$location='eastus',
        ## Azure OpenAI Base URL
        [Parameter(Mandatory,HelpMessage="Azure OpenAI Base URL")]        
        [string]$apiBase,
        ## Azure OpenAI Key
        [Parameter(Mandatory,HelpMessage="Azure OpenAI Key")]
        [string]$apiKey,      

        ## ChatGPT Model Deploy Name
        [Parameter(Mandatory,HelpMessage="ChatGPT Model Deploy Name")]
        [string]$chatGPTDeployName,

        ## The subscription id of AAD for Bot Registered App
        [Parameter(HelpMessage="The subscription id of AAD for Bot Registered App")]        
        [string]$aadSubscription,

        ## Git repo URL
        [Parameter(HelpMessage="Git repo URL")]
        [string]$repoURL='https://github.com/freistli/rootbot.git',

        ## Same Subscription for AAD App Registration and Bot App Azure Resource
        [Parameter(HelpMessage="Same Subscription for AAD App Registration and Bot App Azure Resource")]
        [bool]$sameSubscription=$true,

        ## Release package name on github repo
        [Parameter(HelpMessage="Release package name on github repo")]
        [string]$zipUrl="https://github.com/freistli/rootbot/releases/download/Release/code.zip",

        ## Run in Azure Shell
        [Parameter(HelpMessage="Run in Azure Shell")]
        [bool]$azureShell=$false,

        ## Use Azure Cache for Redis
        [Parameter(HelpMessage="Use Azure Cache for Redis")]
        [string]$useCache="none",

        ## Azure Cache for Redis Host Name
        [Parameter(HelpMessage="Azure Cache for Redis Host Name")]
        [string]$azureCacheForRedisHostName="none",

        ## Azure Cache for Redis Access Key
        [Parameter(HelpMessage="Azure Cache for Redis Access Key")]
        [string]$azureCacheForRedisAccessKey="none"        
                
 )
 
    function PrintMsg {
        param( 
            [string]$msg,
            [System.ConsoleColor]$color="Green"
        )
        
        Write-Host $msg -ForegroundColor $color
    }

    function NeedDeployment {
        param( 
            [string]$deploymentName,
            [string]$resourceGroup
        )
        try{
            $deployment = $(az deployment group show --name $deploymentName --resource-group $resourceGroup --query 'properties.provisioningState' --output tsv 2>$null)
            if ($deployment -eq "Succeeded") 
            { 
                Write-Host "${deploymentName} deployment succeeded, skip" 
                return $false
            } 
            else 
            { 
                return $true

            }
        }
        catch {
            return $true
        }
    }


    $ErrorActionPreference = "Stop"
    $ProgressPreference = "Continue"

    if (!$azureShell) {
        & ".\AZCLIVersionCheck.ps1"
    }
    else {
        PrintMsg "Run in Azure Shell, Bot App Registration & Bot App Azure Resources will be created in the same subscription"
    }

    $resourceGroup = $baseName+"RG"
    $appSettingFilePath= '.\code\settings\appsettings.json'
    $zipfile = '.\code.zip' 
    $newZipFile= './myCode.zip' 
    $botAppId = 'sample'
    $botAppPwd = 'sample'
    $chatgptUrl = 'sample'
 
    Write-Progress -Activity 'Register Bot App in AAD'  -PercentComplete 1 
    
    <#
    Section Zero
    Register Bot App in AAD
    #> 
    
    if(!$azureShell)
    {
        # Login AAD
        PrintMsg "Azure Login for AAD which hosts the Bot App Registration"
        az login --query '[].{Name:name,Subscription:id}' --output table
        
        Write-Progress -Activity 'Register Bot App in AAD'  -PercentComplete 5
        if (-not $aadSubscription) 
        { 
            $aadSubscription = Read-Host "Please enter your subscription ID for AAD tenant" 
        }
        
        az account set --subscription $aadSubscription.trim()
   }

    Write-Progress -Activity 'Register Bot App in AAD'  -PercentComplete 8
    # Create App Registration
    PrintMsg "Create AAD App Registration ${baseName}"
    az ad app create --display-name $baseName --sign-in-audience AzureADMultipleOrgs --query 'appId' --output tsv

    $botAppId = $(az ad app list --display-name $baseName --query '[0].appId' --output tsv)
    PrintMsg "AAD App Registration ${baseName} id ${botAppId}"

    # Get Bot App ID & Password
    if ($botAppId)
    {
        $botAppPwd = $(az ad app credential reset --id $botAppId --display-name "bot app usage" --query 'password' --output tsv)
        Write-Host "Password Created as "$botAppPwd.Substring(0,5)"...."
    }
    else {
        PrintMsg "Failed to create bot app with name ${baseName}, please check if it is duplicated in AAD" "Red"
        exit
    }

    Write-Progress -Activity 'Provision azure resources'  -PercentComplete 10

    <#
    Section ONE
    Provision azure resources
    #>
    if(!$azureShell)
    {
    # Login Azure Resource Subscription
    if(!$sameSubscription)
    {
        $response = Read-Host "Do you use the same subscription as AAD to deploy resources? Type Y or N and press Enter" 
        if ($response -eq "Y") 
        { 
            PrintMsg "You typed Y"         
        } 
        elseif ($response -eq "N") 
        { 
            PrintMsg"You typed N" 
            
            $aadSubscription = $null
            PrintMsg "Azure Login for Azure Resource Subscription"
            az login --query '[].{Name:name,Subscription:id}' --output table
            
            if (-not $aadSubscription) 
            { 
                $aadSubscription = Read-Host "Please enter your subscription ID for Azure Resource Subscription" 
            }
            
            az account set --subscription $aadSubscription.trim()
        } 
        else 
        { 
            PrintMsg "Invalid input" 
            exit
        }
    }
    }
    Write-Progress -Activity "Create Azure Resource Group ${resourceGroup}"  -PercentComplete 20
    PrintMsg "Create Azure Resource Group ${resourceGroup}"
    az group create --name $resourceGroup --location $location

    while (NeedDeployment -deploymentName "AZChatGPTFuncAppDeploy" -resourceGroup $resourceGroup)
    {
    Write-Progress -Activity 'Deploy Azure Function'  -PercentComplete 30
    PrintMsg "Deploy and Build backend Azure Resource with AZChatGPTFuncAppDeploy.bicep, will take several minutes"
    try{
    az deployment group create --resource-group $resourceGroup --template-file AZChatGPTFuncAppDeploy.bicep `
    --parameters azureOpenAIAPIKey=$apiKey azureOpenAIAPIBase=$apiBase chatGPTDeployName=$chatGPTDeployName `
    useCache=$useCache azureRedisHostName=$azureCacheForRedisHostName azureRedisAccessKey=$azureCacheForRedisAccessKey 2>$null
    }
    catch {
        PrintMsg "bicep deploy hits issue, retry"
    }

    }

    if (NeedDeployment -deploymentName "WebAppDeployTemplate" -resourceGroup $resourceGroup )
    {
    Write-Progress -Activity 'Deploy bot web app Azure Resource'  -PercentComplete 50
    PrintMsg "Deploy bot app Azure Resource with WebAppDeployTemplate.bicep"
    az deployment group create --resource-group $resourceGroup --template-file WebAppDeployTemplate.bicep
    }

    if (NeedDeployment -deploymentName "AADBotService" -resourceGroup $resourceGroup )
    {
    Write-Progress -Activity 'Deploy bot service'  -PercentComplete 70
    PrintMsg "Deploy bot service with AADBotApp.bicep"
    az deployment group create --resource-group $resourceGroup --template-file AADBotService.bicep --parameters botAppId=$botAppId
    }
    <#
    Section TWO
    Get chatgptUrl
    #>
    Write-Progress -Activity 'Processing binary output'  -PercentComplete 80
    $funcappName = $(az deployment group show  -g $resourceGroup  -n AZChatGPTFuncAppDeploy --query properties.outputs.funcappname.value --output tsv)
    $funcappKey = $(az functionapp function keys list --name $funcappName  --resource-group $resourceGroup --function-name azureopenai  --query 'default' --output tsv)
    $funcappUrl = $(az functionapp function show --name $funcappName --resource-group $resourceGroup --function-name  azureopenai  --query 'invokeUrlTemplate' --output tsv)
    $chatgptUrl = $funcappUrl+"?code="+ $funcappKey
    Write-Host "chatGPTUrl "$chatgptUrl.Substring(0, $chatgptUrl.Length - 10)"..."

    <#
    Section THREE
    Extract code.zip, modify appsettings.json and Pcakge a new Code.zip
    #>

    # Download the zip file 
    PrintMsg "Download the code zip file"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipfile

    <#
    PrintMsg "Expand the code zip file"
    Expand-Archive -Path $zipfile -DestinationPath ".\code\" -Force

    # Read the contents of the JSON file 
    $json = Get-Content -Path $appSettingFilePath | Out-String 
    
    # Convert the JSON string to a PowerShell object 
    $obj = ConvertFrom-Json $json 
    
    # Modify the object property containing the string you want to replace 
    $obj.MicrosoftAppId = $obj.MicrosoftAppId -replace "{MicrosoftAppId}", $botAppId 
    $obj.MicrosoftAppPassword = $obj.MicrosoftAppPassword -replace "{MicrosoftAppPassword}", $botAppPwd 
    $obj.chatgptUrl = $obj.chatgptUrl -replace "{chatgptUrl}", $chatgptUrl 
    
    # Convert the modified object back to JSON format     
    $json = ConvertTo-Json $obj -Depth 10 
    
    # Write the modified JSON string back to the file     
    $json | Set-Content -Path $appSettingFilePath

    Compress-Archive -Path ".\code\*" -DestinationPath $newZipFile -Update
    #>

    & ".\updateZipFile.ps1" -zipFile $pwd"\"$zipFile -fileToModify "settings\appsettings.json" `
    -botAppIdValue $botAppId -botAppPwdValue $botAppPwd -chatGPTUrlValue $chatgptUrl

    <#
    Section FOUR
    Deploy code.zip to Azure Web App
    #>
    Write-Progress -Activity 'Deploy code.zip to Azure Web App'  -PercentComplete 90    
    $appName = $(az deployment group show  -g $resourceGroup  -n WebAppDeployTemplate --query properties.outputs.webappname.value --output tsv)
    PrintMsg "Deploy code.zip to Azure Web App ${appName}"
    az webapp deploy --resource-group $resourceGroup --name $appName --src-path $zipFile

    Write-Progress -Activity 'Deploy Completed'  -PercentComplete 100
    PrintMsg "Deploy Completed in ${resourceGroup}"

    PrintMsg "Create Teams AI Bot app package"
    
    & ".\ManifestPackage.ps1" -botAppId $botAppId


    
