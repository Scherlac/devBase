# escape=`

ARG GIT_TOKEN
# ARG HTTP_PROXY
# ARG HTTPS_PROXY
FROM mcr.microsoft.com/windows/servercore:ltsc2022-KB5033118-amd64 AS layer1
#FROM mcr.microsoft.com/windows/servercore:10.0.19042.1415 AS layer1

# ENV NO_PROXY="localhost,127.0.0.1"

ENV AGENT_TOOLSDIRECTORY="C:\hostedtoolcache\windows"
ENV TOOLSET_JSON_PATH="C:\image\toolsets\toolset-2022.json"
ENV PSMODULES_ROOT_FOLDER="C:\Program Files\WindowsPowerShell\Modules"

WORKDIR 'C:/Program Files/WindowsPowerShell/Modules'
COPY scripts/ImageHelpers ./ImageHelpers
COPY scripts/TestHelpers ./TestHelpers

# SHELL ["powershell"]
# RUN Get-Module -ListAvailable

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Import-Module ImageHelpers; Import-Module TestHelpers;
# RUN Get-ChildItem -Recurse

WORKDIR C:/image
COPY toolsets ./toolsets/

# RUN  $reg = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'; `
#         $settings = Get-ItemProperty -Path $reg; `
#         Set-ItemProperty -Path $reg -Name ProxyServer -Value 'BP-F06457:3128'; `
#         Set-ItemProperty -Path $reg -Name ProxyEnable -Value 1

#   provisioner "powershell" {
#     environment_vars = ["IMAGE_VERSION=${var.image_version}", "IMAGE_OS=${var.image_os}", "AGENT_TOOLSDIRECTORY=${var.agent_tools_directory}", "IMAGEDATA_FILE=${var.imagedata_file}"]
#     execution_policy = "unrestricted"
#     scripts          = [
#       "${path.root}/../scripts/build/Configure-WindowsDefender.ps1",
#       "${path.root}/../scripts/build/Configure-PowerShell.ps1",
#       "${path.root}/../scripts/build/Install-PowerShellModules.ps1",
#       "${path.root}/../scripts/build/Install-WindowsFeatures.ps1",
#       "${path.root}/../scripts/build/Install-Chocolatey.ps1",
#       "${path.root}/../scripts/build/Configure-BaseImage.ps1",
#       "${path.root}/../scripts/build/Configure-ImageDataFile.ps1",
#       "${path.root}/../scripts/build/Configure-SystemEnvironment.ps1",
#       "${path.root}/../scripts/build/Configure-DotnetSecureChannel.ps1"
#     ]
#   }

# Disabled due to the following error:
# Foreach-Object : The term 'Set-MpPreference' is not recognized as the name of
# a cmdlet, function, script file, or operable program. Check the spelling of
# the name, or if a path was included, verify that the path is correct and try
# again.
# COPY scripts/Installers/Configure-WindowsDefender.ps1 ./Installers/
# RUN      .\Installers\Configure-WindowsDefender.ps1;

COPY scripts/Installers/Configure-PowerShell.ps1 scripts/Installers/Install-PowerShellModules.ps1 ./Installers/
COPY scripts/Tests/PowerShellModules.Tests.ps1 ./Tests/
# ~ 570MB --> 353MB
RUN  `
     .\Installers\Configure-PowerShell.ps1; `
     .\Installers\Install-PowerShellModules.ps1; `
     Invoke-Cleanup;

# ~ 55MB  --> 55MB
COPY scripts/Installers/Install-Chocolatey.ps1 ./Installers/
RUN .\Installers\Install-Chocolatey.ps1; `
     Invoke-Cleanup;

# COPY scripts/Installers/Configure-BaseImage.ps1 ./Installers/
# RUN      .\Installers\Configure-BaseImage.ps1;

# COPY scripts/Installers/Configure-ImageDataFile.ps1 ./Installers/
# RUN      .\Installers\Configure-ImageDataFile.ps1;

# ARG IMAGE_VERSION
# ARG IMAGE_OS
# ARG AGENT_TOOLSDIRECTORY
# COPY scripts/Installers/Configure-SystemEnvironment.ps1 ./Installers/
# RUN      .\Installers\Configure-SystemEnvironment.ps1;

