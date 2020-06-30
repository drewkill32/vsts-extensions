[CmdletBinding()]
param(
    [string] $url,
    [string] $listId,
    [string] $clientId,
    [string] $clientSecret,
    [string] $sourceFolder,
    [string] $contents,
    [string] $imgPath,
    [string] $script
)


Trace-VstsEnteringInvocation $MyInvocation
$ErrorActionPreference = 'Stop'

try {
    $url = If ($url) { $url } Else { Get-VstsInput -Name url -Require }
    $listId = If ($listId) { $listId } Else { Get-VstsInput -Name listId -Require }
    $clientId = If ($clientId) { $clientId } Else { Get-VstsInput -Name clientId -Require }
    $clientSecret = If ($clientSecret) { $clientSecret } Else { Get-VstsInput -Name clientSecret -Require }
    $sourceFolder = If ($sourceFolder) { $sourceFolder } Else { Get-VstsInput -Name sourceFolder -Require }
    $contents = If ($contents) { $contents } Else { Get-VstsInput -Name contents -Require }
    $imgPath = If ($imgPath) { $imgPath } Else { Get-VstsInput -Name imgPath -Require }
    $script = If ($script) { $script } Else { Get-VstsInput -Name script -Require }
    
    Import-Module -Name "$PSScriptRoot\ps_modules\AzureDevOps.SharePoint.Link.dll" -Force -Verbose
    Import-Module -Name "$PSScriptRoot\ps_modules\Html-it.psm1" -Force -Verbose


    $uri = new-object  System.Uri($url)
    $baseUrl = $uri.Scheme + '://' + $uri.Authority
    $imgPath = $baseUrl + $imgPath

    
    $defaultRoot = Resolve-Path -Path $sourceFolder
    $files = Find-VstsMatch -DefaultRoot $defaultRoot -Pattern $contents
    $htmlFiles = @()
    #get html contents
    $tmp = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "SpWiki"
    #clean out the folder
    if (Test-Path $tmp) {
        Remove-Item -Path "$($tmp)\*" -Filter "*.html" -Recurse
    }
    else {
        New-Item -Path $tmp -ItemType Directory | Out-Null
    }

    Foreach ($file in $files) {
        Write-Host $file
        $htmlFiles += @{FileName = $file; HtmlFile = (Convert-ToHtml -MarkdownFile $file -Output $tmp) }
        
    }


    #upload
    foreach ($file in $htmlFiles) {
        $content = Get-Content $file.HtmlFile | Out-String
        if ($content) {
            #replace the string {{date}} with the formatted date
            $content = Convert-DateToken -Content $content
            if ($imgPath) {
                $result = Resolve-ImgPath -Content $content -ImgPath $imgPath  -RootPath ([System.IO.Path]::GetDirectoryName($file.FileName)) -Verbose
                $content = $result.Content
                foreach ($img in $result.Images) {
                    Write-SpFile -ClientId  $clientId -ClientSecret $clientSecret -Url $url  -File $img -DocumentFolder $imgPath 
                }
            }
            Set-Content -path $file.HtmlFile -value $content
            Write-SpWikiPage -ClientId  $clientId -ClientSecret $clientSecret -File $file.HtmlFile -ListId $listId -Url $url -Script $script
        }
        else {
            Write-Warning "$($file.FileName) is empty. File will not be uploaded."
        }
    }
}
finally {
    Remove-Module "AzureDevOps.SharePoint.Link";
    Trace-VstsLeavingInvocation $MyInvocation
}

