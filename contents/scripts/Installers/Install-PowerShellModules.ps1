# Set TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12"

Write-Host "Setup PowerShellGet"
Install-PackageProvider -Proxy $env:HTTP_PROXY -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Specifies the installation policy
Register-PSRepository -Default -Proxy $env:HTTP_PROXY
Set-PSRepository -Proxy $env:HTTP_PROXY -InstallationPolicy Trusted -Name PSGallery

# Install PowerShell modules
$modules = (Get-ToolsetContent).powershellModules

foreach($module in $modules)
{
    $moduleName = $module.name
    Write-Host "Installing ${moduleName} module"

    if ($module.versions)
    {
        foreach ($version in $module.versions)
        {
            Write-Host " - $version"
            Install-Module -Proxy $env:HTTP_PROXY -Name $moduleName -RequiredVersion $version -Scope AllUsers -SkipPublisherCheck -Force
        }
        continue
    }

    Install-Module -Proxy $env:HTTP_PROXY -Name $moduleName -Scope AllUsers -SkipPublisherCheck -Force
}

Import-Module Pester
Invoke-PesterTests -TestFile "PowerShellModules" -TestName "PowerShellModules"