# ~ 17MB --> 17MB
COPY scripts/Installers/Configure-DotnetSecureChannel.ps1 ./Installers/
RUN .\Installers\Configure-DotnetSecureChannel.ps1; `
     Invoke-Cleanup;


#   provisioner "powershell" {
#     scripts = [
#       "${path.root}/../scripts/build/Install-Docker.ps1",
#       "${path.root}/../scripts/build/Install-DockerWinCred.ps1",
#       "${path.root}/../scripts/build/Install-DockerCompose.ps1",
#       "${path.root}/../scripts/build/Install-PowershellCore.ps1",
#       "${path.root}/../scripts/build/Install-WebPlatformInstaller.ps1",
#       "${path.root}/../scripts/build/Install-Runner.ps1"
#     ]
#   }

# COPY scripts/Installers/Install-WindowsFeatures.ps1 ./Installers/
# RUN .\Installers\Install-WindowsFeatures.ps1;

# COPY scripts/Installers/Install-Docker.ps1 scripts/Installers/Install-DockerWinCred.ps1 scripts/Installers/Install-DockerCompose.ps1 ./Installers/
# COPY scripts/Tests/Docker.Tests.ps1 ./Tests/
# RUN .\Installers\Install-Docker.ps1; `
#      .\Installers\Install-DockerWinCred.ps1; `
#      .\Installers\Install-DockerCompose.ps1;

# Moved to later sectio to have all Tools related test subject at similar location

# ~ 115MB --> 107MB
COPY scripts/Installers/Install-Runner.ps1 ./Installers/
COPY scripts/Tests/RunnerCache.Tests.ps1 ./Tests/
RUN .\Installers\Install-Runner.ps1; `
     Invoke-Cleanup;

FROM layer1 AS layer2

#SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]



#   provisioner "powershell" {
#     elevated_password = "${var.install_password}"
#     elevated_user     = "${var.install_user}"
#     scripts           = [
#       "${path.root}/../scripts/build/Install-VisualStudio.ps1",
#       "${path.root}/../scripts/build/Install-KubernetesTools.ps1"
#     ]
#     valid_exit_codes  = [0, 3010]
#   }


COPY scripts/Tests/VisualStudio.Tests.ps1 ./Tests/

COPY scripts/Installers/Install-VisualStudio.ps1 ./Installers/
# ~ 24.7GB --> 7.63GB
RUN .\Installers\Install-VisualStudio.ps1; `
     Invoke-Cleanup;

# COPY scripts/Installers/Install-VS.ps1 ./Installers/
# RUN .\Installers\Install-VS.ps1;


COPY scripts/Tests/Tools.Tests.ps1 ./Tests/

# ~ 561MB --> 451MB
COPY scripts/Installers/Install-PowershellCore.ps1 ./Installers/
RUN .\Installers\Install-PowershellCore.ps1; `
     Invoke-Cleanup;

# ~ 68MB --> 66MB
COPY scripts/Installers/Install-WebPlatformInstaller.ps1 ./Installers/
RUN .\Installers\Install-WebPlatformInstaller.ps1; `
     Invoke-Cleanup;

# COPY scripts/Installers/Install-KubernetesTools.ps1 ./Installers/
# RUN .\Installers\Install-KubernetesTools.ps1;

# COPY scripts/Installers/Install-Kotlin.ps1 ./Installers/
# RUN scripts/Installers/Install-Kotlin.ps1;

#   provisioner "powershell" {
#     pause_before = "2m0s"
#     scripts      = [
#       "${path.root}/../scripts/build/Install-Wix.ps1",
#       "${path.root}/../scripts/build/Install-WDK.ps1",
#       "${path.root}/../scripts/build/Install-VSExtensions.ps1",
#       "${path.root}/../scripts/build/Install-AzureCli.ps1",
#       "${path.root}/../scripts/build/Install-AzureDevOpsCli.ps1",
#       "${path.root}/../scripts/build/Install-ChocolateyPackages.ps1",
#       "${path.root}/../scripts/build/Install-JavaTools.ps1",
#       "${path.root}/../scripts/build/Install-Kotlin.ps1",
#       "${path.root}/../scripts/build/Install-OpenSSL.ps1"
#     ]
#   }


