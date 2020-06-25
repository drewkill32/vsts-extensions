function Use-Env() {
    [CmdletBinding()]
    param(
        [string]$Path = '.\.env'
    )

    if (!(Test-Path $Path)) {
        Write-Verbose "$Path path not found. No Environment variables will be loaded"
        return
    }
    $contents = Get-Content $Path
    Push-Location Env:
    foreach ($item in $contents) {
        $kvp = $item.Split('=', 2)
        $key = $kvp[0]
        $value = $kvp[1]
        Set-Content -Path $key -Value $value
        Write-Verbose "Importing $key"
    }
    Pop-Location
}