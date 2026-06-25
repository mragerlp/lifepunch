<#
.SYNOPSIS
  First-priority wiring: Cornerman sbox MCP + cornerman-lm + SMB bridge IPC.

.DESCRIPTION
  From VENGEANCE (Red):
    1. Ensure SboxBridgeIpc SMB share
    2. Push Map + LM scripts to Green
    3. Refresh Cornerman mcp.json (sbox UNC + cornerman-lm localhost)
    4. Warm LM Studio on Green
    5. Sync SSH IPC mirror to Green (fallback)
  6. Headless SMB map (default) via OneDrive secret + Ensure/Map on Green

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Connect-CornermanBridge.ps1
  powershell -File lifepunch\scripts\Connect-CornermanBridge.ps1 -MirrorOnly
  powershell -File lifepunch\scripts\Initialize-VengeanceSmbSecret.ps1 -VerifyMap
#>
[CmdletBinding()]
param(
    [switch] $SkipLmWarm,
    [switch] $SkipBridgeSync,
    [switch] $MirrorOnly,
    [switch] $TrySmbMap,
    [switch] $PromptForPassword,
    [string] $SshTarget = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$null = Repair-VengeanceSmbPasswordFile
$useSmbMap = -not $MirrorOnly
if ($PSBoundParameters.ContainsKey('TrySmbMap')) {
    $useSmbMap = [bool]$TrySmbMap
}

$onBox = 'C:\lifepunch\cornerman'
$hostsPath = Join-Path $Here 'remote-hosts.json'
$cornermanIp = '192.168.1.229'
if (Test-Path -LiteralPath $hostsPath) {
    $h = Get-Content -LiteralPath $hostsPath -Raw | ConvertFrom-Json
    if ($h.cornerman.host) { $cornermanIp = [string]$h.cornerman.host }
}

function Write-Step([string]$msg) {
    Write-Host ''
    Write-Host "== $msg" -ForegroundColor Cyan
}

function Push-OnBoxScript([string]$Name) {
    $local = Join-Path $Here $Name
    if (-not (Test-Path -LiteralPath $local)) { throw "Missing $local" }
    Push-CornermanFile -Path (Join-Path $onBox $Name) -FileBytes ([IO.File]::ReadAllBytes($local)) -SshTarget $SshTarget | Out-Null
    Write-Host "  OK $Name" -ForegroundColor Green
}

Write-Step 'VENGEANCE bridge share'
$ipcDir = Join-Path $env:TEMP 'sbox-bridge-ipc'
if (-not (Test-Path -LiteralPath $ipcDir)) {
    New-Item -ItemType Directory -Force -Path $ipcDir | Out-Null
}
$share = Get-SmbShare -Name 'SboxBridgeIpc' -ErrorAction SilentlyContinue
if (-not $share -or $share.Path -ne $ipcDir) {
    Write-Host '  WARN: run elevated once on VENGEANCE:' -ForegroundColor Yellow
    Write-Host "  net share SboxBridgeIpc=`"$ipcDir`" /GRANT:Everyone,FULL" -ForegroundColor DarkGray
}
else {
    Write-Host "  OK SboxBridgeIpc -> $ipcDir" -ForegroundColor Green
}
$vengeanceHost = $env:COMPUTERNAME
$uncIpc = "\\$vengeanceHost\SboxBridgeIpc"

Write-Step 'Push Green on-box scripts'
Push-OnBoxScript 'Map-CornermanBridgeShare.ps1'
Push-OnBoxScript 'Ensure-CornermanBridgeShare.ps1'
Push-OnBoxScript 'Start-CornermanLmStudio.ps1'
Push-OnBoxScript 'Start-CornermanSboxEditorTunnel.ps1'

Write-Step 'Refresh Cornerman mcp.json'
& (Join-Path $Here 'Install-CornermanSboxBridgeMcp.ps1') -SshTarget $SshTarget -SkipShare -SkipLmClone

if (-not $SkipLmWarm) {
    Write-Step 'Warm LM Studio on Green'
    & (Join-Path $Here 'Send-CornermanWorkflow.ps1') -Action WarmDistill -SshTarget $SshTarget -NoHubIngest
}

if (-not $SkipBridgeSync) {
    Write-Step 'SSH IPC mirror to Green (SMB-free)'
    $mirror = Join-Path $Here 'Sync-CornermanBridgeIpcMirror.ps1'
    if (-not (Test-Path -LiteralPath $mirror)) { throw "Missing $mirror" }
    # Mirror sync only — do NOT -UpdateMcpJson (SMB UNC is primary; SSH mirror is stale fallback).
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $mirror -SshTarget $SshTarget

    $watch = Join-Path $Here 'Start-CornermanBridgeIpcMirrorWatch.ps1'
    if (Test-Path -LiteralPath $watch) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $watch -Background
    }

    if ($useSmbMap) {
        Write-Step 'Headless native SMB map'
        $password = Get-VengeanceSmbPassword
        if ($PromptForPassword) {
            $sec = Read-Host 'VENGEANCE\jared password (for Green SMB map)' -AsSecureString
            $savedPath = Set-VengeanceSmbPassword -Password $sec
            Write-Host "  Saved $savedPath" -ForegroundColor DarkGray
            $password = Get-VengeanceSmbPassword
        }
        if (-not $password) {
            throw 'Missing vengeance-smb.password — run: powershell -File lifepunch\scripts\Initialize-VengeanceSmbBridgeUser.ps1'
        }
        $null = Sync-VengeanceSmbPasswordToCornerman -SshTarget $SshTarget

        & (Join-Path $Here 'Install-CornermanBridgeShareMapTask.ps1') -SshTarget $SshTarget -RunNow

        if (-not (Test-CornermanBridgeShareReachable -SshTarget $SshTarget)) {
            Write-Host '  NOTE: SMB UNC not visible from SSH batch session (expected). mcp.json -> UNC; map in Green desktop session.' -ForegroundColor Yellow
            Write-Host '  On Green: Map-CornermanBridgeShare.ps1 then Cursor Reload Window.' -ForegroundColor DarkGray
        }
        else {
            Write-Host '  OK Cornerman SMB bridge (interactive session)' -ForegroundColor Green
        }
        & (Join-Path $Here 'Install-CornermanSboxBridgeMcp.ps1') -SshTarget $SshTarget -SkipShare -SkipLmClone
    }
}

Write-Step 'Close LM Studio GUI on Green (headless lms serve stays)'
$closeGui = Join-Path $Here 'Close-CornermanLmStudioGui.ps1'
if (Test-Path -LiteralPath $closeGui) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $closeGui -SshTarget $SshTarget -Quiet
}

Write-Step 'Probe'
$lmOk = $false
$lmModels = @()
try {
    $lmModels = (Invoke-RestMethod -Uri "http://${cornermanIp}:1234/v1/models" -TimeoutSec 8).data.id
    $lmOk = $true
}
catch { }

$probe = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
`$statusPath = Join-Path '$uncIpc' 'status.json'
`$shareOk = Test-Path -LiteralPath '$uncIpc'
`$statusOk = Test-Path -LiteralPath `$statusPath
`$hb = 'n/a'
if (`$statusOk) {
  try { `$hb = (Get-Content -LiteralPath `$statusPath -Raw | ConvertFrom-Json).heartbeat } catch { `$hb = 'parse-fail' }
}
Write-Output "smb_share=`$shareOk status_json=`$statusOk heartbeat=`$hb"
"@ -ConnectTimeout 20

Write-Host "  LM Studio ($cornermanIp:1234): $(if ($lmOk) { 'OK — ' + ($lmModels -join ', ') } else { 'FAIL' })" -ForegroundColor $(if ($lmOk) { 'Green' } else { 'Red' })
Write-Host "  Green SMB probe: $($probe.Output)" -ForegroundColor $(if ($probe.Output -match 'status_json=True') { 'Green' } else { 'Yellow' })

Write-Host ''
Write-Host 'LM watchdog (once, elevated on Green): Send-CornermanWorkflow.ps1 -Action InstallLmWatchdog' -ForegroundColor DarkGray
Write-Host 'Done. On Green: restart Cursor -> MCP sbox + sbox-editor + cornerman-lm.' -ForegroundColor Cyan
Write-Host 'Green dual-stack: SSH mirror sbox + reverse tunnel for sbox-editor.' -ForegroundColor DarkGray
Write-Host 'VENGEANCE s&box editor must stay open for both MCP servers.' -ForegroundColor DarkGray
