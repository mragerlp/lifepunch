<#
.SYNOPSIS
  Pull latest Cornerman idle session from Green for review on VENGEANCE.

.EXAMPLE
  powershell -File lifepunch\scripts\Pull-CornermanIdle.ps1
  powershell -File lifepunch\scripts\Pull-CornermanIdle.ps1 -SessionName 20260613-081744-menu-ui-2026-06-13
#>
[CmdletBinding()]
param(
    [string] $SessionName = '',
    [string] $SshTarget = '',
    [string] $LocalReviewRoot = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

function Get-CornermanIdleSessionNames {
    param([string] $Target)
    $listScript = @'
$root = 'C:\lifepunch\cornerman\idle\sessions'
if (-not (Test-Path -LiteralPath $root)) { Write-Output 'NO_SESSIONS'; exit 0 }
Get-ChildItem -LiteralPath $root -Directory | Sort-Object Name -Descending | Select-Object -First 10 -ExpandProperty Name
'@
    $r = Invoke-CornermanSshExec -ScriptBlock $listScript -SshTarget $Target
    if ($r.ExitCode -ne 0) { throw "SSH list failed: $($r.Output)" }
    @($r.Output -split "`n" | Where-Object {
            $_ -match '^\d{8}-\d{6}-'
        })
}

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not $LocalReviewRoot) {
    $od = Join-Path $env:USERPROFILE 'OneDrive\Lifepunch\cornerman-idle-review'
    $LocalReviewRoot = if (Test-Path -LiteralPath (Split-Path $od -Parent)) { $od } else { 'C:\lifepunch\cornerman-idle-review' }
}

$names = Get-CornermanIdleSessionNames -Target $SshTarget
if ($names.Count -eq 0) {
    Write-Host 'No idle sessions on Cornerman.' -ForegroundColor Yellow
    exit 0
}

$pick = if ($SessionName) {
    if ($names -notcontains $SessionName) { throw "Session not found: $SessionName. Available: $($names -join ', ')" }
    $SessionName
} else {
    $names[0]
}

Write-Host "Pulling idle session: $pick" -ForegroundColor Cyan
$dest = Join-Path $LocalReviewRoot $pick
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$remoteRoot = "C:\lifepunch\cornerman\idle\sessions\$pick"
$listFilesScript = @"
`$root = '$remoteRoot'
if (-not (Test-Path -LiteralPath `$root)) { Write-Output 'ROOT_MISSING'; exit 1 }
Get-ChildItem -LiteralPath `$root -Recurse -File | ForEach-Object {
  `$_.FullName.Substring(`$root.Length + 1)
}
"@
$lr = Invoke-CornermanSshExec -ScriptBlock $listFilesScript -SshTarget $SshTarget
if ($lr.Output -match 'ROOT_MISSING') { throw "Idle session missing on Green: $pick" }

$relFiles = @($lr.Output -split "`n" | Where-Object { $_.Trim() })
$pulled = 0
foreach ($rel in $relFiles) {
    $remoteFile = Join-Path $remoteRoot $rel
    $fetch = "Get-Content -LiteralPath '$remoteFile' -Raw -Encoding UTF8"
    $fr = Invoke-CornermanSshExec -ScriptBlock $fetch -SshTarget $SshTarget
    if (-not $fr.Output) { continue }
    $local = Join-Path $dest $rel
    $parent = Split-Path $local -Parent
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    Set-Content -LiteralPath $local -Value $fr.Output -Encoding utf8
    $pulled++
}

# Mirror key outbox pings for the same session label
$outboxFiles = @(
    'IDLE_READY.txt',
    'to-vengeance-idle-menu-ui-2026-06-13.txt',
    'MENU_SCSS_AUDIT.txt',
    'MENU_PLAYTEST_RESULT.txt'
)
$outboxDest = Join-Path $dest 'outbox-mirror'
New-Item -ItemType Directory -Force -Path $outboxDest | Out-Null
foreach ($name in $outboxFiles) {
    $p = "C:\lifepunch\cornerman\outbox\$name"
    $fetch = "if (Test-Path -LiteralPath '$p') { Get-Content -LiteralPath '$p' -Raw -Encoding UTF8 }"
    $fr = Invoke-CornermanSshExec -ScriptBlock $fetch -SshTarget $SshTarget
    if ($fr.Output) {
        Set-Content -LiteralPath (Join-Path $outboxDest $name) -Value $fr.Output -Encoding utf8
    }
}

Write-Host "Pulled $pulled file(s) to: $dest" -ForegroundColor Green
if (Test-Path -LiteralPath (Join-Path $dest 'MANIFEST.txt')) {
    Get-Content -LiteralPath (Join-Path $dest 'MANIFEST.txt')
}
