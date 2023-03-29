[CmdletBinding()]
    param(
        [string]$zipFile,
        [string]$fileToModify,
        [string]$botAppIdValue,
        [string]$botAppPwdValue,
        [string]$chatGPTUrlValue
    )

    $ErrorActionPreference = "Stop"
    Add-Type -assembly "system.io.compression.filesystem"

    try{    

    $tempFile = [System.IO.Path]::GetTempFileName()
    $zip = [System.IO.Compression.ZipFile]::Open($zipFile, [System.IO.Compression.ZipArchiveMode]::Update)
    $entry = $zip.GetEntry($fileToModify)
    $entry.Name
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry,$tempFile,$true)
    $json = Get-Content $tempFile | Out-String  | ConvertFrom-Json
    $json.MicrosoftAppId = $botAppIdValue 
    $json.MicrosoftAppPassword = $botAppPwdValue 
    $json.chatgptUrl = $chatGPTUrlValue
    $json | ConvertTo-Json -Depth 10 | Set-Content $tempFile
    $entry.Delete()
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$tempFile, $fileToModify)
    $zip.Dispose()
    }
    catch {


        Write-Host "Error updating zip file: $_"
        if($null -ne $zip)
        {
            $zip.Dispose()
        }
    }
    Remove-Item $tempFile



