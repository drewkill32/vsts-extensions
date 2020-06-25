[CmdletBinding()]
param(
    [string] $url,
    [string] $documentFolder,
    [string] $clientId,
    [string] $clientSecret,
    [string] $sourceFolder,
    [string] $contents
)


Trace-VstsEnteringInvocation $MyInvocation
$ErrorActionPreference = 'Stop'
try {
    $url = If ($url) { $url } Else { Get-VstsInput -Name url -Require }
    $documentFolder = If ($documentFolder) { $documentFolder } Else { Get-VstsInput -Name documentFolder -Require }
    $clientId = If ($clientId) { $clientId } Else { Get-VstsInput -Name clientId -Require }
    $clientSecret = If ($clientSecret) { $clientSecret } Else { Get-VstsInput -Name clientSecret -Require }
    $sourceFolder = If ($sourceFolder) { $sourceFolder } Else { Get-VstsInput -Name sourceFolder -Require }
    $contents = If ($contents) { $contents } Else { Get-VstsInput -Name contents -Require }

    Import-Module -Name "$PSScriptRoot\ps_modules\AzureDevOps.SharePoint.Link.dll" -Force -Verbose

    
    $defaultRoot = Resolve-Path -Path $sourceFolder
    $files = Find-VstsMatch -DefaultRoot $defaultRoot -Pattern $contents
    Foreach ($file in $files) {
        Write-Host $file
        Write-SpFile -ClientId  $clientId -ClientSecret $clientSecret -Url $url -DocumentFolder $documentFolder -File $file
    }
    


}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
