<#
.SYNOPSIS
  Watch MCP + Tier-3 connectivity during work; toast when anything drops on Red or Green.

.DESCRIPTION
  VENGEANCE-only: run on Red while you work (or via Start-SboxDxrpEditor.ps1).
  Toasts fire on this machine only — Cornerman never gets Windows notifications.
  Notifies on disconnect edges only.

.EXAMPLE
  powershell -File Watch-CvlConnectivity.ps1
  powershell -File Watch-CvlConnectivity.ps1 -IntervalSeconds 30 -FixOnDown
#>
[CmdletBinding()]
param(
    [int] $IntervalSeconds = 30,
    [string] $SshTarget = '',
    [switch] $FixOnDown,
    [switch] $Quiet
)

$ErrorActionPreference = 'Continue'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'LifePunch-OpsNode.ps1')
. (Join-Path $Here 'Send-LifePunchToast.ps1')

if (-not (Test-IsVengeanceWorkstation)) {
    Write-Host 'Watch-CvlConnectivity is VENGEANCE-only (no toasts on Cornerman/lifepunchnet).' -ForegroundColor Yellow
    exit 0
}

# Single instance — do not stack watchers (each spawns a visible/hidden terminal loop).
$selfPid = $PID
$dupes = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object {
        $_.ProcessId -ne $selfPid -and
        $_.CommandLine -and
        $_.CommandLine -match 'Watch-CvlConnectivity\.ps1'
    })
if ($dupes.Count -gt 0) {
    Write-Host "Watch-CvlConnectivity already running (pid $($dupes[0].ProcessId)). Exiting." -ForegroundColor Yellow
    exit 0
}

$statePath = Join-Path $env:LOCALAPPDATA 'LifePunch\cvl-connectivity-state.json'
New-Item -ItemType Directory -Force -Path (Split-Path $statePath -Parent) | Out-Null

$prevDown = @()
if (Test-Path -LiteralPath $statePath) {
    try {
        $saved = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
        if ($saved.down) { $prevDown = @($saved.down) }
    }
    catch { }
}

function Write-Watch([string]$m, [string]$Color = 'Gray') {
    if (-not $Quiet) { Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $m" -ForegroundColor $Color }
}

Write-Watch 'CVL connectivity watch started (Ctrl+C to stop)' 'Cyan'
Write-Watch "Poll every ${IntervalSeconds}s - toast on MCP/Tier-3 disconnect" 'DarkGray'

while ($true) {
    $jsonLine = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Get-CvlConnectivityStatus.ps1') -SshTarget $SshTarget 2>$null
    if (-not $jsonLine) {
        Write-Watch 'Probe failed' 'Yellow'
        Start-Sleep -Seconds $IntervalSeconds
        continue
    }

    $status = $jsonLine | ConvertFrom-Json
    $down = @($status.down)
    $newDown = @($down | Where-Object { $_ -notin $prevDown })
    $recovered = @($prevDown | Where-Object { $_ -notin $down })

    if ($newDown.Count -gt 0) {
        $msg = ($newDown -join '; ')
        if ($msg.Length -gt 180) { $msg = $msg.Substring(0, 177) + '...' }
        Send-LifePunchToast -Title 'CVL MCP/Tier-3 DOWN' -Message $msg -Tone 'error'
        Write-Watch "DOWN: $msg" 'Red'

        if ($FixOnDown) {
            Write-Watch 'Auto-fix (local MCP only, no Green warm)...' 'Yellow'
            $mcpInstall = Join-Path $Here 'Install-VengeanceMcpStack.ps1'
            if (Test-Path -LiteralPath $mcpInstall) {
                & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $mcpInstall -SkipProbe | Out-Null
            }
        }
    }

    if ($recovered.Count -gt 0) {
        $msg = ($recovered -join '; ')
        Send-LifePunchToast -Title 'CVL connectivity restored' -Message $msg -Tone 'default'
        Write-Watch "OK: $msg" 'Green'
    }

    if ($status.allOk -and $newDown.Count -eq 0 -and $recovered.Count -eq 0 -and -not $Quiet) {
        Write-Watch 'All MCP + Tier-3 links OK' 'DarkGray'
    }

    $prevDown = $down
    @{ ts = (Get-Date).ToUniversalTime().ToString('o'); down = $down; allOk = $status.allOk } |
        ConvertTo-Json -Compress | Set-Content -LiteralPath $statePath -Encoding UTF8

    Start-Sleep -Seconds $IntervalSeconds
}
