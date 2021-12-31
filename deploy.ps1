

Write-Output "dtrUser : $dtrUser"

$startLocation = Get-Location 

Set-Location $PSScriptRoot

. ./configure.ps1
Write-Output "Pushing the image for repository ${dockerRepository} with tag ${dockerVersionTag} and ${dockerVersionTagLatest}"
    
docker push "${dockerRegistry}${dockerRepository}:${dockerVersionTag}"
docker push "${dockerRegistry}${dockerRepository}:${dockerVersionTagLatest}"

# revert location to origin 
Set-Location $startLocation