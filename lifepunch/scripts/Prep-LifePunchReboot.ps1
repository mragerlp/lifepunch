<#
.SYNOPSIS
  Prep VENGEANCE, Cornerman, and lifepunchnet for a full machine reboot.

.DESCRIPTION
  Run on VENGEANCE before rebooting the LifePunch web. Stops stale voice windows,
  refreshes shortcuts, deploys Cornerman relay + ops pack over SSH, builds ops zip
  for lifepunchnet RDP handoff, and prints the elevated lifepunchnet one-liner.

  After all machines reboot:
    1. lifepunchnet - auto-boot :9000 / :9101 / :9102 (if Prep-LifePunchReboot-Lifepunchnet ran)
    2. Cornerman - on logon: Talk to Vengeance or VENGEANCE Start Day SSH-starts PTT
    3. VENGEANCE - double-click LifePunch Start Day

.EXAMPLE
  cd lifepunch\scripts
  powershell -ExecutionPolicy Bypass -File .\Prep-LifePunchReboot.ps1 -OpenLifepunchnetRdp
#>
[CmdletBinding()]
param(
    [string] $CornermanSsh = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }),
    [string] $CornermanIp = '192.168.1.227',
    [string] $LifepunchnetHost = '205.209.104.22',
    [string] $RemoteAddress = '71.250.46.224',
    [string] $VengeanceLanIp = '',
    [switch] $SkipStopVoice,
    [switch] $SkipCornerman,
    [switch] $SkipOpsUniform,
    [switch] $OpenLifepunchnetRdp
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
$OpsPack = Join-Path $RepoRoot 'lifepunch\branding\lifepunch-ops'
$ServerScripts = Join-Path $RepoRoot 'lifepunch\server\scripts'

function Write-Step($m) { Write-Host ''; Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Note($m) { Write-Host "    $m" -ForegroundColor DarkGray }
function Write-Pass($m) { Write-Host "    [OK] $m" -ForegroundColor Green }
function Write-Fail($m) { Write-Host "    [!!] $m" -ForegroundColor Yellow }

function Invoke-SshQuiet {
    param([string]$RemoteCommand)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & ssh -o BatchMode=yes -o ConnectTimeout=12 $CornermanSsh $RemoteCommand 2>$null
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    return $code
}

function Stop-StaleVoiceProcesses {
    $patterns = @(
        'start-vengeance-voice-watch', 'start-session-sync', 'start-server-host-watch',
        'watch-cornerman-voice', 'Start-CornermanVoiceRelay', 'Start-LifePunchDay'
    )
    $n = 0
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue | ForEach-Object {
        $cmd = $_.CommandLine
        if (-not $cmd) { return }
        foreach ($p in $patterns) {
            if ($cmd -like "*$p*") {
                Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
                $n++
                break
            }
        }
    }
    Get-CimInstance Win32_Process -Filter "Name='python.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match 'relay\.py' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue; $n++ }
    return $n
}

function Get-LocalLanIp {
    if ($VengeanceLanIp) { return $VengeanceLanIp.Trim() }
    $candidates = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -like '192.168.*' -and $_.PrefixOrigin -ne 'WellKnown' } |
        Select-Object -ExpandProperty IPAddress
    if ($candidates) { return $candidates[0] }
    return '192.168.1.236'
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  LIFEPUNCH REBOOT PREP - all nodes' -ForegroundColor Cyan
Write-Host '  At a glance after reboot: Start Day (tri-stack)' -ForegroundColor DarkGray
Write-Host '============================================================' -ForegroundColor Cyan

# --- VENGEANCE ---
Write-Step 'VENGEANCE - desk prep'
if (-not $SkipStopVoice) {
    $stopped = Stop-StaleVoiceProcesses
    Write-Note "Stopped $stopped stale voice/relay process(es)"
}

$watchCfg = Join-Path $Here 'server-host-watch.local.json'
if (Test-Path -LiteralPath $watchCfg) { Write-Pass 'server-host-watch.local.json present' }
else { Write-Fail 'Missing server-host-watch.local.json - copy .example + lifepunchnet token' }

Write-Note 'Refreshing desktop shortcuts (all tiers)...'
& (Join-Path $Here 'Install-LifePunchShortcutIcons.ps1')

if (-not $SkipOpsUniform) {
    $lanIp = Get-LocalLanIp
    $apply = Join-Path $OpsPack 'Apply-LifePunchOpsConsole.ps1'
    if (Test-Path -LiteralPath $apply) {
        Write-Note "Applying ops uniform (vengeance, LAN $lanIp)..."
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $apply -Machine vengeance -NodeIp $lanIp
    }
}

$zipScript = Join-Path $OpsPack 'Build-OpsDeployZip.ps1'
if (Test-Path -LiteralPath $zipScript) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $zipScript
    $zipPath = Join-Path (Split-Path -Parent $OpsPack) 'lifepunch-ops-deploy.zip'
    Write-Pass "Ops deploy zip: $zipPath"
}

