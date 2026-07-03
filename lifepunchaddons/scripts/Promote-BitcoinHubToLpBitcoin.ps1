# Promote Steam Machine hub from legacy bitcoinmining tree -> lpbitcoin/bitcoinhub (publish staging).
param( [switch] $WhatIf )

$ErrorActionPreference = 'Stop'
$repoAddons = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$assets = Join-Path $repoAddons 'Assets\addons\lifepunch'

$legacyModel = Join-Path $assets 'bitcoinmining\models\lifepunch\bitcoinmining\bitcoin-miner'
$legacyEntity = Join-Path $assets 'bitcoinmining\entities\bitcoinminer'
$hubRoot = Join-Path $assets 'lpbitcoin\bitcoinhub'
$texDest = Join-Path $hubRoot 'assets\textures'
$matDest = Join-Path $hubRoot 'assets\models\materials'
$mdlDest = Join-Path $hubRoot 'assets\models'
$fbxDest = Join-Path $hubRoot 'assets\source\fbx'
$blendDest = Join-Path $hubRoot 'assets\source\blend'
$prefabDest = Join-Path $hubRoot 'assets\entities'

$texPrefix = 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/textures/'
$matPrefix = 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/materials/'
$fbxRel = 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/source/fbx/steam-machine.fbx'

$keepTextures = @(
    'sm_body_mat_BaseColor.png', 'sm_body_mat_Normal.png',
    'sm_body_mat_Metallic-sm_body_mat_Roughness@channels=G.png', 'sm_body_mat_Metallic-sm_body_mat_Roughness@channels=B.png',
    'sm_details_one_mat_BaseColor.png', 'sm_details_one_mat_Normal.png', 'sm_details_one_mat_Metallic-sm_details_one_mat_Roughness@cha.png',
    'sm_details_two_mat_BaseColor.png', 'sm_details_two_mat_Normal.png', 'sm_details_two_mat_Metallic-sm_details_two_mat_Roughness@cha.png',
    'sm_panel_mat_BaseColor.png', 'sm_panel_mat_Normal.png',
    'sm_panel_mat_Metallic-sm_panel_mat_Roughness@channels=G.png', 'sm_panel_mat_Metallic-sm_panel_mat_Roughness@channels=B.png',
    'sm_fence_led_mat_BaseColor-sm_fence_led_mat_Alpha.png', 'sm_fence_led_mat_Normal.png',
    'sm_fence_led_mat_Metallic-sm_fence_led_mat_Roughness@channel.png', 'sm_fence_led_mat_Emissive.png'
)