COPY scripts/Installers/Install-Wix.ps1 scripts/Installers/Install-WDK.ps1 scripts/Installers/Install-VSExtensions.ps1 ./Installers/
COPY scripts/Tests/Wix.Tests.ps1 scripts/Tests/WDK.Tests.ps1 scripts/Tests/Vsix.Tests.ps1 ./Tests/
# ~ 5.7GB --> 1.67GB
RUN .\Installers\Install-Wix.ps1; `
     # .\Installers\Install-WDK.ps1; `
     .\Installers\Install-VSExtensions.ps1; `
     Invoke-Cleanup;

COPY scripts/Tests/CLI.Tools.Tests.ps1 ./Tests/

COPY scripts/Installers/Install-AzureCli.ps1 scripts/Installers/Install-AzureDevOpsCli.ps1 ./Installers/
# ~ 526MB --> 455MB
RUN .\Installers\Install-AzureCli.ps1; `
     .\Installers\Install-AzureDevOpsCli.ps1; `
     Invoke-Cleanup;

# COPY scripts/Installers/Install-AWSTools.ps1 scripts/Installers/Install-AliyunCli.ps1 scripts/Installers/Install-CloudFoundryCli.ps1 ./Installers/
# RUN .\Installers\Install-AWSTools.ps1; `
#      .\Installers\Install-AliyunCli.ps1; `
#      .\Installers\Install-CloudFoundryCli.ps1;

COPY scripts/Installers/Install-GitHub-CLI.ps1 ./Installers/
# ~ 132MB --> 114MB
RUN .\Installers\Install-GitHub-CLI.ps1; `
     Invoke-Cleanup;

# COPY scripts/Installers/Install-ChocolateyPackages.ps1 ./Installers/
# COPY scripts/Tests/ChocoPackages.Tests.ps1 ./Tests/
# # ~ 1.8GB --> 1.31GB --> 3.14GB?? change for unknown reason --> removed.
# RUN .\Installers\Install-ChocolateyPackages.ps1; `
#      Invoke-Cleanup;

COPY scripts/Installers/Install-JavaTools.ps1 ./Installers/
COPY scripts/Tests/Java.Tests.ps1 ./Tests/
# ~ 1.9GB --> 1.29GB --> 1.16GB
RUN Install-ChocoPackage 7zip.install; `
     .\Installers\Install-JavaTools.ps1; `
     Invoke-Cleanup;
# Kotlin is installed in the previous layer with other tools related to Tools.Tests.ps1

