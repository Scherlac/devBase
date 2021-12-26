
Param(
    [string]$gitToken,
    [string]$httpProxy,
    [string] $npmEmail = ${env:npmEmail},
    [string] $npmApiKey = ${env:npmApiKey}
    )

$startLocation = Get-Location 

Set-Location $PSScriptRoot

. ./configure.ps1
Write-Output "Building the image for repository ${dockerRepository} with tag ${dockerVersionTag} and ${dockerVersionTagLatest}"

# build and push (two tags: https://stackoverflow.com/a/31963727/5770014)

("layer1", "layer2", "layer3", "layer4") | % {
    $layer = $_;

    docker build `
    -t "${dockerRegistry}/${dockerOrganization}/${dockerRepository}:${layer}" `
    --target "${layer}" `
    --build-arg GIT_TOKEN=$gitToken `
    --build-arg HTTP_PROXY=$httpProxy `
    --build-arg HTTPS_PROXY=$httpProxy `
    --build-arg npmEmail=$npmEmail `
    --build-arg npmApiKey=$npmApiKey `
    -f $dockerPath $workSpace/contents

    docker push "${dockerRegistry}/${dockerOrganization}/${dockerRepository}:${layer}"

}

docker build `
    -t "${dockerRegistry}/${dockerOrganization}/${dockerRepository}:${dockerVersionTag}" `
    -t "${dockerRegistry}/${dockerOrganization}/${dockerRepository}:${dockerVersionTagLatest}" `
    --build-arg GIT_TOKEN=$gitToken `
    --build-arg HTTP_PROXY=$httpProxy `
    --build-arg HTTPS_PROXY=$httpProxy `
    --build-arg npmEmail=$npmEmail `
    --build-arg npmApiKey=$npmApiKey `
    -f $dockerPath $workSpace/contents

# revert location to origin 
Set-Location $startLocation