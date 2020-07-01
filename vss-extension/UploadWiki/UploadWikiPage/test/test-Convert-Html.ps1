Import-Module "$PSScriptRoot\..\..\..\..\modules\Env.psm1" 

Use-Env -Path "$PSScriptRoot\..\..\..\..\.env" 

Import-Module "$PSScriptRoot\..\V0\ps_modules\html-it.psm1" -Verbose


$uri = new-object  System.Uri($env:url)
$baseUrl = $uri.Scheme + '://' + $uri.Authority
$imgPath = $baseUrl + $env:imgPath

$htmlFile = Convert-ToHtml -MarkdownFile $env:MarkdownFile -Output $PSScriptRoot

$content = Get-Content -Path $htmlFile | Out-String
$content = Convert-DateToken -Content $content

$result = Resolve-ImgPath -Content $content -ImgPath $imgPath  -RootPath ([System.IO.Path]::GetDirectoryName($env:MarkdownFile)) -Verbose
$result

Remove-Module "html-it";


