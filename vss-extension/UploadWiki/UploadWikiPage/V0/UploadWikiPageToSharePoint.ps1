[CmdletBinding()]
param(
    [string] $url,
    [string] $listId,
    [string] $clientId,
    [string] $clientSecret,
    [string] $sourceFolder,
    [string] $contents,
    [string] $imgPath
)



function Convert-ToHtml {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MarkdownFile,
        [Parameter(Mandatory = $true)]
        [string]$Output,
        [bool] $ImgToBase64
    )
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "node.exe"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = "$PSScriptRoot/index.js $MarkdownFile $Output $ImgToBase64" 
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    
    do {
        Write-Host $p.StandardOutput.ReadLine();
    } while (!$p.HasExited)
    if ($p.ExitCode -eq 0) {
        return Join-Path -Path $Output -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($MarkdownFile) + ".html")
    }
    else {
        Write-Error $p.StandardError.ReadToEnd()
    }
}


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
    
    Import-Module -Name "$PSScriptRoot\ps_modules\AzureDevOps.SharePoint.Link.dll" -Force -Verbose

    $pattern = '(<img[^>]+src=")([^"]+)("[^>]*>)'
    $uri = new-object  System.Uri($url)
    $baseUrl = $uri.Scheme + '://' + $uri.Authority
    $imgPath = $baseUrl + $imgPath


    $defaultRoot = Resolve-Path -Path $sourceFolder
    $files = Find-VstsMatch -DefaultRoot $defaultRoot -Pattern $contents

    $htmlFiles = @()
    #get html contents
    $tmp = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "SpWiki"
    #clean out the folder
    Remove-Item -Path "$($tmp)\*" -Filter "*.html" -Recurse

    Foreach ($file in $files) {
        Write-Host $file
        $htmlFiles += @{FileName = $file; HtmlFile = (Convert-ToHtml -MarkdownFile $file -Output $tmp) }
        
    }


    #upload
    foreach ($file in $htmlFiles) {
        if ($imgPath) {
            $content = Get-Content $file.HtmlFile
            $evalutor = {
                param($match)
                
                if ($match.groups[2].Value.StartsWith('http')) {
                    return $match.groups[0].Value;
                }
                
                $imgSrc = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FileName), $match.groups[2].Value))
                Write-SpFile -ClientId  $clientId -ClientSecret $clientSecret -Url $url  -File $imgSrc -DocumentFolder $imgPath | Out-Null
                return $match.groups[1].Value + $imgPath + '/' + [System.IO.Path]::GetFileName($match.Groups[2].Value) + $match.groups[3].Value
            }
            $content = [regex]::Replace($content, $pattern, $evalutor)
            Set-Content -path $file.HtmlFile -value $content
        }

        Write-SpWikiPage -ClientId  $clientId -ClientSecret $clientSecret -File $file.HtmlFile -ListId $listId -Url $url
    }
}
finally {
    Remove-Module "AzureDevOps.SharePoint.Link";
    Trace-VstsLeavingInvocation $MyInvocation
}