# --- Cornerman ---
if (-not $SkipCornerman) {
    Write-Step "Cornerman - relay + shortcuts ($CornermanSsh)"
    $sshProbe = Invoke-SshQuiet 'powershell -NoProfile -NonInteractive -Command Write-Output ok'
    if ($sshProbe -ne 0) {
        Write-Fail "SSH to $CornermanSsh failed - RDP Cornerman and re-run prep later"
    }
    else {
        Write-Pass "SSH to $CornermanSsh"
        $ptt = Join-Path $Here 'cornerman-relay\Apply-CornermanPushToTalk.ps1'
        if (Test-Path -LiteralPath $ptt) {
            $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ptt -CornermanHost $CornermanSsh
            $ErrorActionPreference = $prev
            Write-Pass 'Cornerman PTT deploy'
        }
        $talkShortcut = Join-Path $Here 'Install-LifePunchTalkToVengeanceShortcut.ps1'
        if (Test-Path -LiteralPath $talkShortcut) {
            $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $talkShortcut
            $ErrorActionPreference = $prev
            Write-Pass 'Talk to Vengeance shortcuts'
        }
        if (-not $SkipOpsUniform) {
            Write-Note 'Copying ops pack to Cornerman...'
            Invoke-SshQuiet 'powershell -NoProfile -Command New-Item -ItemType Directory -Force -Path C:\lifepunch\branding' | Out-Null
            $zipPath = Join-Path (Split-Path -Parent $OpsPack) 'lifepunch-ops-deploy.zip'
            if (Test-Path -LiteralPath $zipPath) {
                & scp -o BatchMode=yes $zipPath "${CornermanSsh}:C:/lifepunch/branding/lifepunch-ops-deploy.zip" 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Invoke-SshQuiet 'powershell -NoProfile -Command Expand-Archive -LiteralPath C:\lifepunch\branding\lifepunch-ops-deploy.zip -DestinationPath C:\lifepunch\branding -Force' | Out-Null
                    $applyRemote = "powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\branding\lifepunch-ops\Apply-LifePunchOpsConsole.ps1 -Machine cornerman -NodeIp $CornermanIp"
                    Invoke-SshQuiet $applyRemote | Out-Null
                    Write-Pass 'Cornerman ops uniform applied'
                }
            }
        }
        $cmdCheck = Invoke-SshQuiet 'cmd /c if exist "C:\Projects\cornerman-rag\Talk to Vengeance.cmd" exit /b 0'
        if ($cmdCheck -eq 0) { Write-Pass 'Talk to Vengeance.cmd on Cornerman' }
        else { Write-Fail 'Talk to Vengeance.cmd missing - re-run Apply-CornermanPushToTalk' }

        Write-Note 'Cornerman headless boot tasks (needs elevated on-box)...'
        $bootInstall = Join-Path $Here 'Install-CornermanHeadlessBoot.ps1'
        $bootInvoke = Join-Path $Here 'Invoke-CornermanHeadlessBoot.ps1'
        if ((Test-Path -LiteralPath $bootInstall) -and (Test-Path -LiteralPath $bootInvoke)) {
            Invoke-SshQuiet 'powershell -NoProfile -Command New-Item -ItemType Directory -Force -Path C:\lifepunch\cornerman' | Out-Null
            & scp -o BatchMode=yes $bootInvoke "${CornermanSsh}:C:/lifepunch/cornerman/Invoke-CornermanHeadlessBoot.ps1" 2>$null
            & scp -o BatchMode=yes $bootInstall "${CornermanSsh}:C:/lifepunch/cornerman/Install-CornermanHeadlessBoot.ps1" 2>$null
            $bootRemote = 'powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Install-CornermanHeadlessBoot.ps1'
            if ((Invoke-SshQuiet $bootRemote) -eq 0) { Write-Pass 'Cornerman headless boot tasks' }
            else { Write-Fail 'Headless boot install needs RDP elevated: Install-CornermanHeadlessBoot.ps1' }
        }
    }
}

# --- lifepunchnet ---
Write-Step "lifepunchnet - RDP prep ($LifepunchnetHost)"
Write-Note 'SSH :22 not available from VENGEANCE - use RDP for on-box prep.'
Write-Host ''
Write-Host '  ON lifepunchnet (elevated PowerShell):' -ForegroundColor Yellow
Write-Host '    cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts' -ForegroundColor White
Write-Host "    powershell -ExecutionPolicy Bypass -File .\Prep-LifePunchReboot-Lifepunchnet.ps1 -RemoteAddress $RemoteAddress" -ForegroundColor White
Write-Host ''
Write-Host '  Copy ops zip via RDP:' -ForegroundColor Yellow
$zipOut = Join-Path (Split-Path -Parent $OpsPack) 'lifepunch-ops-deploy.zip'
Write-Host "    $zipOut" -ForegroundColor White
Write-Host '      -> C:\lifepunch\branding\lifepunch-ops-deploy.zip' -ForegroundColor DarkGray
Write-Host ''

if ($OpenLifepunchnetRdp) {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $rdpLnk = Join-Path $desktop 'lifepunchnet (RDP).lnk'
    if (Test-Path -LiteralPath $rdpLnk) {
        Start-Process -FilePath $rdpLnk
        Write-Pass 'Opened lifepunchnet (RDP)'
    }
    else {
        Write-Fail 'No lifepunchnet (RDP).lnk - run Install-LifePunchRemoteShortcuts.ps1'
    }
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Green
Write-Host '  REBOOT ORDER (recommended)' -ForegroundColor Green
Write-Host '============================================================' -ForegroundColor Green
Write-Host '  1. lifepunchnet - Prep-LifePunchReboot-Lifepunchnet (elevated), then reboot' -ForegroundColor White
Write-Host '  2. Cornerman - reboot' -ForegroundColor White
Write-Host '  3. VENGEANCE - reboot, then LifePunch Start Day' -ForegroundColor White
Write-Host ''
Write-Host '  Canon: lifepunch/docs/OPS_CLARITY_CHECKPOINT.md' -ForegroundColor DarkGray
Write-Host ''
