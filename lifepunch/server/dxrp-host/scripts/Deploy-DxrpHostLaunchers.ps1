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
    # lifepunchnet: ONE install root. Dev + Official differ by bat/token, not folder.
    [string] $DevelopmentRoot = '',
    [string] $RepoDxrpHost = ''
)

$ErrorActionPreference = 'Stop'

if (-not $DevelopmentRoot) {
    $DevelopmentRoot = $OfficialRoot
}

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

$scriptFiles = @(
    @{ Src = 'auto_update.bat'; Dst = 'auto_update.bat' },
    @{ Src = 'auto_update_all.bat'; Dst = 'auto_update_all.bat' },
    @{ Src = 'fix_steam.bat'; Dst = 'fix_steam.bat' },
    @{ Src = 'fix_dev_server_now.bat'; Dst = 'fix_dev_server_now.bat' },
    @{ Src = 'Fix-LifepunchnetDevServerNow.ps1'; Dst = 'Fix-LifepunchnetDevServerNow.ps1' },
    @{ Src = 'Test-LifepunchnetDevServerReady.ps1'; Dst = 'Test-LifepunchnetDevServerReady.ps1' },
    @{ Src = 'Patch-LifepunchnetUlxCompile.ps1'; Dst = 'Patch-LifepunchnetUlxCompile.ps1' },
    @{ Src = 'Update-LifepunchnetSboxServers.ps1'; Dst = 'Update-LifepunchnetSboxServers.ps1' },
    @{ Src = 'Fix-LifepunchnetSteamClient.ps1'; Dst = 'Fix-LifepunchnetSteamClient.ps1' }
)

function Deploy-ScriptBundle {
    param([string] $DestRoot, [string] $Label)
    foreach ($f in $scriptFiles) {
        $srcPath = Join-Path $RepoDxrpHost 'scripts' $f.Src
        if (-not (Test-Path -LiteralPath $srcPath)) { continue }
        $dstPath = Join-Path $DestRoot $f.Dst
        Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force
        Write-Host "  $Label -> $($f.Dst)" -ForegroundColor DarkGray
    }
}

Deploy-Profile -SourceDir (Join-Path $RepoDxrpHost 'official') -DestRoot $OfficialRoot -Label 'Official'
Deploy-Profile -SourceDir (Join-Path $RepoDxrpHost 'development') -DestRoot $DevelopmentRoot -Label 'Development'

$deployRoots = @($OfficialRoot)
if ($DevelopmentRoot -ne $OfficialRoot) {
    $deployRoots += $DevelopmentRoot
}
foreach ($root in $deployRoots) {
    Deploy-ScriptBundle -DestRoot $root -Label (Split-Path -Leaf $root)
}

Write-Host ''
Write-Host "Install root: $OfficialRoot (Dev + Official launchers in same folder)." -ForegroundColor Cyan
Write-Host '  Official: server1_start.bat   Development: server2_start.bat' -ForegroundColor Cyan
Write-Host 'Engine updates: auto_update.bat (Dev) or auto_update_all.bat (Dev+Official).' -ForegroundColor Cyan
Write-Host 'Secrets: secure\official.local.env + secure\development.local.env (never committed).' -ForegroundColor Yellow
