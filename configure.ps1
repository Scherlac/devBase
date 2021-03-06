$baseTag="dev"

$dockerRepository="scherlac/windows-servercore-devbase".ToLower()

$dockerRegistry=""

$workSpace=([System.IO.Path]::GetFullPath($PSScriptRoot))
$dockerPath=([System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot Dockerfile)))
Write-Output "The workSpace location is: $workSpace"

# we may use the git commit hash to identify the image: 
# - commit the changes first
# - build and push the new image
$dockerVersionTag=("${baseTag}-" + (git rev-parse HEAD).Substring(0,11)).ToLower()
$dockerVersionTagLatest=("${baseTag}-latest").ToLower()
