# CVL handoff baton emitter (VENGEANCE / Red) - git-based signal bus.
# Rewrites the LATEST baton in lifepunch/docs/handoff/CVL_RELAY_BATON.md (archiving the prior one to
# HISTORY), prints the baton for copy/paste, and optionally drops a git-synced to-<node>-*.txt signal
# into cornerman-outbox/. Complements Send-CornermanWorkflow.ps1 (live SSH work transport).
# Does NOT git commit - the owner commit-gate holds (propose scope, then Bloodwave GO).
# NOTE: keep this file pure ASCII; the box-drawing bar is generated at runtime (PS 5.1 reads .ps1 as ANSI).

[CmdletBinding()]
param(
    [string] $From   = 'Red/Cursor/Auto',
    [string] $Lane   = 'LIFEPUNCH lpbitcoin',
    [string] $Did    = '',
    [string] $State  = 'PLAN ONLY',
    [string] $Next   = '',
    [string] $To     = 'Bloodwave GO',
    [string] $Paste  = 'lifepunch/docs/CVL_AGENT_ONBOARDING.md',
    [string] $Commit = 'none',
    [ValidateSet('', 'cornerman', 'vengeance', 'mac')]
    [string] $Signal = '',
    [switch] $Print
)

$ErrorActionPreference = 'Stop'

$handoffDir = Join-Path $PSScriptRoot '..\docs\handoff'
$batonPath  = (Resolve-Path (Join-Path $handoffDir 'CVL_RELAY_BATON.md')).Path
$stamp      = Get-Date -Format 'yyyy-MM-dd HH:mm'
$utf8NoBom  = New-Object System.Text.UTF8Encoding($false)

if (-not $Did)  { Write-Warning 'No -Did supplied - the baton DID line will be empty.' }
if (-not $Next) { Write-Warning 'No -Next supplied - the baton NEXT line will be empty.' }

# Box-drawing bar generated at runtime so the source stays ASCII.
$bar = ([char]0x2500).ToString() * 2

$baton = @"
$bar CVL HANDOFF $bar
FROM:   $From
LANE:   $Lane
DID:    $Did
STATE:  $State
NEXT:   $Next
TO:     $To
PASTE:  $Paste
COMMIT: $Commit
"@

$fenceOpen  = '```text'
$fenceClose = '```'
$startM = '<!-- CVL_BATON_LATEST_START -->'
$endM   = '<!-- CVL_BATON_LATEST_END -->'
$histM  = '<!-- CVL_BATON_HISTORY_START -->'

$content = [System.IO.File]::ReadAllText($batonPath, $utf8NoBom)
$si = $content.IndexOf($startM)
$ei = $content.IndexOf($endM)
$hi = $content.IndexOf($histM)
if (($si -lt 0) -or ($ei -lt 0) -or ($hi -lt 0)) {
    throw "CVL baton markers not found in $batonPath - restore START/END/HISTORY markers first."
}

# Archive current LATEST (between markers) into HISTORY, most recent first.
$prevStart = $si + $startM.Length
$prevBlock = $content.Substring($prevStart, $ei - $prevStart).Trim()
$histEntry = "`n`n### $stamp`n$prevBlock"

# Replace between LATEST markers with the new baton (markers stay in place).
$newBody = "`n`n$fenceOpen`n$baton`n$fenceClose`n`n"
$content = $content.Substring(0, $prevStart) + $newBody + $content.Substring($ei)

# Insert the archived block right after the HISTORY marker.
$hi = $content.IndexOf($histM)
$content = $content.Substring(0, $hi + $histM.Length) + $histEntry + $content.Substring($hi + $histM.Length)

if (-not $Print) {
    [System.IO.File]::WriteAllText($batonPath, $content, $utf8NoBom)
    Write-Host "Updated baton  -> $batonPath" -ForegroundColor Green
}

if ($Signal) {
    $fileStamp = Get-Date -Format 'yyyy-MM-dd_HHmm'
    $sigPath = Join-Path $handoffDir ("cornerman-outbox\to-{0}-handoff-{1}.txt" -f $Signal, $fileStamp)
    if (-not $Print) {
        [System.IO.File]::WriteAllText($sigPath, $baton, $utf8NoBom)
        Write-Host "Signal dropped -> $sigPath" -ForegroundColor Green
    }
}

Write-Host ''
Write-Host $baton
Write-Host ''
Write-Host 'Owner gate: propose this scope, then on GO -> git add/commit/push the baton (+signal).' -ForegroundColor Yellow
