# Push lifepunch.ulx staff menu fix task to Cornerman inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_STAFF_MENU_TASK.md'; inbox = 'CORNERMAN_STAFF_MENU_TASK.md' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\adminmenu\StaffMenu.razor'; inbox = 'StaffMenu.razor' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\adminmenu\StaffMenu.razor.scss'; inbox = 'StaffMenu.razor.scss' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\adminmenu\StaffMenuHost.cs'; inbox = 'StaffMenuHost.cs' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\adminmenu\StaffMenuActions.cs'; inbox = 'StaffMenuActions.cs' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\BitminerTerminal.razor.scss'; inbox = 'BITMINER_GRADIENT_FIX_REFERENCE.scss' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-staff-menu.txt'; inbox = 'to-cornerman-staff-menu.txt' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$($f.inbox)" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'staff-menu-fix-2026-06-11'
    issued     = (Get-Date -Format 'yyyy-MM-dd')
    priority   = 'P0'
    lane       = 'cornerman'
    modelHint  = 'WarmCoder for SCSS; WarmDistill for Hit Shapes notes'
    title      = 'lifepunch.ulx — staff menu SCSS fix + Hit Shapes study'
    summary    = 'Remove 7 linear-gradient rules from StaffMenu.razor.scss (s&box UI rejects them). Output patched scss to outbox. Optional Hit Shapes radial UX notes.'
    primaryDoc = 'CORNERMAN_STAFF_MENU_TASK.md'
    tasks      = @(
        @{ order = 0; id = 'scss-gradients'; doc = 'CORNERMAN_STAFF_MENU_TASK.md'; deliverable = 'outbox/STAFF_MENU_SCSS_FIX.scss' },
        @{ order = 1; id = 'hit-shapes-notes'; doc = 'CORNERMAN_STAFF_MENU_TASK.md'; deliverable = 'outbox/STAFF_MENU_HIT_SHAPES_NOTES.txt' },
        @{ order = 2; id = 'staff-09'; doc = 'CORNERMAN_STAFF_MENU_TASK.md'; optional = $true }
    )
    redVerify  = @(
        'Sync-LifePunchAddonsToDxrp.ps1 -Addon adminmenu'
        'play game.scene -> staffmenu -> log filter gradient empty'
    )
} | ConvertTo-Json -Depth 6

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\STAFF_MENU_FIX.json' -Text $directive
Write-Host 'OK inbox\STAFF_MENU_FIX.json' -ForegroundColor Green

Write-Host ''
Write-Host 'Next on Green: Send-CornermanWorkflow.ps1 -Action WarmCoder' -ForegroundColor Cyan
Write-Host 'Then run CORNERMAN_STAFF_MENU_TASK.md P0 + P1.' -ForegroundColor Cyan
