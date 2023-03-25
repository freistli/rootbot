<# 
.SYNOPSIS 
.DESCRIPTION
    Create Teams AI Bot app package
#>
[CmdletBinding()]
param(
        ## Base Name of Bot App Resources
        [Parameter(Mandatory,HelpMessage="Bot App Id")]        
        [string]$botAppId,

        ## Base Name of Bot App Resources
        [Parameter(HelpMessage="Teams App Id")]        
        [string]$teamsAppId = ""
 )

 $ErrorActionPreference = "Stop"

 $botAppId = $botAppId.ToLower()
 if($teamsAppId -eq "")
 {
    $teamsAppId = $botAppId.Substring(0, $botAppId.Length - 3)+"aab"    
 }

 Write-Host "Teams App Id is "$teamsAppId 

$sourcePath = ".\package"
$targetPath = ".\TeamsAIBot.zip"

Set-Location $sourcePath
Copy-Item -Path ".\manifest.template.json" -Destination ".\manifest.json" -Force

# Read the contents of the JSON file 
$json = Get-Content -Path ".\manifest.json" | Out-String 
    
# Convert the JSON string to a PowerShell object 
$obj = ConvertFrom-Json $json 

# Modify the object property containing the string you want to replace 
$obj.id = $obj.id -replace "{TeamsAppId}", $teamsAppId 
$obj.bots[0].botId = $obj.bots[0].botId -replace "{botAppId}", $botAppId 
$obj.webApplicationInfo.id = $obj.webApplicationInfo.id -replace "{botAppId}", $botAppId 
$obj.composeExtensions[0].botId = $obj.composeExtensions[0].botId -replace "{botAppId}", $botAppId 
# Convert the modified object back to JSON format     
$json = ConvertTo-Json $obj -Depth 10 
    
# Write the modified JSON string back to the file     
$json | Set-Content -Path ".\manifest.json"

Set-Location "..\"
Compress-Archive -Path ".\package\*" -DestinationPath $targetPath -Update

$item = Get-Item $targetPath 

$fullPath = $item.FullName 

Write-Host "The generated Teams Bot App Package is ${fullPath}." -ForegroundColor Green

if (!([System.Environment]::OSVersion.Platform -eq "Unix")) 
{ 
    Write-Host "Running on Windows, open ${targetPath} in explorer.exe" -ForegroundColor Green
    explorer.exe ".\TeamsAIBot.zip"
}
