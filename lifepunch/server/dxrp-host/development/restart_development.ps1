# Restart Development (Server 2) — Dxura dxrp-server.cs launcher.

param(
    [string] $InstallRoot = 'C:\S&BOX DXRP Server',
    [int] $GamePort = 27016,
    [switch] $NoStart
)

$ErrorActionPreference = 'Stop'

function Import-LocalEnvFile([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    Get-Content -LiteralPath $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith('#')) { return }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { return }
        $name = $line.Substring(0, $eq).Trim()
        $value = $line.Substring($eq + 1).Trim().Trim('"')
        Set-Item -Path "Env:$name" -Value $value
    }
}

if (-not (Test-Path -LiteralPath $InstallRoot)) {
    throw "Install root missing: $InstallRoot"
}

Push-Location $InstallRoot
try {
    Import-LocalEnvFile (Join-Path $InstallRoot 'secure\development.local.env')

    if (-not $env:DXRP_TOKEN_DEVELOPMENT) {
        throw 'DXRP_TOKEN_DEVELOPMENT not set — create secure\development.local.env on the box.'
    }

    if (-not (Test-Path -LiteralPath 'dxrp-server.cs')) {
        throw 'dxrp-server.cs missing — Dxura host files must live in the install root.'
    }

    $example = 'dxrp-server-config.json.example'
    $config = 'dxrp-server-config.json'
    if (-not (Test-Path -LiteralPath $config) -and (Test-Path -LiteralPath $example)) {
        Copy-Item -LiteralPath $example -Destination $config
    }

    Get-Process -Name 'sbox-server','dotnet' -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -and $_.Path.StartsWith($InstallRoot, [StringComparison]::OrdinalIgnoreCase) } |
        Stop-Process -Force -ErrorAction SilentlyContinue

    if ($NoStart) { return }

    Write-Host "Starting Development via dxrp-server.cs (game port $GamePort)..." -ForegroundColor Green
    & dotnet run dxrp-server.cs --token $env:DXRP_TOKEN_DEVELOPMENT
}
finally {
    Pop-Location
}
