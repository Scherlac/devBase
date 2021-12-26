################################################################################
##  File:  Install-NodeLts.ps1
##  Desc:  Install nodejs-lts and other common node tools.
##         Must run after python is configured
################################################################################

$PrefixPath = 'C:\npm\prefix'
$CachePath = 'C:\npm\cache'


function New-NpmConfiguration {

    param (
        [string] $npmEmail = ${env:npmEmail},
        [string] $npmApiKey = ${env:npmApiKey},
        [string] $configFile = (Join-Path  "${env:USERPROFILE}" '.npmrc'),
        [string] $artifactoryUrl = ${env:artifactoryNPMVirtualUrl}
        )
     
    ( @"
strict-ssl=false 
_auth="$npmApiKey"
email=$npmEmail
always-auth=true
registry=$artifactoryUrl
"@ ) | Out-File -Encoding ascii -NoNewline -FilePath $configFile

} 

New-Item -Path $PrefixPath -Force -ItemType Directory
New-Item -Path $CachePath -Force -ItemType Directory

Choco-Install -PackageName nodejs-lts -ArgumentList "--force"

Add-MachinePathItem $PrefixPath
$env:Path = Get-MachinePath

setx npm_config_prefix $PrefixPath /M
$env:npm_config_prefix = $PrefixPath

New-NpmConfiguration
npm config set cache $CachePath --global
