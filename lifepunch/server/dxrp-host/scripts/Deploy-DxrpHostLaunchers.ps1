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
    [string] $OfficialRoot = 'C:\SBOX-DXRP-Server',
    [string] $DevelopmentRoot = 'C:\Program Files (x86)\Steam\steamapps\common\sbox',
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
        [string] $Label,
        [string[]] $FileMap,
        [string] $ConfigExampleDst = 'dxrp-server-config.json.example'
    )

    if (-not (Test-Path -LiteralPath $SourceDir)) {
        throw "Missing source: $SourceDir"
    }

    New-Item -ItemType Directory -Force -Path $DestRoot | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $DestRoot 'secure') | Out-Null

    foreach ($entry in $FileMap) {
        $srcPath = Join-Path $SourceDir $entry.Src
        if (-not (Test-Path -LiteralPath $srcPath)) { continue }
        $dstPath = Join-Path $DestRoot $entry.Dst
        Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force
        Write-Host "  $Label -> $($entry.Dst)" -ForegroundColor DarkGray
    }

    $exampleSrc = Join-Path $SourceDir 'dxrp-server-config.json.example'
    if (Test-Path -LiteralPath $exampleSrc) {
        Copy-Item -LiteralPath $exampleSrc -Destination (Join-Path $DestRoot $ConfigExampleDst) -Force
        Write-Host "  $Label -> $ConfigExampleDst" -ForegroundColor DarkGray
    }

    Write-Host "OK $Label -> $DestRoot" -ForegroundColor Green
}

Write-Host 'Deploying LifePunch DXRP host launchers...' -ForegroundColor Cyan

$officialFiles = @(
    @{ Src = 'server1_start.bat'; Dst = 'server1_start.bat' },
    @{ Src = 'restart_official.ps1'; Dst = 'restart_official.ps1' }
)
$developmentFiles = @(
    @{ Src = 'server2_start.bat'; Dst = 'server2_start.bat' },
    @{ Src = 'start_dev_server.bat'; Dst = 'start_dev_server.bat' },
    @{ Src = 'show_dev_server_log.bat'; Dst = 'show_dev_server_log.bat' },
    @{ Src = 'restart_development.ps1'; Dst = 'restart_development.ps1' }
)

$sharedScripts = @(
    @{ Src = 'fix_steam.bat'; Dst = 'fix_steam.bat' },
    @{ Src = 'Dxrp-HostProcess.ps1'; Dst = 'Dxrp-HostProcess.ps1' },
    @{ Src = 'Set-DxrpServerConfig.ps1'; Dst = 'Set-DxrpServerConfig.ps1' },
    @{ Src = 'Update-LifepunchnetSboxServers.ps1'; Dst = 'Update-LifepunchnetSboxServers.ps1' },
    @{ Src = 'Fix-LifepunchnetSteamClient.ps1'; Dst = 'Fix-LifepunchnetSteamClient.ps1' },
    @{ Src = 'Apply-DxrpHostCompileHotfixes.ps1'; Dst = 'Apply-DxrpHostCompileHotfixes.ps1' }
)
$officialScripts = @(
    @{ Src = 'auto_update.bat'; Dst = 'auto_update.bat' },
    @{ Src = 'auto_update_all.bat'; Dst = 'auto_update_all.bat' },
    @{ Src = 'auto_update_official.bat'; Dst = 'auto_update_official.bat' }
)
$developmentScripts = @(
    @{ Src = 'auto_update.bat'; Dst = 'auto_update.bat' },
    @{ Src = 'Run-DevServer.ps1'; Dst = 'Run-DevServer.ps1' }
)
# ULX patch is NOT deployed by default — only if lifepunch.ulx is pinned on the Dev gamemode.
# Manual: scripts\Patch-LifepunchnetUlxCompile.ps1 (repo clone path).

function Deploy-ScriptBundle {
    param(
        [string] $DestRoot,
        [string] $Label,
        [array] $Files
    )
    foreach ($f in $Files) {
        $srcPath = Join-Path (Join-Path $RepoDxrpHost 'scripts') $f.Src
        if (-not (Test-Path -LiteralPath $srcPath)) { continue }
        $dstPath = Join-Path $DestRoot $f.Dst
        Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force
        Write-Host "  $Label -> $($f.Dst)" -ForegroundColor DarkGray
    }
}

Deploy-Profile -SourceDir (Join-Path $RepoDxrpHost 'official') -DestRoot $OfficialRoot -Label 'Official' -FileMap $officialFiles -ConfigExampleDst 'dxrp-server-config.official.json.example'
Deploy-Profile -SourceDir (Join-Path $RepoDxrpHost 'development') -DestRoot $DevelopmentRoot -Label 'Development' -FileMap $developmentFiles -ConfigExampleDst 'dxrp-server-config.development.json.example'

Deploy-ScriptBundle -DestRoot $OfficialRoot -Label 'Official' -Files ($sharedScripts + $officialScripts)
if ($DevelopmentRoot -ne $OfficialRoot) {
    Deploy-ScriptBundle -DestRoot $DevelopmentRoot -Label 'Development' -Files ($sharedScripts + $developmentScripts)
}

