<#
.SYNOPSIS
Converts a markdown file to an HTML file using node and Markdown It

.DESCRIPTION
Long description

.PARAMETER MarkdownFile
Path to the Markdown file

.PARAMETER Output
Directory where the html will be written to

.PARAMETER ImgToBase64
convert images to Base64 images

.EXAMPLE
An example

.NOTES
General notes
#>
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
    $pinfo.Arguments = "$PSScriptRoot/../index.js $MarkdownFile $Output $ImgToBase64" 
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    
    do {
        $line = $p.StandardOutput.ReadLine()
        if ($line) {
            Write-Verbose $line
        }
    } while (!$p.HasExited)
    if ($p.ExitCode -eq 0) {
        return Join-Path -Path $Output -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($MarkdownFile) + ".html")
    }
    else {
        $outError = $p.StandardError.ReadToEnd()
        if ($outError) {
            Write-Error $outError
        }        
    }
}

<#
.SYNOPSIS
converts a {{date}} token into a Date format

.DESCRIPTION
converts a {{date}} token into a Date format

.PARAMETER Content
the string to convert

.EXAMPLE
An example

.NOTES
General notes
#>
function Convert-DateToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content
    )
    return $Content -replace "{{date}}", (Get-Date -Format D)  
}

function Resolve-ImgPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content,
        [Parameter(Mandatory = $true)]
        [string]$ImgPath,
        [string]$RootPath = (Get-Location)
    )

    if (!$content) {
        return
    }
    $pattern = '(<img[^>]+src=")([^"]+)("[^>]*>)'
    $imgs = @()
    $evalutor = {
        param($match)
        $match.groups[0].value    
        if ($match.groups[2].Value.StartsWith('http')) {
            return $match.groups[0].Value;
        }
        
        $imgSrc = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($RootPath), $match.groups[2].Value))
        if (Test-Path $imgSrc) {
            $imgs += $imgSrc
            $httpPath = $imgPath + '/' + [System.IO.Path]::GetFileName($match.Groups[2].Value)
            Write-Verbose "Replacing $imgSrc with $httpPath"
            return $match.groups[1].Value + $httpPath + $match.groups[3].Value
        }
        else {
            Write-Warning $"Image $imgSrc was not found"
            return $match.groups[0].Value;
        }   
    }

    $replaced = [regex]::Replace($content, $pattern, $evalutor, 2) #2 = Multiline
    return @{Content = $replaced; Images = $imgs }
}