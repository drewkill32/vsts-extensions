Import-Module "$PSScriptRoot\..\..\modules\Env.psm1" 

Use-Env -Path "$PSScriptRoot\..\..\.env"

Import-Module "$PSScriptRoot\..\V0\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1" -Verbose
& "$PSScriptRoot\..\V0\UploadFilesToSharePoint.ps1" -Url $env:Url  -ClientId $env:ClientId -ClientSecret $env:ClientSecret -DocumentFolder $env:DocumentFolder -SourceFolder "$PSScriptRoot\sample" -Contents '*.md';
Remove-Module "VstsTaskSdk";