function Ensure-Dir([string]$Path) {
    if (-not $WhatIf -and -not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Copy-File([string]$From, [string]$To) {
    if (-not (Test-Path -LiteralPath $From)) { return }
    Ensure-Dir (Split-Path -Parent $To)
    if ($WhatIf) { Write-Host "[WhatIf] $From -> $To"; return }
    Copy-Item -LiteralPath $From -Destination $To -Force
}

Write-Host 'Promote Bitcoin hub -> lpbitcoin/bitcoinhub' -ForegroundColor Cyan

# Park old Sketchfab generic PC stub
$sketchArchive = Join-Path $hubRoot '_archive\sketchfab-generic-pc'
foreach ($rel in @(
    'assets\models\bitcoin-hub.vmdl', 'assets\models\bitcoin-hub.vmdl_c',
    'assets\models\materials\generic-pc-desktop.vmat', 'assets\models\materials\generic-pc-desktop.vmat_c',
    'assets\source\fbx\generic-pc-desktop.fbx', 'assets\textures\generic-pc-desktop_basecolor.png'
)) {
    $src = Join-Path $hubRoot $rel
    if (Test-Path -LiteralPath $src) {
        $dst = Join-Path $sketchArchive ($rel -replace '\\','/')
        if ($WhatIf) { Write-Host "[WhatIf] archive $src" }
        else {
            Ensure-Dir (Split-Path -Parent $dst)
            Move-Item -LiteralPath $src -Destination $dst -Force
        }
    }
}

Ensure-Dir $texDest; Ensure-Dir $matDest; Ensure-Dir $fbxDest; Ensure-Dir $blendDest; Ensure-Dir $prefabDest

Copy-File (Join-Path $legacyModel 'source\steam-machine.fbx') (Join-Path $fbxDest 'steam-machine.fbx')
Copy-File (Join-Path $legacyModel 'source\bitcoinminer.blend') (Join-Path $blendDest 'bitcoinminer.blend')

$legacyTex = Join-Path $legacyEntity 'textures'
foreach ($name in $keepTextures) {
    Copy-File (Join-Path $legacyTex $name) (Join-Path $texDest $name)
    Get-ChildItem -LiteralPath $legacyTex -Filter "*$($name.ToLower().Replace('.png',''))*.vtex_c" -ErrorAction SilentlyContinue |
        ForEach-Object { Copy-File $_.FullName (Join-Path $texDest $_.Name) }
}

$smSlots = @('body', 'details-one', 'details-two', 'panel', 'fence-led')
foreach ($slot in $smSlots) {
    $legacyName = "bitcoin-miner-sm-$slot.vmat"
    $newName = "bitcoinhub-sm-$slot.vmat"
    $src = Join-Path $legacyModel "materials\$legacyName"
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $text = Get-Content -LiteralPath $src -Raw
    $text = $text -replace 'addons/lifepunch/bitcoinmining/entities/bitcoinminer/textures/', $texPrefix
    $text = $text -replace 'bitcoin-miner hub', 'bitcoinhub'
    if ($WhatIf) { Write-Host "[WhatIf] vmat $newName" }
    else {
        Set-Content -LiteralPath (Join-Path $matDest $newName) -Value $text -NoNewline
        $legacyC = "$src`_c"
        if (Test-Path -LiteralPath $legacyC) {
            Copy-File $legacyC (Join-Path $matDest "$newName`_c")
        }
    }
}

if (-not $WhatIf) {
    $vmdlBody = Get-Content -LiteralPath (Join-Path $legacyModel 'bitcoin-miner.vmdl') -Raw
    $vmdlBody = $vmdlBody -replace 'bitcoin-miner-sm-', 'bitcoinhub-sm-'
    $vmdlBody = $vmdlBody -replace 'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/materials/', $matPrefix
    $vmdlBody = $vmdlBody -replace 'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/source/steam-machine.fbx', $fbxRel
    Set-Content -LiteralPath (Join-Path $mdlDest 'bitcoinhub.vmdl') -Value $vmdlBody -NoNewline
    Copy-File (Join-Path $legacyModel 'bitcoin-miner.vmdl_c') (Join-Path $mdlDest 'bitcoinhub.vmdl_c')

    $vmdlFan = Get-Content -LiteralPath (Join-Path $legacyModel 'bitcoin-miner-fan.vmdl') -Raw
    $vmdlFan = $vmdlFan -replace 'bitcoin-miner-sm-', 'bitcoinhub-sm-'
    $vmdlFan = $vmdlFan -replace 'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/materials/', $matPrefix
    $vmdlFan = $vmdlFan -replace 'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/source/steam-machine.fbx', $fbxRel
    Set-Content -LiteralPath (Join-Path $mdlDest 'bitcoinhub-fan.vmdl') -Value $vmdlFan -NoNewline
    Copy-File (Join-Path $legacyModel 'bitcoin-miner-fan.vmdl_c') (Join-Path $mdlDest 'bitcoinhub-fan.vmdl_c')

    $prefab = Get-Content -LiteralPath (Join-Path $legacyEntity 'bitcoin-miner.prefab') -Raw
    $prefab = $prefab -replace 'bitcoin-miner', 'bitcoinhub'
    $prefab = $prefab -replace 'addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/', 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/'
    $prefab = $prefab -replace 'bitcoinhub-fan\.vmdl', 'bitcoinhub-fan.vmdl'
    Set-Content -LiteralPath (Join-Path $prefabDest 'bitcoinhub.prefab') -Value $prefab -NoNewline
}

foreach ($doc in @('MODEL_BUILD.md', 'NAV.md', 'HUB_FAN_SETUP.md', 'material-map.json')) {
    $src = Join-Path $legacyModel $doc
    if (Test-Path -LiteralPath $src) {
        if ($WhatIf) { Write-Host "[WhatIf] doc $doc" }
        else {
            $t = Get-Content -LiteralPath $src -Raw
            $t = $t -replace 'bitcoin-miner', 'bitcoinhub'
            $t = $t -replace 'bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner', 'lpbitcoin/bitcoinhub/assets/models'
            $t = $t -replace 'entities/bitcoinminer', 'lpbitcoin/bitcoinhub/assets/entities'
            Set-Content -LiteralPath (Join-Path $mdlDest $doc) -Value $t -NoNewline
        }
    }
}

$movedStub = @"
# Hub moved to lpbitcoin staging

Active Steam Machine hub lives at:

``lpbitcoin/bitcoinhub/assets/``

- Model: ``assets/models/bitcoinhub.vmdl``
- Prefab: ``assets/entities/bitcoinhub.prefab``
- Textures: ``assets/textures/sm_*``

Do not add new hub work here. Archive only.
"@

if (-not $WhatIf) {
    Set-Content -LiteralPath (Join-Path $legacyModel 'MOVED.md') -Value $movedStub
    Set-Content -LiteralPath (Join-Path $legacyEntity 'MOVED.md') -Value $movedStub
    $audit = @{
        slot = 'bitcoinhub'
        role = 'Bitcoin HUB (Steam Machine)'
        primary_mesh = 'assets/source/fbx/steam-machine.fbx'
        vmdl = 'assets/models/bitcoinhub.vmdl'
        prefab = 'assets/entities/bitcoinhub.prefab'
        promotedFrom = 'bitcoinmining/models/.../bitcoin-miner'
        notes = @('Jun 2026 promotion — canonical path is lpbitcoin/bitcoinhub')
    } | ConvertTo-Json -Depth 4
    Ensure-Dir (Join-Path $hubRoot 'audit')
    Set-Content -LiteralPath (Join-Path $hubRoot 'audit\manifest.json') -Value $audit
}

Write-Host 'Done. Open: lpbitcoin/bitcoinhub/assets/models/bitcoinhub.vmdl' -ForegroundColor Green
Write-Host 'Update LpBitcoinIdent + Sync-LifePunchAddonsToDxrp (includes lpbitcoin).' -ForegroundColor Yellow
