#!/bin/env pwsh
Param(
    [string]$httpProxy = ${env:HTTP_PROXY}
)
# OSS: 
# - https://docs.microsoft.com/en-us/dotnet/framework/network-programming/proxy-configuration
# - https://stackoverflow.com/a/66586880/5770014

$filesToUpdate = $(
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\Config\machine.config",
"C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"
)

$filesToUpdate | % {
    $file = $_
    Write-Host "Processing file: $file"

    # adding proxy inforamtion to global configuration
    $xmlDoc = [System.Xml.XmlDocument]::new()
    $xmlDoc.Load($file)
    $proxyConfig = $xmlDoc.SelectSingleNode("/configuration/system.net")
    if (!$proxyConfig)
    {
        Write-Host "Adding proxy configuration..."

        $xmlRoot = $xmlDoc.SelectSingleNode("/configuration")
        $xmlChild = $xmlDoc.CreateDocumentFragment()
    
        $xmlChild.InnerXml = @"
<system.net>  
<defaultProxy>  
<proxy  proxyaddress="${httpProxy}" bypassonlocal="True" />  
<bypasslist>  
<add address=".*\.domain\.com$" />  
</bypasslist>  
</defaultProxy>  
</system.net>  
"@
    
        $xmlRoot.AppendChild($xmlChild) > $null
        $xmlDoc.Save($file)
    }
}