COPY scripts/Installers/Install-OpenSSL.ps1 ./Installers/
#COPY scripts/Tests/Tools.Tests.ps1 ./Tests/
# ~ 684MB --> 533MB
RUN .\Installers\Install-OpenSSL.ps1; `
     Invoke-Cleanup;


#   provisioner "powershell" {
#     execution_policy = "remotesigned"
#     scripts          = ["${path.root}/../scripts/build/Install-ServiceFabricSDK.ps1"]
#   }

# COPY scripts/Installers/Install-ServiceFabricSDK.ps1 ./Installers/
# RUN      .\Installers\Install-ServiceFabricSDK.ps1;


#   provisioner "powershell" {
#     scripts = [
#       "${path.root}/../scripts/build/Install-ActionsCache.ps1",
#  *     "${path.root}/../scripts/build/Install-Ruby.ps1",
#  *     "${path.root}/../scripts/build/Install-PyPy.ps1",
#  *     "${path.root}/../scripts/build/Install-Toolset.ps1",
#  *     "${path.root}/../scripts/build/Configure-Toolset.ps1",
#  *     "${path.root}/../scripts/build/Install-NodeJS.ps1",
#       "${path.root}/../scripts/build/Install-AndroidSDK.ps1",
#  *    "${path.root}/../scripts/build/Install-PowershellAzModules.ps1",
#       "${path.root}/../scripts/build/Install-Pipx.ps1",
#  *     "${path.root}/../scripts/build/Install-Git.ps1",
#  *     "${path.root}/../scripts/build/Install-GitHub-CLI.ps1",
#       "${path.root}/../scripts/build/Install-PHP.ps1",
#       "${path.root}/../scripts/build/Install-Rust.ps1",
#       "${path.root}/../scripts/build/Install-Sbt.ps1",
#       "${path.root}/../scripts/build/Install-Chrome.ps1",
#       "${path.root}/../scripts/build/Install-EdgeDriver.ps1",
#       "${path.root}/../scripts/build/Install-Firefox.ps1",
#       "${path.root}/../scripts/build/Install-Selenium.ps1",
#       "${path.root}/../scripts/build/Install-IEWebDriver.ps1",
#       "${path.root}/../scripts/build/Install-Apache.ps1",
#       "${path.root}/../scripts/build/Install-Nginx.ps1",
#       "${path.root}/../scripts/build/Install-Msys2.ps1",
#       "${path.root}/../scripts/build/Install-WinAppDriver.ps1",
#       "${path.root}/../scripts/build/Install-R.ps1",
#       "${path.root}/../scripts/build/Install-AWSTools.ps1",
#       "${path.root}/../scripts/build/Install-DACFx.ps1",
#       "${path.root}/../scripts/build/Install-MysqlCli.ps1",
#       "${path.root}/../scripts/build/Install-SQLPowerShellTools.ps1",
#       "${path.root}/../scripts/build/Install-SQLOLEDBDriver.ps1",
#  *     "${path.root}/../scripts/build/Install-DotnetSDK.ps1",
#       "${path.root}/../scripts/build/Install-Mingw64.ps1",
#       "${path.root}/../scripts/build/Install-Haskell.ps1",
#       "${path.root}/../scripts/build/Install-Stack.ps1",
#  *     "${path.root}/../scripts/build/Install-Miniconda.ps1",
#       "${path.root}/../scripts/build/Install-AzureCosmosDbEmulator.ps1",
#       "${path.root}/../scripts/build/Install-Mercurial.ps1",
#       "${path.root}/../scripts/build/Install-Zstd.ps1",
#       "${path.root}/../scripts/build/Install-NSIS.ps1",
#  *     "${path.root}/../scripts/build/Install-Vcpkg.ps1",
#       "${path.root}/../scripts/build/Install-PostgreSQL.ps1",
#       "${path.root}/../scripts/build/Install-Bazel.ps1",
#       "${path.root}/../scripts/build/Install-AliyunCli.ps1",
#  *     "${path.root}/../scripts/build/Install-RootCA.ps1",
#       "${path.root}/../scripts/build/Install-MongoDB.ps1",
#       "${path.root}/../scripts/build/Install-CodeQLBundle.ps1",
#       "${path.root}/../scripts/build/Configure-Diagnostics.ps1"
#     ]
#   }

COPY scripts/Installers/Install-PyPy.ps1 ./Installers/
# ~ 372MB --> 170MB
RUN .\Installers\Install-PyPy.ps1; `
     Invoke-Cleanup;

COPY scripts/Installers/Install-Ruby.ps1 ./Installers/
# ~ 217MB --> 129MB --> 77MB
RUN .\Installers\Install-Ruby.ps1; `
     Invoke-Cleanup;

COPY scripts/Installers/Install-Toolset.ps1 scripts/Installers/Configure-Toolset.ps1 ./Installers/
COPY scripts/Tests/Toolset.Tests.ps1 ./Tests/
# ~ 5.8GB --> 2.17GB --> 1.12GB
RUN .\Installers\Install-Toolset.ps1; `
     .\Installers\Configure-Toolset.ps1; `
     Invoke-Cleanup;

# Note: Node installation is moved to the next layer due to the extended time it takes to install and configure

# COPY scripts/Installers/Install-PowershellAzModules.ps1 ./Installers/
# COPY scripts/Tests/PowershellAzModules.Tests.ps1 ./Tests/
# # ~ 2.26GB
# RUN .\Installers\Install-PowershellAzModules.ps1;

COPY scripts/Installers/Install-Git.ps1 ./Installers/
COPY scripts/Tests/Git.Tests.ps1 ./Tests/
# ~ 466MB --> 400MB
RUN .\Installers\Install-Git.ps1; `
     Invoke-Cleanup;
# GitHub CLI is installed in the previous layer with other CLI tools

