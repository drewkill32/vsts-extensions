Import-Module "$PSScriptRoot\..\..\..\..\modules\Env.psm1" 

Use-Env -Path "$PSScriptRoot\..\..\..\..\.env" 

# Import-Module "$PSScriptRoot\..\V0\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1"
# & "$PSScriptRoot\..\V0\UploadWikiPageToSharePoint.ps1" -Url $env:Url  -ClientId $env:ClientId -ClientSecret $env:ClientSecret -ListId $env:ListId -SourceFolder "$PSScriptRoot\sample" -Contents '*.md' -ImgPath $env:ImgPath;
#Remove-Module "VstsTaskSdk";


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
    $pinfo.FileName = "node"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    #$pinfo.Arguments = "$PSScriptRoot/index.js $MarkdownFile $Output $ImgToBase64" 
    Test-Path "$PSScriptRoot/../V0/index.js"
    $pinfo.Arguments = "'$PSScriptRoot/../V0/index.js' '$MarkdownFile' '$Output' $ImgToBase64" 
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    Write-Host $MarkdownFile
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

Convert-ToHtml -MarkdownFile $PSScriptRoot\sample\sample.md -Output $PSScriptRoot\sample\