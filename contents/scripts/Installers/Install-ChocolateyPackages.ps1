################################################################################
##  File:  Install-ChocolateyPackages.ps1
##  Desc:  Install common Chocolatey packages
################################################################################

$commonPackages = (Get-ToolsetContent).choco.common_packages

foreach ($package in $commonPackages) {
    # check if package is disabled
    if ($package.disabled -eq $true) {
        Write-Host "Skipping disabled package: $package.name"
        continue
    }
    Install-ChocoPackage $package.name -ArgumentList $package.args
}

Invoke-PesterTests -TestFile "ChocoPackages"
