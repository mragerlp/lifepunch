# Reset Green clone to origin/main (read-only box — Red is source of truth).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Cornerman-Workflow.ps1')
if (-not (Test-CornermanSshReady)) { throw 'Cornerman SSH not ready' }
$r = Invoke-CornermanSshExec -ScriptBlock @'
Push-Location C:\Projects\lifepunch
git rebase --abort 2>$null
git fetch origin 2>&1
git reset --hard origin/main 2>&1
git clean -fd -- lifepunch/scripts 2>&1
git status -sb
git log -1 --oneline
Pop-Location
'@ -ConnectTimeout 90
Write-Host $r.Output
if ($r.ExitCode -ne 0) { exit $r.ExitCode }
