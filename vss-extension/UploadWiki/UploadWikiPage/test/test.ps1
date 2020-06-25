Import-Module "$PSScriptRoot\..\..\modules\Env.psm1" 

Use-Env -Path "$PSScriptRoot\..\..\.env" -Verbose

Import-Module "$PSScriptRoot\..\V0\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1"
& "$PSScriptRoot\..\V0\UploadWikiPageToSharePoint.ps1" -Url $env:Url  -ClientId $env:ClientId -ClientSecret $env:ClientSecret -ListId $env:ListId -SourceFolder "$PSScriptRoot\sample" -Contents '*.md' -ImgPath $env:ImgPath;
Remove-Module "VstsTaskSdk";


