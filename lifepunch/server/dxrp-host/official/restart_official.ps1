# Restart Official (Server 1 / 70p) — Dxura dxrp-server.cs launcher.
# Run from install root or anywhere; uses $InstallRoot.

param(
    [string] $InstallRoot = 'C:\S&BOX DXRP Server',
    [int] $GamePort = 27015,
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
    Import-LocalEnvFile (Join-Path $InstallRoot 'secure\official.local.env')

    if (-not $env:DXRP_TOKEN_OFFICIAL) {
        throw 'DXRP_TOKEN_OFFICIAL not set — create secure\official.local.env on the box.'
    }

    if (-not (Test-Path -LiteralPath 'dxrp-server.cs')) {
        throw 'dxrp-server.cs missing — Dxura host files must live in the install root.'
    }

    $example = 'dxrp-server-config.json.example'
    $config = 'dxrp-server-config.json'
    if (-not (Test-Path -LiteralPath $config) -and (Test-Path -LiteralPath $example)) {
        Copy-Item -LiteralPath $example -Destination $config
        Write-Host "Created $config from example (port $GamePort in extraArgs)." -ForegroundColor Yellow
    }

    Write-Host 'Stopping prior s&box / dxrp-server processes in this session...' -ForegroundColor Cyan
    Get-Process -Name 'sbox-server','dotnet' -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -and $_.Path.StartsWith($InstallRoot, [StringComparison]::OrdinalIgnoreCase) } |
        Stop-Process -Force -ErrorAction SilentlyContinue

    if ($NoStart) {
        Write-Host 'NoStart — stop only.' -ForegroundColor Green
        return
    }

    Write-Host "Starting Official via dxrp-server.cs (game port $GamePort)..." -ForegroundColor Green
    & dotnet run dxrp-server.cs --token $env:DXRP_TOKEN_OFFICIAL
}
finally {
    Pop-Location
}
