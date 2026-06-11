<#
.SYNOPSIS
  Apply Cornerman full-performance settings and warm Tier-3 (LM Studio).

.DESCRIPTION
  Idempotent. Safe to run from VENGEANCE via Send-CornermanWorkflow -Action FullPerformance.
  Elevated sections (power plan, CPU throttle) run when admin/SYSTEM; LM Studio runs in user context.

  Variable Graphics Memory (~48 GB) still requires AMD Adrenalin GUI once per box — this script
  logs a reminder if the Vulkan device reports low heap (heuristic only).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Invoke-CornermanFullPerformance.ps1
#>
[CmdletBinding()]
param(
    [ValidateSet('distill', 'coder', 'all', 'none')]
    [string] $WarmModel = 'all',
    [switch] $SkipLmStudio,
    [switch] $SkipVoiceRelay,
    [switch] $Quiet
)

$ErrorActionPreference = 'Continue'
$logPath = 'C:\lifepunch\cornerman\performance.log'
$onBoxDir = 'C:\lifepunch\cornerman'

function Write-Perf([string]$m) {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $m"
    New-Item -ItemType Directory -Force -Path $onBoxDir | Out-Null
    Add-Content -LiteralPath $logPath -Value $line -ErrorAction SilentlyContinue
    if (-not $Quiet) { Write-Host $line }
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

Write-Perf "START (admin=$isAdmin user=$env:USERNAME)"

if ($isAdmin) {
    try {
        $ultimate = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
        $highPerf = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
        $plans = @(powercfg /list 2>$null)
        $activeGuid = $highPerf
        if ($plans -match $ultimate) {
            $activeGuid = $ultimate
        }
        powercfg /setactive $activeGuid | Out-Null
        powercfg /SETACVALUEINDEX $activeGuid SUB_PROCESSOR PROCTHROTTLEMIN 100 | Out-Null
        powercfg /SETACVALUEINDEX $activeGuid SUB_PROCESSOR PROCTHROTTLEMAX 100 | Out-Null
        powercfg /SETACVALUEINDEX $activeGuid SUB_PROCESSOR PERFBOOSTMODE 2 | Out-Null
        powercfg /SETACTIVE $activeGuid | Out-Null
        powercfg -change -standby-timeout-ac 0 | Out-Null
        powercfg -change -hibernate-timeout-ac 0 | Out-Null
        powercfg -change -disk-timeout-ac 0 | Out-Null
        powercfg -change -monitor-timeout-ac 30 | Out-Null
        powercfg -change -standby-timeout-dc 0 | Out-Null
        powercfg -change -hibernate-timeout-dc 0 | Out-Null
        powercfg /hibernate off | Out-Null
        powercfg /SETACVALUEINDEX $activeGuid SUB_NONE CONSOLELOCK 0 | Out-Null
        powercfg /SETACTIVE $activeGuid | Out-Null
        Write-Perf "power plan OK ($activeGuid)"
    }
    catch {
        Write-Perf "power plan FAIL: $($_.Exception.Message)"
    }

    foreach ($svc in 'sshd', 'TermService') {
        try {
            $s = Get-Service -Name $svc -ErrorAction Stop
            if ($s.StartType -ne 'Automatic') { Set-Service -Name $svc -StartupType Automatic -ErrorAction Stop }
            if ($s.Status -ne 'Running') { Start-Service -Name $svc -ErrorAction Stop }
            Write-Perf "$svc OK"
        }
        catch {
            Write-Perf "$svc FAIL: $($_.Exception.Message)"
        }
    }
}
else {
    Write-Perf 'SKIP power/services — not elevated (trigger Headless-Startup task from Red)'
}

if ($env:USERNAME -and $env:USERNAME -ne 'SYSTEM' -and -not $SkipLmStudio) {
    $lmsScript = Join-Path $onBoxDir 'Start-CornermanLmStudio.ps1'
    if (Test-Path -LiteralPath $lmsScript) {
        try {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $lmsScript -WarmModel $WarmModel -Quiet
            Write-Perf "LM Studio warm OK ($WarmModel)"
        }
        catch {
            Write-Perf "LM Studio FAIL: $($_.Exception.Message)"
        }
    }
    else {
        Write-Perf 'LM Studio script missing at C:\lifepunch\cornerman\'
    }

    if (-not $SkipVoiceRelay) {
        $relayStarter = 'C:\Projects\cornerman-rag\Start-CornermanVoiceRelay.ps1'
        if (Test-Path -LiteralPath $relayStarter) {
            try {
                & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $relayStarter
                Write-Perf 'Voice relay start OK'
            }
            catch {
                Write-Perf "Voice relay FAIL: $($_.Exception.Message)"
            }
        }
    }
}

Write-Perf 'DONE'
if (-not $Quiet) {
    Write-Host ''
    Write-Host 'Cornerman full-performance pass complete.' -ForegroundColor Cyan
    Write-Host "  Log: $logPath" -ForegroundColor DarkGray
    Write-Host '  VGM: AMD Adrenalin > Performance > Tuning > Variable Graphics Memory > max (~48 GB)' -ForegroundColor DarkGray
}
