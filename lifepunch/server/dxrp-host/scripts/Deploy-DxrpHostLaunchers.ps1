<#
.SYNOPSIS
  Copy LifePunch DXRP host launch wrappers from repo lane to on-box install roots.

.DESCRIPTION
  Run on lifepunchnet after git pull. Does NOT copy dxrp-server.cs (upstream on box).
  Does NOT overwrite dxrp-server-config.json or secure/*.local.env.

.EXAMPLE
  cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
  powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
#>
[CmdletBinding()]
param(
    [string] $OfficialRoot = 'C:\S&BOX DXRP Server',
    [string] $DevelopmentRoot = 'C:\S&BOX DXRP Server Dev',
    [string] $RepoDxrpHost = ''
)

$ErrorActionPreference = 'Stop'

if (-not $RepoDxrpHost) {
    $RepoDxrpHost = Split-Path -Parent $PSScriptRoot
}

function Deploy-Profile {
    param(
        [string] $SourceDir,
        [string] $DestRoot,
        [string] $Label
    )

    if (-not (Test-Path -LiteralPath $SourceDir)) {
        throw "Missing source: $SourceDir"
    }

    New-Item -ItemType Directory -Force -Path $DestRoot | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $DestRoot 'secure') | Out-Null

    $files = @(
        @{ Src = 'server1_start.bat'; Dst = 'server1_start.bat' },
        @{ Src = 'server2_start.bat'; Dst = 'server2_start.bat' },
        @{ Src = 'restart_official.ps1'; Dst = 'restart_official.ps1' },
        @{ Src = 'restart_development.ps1'; Dst = 'restart_development.ps1' },
        @{ Src = 'dxrp-server-config.json.example'; Dst = 'dxrp-server-config.json.example' }
    )

    foreach ($f in $files) {
        $srcPath = Join-Path $SourceDir $f.Src
        if (-not (Test-Path -LiteralPath $srcPath)) { continue }
        $dstPath = Join-Path $DestRoot $f.Dst
        Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force
        Write-Host "  $Label -> $($f.Dst)" -ForegroundColor DarkGray
    }

    Write-Host "OK $Label -> $DestRoot" -ForegroundColor Green
}

Write-Host 'Deploying LifePunch DXRP host launchers...' -ForegroundColor Cyan

Deploy-Profile -SourceDir (Join-Path $RepoDxrpHost 'official') -DestRoot $OfficialRoot -Label 'Official'
Deploy-Profile -SourceDir (Join-Path $RepoDxrpHost 'development') -DestRoot $DevelopmentRoot -Label 'Development'

Write-Host ''
Write-Host 'Next: point desktop shortcut at server1_start.bat in Official root.' -ForegroundColor Cyan
Write-Host 'Secrets stay in secure\official.local.env (never committed).' -ForegroundColor Yellow
