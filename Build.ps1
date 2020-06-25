MSBuild /p:Configuration=Release
Set-Location $PSScriptRoot 
$module = Get-ChildItem -Path .\src\AzureDevOps.SharePoint.Link\bin\Release\net472\AzureDevOps.SharePoint.Link.dll

Get-ChildItem -Recurse -Directory -Filter ps_modules | ForEach-Object { Copy-Item -Path $module -Destination $_.FullName -Force }
