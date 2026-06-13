<#
.SYNOPSIS
  Pre-launch routine: Cornerman health + headless Tier-3 LM + dual MCP on Red and Green.

.DESCRIPTION
  Run from VENGEANCE before Start-SboxDxrpEditor.ps1 or any focused project session.

  Checks:
    - VENGEANCE RAM / bloat (Discord, Spotify, LM Studio GUI on Red, duplicate s&box)
    - Cornerman RAM / bloat (LM Studio GUI, browsers, etc.)
    - Tier-3 serve lane (distill+embed in VRAM via lms CLI - no GUI required)
    - VENGEANCE dual MCP (sbox bridge IPC + sbox-editor HTTP + mcp.json)
    - Cornerman triple MCP (SMB sbox + SSH tunnel sbox-editor + cornerman-lm)

  Use -Fix to stop wrong-node apps on VENGEANCE, warm Green LM, refresh bridge wiring.

.EXAMPLE
  powershell -File lifepunch\scripts\Test-PreLaunchCheckup.ps1
  powershell -File lifepunch\scripts\Test-PreLaunchCheckup.ps1 -Fix
  powershell -File lifepunch\scripts\Test-PreLaunchCheckup.ps1 -RequireEditor
#>
[CmdletBinding()]
param(
    [switch] $Fix,
    [switch] $RequireEditor,
    [switch] $Quiet,
    [string] $SshTarget = '',
    [int] $EditorPort = 9090
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }

$cornermanIp = '192.168.1.229'
$hostsPath = Join-Path $Here 'remote-hosts.json'
if (Test-Path -LiteralPath $hostsPath) {
    $h = Get-Content -LiteralPath $hostsPath -Raw | ConvertFrom-Json
    if ($h.cornerman.host) { $cornermanIp = [string]$h.cornerman.host }
}

$script:Fail = 0
$script:Warn = 0
$script:Lines = [System.Collections.Generic.List[string]]::new()

function Write-Check([string]$Label, [bool]$Ok, [string]$Detail, [switch]$Warning) {
    $color = if ($Ok) { 'Green' } elseif ($Warning) { 'Yellow' } else { 'Red' }
    $tag = if ($Ok) { 'OK' } elseif ($Warning) { 'WARN' } else { 'FAIL' }
    if (-not $Ok -and -not $Warning) { $script:Fail++ }
    if ($Warning) { $script:Warn++ }
    $line = "  [$tag] $Label - $Detail"
    $script:Lines.Add($line)
    if (-not $Quiet) { Write-Host $line -ForegroundColor $color }
}

function Invoke-RemoteProbe([string]$ScriptName) {
    $onBox = "C:\lifepunch\cornerman\$ScriptName"
    $local = Join-Path $Here $ScriptName
    if (-not (Test-Path -LiteralPath $local)) { return $null }
    $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$onBox')) { throw 'Missing $onBox -  run Sync-CornermanRebootScripts.ps1' }
& powershell -NoProfile -ExecutionPolicy Bypass -File '$onBox'
"@ -ConnectTimeout 45
    if ($r.ExitCode -ne 0) { return $null }
    $jsonLine = ($r.Output -split "`n" | Where-Object { $_.Trim().StartsWith('{') } | Select-Object -Last 1)
    if (-not $jsonLine) { return $null }
    return ($jsonLine | ConvertFrom-Json)
}

function Get-LocalVengeanceHealth {
    $probe = Join-Path $Here 'Get-VengeanceHealthProbe.ps1'
    if (-not (Test-Path -LiteralPath $probe)) { return $null }
    $jsonLine = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $probe 2>$null
    if (-not $jsonLine) { return $null }
    return ($jsonLine | ConvertFrom-Json)
}

