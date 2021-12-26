

# OSS: https://github.com/actions/virtual-environments/blob/main/docs/create-image-and-azure-resources.md

$proxy="http://127.0.0.1:3128"

Invoke-WebRequest -proxy $proxy https://chocolatey.org/install.ps1 -OutFile choco_install.ps1

.\choco_install.ps1 -ProxyUrl $proxy
#The PATH shall be unpated and shuld include "C:\ProgramData\chocolatey\bin" folder

# WARNING: Files from a previous installation of Chocolatey were found at 'C:\ProgramData\chocolatey'.
# WARNING: An existing Chocolatey installation was detected. Installation will not continue.
# For security reasons, this script will not overwrite existing installations.

# Please use choco upgrade chocolatey to handle upgrades of Chocolatey itself.
# PS C:\01_Dev\SelfHostedImage> .\choco_install.ps1 -ProxyUrl http://127.0.0.1:3128
# Forcing web requests to allow TLS v1.2 (Required for requests to Chocolatey.org)
# Getting latest version of the Chocolatey package for download.
# Using explicit proxy server 'http://127.0.0.1:3128'.
# Getting Chocolatey from https://community.chocolatey.org/api/v2/package/chocolatey/0.10.15.
# Downloading https://community.chocolatey.org/api/v2/package/chocolatey/0.10.15 to C:\Users\Scherlac\AppData\Local\Temp\chocolatey\chocoInstall\chocolatey.zip
# Using explicit proxy server 'http://127.0.0.1:3128'.
# Extracting C:\Users\Scherlac\AppData\Local\Temp\chocolatey\chocoInstall\chocolatey.zip to C:\Users\Scherlac\AppData\Local\Temp\chocolatey\chocoInstall
# Installing Chocolatey on the local machine
# Creating ChocolateyInstall as an environment variable (targeting 'Machine')
#   Setting ChocolateyInstall to 'C:\ProgramData\chocolatey'
# WARNING: It's very likely you will need to close and reopen your shell
#   before you can use choco.
# Restricting write permissions to Administrators
# We are setting up the Chocolatey package repository.
# The packages themselves go to 'C:\ProgramData\chocolatey\lib'
#   (i.e. C:\ProgramData\chocolatey\lib\yourPackageName).
# A shim file for the command line goes to 'C:\ProgramData\chocolatey\bin'
#   and points to an executable in 'C:\ProgramData\chocolatey\lib\yourPackageName'.

# Creating Chocolatey folders if they do not already exist.

# WARNING: You can safely ignore errors related to missing log files when
#   upgrading from a version of Chocolatey less than 0.9.9.
#   'Batch file could not be found' is also safe to ignore.
#   'The system cannot find the file specified' - also safe.
# chocolatey.nupkg file not installed in lib.
#  Attempting to locate it from bootstrapper.
# PATH environment variable does not have C:\ProgramData\chocolatey\bin in it. Adding...
# WARNING: Not setting tab completion: Profile file does not exist at 'C:\Users\Scherlac\OneDrive
# GmbH\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'.
# Chocolatey (choco.exe) is now ready.
# You can call choco from anywhere, command line or powershell by typing choco.
# Run choco /? for a list of functions.
# You may need to shut down and restart powershell and/or consoles
#  first prior to using choco.
# Ensuring Chocolatey commands are on the path
# Ensuring chocolatey.nupkg is in the lib folder

# Download packer from https://www.packer.io/downloads, or install it via Chocolately.
choco install packer -y

# Chocolatey v0.10.15
# [Pending] Removing incomplete install for 'packer'
# Installing the following packages:
# packer
# By installing you accept licenses for the packages.

# packer v1.7.3 [Approved]
# packer package files install completed. Performing other installation steps.
# Removing old packer plugins
# Using system proxy server 'proxy.domain.com:8080'.
# Downloading packer 64 bit
#   from 'https://releases.hashicorp.com/packer/1.7.3/packer_1.7.3_windows_amd64.zip'
# Using system proxy server 'proxy.domain.com:8080'.
# Progress: 100% - Completed download of C:\Users\Scherlac\AppData\Local\Temp\chocolatey\packer\1.7.3\packer_1.7.3_windows_amd64.zip (30.46 MB).
# Download of packer_1.7.3_windows_amd64.zip (30.46 MB) completed.
# Hashes match.
# Extracting C:\Users\Scherlac\AppData\Local\Temp\chocolatey\packer\1.7.3\packer_1.7.3_windows_amd64.zip to C:\ProgramData\chocolatey\lib\packer\tools...
# C:\ProgramData\chocolatey\lib\packer\tools
#  ShimGen has successfully created a shim for packer.exe
#  The install of packer was successful.
#   Software installed to 'C:\ProgramData\chocolatey\lib\packer\tools'

# Chocolatey installed 1/1 packages.
#  See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).

# Install the Azure Az PowerShell module - https://docs.microsoft.com/en-us/powershell/azure/install-az-ps.
Install-Module -Name Az -Repository PSGallery -Force

# FAILED

# PackageManagement\Get-PackageSource : Unable to find repository 'PSGallery'. Use Get-PSRepository to see all available
# repositories.
# At C:\Program Files\WindowsPowerShell\Modules\PowerShellGet\1.0.0.1\PSModule.psm1:4489 char:35
# + ... ckageSources = PackageManagement\Get-PackageSource @PSBoundParameters
# +                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     + CategoryInfo          : ObjectNotFound: (Microsoft.Power...etPackageSource:GetPackageSource) [Get-PackageSource]
#    , Exception
#     + FullyQualifiedErrorId : SourceNotFound,Microsoft.PowerShell.PackageManagement.Cmdlets.GetPackageSource

# OSS: 
# - https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-6.2.1#offline-installation
# - https://docs.microsoft.com/en-us/powershell/azure/install-az-ps-msi?view=azps-6.2.1#install-or-update-on-windows-using-the-msi-package
# - https://github.com/Azure/azure-powershell/releases/tag/v6.2.1-July2021

#Invoke-WebRequest -proxy http://127.0.0.1:3128 https://psg-prod-eastus.azureedge.net/packages/az.6.2.1.nupkg -OutFile az.6.2.1.nupkg
Invoke-WebRequest -proxy $proxy https://github.com/Azure/azure-powershell/releases/download/v6.2.1-July2021/Az-Cmdlets-6.2.1.34515-x64.msi -OutFile Az-Cmdlets-x64.msi
# .\Az-Cmdlets-x64.msi /quiet /qb
Start-Process msiexec.exe -Wait -ArgumentList '/I Az-Cmdlets-x64.msi /quiet'


# Install Azure CLI - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&tabs=azure-cli.
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

# Download Virtual-Environments repository.
git clone https://github.com/actions/virtual-environments.git

# Import GenerateResourcesAndImage script from /helpers folder, and run GenerateResourcesAndImage function via Powershell.
cd .\virtual-environments\
Import-Module .\helpers\GenerateResourcesAndImage.ps1

GenerateResourcesAndImage -SubscriptionId "*" -ResourceGroupName "*" -ImageGenerationRepositoryRoot "$pwd" -ImageType  Windows2019 -AzureLocation "West Europe"