$cleanup = Join-Path $PSScriptRoot 'Remove-StaleDxrpHostFiles.ps1'
if (Test-Path -LiteralPath $cleanup) {
    Write-Host 'Removing stale / wrong-profile files...' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $cleanup -OfficialRoot $OfficialRoot -DevelopmentRoot $DevelopmentRoot
}

$hook = Join-Path $PSScriptRoot 'Install-DxrpServerCompileHotfixHook.ps1'
if (Test-Path -LiteralPath $hook) {
    Write-Host 'Installing dxrp-server.cs compile hotfix hooks...' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hook -InstallRoot $OfficialRoot
    if ($DevelopmentRoot -ne $OfficialRoot) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hook -InstallRoot $DevelopmentRoot
    }
}

function New-DxrpDesktopShortcut {
    param(
        [string] $DesktopPath,
        [string] $ShortcutName,
        [string] $StartBat,
        [string] $Description,
        [string] $InstallRoot
    )

    $wsh = New-Object -ComObject WScript.Shell
    $lnk = $wsh.CreateShortcut((Join-Path $DesktopPath ($ShortcutName + '.lnk')))
    $lnk.TargetPath = "$env:SystemRoot\System32\cmd.exe"
    $lnk.Arguments = ('/k ' + $StartBat)
    $lnk.WorkingDirectory = $InstallRoot
    $lnk.WindowStyle = 1
    $lnk.Description = $Description
    $lnk.Save()
}

function Remove-StaleDxrpDesktopItems {
    param(
        [string[]] $DesktopPaths,
        [switch] $IncludeCurrentShortcuts
    )

    $staleNames = @(
        'Dev Log (Notepad).lnk',
        'Dev Logs (Live).lnk',
        'LIFEPUNCH Official (Server 1).lnk',
        'OPEN LIFEPUNCH DEVELOPMENT CONSOLE.bat',
        'OPEN LIFEPUNCH OFFICIAL CONSOLE.bat'
    )
    if ($IncludeCurrentShortcuts) {
        $staleNames += @('LIFEPUNCH Official.lnk', 'LIFEPUNCH Development.lnk')
    }

    foreach ($desktop in $DesktopPaths) {
        if (-not $desktop) { continue }
        foreach ($name in $staleNames) {
            $p = Join-Path $desktop $name
            if (Test-Path -LiteralPath $p) {
                Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
                Write-Host ('  removed: ' + $p) -ForegroundColor DarkYellow
            }
        }
    }
}

function New-DxrpDesktopShortcuts {
    param(
        [string] $OfficialInstallRoot,
        [string] $DevelopmentInstallRoot
    )

    try {
        $userDesktop = [Environment]::GetFolderPath('Desktop')
        $publicDesktop = [Environment]::GetFolderPath('CommonDesktopDirectory')

        # Drop legacy names everywhere; drop current shortcuts from Public only (duplicate surface).
        Remove-StaleDxrpDesktopItems -DesktopPaths @($userDesktop, $publicDesktop)
        if ($publicDesktop) {
            Remove-StaleDxrpDesktopItems -DesktopPaths @($publicDesktop) -IncludeCurrentShortcuts
        }

        if (-not $userDesktop) { throw 'Could not resolve user Desktop folder.' }

        New-DxrpDesktopShortcut -DesktopPath $userDesktop `
            -ShortcutName 'LIFEPUNCH Official' `
            -StartBat 'server1_start.bat' `
                -Description 'Official 70p - dotnet run dxrp-server.cs' `
            -InstallRoot $OfficialInstallRoot

        New-DxrpDesktopShortcut -DesktopPath $userDesktop `
            -ShortcutName 'LIFEPUNCH Development' `
            -StartBat 'server2_start.bat' `
                -Description 'Development - dotnet run dxrp-server.cs' `
            -InstallRoot $DevelopmentInstallRoot

        Write-Host ('Desktop shortcuts: ' + $userDesktop) -ForegroundColor Green
        Write-Host ('  Official -> ' + $OfficialInstallRoot + '\server1_start.bat') -ForegroundColor DarkGray
        Write-Host ('  Development -> ' + $DevelopmentInstallRoot + '\server2_start.bat') -ForegroundColor DarkGray
    }
    catch {
        Write-Host ('WARN: Could not create desktop shortcuts: ' + $_) -ForegroundColor Yellow
    }
}

New-DxrpDesktopShortcuts -OfficialInstallRoot $OfficialRoot -DevelopmentInstallRoot $DevelopmentRoot

Write-Host ''
Write-Host ('Official:  ' + $OfficialRoot + '  -> server1_start.bat (dotnet run dxrp-server.cs, port 27015)') -ForegroundColor Cyan
Write-Host ('Development: ' + $DevelopmentRoot + ' -> server2_start.bat (dotnet run dxrp-server.cs, port 27016)') -ForegroundColor Cyan
Write-Host ('Tokens: ' + $OfficialRoot + '\secure\official.local.env + development.local.env') -ForegroundColor Yellow
