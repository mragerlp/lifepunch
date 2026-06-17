# Push full ModelDoc greenfield handoff bundle to Cornerman inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    'lifepunch\addons\docs\briefs\CORNERMAN_MODELDOC_GREENFIELD_TASK.md',
    'lifepunch\addons\config\package-staging.json',
    'lifepunch\addons\docs\PACKAGE_STAGING_LAYOUT.md',
    'lifepunch\addons\docs\MODEL_FOUNDATION_PASS.md',
    'lifepunch\addons\docs\LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md',
    'lifepunch\docs\handoff\cornerman-inbox\DESKTOP_ADDONS_INVENTORY_2026-06-17.json',
    'lifepunch\docs\handoff\cornerman-inbox\DESKTOP_ADDONS_INVENTORY_2026-06-17.md',
    'lifepunch\docs\handoff\cornerman-inbox\REPO_ADDONS_SNAPSHOT_2026-06-17.json'
)

foreach ($rel in $files) {
    $src = Join-Path $RepoRoot $rel
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Host "SKIP missing $rel" -ForegroundColor Yellow
        continue
    }
    $name = Split-Path $src -Leaf
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$name" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$name" -ForegroundColor Green
}

# Also push the brief under its canonical name if filename differs
$briefSrc = Join-Path $RepoRoot 'lifepunch\addons\docs\briefs\CORNERMAN_MODELDOC_GREENFIELD_TASK.md'
Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_MODELDOC_GREENFIELD_TASK.md' -Text (Get-Content -LiteralPath $briefSrc -Raw)

$directive = @{
    id      = ('full-addons-handoff-{0}' -f (Get-Date -Format 'yyyyMMdd-HHmm'))
    action  = 'Inbox'
    message = @'
OWNER DESKTOP ROOT (canonical): C:\Users\jared\OneDrive\Desktop\UPLOAD READY ADDONS\addons
LifePunch package tree: ...\addons\lifepunch\{lpPackage}\{entitySlot}\

Red pushed DESKTOP_ADDONS_INVENTORY + REPO_ADDONS_SNAPSHOT + package-staging.json to inbox.
Scope = ENTIRE lifepunch lp* portfolio (10 packages, 42 entity slots) — NOT weapons-only.

Green: use inbox inventory as Desktop truth (Green cannot read Red OneDrive live).
Work order = brief CORNERMAN_MODELDOC_GREENFIELD_TASK.md sections 1-10.
Deliver full outbox rollup + per-package material-map drafts where FBX exists.
Future ship barrier = DXRP portal upload (prepare-publish.ps1 + _c) — document in P2 section only.
'@
    execute = $false
} | ConvertTo-Json -Compress

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\cornerman-inbox-directive.json' -Text $directive
Write-Host 'OK inbox\cornerman-inbox-directive.json' -ForegroundColor Green
