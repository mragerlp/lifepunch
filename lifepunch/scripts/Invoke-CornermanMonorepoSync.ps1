# Stash dirty Green clone and pull --rebase (read-only box).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Cornerman-Workflow.ps1')
if (-not (Test-CornermanSshReady)) { throw 'Cornerman SSH not ready' }
$r = Invoke-CornermanSshExec -ScriptBlock @'
$root = 'C:\Projects\lifepunch'
if (-not (Test-Path -LiteralPath (Join-Path $root '.git'))) { throw 'no clone' }
Push-Location $root
$dirty = git status --porcelain
if ($dirty) { git stash push -m 'cornerman-pre-pull' 2>&1 }
git fetch origin 2>&1
git pull --rebase 2>&1
git log -1 --oneline
Pop-Location
'@ -ConnectTimeout 120
Write-Host $r.Output
if ($r.ExitCode -ne 0) { exit $r.ExitCode }