function Test-VengeanceHealth {
    $v = Get-LocalVengeanceHealth
    if (-not $v) {
        Write-Check 'VENGEANCE health probe' $false 'missing Get-VengeanceHealthProbe.ps1'
        return
    }
    $ramOk = ($v.ramFreeGb -ge 4) -and ($v.ramUsedPct -lt 90)
    Write-Check 'VENGEANCE RAM headroom' $ramOk "$($v.ramFreeGb)GB free / $($v.ramTotalGb)GB ($($v.ramUsedPct)% used)"

    foreach ($b in @($v.bloat)) {
        if ($b) { Write-Check 'VENGEANCE bloat' $false $b -Warning }
    }
    if ($v.bloat.Count -eq 0) {
        Write-Check 'VENGEANCE bloat scan' $true 'no wrong-node heavy apps'
    }

    if ($v.staleSbox) {
        Write-Check 'VENGEANCE s&box instances' $false "$($v.sboxProcessCount) running - keep one editor only" -Warning
    }
    else {
        Write-Check 'VENGEANCE s&box instances' $true $(if ($v.sboxProcessCount -eq 0) { 'none (launch editor next)' } else { "$($v.sboxProcessCount) running" })
    }

    if ($v.optionalServices.Count -gt 0) {
        $svcList = $v.optionalServices -join ', '
        Write-Check 'VENGEANCE optional services' $false "running: $svcList (disable manually if unused)" -Warning
    }
    else {
        Write-Check 'VENGEANCE optional services' $true 'no flagged telemetry/xbox services running'
    }
}

function Test-VengeanceMcpStack {
    $ipcDir = Join-Path $env:TEMP 'sbox-bridge-ipc'
    $statusPath = Join-Path $ipcDir 'status.json'
    $bridgeOk = $false
    $bridgeAge = 'n/a'
    if (Test-Path -LiteralPath $statusPath) {
        try {
            $st = Get-Content -LiteralPath $statusPath -Raw | ConvertFrom-Json
            if ($st.heartbeat) {
                $hb = [datetime]$st.heartbeat
                $bridgeAge = [math]::Round(((Get-Date).ToUniversalTime() - $hb).TotalSeconds, 0).ToString() + 's'
                $bridgeOk = ((Get-Date).ToUniversalTime() - $hb).TotalSeconds -lt 120
            }
        }
        catch { }
    }
    Write-Check 'VENGEANCE bridge IPC' $bridgeOk "heartbeat age $bridgeAge ($statusPath)" -Warning:(-not $bridgeOk)

    $share = Get-SmbShare -Name 'SboxBridgeIpc' -ErrorAction SilentlyContinue
    Write-Check 'VENGEANCE SboxBridgeIpc share' ($null -ne $share) $(if ($share) { $share.Path } else { 'missing -  elevated net share once' })

    $mcpPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
    $keys = @()
    if (Test-Path -LiteralPath $mcpPath) {
        $mj = Get-Content -LiteralPath $mcpPath -Raw | ConvertFrom-Json
        if ($mj.mcpServers) { $keys = @($mj.mcpServers.PSObject.Properties.Name) }
    }
    $dualOk = ('sbox' -in $keys) -and ('sbox-editor' -in $keys)
    Write-Check 'VENGEANCE mcp.json dual stack' $dualOk ($keys -join ', ')

    $editorUrl = "http://127.0.0.1:$EditorPort/sbox-mcp"
    $editorOk = $false
    try {
        $null = Invoke-WebRequest -Uri $editorUrl -Method Post -ContentType 'application/json' `
            -Body '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"preflight","version":"1"}}}' `
            -TimeoutSec 4 -UseBasicParsing
        $editorOk = $true
    }
    catch { }
    if ($RequireEditor) {
        Write-Check 'VENGEANCE sbox-editor MCP' $editorOk $editorUrl
    }
    else {
        Write-Check 'VENGEANCE sbox-editor MCP' $editorOk $editorUrl -Warning:(-not $editorOk)
    }

    $lmOk = $false
    try {
        $null = Invoke-RestMethod -Uri "http://${cornermanIp}:1234/v1/models" -TimeoutSec 6
        $lmOk = $true
    }
    catch { }
    Write-Check 'Cornerman LM API (LAN)' $lmOk "http://${cornermanIp}:1234"
}

if (-not $Quiet) {
    Write-Host ''
    Write-Host '=== LifePunch pre-launch checkup ===' -ForegroundColor Cyan
    Write-Host "  Red: $env:COMPUTERNAME  Green SSH: $SshTarget" -ForegroundColor DarkGray
    Write-Host ''
}

if ($Fix) {
    if (-not $Quiet) { Write-Host 'Fix pass...' -ForegroundColor Cyan }
    $cleanup = Join-Path $Here 'Invoke-VengeanceBloatCleanup.ps1'
    if (Test-Path -LiteralPath $cleanup) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $cleanup
    }
    if (Test-CornermanSshReady -SshTarget $SshTarget) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Sync-CornermanRebootScripts.ps1') | Out-Null
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Fix-CornermanLmServe.ps1') 2>$null | Out-Null
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Connect-CornermanBridge.ps1') -SkipSmbMap 2>$null | Out-Null
        Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
