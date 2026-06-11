<#
.SYNOPSIS
  Re-apply Cornerman headless settings every boot (power, SSH/RDP, network) — no password prompt.

.DESCRIPTION
  Idempotent maintenance run by scheduled tasks LifePunch-Cornerman-Headless-*.
  Enable-CornermanHeadless.ps1 registers those tasks; this script is copied to
  C:\lifepunch\cornerman\ on the box.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'

function Write-BootNote($m) {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $m"
    Add-Content -LiteralPath 'C:\lifepunch\cornerman\headless-boot.log' -Value $line -ErrorAction SilentlyContinue
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    Write-BootNote 'SKIP — not elevated'
    exit 0
}

New-Item -ItemType Directory -Force -Path 'C:\lifepunch\cornerman' | Out-Null
Write-BootNote 'START'

try {
    powercfg -change -standby-timeout-ac 0 | Out-Null
    powercfg -change -hibernate-timeout-ac 0 | Out-Null
    powercfg -change -disk-timeout-ac 0 | Out-Null
    powercfg -change -monitor-timeout-ac 30 | Out-Null
    powercfg -change -standby-timeout-dc 0 | Out-Null
    powercfg -change -hibernate-timeout-dc 0 | Out-Null
    powercfg /hibernate off | Out-Null
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0 | Out-Null
    powercfg /SETACTIVE SCHEME_CURRENT | Out-Null
    Write-BootNote 'powercfg OK'
}
catch {
    Write-BootNote "powercfg FAIL: $($_.Exception.Message)"
}

$pers = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
try {
    if (-not (Test-Path -LiteralPath $pers)) { New-Item -Path $pers -Force | Out-Null }
    Set-ItemProperty -Path $pers -Name NoLockScreen -Value 1 -Type DWord -Force
    Write-BootNote 'NoLockScreen OK'
}
catch {
    Write-BootNote "NoLockScreen FAIL: $($_.Exception.Message)"
}

foreach ($svc in 'sshd', 'TermService') {
    try {
        $s = Get-Service -Name $svc -ErrorAction Stop
        if ($s.StartType -ne 'Automatic') {
            Set-Service -Name $svc -StartupType Automatic -ErrorAction Stop
        }
        if ($s.Status -ne 'Running') {
            Start-Service -Name $svc -ErrorAction Stop
        }
        Write-BootNote "$svc OK"
    }
    catch {
        Write-BootNote "$svc FAIL: $($_.Exception.Message)"
    }
}

try {
    Get-NetConnectionProfile -ErrorAction Stop | Where-Object { $_.NetworkCategory -eq 'Public' } |
        ForEach-Object {
            Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private -ErrorAction Stop
            Write-BootNote "Network $($_.Name) Public -> Private"
        }
}
catch {
    Write-BootNote "Network profile FAIL: $($_.Exception.Message)"
}

# Tier-3 LM Studio (logon user only — skip SYSTEM AtStartup task)
if ($env:USERNAME -and $env:USERNAME -ne 'SYSTEM') {
    $lmsScript = 'C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1'
    if (Test-Path -LiteralPath $lmsScript) {
        try {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $lmsScript -WarmModel distill -Quiet
            Write-BootNote 'LM Studio distill warm OK'
        }
        catch {
            Write-BootNote "LM Studio FAIL: $($_.Exception.Message)"
        }
    }
    else {
        Write-BootNote 'LM Studio script missing (copy Start-CornermanLmStudio.ps1 to C:\lifepunch\cornerman\)'
    }

    $relayStarter = 'C:\Projects\cornerman-rag\Start-CornermanVoiceRelay.ps1'
    if (Test-Path -LiteralPath $relayStarter) {
        try {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $relayStarter
            Write-BootNote 'Voice relay start OK'
        }
        catch {
            Write-BootNote "Voice relay FAIL: $($_.Exception.Message)"
        }
    }
}

Write-BootNote 'DONE'
