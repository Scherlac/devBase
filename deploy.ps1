

Write-Output "dtrUser : $dtrUser"

$startLocation = Get-Location 

Set-Location $PSScriptRoot

. ./configure.ps1
Write-Output "Pushing the image for repository ${dockerRepository} with tag ${dockerVersionTag} and ${dockerVersionTagLatest}"

if (! $dockerIsLoggedIn)
{
    #docker login "${dockerRegistry}" 
    #Write-Output "Login skipped..."
    docker login -u $dtrUser p $dtrPwd ${dockerRegistry}
    if (! $?) 
    {
        Write-Output "The docker login failed to ${dockerRegistry}" 
        exit 1 
    }
}   
    
docker push "${dockerRegistry}/${dockerOrganization}/${dockerRepository}:${dockerVersionTag}"
docker push "${dockerRegistry}/${dockerOrganization}/${dockerRepository}:${dockerVersionTagLatest}"

# revert location to origin 
Set-Location $startLocation