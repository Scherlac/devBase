
Param(
    [string] $gitToken,
    [string] $npmEmail = ${env:npmEmail},
    [string] $npmApiKey = ${env:npmApiKey}     
    )

$startLocation = Get-Location 

Set-Location $PSScriptRoot

. ./configure.ps1
Write-Output "Building the image for repository ${dockerRepository} with tag ${dockerVersionTag} and ${dockerVersionTagLatest}"

# build and push (two tags: https://stackoverflow.com/a/31963727/5770014)

$ret = $true

("layer1", "layer2", "layer3", "layer4", "layer5") | % {
    $layer = $_;

    docker build `
    -t "${dockerRegistry}${dockerRepository}:${layer}" `
    --target "${layer}" `
    --isolation="hyperv" `
    --build-arg GIT_TOKEN=$gitToken `
    -f $dockerPath $workSpace/contents
    $ret = $ret -and $?

    if ($ret -eq $false) {
        Write-Output "Failed to build layer ${layer}"
        exit 1
    }
    # docker push "${dockerRegistry}/${dockerRepository}:${layer}"

}

docker build `
    -t "${dockerRegistry}${dockerRepository}:${dockerVersionTag}" `
    -t "${dockerRegistry}${dockerRepository}:${dockerVersionTagLatest}" `
    --isolation="hyperv" `
    --build-arg GIT_TOKEN=$gitToken `
    -f $dockerPath $workSpace/contents

# docker push "${dockerRegistry}/${dockerRepository}:${dockerVersionTag}"
# docker push "${dockerRegistry}/${dockerRepository}:${dockerVersionTagLatest}"

# https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe
# Invoke-WebRequest https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe -OutFile BuildTools_Full.exe
# .\BuildTools_Full.exe --allWorkloads --includeRecommended --quiet --norestart --wait --nocache
# .\BuildTools_Full.exe /quiet /norestart /wait /nocache /log "C:\image\BuildTools2015-Install.log"

# revert location to origin 
Set-Location $startLocation