$ErrorActionPreference = "Stop"

$minimumVersion = [version]'2.46.0' 
$result = $(az --version | Select-String "azure-cli" | % { $_.Line} )

if ($result -match "\d+\.\d+\.\d+") 
{ 
    $version = $matches[0] 
    Write-Host "azure-cli: "$version -ForegroundColor Green
}


if ( $version -lt $minimumVersion) { 
    Write-Host "Your Azure CLI version is ${version}. Before run this scirpt, please upgrade to version $($minimumVersion) or later." -ForegroundColor Yellow
    $response = Read-Host "Do you want to upgrade now? (Y/N)"
    if ($response.ToLower() -eq 'y') { 
        Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile AzureCLI.msi 
        Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi' 
        exit
    } 
    else { 
        exit 
    } 
}