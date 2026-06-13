# Push third-party separation audit + day prep to Green outbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')
$files = @(
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\BITCOINMINING_THIRDPARTY_SEPARATION_AUDIT.md'; out = 'BITCOINMINING_THIRDPARTY_SEPARATION_AUDIT.md' },
    @{ rel = 'lifepunch\docs\handoff\TODAY_BITCOIN_HACKER_PREP.md'; out = 'TODAY_BITCOIN_HACKER_PREP.md' }
)
foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    $text = Get-Content -LiteralPath $src -Raw
    Push-CornermanText -Path "C:\lifepunch\cornerman\outbox\$($f.out)" -Text $text | Out-Null
    Write-Host "OK outbox\$($f.out)" -ForegroundColor Green
}
