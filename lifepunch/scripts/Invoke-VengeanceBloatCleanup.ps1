<#
.SYNOPSIS
  Stop wrong-node / heavy apps on VENGEANCE that compete with Cursor + s&box.

.DESCRIPTION
  Safe auto-quit only for apps documented in REMOTE_APPS_LIFEPUNCHNET.md and
  CORNERMAN_MODEL_ROUTING.md as off-Red. Does NOT touch services, s&box, Cursor, Steam.

.EXAMPLE
  powershell -File Invoke-VengeanceBloatCleanup.ps1
  powershell -File Invoke-VengeanceBloatCleanup.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Continue'

$targets = @(
    @{ Label = 'Discord'; Match = '(?i)^Discord$' }
    @{ Label = 'Spotify'; Match = '(?i)^Spotify$' }
    @{ Label = 'Slack'; Match = '(?i)^slack$' }
    @{ Label = 'iTunes'; Match = '(?i)^iTunes$' }
    @{ Label = 'LM Studio GUI'; Match = '(?i)LM Studio' }
    @{ Label = 'Ollama'; Match = '(?i)^ollama$' }
)

$stopped = [System.Collections.Generic.List[string]]::new()

foreach ($t in $targets) {
    $procs = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match $t.Match })
    foreach ($p in $procs) {
        $mb = [math]::Round($p.WorkingSet64 / 1MB, 0)
        if ($PSCmdlet.ShouldProcess("$($p.ProcessName) (pid $($p.Id), ${mb}MB)", "Stop wrong-node app on VENGEANCE")) {
            try {
                $p.CloseMainWindow() | Out-Null
                Start-Sleep -Milliseconds 400
                if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction Stop }
                $stopped.Add("$($t.Label) (${mb}MB)")
            }
            catch {
                Write-Host "  SKIP $($p.ProcessName): $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
}

# Extra stale s&box editors (keep newest by start time)
$sbox = @(Get-Process -Name 'sbox' -ErrorAction SilentlyContinue | Sort-Object StartTime -Descending)
if ($sbox.Count -gt 1) {
    foreach ($extra in $sbox | Select-Object -Skip 1) {
        if ($PSCmdlet.ShouldProcess("sbox pid $($extra.Id)", 'Stop duplicate s&box instance')) {
            try {
                Stop-Process -Id $extra.Id -Force -ErrorAction Stop
                $stopped.Add("stale s&box pid $($extra.Id)")
            }
            catch { }
        }
    }
}

if ($stopped.Count -eq 0) {
    Write-Host 'VENGEANCE bloat cleanup: nothing to stop' -ForegroundColor DarkGray
}
else {
    Write-Host 'VENGEANCE bloat cleanup stopped:' -ForegroundColor Green
    $stopped | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
}
