$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$src = Join-Path $RepoRoot 'lifepunch\docs\handoff\cornerman-outbox\OWNER_ASK_LOUD_CLICK_TYPING.txt'
$text = Get-Content -LiteralPath $src -Raw
Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\OWNER_ASK_LOUD_CLICK_TYPING.txt' -Text $text
Write-Host 'OK inbox\OWNER_ASK_LOUD_CLICK_TYPING.txt' -ForegroundColor Green
