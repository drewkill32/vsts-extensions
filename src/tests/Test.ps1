Import-Module -Name "$PSScriptRoot\..\..\modules\Env.psm1"
Import-Module -Name ".\AzureDevOps.SharePoint.Link.dll"
Use-Env "$PSScriptRoot\.env"



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
    $pinfo.Arguments = "$PSScriptRoot/../../vss-extension/UploadWiki/UploadWikiPage/V0/index.js $MarkdownFile $Output $ImgToBase64" 
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    
    do {
        $line = $p.StandardOutput.ReadLine();
        if ($line) {
            Write-Verbose $line;
        }
    } while (!$p.HasExited)
    # if ($p.ExitCode -eq 0) {
    #     #return Join-Path -Path $Output -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($MarkdownFile) + ".html")
    # }
    # else {
    #     #Write-Error $p.StandardError.ReadToEnd()
    # }
}

try {
    Convert-ToHtml -MarkdownFile  $env:File -Output $PSScriptRoot -Verbose
    $htmlFile = "$PSScriptRoot\$(([System.IO.Path]::GetFileNameWithoutExtension($env:File))).html"
    Write-SpWikiPage -ClientId $env:ClientId -ClientSecret $env:ClientSecret -Url $env:Url -ListId $env:ListId -File $htmlFile -Script $env:Script -Verbose
}
catch {
    Write-Error $_
}
