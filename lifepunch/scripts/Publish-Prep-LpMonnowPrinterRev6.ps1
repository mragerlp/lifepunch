# Rev 6 publish prep: sync editor -> stage upload -> desktop handoff folder + gate checks.
param(
    [string]$MonnowRoot = "$env:USERPROFILE\OneDrive\Desktop\monnowsaddons",
    [int]$RevisionNumber = 6,
    [switch]$SkipDxrpSync,
    [switch]$OpenFolder,
    [switch]$PullCompiledFromDxrp
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$SourceRoot = Join-Path $MonnowRoot "Monnow's Printer Addon\LifePunch"
$PrepareScript = Join-Path $Here 'Prepare-LpMonnowPrinterPublish.ps1'
$SyncScript = Join-Path $Here 'Sync-LpMonnowPrinterToDxrp.ps1'
$RepoRoot = (Resolve-Path (Join-Path $Here '..')).Path
if (Test-Path -LiteralPath (Join-Path $RepoRoot 'lifepunch\addons')) {
    $MonorepoRoot = $RepoRoot
} else {
    $MonorepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
}
$UploadRoot = Join-Path $MonorepoRoot 'lifepunch\addons\.dxrp-publish\upload'
$DesktopPublish = Join-Path ([Environment]::GetFolderPath('Desktop')) "lifepunch\addons\publish\lpmonnowsprinterupgrade-rev$RevisionNumber"

$configPath = Join-Path $Here 'dxrp-editor.local.json'
$dxrpGame = $null
if (Test-Path -LiteralPath $configPath) {
    $cfg = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    $dxrpGame = Split-Path -Parent $cfg.projectPath
}

if (-not $SkipDxrpSync) {
    & $SyncScript -MonnowRoot $MonnowRoot
}

if ($PullCompiledFromDxrp -and $dxrpGame) {
    $compiledSource = Join-Path $dxrpGame 'Assets\addons\lifepunch\monnowprinterlp'
    $compiledDest = Join-Path $SourceRoot 'assets\monnowprinterlp'
    if (Test-Path -LiteralPath $compiledSource) {
        Get-ChildItem -LiteralPath $compiledSource -Recurse -File -Filter '*_c' | ForEach-Object {
            $rel = $_.FullName.Substring($compiledSource.Length).TrimStart('\', '/')
            $target = Join-Path $compiledDest $rel
            $parent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $parent)) {
                New-Item -ItemType Directory -Force -Path $parent | Out-Null
            }
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
        Write-Host "Pulled *_c from DXRP editor back to Desktop source." -ForegroundColor Green
    }
}

& $PrepareScript -MonnowRoot $MonnowRoot

$required = @(
    'Assets\addons\lifepunch\monnowprinterlp\monnowprinter.prefab',
    'Assets\addons\lifepunch\monnowprinterlp\monnowprinter.prefab_c',
    'Assets\addons\lifepunch\monnowprinterlp\models\money_printer.vmdl_c',
    'Code\Addons\lifepunch\lpmonnowsprinterupgrade\MonnowPrinterEntity.cs'
)

$failed = @()
foreach ($rel in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $UploadRoot $rel))) {
        $failed += $rel
    }
}

if ($failed.Count -gt 0) {
    Write-Host 'GATE FAIL - missing required publish files:' -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Host 'Open DXRP editor, compile prefab + vmdl, then re-run with -PullCompiledFromDxrp' -ForegroundColor Yellow
    exit 1
}

if (Test-Path -LiteralPath $DesktopPublish) {
    Remove-Item -LiteralPath $DesktopPublish -Recurse -Force
}

& robocopy $UploadRoot $DesktopPublish /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if ($LASTEXITCODE -ge 8) {
    throw "robocopy to desktop publish folder failed ($LASTEXITCODE)"
}

$readme = @"
lpmonnowsprinterupgrade REV $RevisionNumber - PORTAL UPLOAD HANDOFF
===================================================================

Portal addon: lpmonnowsprinterupgrade (019f0c85-d5df-798c-8c9d-3bbd228793cf)

1. Assets tab upload -> everything under:
   $DesktopPublish\Assets\

   MUST include:
   addons/lifepunch/monnowprinterlp/monnowprinter.prefab
   addons/lifepunch/monnowprinterlp/monnowprinter.prefab_c

2. Code tab upload -> everything under:
   $DesktopPublish\Code\

3. Addon -> Content: ONE Entity row (Monnowlith Printer).

4. Gamemode LIFEPUNCH Dev:
   - Content: ONE Monnowlith Printer row (delete tier 2/3 if present)
   - Entities: ONE row -> Monnowlith Printer
   - Market: ONE listing under #entity.category.printer
   - Pin Rev $RevisionNumber -> Save -> Sync Servers

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
"@

Set-Content -LiteralPath (Join-Path $DesktopPublish 'UPLOAD_README.txt') -Value $readme -Encoding UTF8

Write-Host ''
Write-Host "REV $RevisionNumber PUBLISH PREP OK" -ForegroundColor Green
Write-Host "Desktop handoff: $DesktopPublish" -ForegroundColor Cyan
Write-Host "Repo staging:    $UploadRoot" -ForegroundColor DarkGray

if ($OpenFolder) {
    Invoke-Item $DesktopPublish
}
