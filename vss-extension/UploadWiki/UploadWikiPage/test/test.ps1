Import-Module "$PSScriptRoot\..\..\..\..\modules\Env.psm1" 

Use-Env -Path "$PSScriptRoot\..\..\..\..\.env" 

Import-Module "$PSScriptRoot\..\V0\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1"
& "$PSScriptRoot\..\V0\UploadWikiPageToSharePoint.ps1" -Url $env:Url  -ClientId $env:ClientId -ClientSecret $env:ClientSecret -ListId $env:ListId -SourceFolder "D:\Code\STERIS.Docs\" -Contents 'docs\**\*.md' -ImgPath $env:ImgPath -Script "D:\Code\STERIS.Docs\assets\scripts\scripts.html";
#& "$PSScriptRoot\..\V0\UploadWikiPageToSharePoint.ps1" -Url $env:Url  -ClientId $env:ClientId -ClientSecret $env:ClientSecret -ListId $env:ListId -SourceFolder "$PSScriptRoot\sample" -Contents '*.md' -ImgPath $env:ImgPath -Script "$PSScriptRoot\sample\scripts.html";
Remove-Module "VstsTaskSdk";

