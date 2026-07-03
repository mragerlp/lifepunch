<#
.SYNOPSIS
  Archive subway + truck Blender source into reference-intake (study-only, never commit).

.PARAMETER SubwaySource
  Owner pack root for subway art (default: Desktop\subway).

.PARAMETER TruckSource
  Owner pack root for truck art (default: Desktop\truck).

.EXAMPLE
  powershell -File Intake-AdditionalDropLocations.ps1
#>
[CmdletBinding()]
param(
    [string] $SubwaySource = 'C:\Users\jared\Desktop\subway',
    [string] $TruckSource = 'C:\Users\jared\Desktop\truck',
    [string] $IntakeRoot = 'C:\lifepunch\reference-intake\additional-drug-drops',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'

function Ensure-Dir([string]$Path) {
    if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path"; return }
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
}

function Mirror-Tree([string]$From, [string]$To, [string]$Label) {
    if (-not (Test-Path -LiteralPath $From)) { throw "Missing source: $From" }
    if ($WhatIf) {
        Write-Host "[WhatIf] robocopy $Label"
        return
    }
    Ensure-Dir $To
    & robocopy $From $To /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Label" }
    $n = (Get-ChildItem $To -Recurse -File).Count
    Write-Host "  $Label - $n files" -ForegroundColor Green
}

Write-Host 'Additional Drop Locations — reference intake' -ForegroundColor Cyan
Write-Host "  Intake: $IntakeRoot" -ForegroundColor DarkGray

$subwayDest = Join-Path $IntakeRoot 'subway'
$truckDest = Join-Path $IntakeRoot 'truck'

Mirror-Tree $SubwaySource $subwayDest 'subway (Blender + textures)'
Mirror-Tree $TruckSource $truckDest 'truck (Blender)'

$readme = @"
# Additional Drop Locations — reference intake

Study-only Blender source for two extra drug **drop-off sites** (cosmetic props).
Never commit this tree to the monorepo.

| Site | Source | Notes |
|------|--------|-------|
| Subway | ``subway/`` | Bombardier Underground S Train Carriage.blend; replace London Underground logo before ship |
| Truck | ``truck/`` | Truck.blend |

Runtime: ``additionaldroplocations`` addon spawns core DXRP ``prefabs/world/drug_drop.prefab`` at configured map positions.
Cosmetic meshes ship later under ``Assets/addons/lifepunch/additionaldroplocations/``.

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
"@

$readmePath = Join-Path $IntakeRoot 'README.md'
if ($WhatIf) {
    Write-Host "[WhatIf] $readmePath"
} else {
    Set-Content -LiteralPath $readmePath -Value $readme -Encoding UTF8
    Write-Host 'README OK' -ForegroundColor Green
}

Write-Host 'Intake OK' -ForegroundColor Cyan
