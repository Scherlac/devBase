# escape=` 

ARG GIT_TOKEN
# ARG HTTP_PROXY
# ARG HTTPS_PROXY
FROM mcr.microsoft.com/windows/servercore:win10-21h1-preview AS layer1
#FROM mcr.microsoft.com/windows/servercore:10.0.19042.1415 AS layer1

# ENV NO_PROXY="localhost,127.0.0.1"

ENV AGENT_TOOLSDIRECTORY="C:\hostedtoolcache\windows"
ENV TOOLSET_JSON_PATH="C:\image\toolsets\toolset-2019.json"
ENV PSMODULES_ROOT_FOLDER="C:\Modules"

WORKDIR C:/image
COPY scripts ./
COPY toolsets ./toolsets/

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# RUN  $reg = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'; `
#         $settings = Get-ItemProperty -Path $reg; `
#         Set-ItemProperty -Path $reg -Name ProxyServer -Value 'BP-F06457:3128'; `
#         Set-ItemProperty -Path $reg -Name ProxyEnable -Value 1

RUN Import-Module .\ImageHelpers\ImageHelpers.psm1 -Force; `
     .\Installers\Install-PowerShellModules.ps1;

RUN Import-Module .\ImageHelpers\ImageHelpers.psm1 -Force; `
     .\Installers\Initialize-VM.ps1; `
     .\Installers\Install-WebPlatformInstaller.ps1

RUN Import-Module .\ImageHelpers\ImageHelpers.psm1 -Force; `
    .\Installers\Install-PowershellCore.ps1; `
    # .\Installers\Update-DotnetProxy.ps1; `
    .\Installers\Install-Git.ps1;

FROM localhost:5000/windows-servercore-devbase:layer1 AS layer2

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Import-Module .\ImageHelpers\ImageHelpers.psm1 -Force; `
     .\Installers\Install-AzureCli.ps1;

RUN Import-Module .\ImageHelpers\ImageHelpers.psm1 -Force; `
    .\Installers\Install-VS.ps1;

RUN Import-Module .\ImageHelpers\ImageHelpers.psm1 -Force; `
    .\Installers\Install-DotnetSDK.ps1;

FROM localhost:5000/windows-servercore-devbase:layer2 AS layer3

ARG artifactoryNPMVirtualUrl="https://registry.npmjs.org/"
ARG npmEmail
ARG npmApiKey
 
ENV TOOLSET_JSON_PATH="C:\image\toolsets\toolset-2019.json"

# COPY Install-NodeLts.ps1 ./Installers/Install-NodeLts.ps1
# COPY ChocoPackages.Tests.ps1 ./Tests/ChocoPackages.Tests.ps1

RUN Import-Module .\ImageHelpers\ImageHelpers.psm1 -Force; `
    .\Installers\Install-NodeLts.ps1;

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
        azurite;
    #npm install -g --save-dev webpack webpack-cli

RUN Import-Module .\ImageHelpers\ImageHelpers.psm1 -Force; `
     .\Installers\Install-CommonUtils.ps1

FROM localhost:5000/windows-servercore-devbase:layer3 AS layer4

ENV PLAYWRIGHT_BROWSERS_PATH="C:\ms-playwright"

RUN mkdir ${env:PLAYWRIGHT_BROWSERS_PATH}; `
    cd ${env:PLAYWRIGHT_BROWSERS_PATH}; `
    npm init -fy; `
    npm install -D playwright@1.14.1; `
    rm -Recurse -Force -Path .\node_modules\;

