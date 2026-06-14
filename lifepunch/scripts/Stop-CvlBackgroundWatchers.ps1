<#
.SYNOPSIS
  Stop hidden/minimized CVL background PowerShell watchers (connectivity poll, stuck fix passes).

.EXAMPLE
  powershell -File lifepunch\scripts\Stop-CvlBackgroundWatchers.ps1
#>
[CmdletBinding()]
param([switch] $Quiet)

$patterns = @(
    'Watch-CvlConnectivity\.ps1',
    'Test-PreLaunchCheckup\.ps1.*-Fix',
    'Fix-CornermanLmServe\.ps1',
    'Sync-CornermanRebootScripts\.ps1'
)

$stopped = [System.Collections.Generic.List[string]]::new()
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    ForEach-Object {
        $cmd = $_.CommandLine
        if (-not $cmd) { return }
        foreach ($pat in $patterns) {
            if ($cmd -match $pat) {
                try {
                    Stop-Process -Id $_.ProcessId -Force -ErrorAction Stop
                    $stopped.Add("pid $($_.ProcessId) ($pat)")
                }
                catch {
                    if (-not $Quiet) { Write-Host "skip pid $($_.ProcessId): $($_.Exception.Message)" -ForegroundColor Yellow }
                }
                break
            }
        }
    }

if ($stopped.Count -eq 0) {
    if (-not $Quiet) { Write-Host 'No CVL background watchers running.' -ForegroundColor DarkGray }
}
else {
    foreach ($s in $stopped) {
        if (-not $Quiet) { Write-Host "Stopped $s" -ForegroundColor Green }
    }
}