COPY scripts/Installers/Install-DotnetSDK.ps1 ./Installers/
COPY scripts/Tests/DotnetSDK.Tests.ps1 ./Tests/
# ~ 6.33GB --> 1.52GB --> 854MB
RUN .\Installers\Install-DotnetSDK.ps1; `
     Invoke-Cleanup;

COPY scripts/Installers/Install-Miniconda.ps1 ./Installers/
COPY scripts/Tests/Miniconda.Tests.ps1 ./Tests/
# ~ 794MB --> 703MB
RUN .\Installers\Install-Miniconda.ps1; `
     Invoke-Cleanup;

COPY scripts/Installers/Install-Vcpkg.ps1 ./Installers/
#COPY scripts/Tests/Tools.Tests.ps1 ./Tests/
# ~ 179MB --> 164MB
RUN .\Installers\Install-Vcpkg.ps1; `
     Invoke-Cleanup;

COPY scripts/Installers/Install-RootCA.ps1 ./Installers/
# ~ 39MB --> 32MB
RUN .\Installers\Install-RootCA.ps1; `
     Invoke-Cleanup;


FROM layer2 AS layer3

ARG artifactoryNPMVirtualUrl="https://registry.npmjs.org/"
ARG npmEmail
ARG npmApiKey

COPY scripts/Installers/Install-NodeJS.ps1 ./Installers/
COPY scripts/Tests/Node.Tests.ps1 ./Tests/
# ~ 286MB --> 202MB --> 208MB
RUN .\Installers\Install-NodeJS.ps1; `
     Invoke-Cleanup;

# "global_packages": [
#     { "name": "yarn", "test": "yarn --version" },
#     { "name": "newman", "test": "newman --version" },
#     { "name": "lerna", "test": "lerna --version" },
#     { "name": "gulp-cli", "test": "gulp --version" },
#     { "name": "grunt-cli", "test": "grunt --version" }
# ]

# ~ 511MB --> 365MB --> 370MB
#configure npm and install npm packages
RUN npm install -g `
        cordova `
        grunt-cli `
        gulp-cli `
        # parcel-bundler `
        yarn `
        lerna `
        sass `
        newman `
        @angular/cli `
        # @playwright/test `
        # playwright `
        typescript `
        # yarn `
        azurite; `
     npm cache clean --force; `
     Invoke-Cleanup;
    #npm install -g --save-dev webpack webpack-cli

        # "common_packages": [
        #  *   { "name": "7zip.install" },
        #     { "name": "aria2" },
        #  *   { "name": "azcopy10" },
        #  *   { "name": "Bicep" },
        #     { "name": "innosetup" },
        #  *   { "name": "jq" },
        #  *   { "name": "NuGet.CommandLine" },
        #  *   { "name": "packer" },
        #     {
        #         "name": "strawberryperl" ,
        #         "args": [ "--version", "5.32.1.1" ]
        #     },
        #  *   { "name": "pulumi" },
        #     { "name": "tortoisesvn" },
        #  *   { "name": "swig" },
        #  *   { "name": "vswhere" },
        #     {
        #         "name": "julia",
        #         "args": [ "--ia", "/DIR=C:\\Julia" ]
        #     },
        #     {
        #   *      "name": "cmake.install",
        #         "args": [ "--installargs", "ADD_CMAKE_TO_PATH=\"System\"" ]
        #     },
        #   *  { "name": "imagemagick" }
        # ]


# COPY scripts/Installers/Install-ChocolateyPackages.ps1 ./Installers/
# RUN      .\Installers\Install-ChocolateyPackages.ps1;


FROM layer3 AS layer4

# ~ 255MB
RUN Install-ChocoPackage cmake.install -ArgumentList @( '--installargs',  'ADD_CMAKE_TO_PATH="System"' ); `
     Invoke-Cleanup;


FROM layer4 AS layer5

# ENV PLAYWRIGHT_BROWSERS_PATH="C:\ms-playwright"

# RUN mkdir ${env:PLAYWRIGHT_BROWSERS_PATH}; `
#     cd ${env:PLAYWRIGHT_BROWSERS_PATH}; `
#     npm init -fy; `
#     npm install -D playwright@1.14.1; `
#     rm -Recurse -Force -Path .\node_modules\;

# ~ 40MB
RUN $env:PIP_CACHE_DIR=$env:TEMP; `
     pip install `
          ninja `
          meson; `
     Invoke-Cleanup;