Get-Process -ErrorAction SilentlyContinue | Where-Object { `$_.ProcessName -match 'LM Studio' } | ForEach-Object {
  `$null = `$_.CloseMainWindow(); Start-Sleep -Milliseconds 300
}
"@ -ConnectTimeout 15 | Out-Null
        $tunnel = 'C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1'
        Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (Test-Path -LiteralPath '$tunnel') {
  & powershell -NoProfile -ExecutionPolicy Bypass -File '$tunnel' -Background
}
"@ -ConnectTimeout 25 | Out-Null
    }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Install-VengeanceSboxEditorMcp.ps1') -SkipProbe | Out-Null
    if (-not $Quiet) { Write-Host '' }
}

if (-not $Quiet) { Write-Host '' }
Write-Host '--- VENGEANCE (Red) ---' -ForegroundColor Cyan
Test-VengeanceHealth

if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    Write-Check 'Cornerman SSH' $false $SshTarget
}
else {
    if (-not $Quiet) { Write-Host '' ; Write-Host '--- Cornerman (Green) ---' -ForegroundColor Cyan }
    Write-Check 'Cornerman SSH' $true $SshTarget
    $health = Invoke-RemoteProbe 'Get-CornermanHealthProbe.ps1'
    if ($health) {
        $ramOk = ($health.ramFreeGb -ge 2) -and ($health.ramUsedPct -lt 92)
        Write-Check 'Cornerman RAM headroom' $ramOk "$($health.ramFreeGb)GB free / $($health.ramTotalGb)GB ($($health.ramUsedPct)% used)"

        Write-Check 'LM Studio GUI closed' (-not $health.lmGuiRunning) $(if ($health.lmGuiRunning) { "GUI using $($health.lmGuiRamMb)MB -  close window" } else { 'headless serve only' })

        Write-Check 'Tier-3 VRAM serve' $health.lmServeOk "loaded: $($health.lmVramLoaded)"
        Write-Check 'Tier-3 catalog' $health.lmCatalogOk '3 models on disk'
        Write-Check 'LM watchdog task' $health.lmWatchdogOk 'LifePunch-Cornerman-LM-Watchdog'

        foreach ($b in @($health.bloat)) {
            if ($b) { Write-Check 'Bloat' $false $b -Warning }
        }
        if ($health.bloat.Count -eq 0) {
            Write-Check 'Bloat scan' $true 'no flagged heavy apps'
        }

        Write-Check 'Green SMB bridge' $health.smbShareOk 'UNC SboxBridgeIpc'
        if ($RequireEditor) {
            Write-Check 'Green editor tunnel :9090' $health.tunnel9090Ok 'SSH forward to VENGEANCE chomnr'
        }
        else {
            Write-Check 'Green editor tunnel :9090' $health.tunnel9090Ok 'SSH forward to VENGEANCE chomnr' -Warning:(-not $health.tunnel9090Ok)
        }
        Write-Check 'Green mcp.json triple' $health.mcpTripleOk $health.mcpKeys
    }
    else {
        Write-Check 'Cornerman health probe' $false 'push Get-CornermanHealthProbe.ps1 via Sync-CornermanRebootScripts'
    }
}

if (-not $Quiet) { Write-Host '' ; Write-Host '--- MCP stack ---' -ForegroundColor Cyan }
Test-VengeanceMcpStack

if (-not $Quiet) {
    Write-Host ''
    if ($script:Fail -eq 0) {
        Write-Host "PASS - pre-launch checkup ($($script:Warn) warning(s))" -ForegroundColor Green
    }
    else {
        Write-Host "FAIL - $($script:Fail) blocker(s), $($script:Warn) warning(s)" -ForegroundColor Red
        Write-Host '  Fix: powershell -File lifepunch\scripts\Test-PreLaunchCheckup.ps1 -Fix' -ForegroundColor Yellow
        Write-Host '  Then: Start-SboxDxrpEditor.ps1' -ForegroundColor DarkGray
    }
    Write-Host ''
}

exit $(if ($script:Fail -eq 0) { 0 } else { 1 })
