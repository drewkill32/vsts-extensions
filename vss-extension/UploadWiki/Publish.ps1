
Push-Location $PSScriptRoot
Import-Module ".\modules\Env.psm1" 

Use-Env -Path ".\.env" -Verbose

tfx extension publish --manifest-globs vss-extension.json --share-with $env:ShareWith --token $env:TfxToken

Pop-Location