<#
.SYNOPSIS
  Normalize Desktop lifepunchaddons drops into game-ready layout per slot.

.DESCRIPTION
  Creates per-slot:
    assets/source/fbx|blend|obj/
    assets/textures/
    assets/models/
    code/components|ui|docs/
    audit/manifest.json
  Original zips + extracted/ untouched. Copies only — nothing deleted.

.EXAMPLE
  powershell -File lifepunchaddons\scripts\Normalize-LifepunchDesktopPackages.ps1
#>
[CmdletBinding()]
param(
    [string] $Root = "$env:USERPROFILE\OneDrive\Desktop\lifepunchaddons"
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Copy-IfExists {
    param([string]$From, [string]$ToDir, [string]$Label = '')
    if (-not (Test-Path -LiteralPath $From)) { return $false }
    Ensure-Dir $ToDir
    $dest = Join-Path $ToDir (Split-Path $From -Leaf)
    Copy-Item -LiteralPath $From -Destination $dest -Force
    return $true
}

function Copy-Tree2K {
    param([string]$FromDir, [string]$ToDir)
    if (-not (Test-Path -LiteralPath $FromDir)) { return 0 }
    Ensure-Dir $ToDir
    $n = 0
    $twoK = Join-Path $FromDir '2K'
    if (Test-Path -LiteralPath $twoK) {
        Get-ChildItem -LiteralPath $twoK -File -Force | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $ToDir $_.Name) -Force
            $n++
        }
        return $n
    }
    Get-ChildItem -LiteralPath $FromDir -Recurse -File -Force -Include *.png,*.jpg,*.jpeg,*.tga |
        Where-Object { $_.FullName -match '\\2K\\' -or $_.Name -match '_2K' } |
        ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $ToDir $_.Name) -Force
            $n++
        }
    if ($n -eq 0) {
        Get-ChildItem -LiteralPath $FromDir -Recurse -File -Force -Include *.png,*.jpg,*.jpeg |
            Select-Object -First 32 | ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $ToDir $_.Name) -Force
                $n++
            }
    }
    return $n
}

function Write-SlotManifest {
    param([string]$SlotPath, [hashtable]$Data)
    $audit = Join-Path $SlotPath 'audit'
    Ensure-Dir $audit
    ($Data | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath (Join-Path $audit 'manifest.json') -Encoding UTF8
}

function Normalize-Slot {
    param(
        [string]$RelSlot,
        [scriptblock]$Body
    )
    $slotPath = Join-Path $Root $RelSlot
    if (-not (Test-Path -LiteralPath $slotPath)) {
        Write-Host "  SKIP missing slot $RelSlot" -ForegroundColor DarkYellow
        return
    }
    $assets = Join-Path $slotPath 'assets'
    $fbxDir = Join-Path $assets 'source\fbx'
    $blendDir = Join-Path $assets 'source\blend'
    $objDir = Join-Path $assets 'source\obj'
    $texDir = Join-Path $assets 'textures'
    $modelsDir = Join-Path $assets 'models'
    Ensure-Dir (Join-Path $slotPath 'code\components')
    Ensure-Dir (Join-Path $slotPath 'code\ui')
    Ensure-Dir (Join-Path $slotPath 'code\docs')
    Ensure-Dir (Join-Path $slotPath 'audit')
    Ensure-Dir (Join-Path $slotPath 'docs')
    Ensure-Dir $modelsDir
    & $Body $slotPath $fbxDir $blendDir $objDir $texDir
    Write-Host "  OK $RelSlot" -ForegroundColor Green
}

if (-not (Test-Path -LiteralPath $Root)) { throw "Missing $Root" }

Write-Host "Normalize -> assets/ layout under $Root" -ForegroundColor Cyan

# --- lpbitcoin ---
Normalize-Slot 'lpbitcoin\bitcoinhub' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'cpu_gamer.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'cpu_gamer.blend') $blend | Out-Null
    Write-SlotManifest $s @{
        slot = 'bitcoinhub'; role = 'Bitcoin HUB (CPU GAMER)'; primary_mesh = 'assets/source/fbx/cpu_gamer.fbx'
        notes = @('Solid colors in source — vmats in ModelDoc'; 'Fan spin = child GO Phase 2')
        issues = @()
    }
}

Normalize-Slot 'lpbitcoin\hashdterminal' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\fbx\PC.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'old_pc.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\textures') $tex
    Write-SlotManifest $s @{
        slot = 'hashdterminal'; role = 'HASHD Terminal'; primary_mesh = 'assets/source/fbx/PC.fbx'
        texture_files = $tn; issues = @()
    }
}

Normalize-Slot 'lpbitcoin\gpurack' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\gpu_farm\GPU_Farm\GPU_Farm_Static.obj') $obj | Out-Null
    Copy-IfExists (Join-Path $s 'gpu_crypto_farm.blend') $blend | Out-Null
    $animDir = Join-Path $s 'assets\source\fbx\_reference_anim'
    Ensure-Dir $animDir
    Copy-IfExists (Join-Path $s 'extracted\gpu_farm\GPU_Farm\GPU_Farm_Anim.fbx') $animDir | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\gpu_farm\GPU_Farm') $tex
    $blank = Join-Path $s 'extracted\gpu_blank_textures_new\GPU_Blank_Textures (New)'
    if (Test-Path $blank) { Copy-Tree2K $blank $tex | Out-Null }
    Write-SlotManifest $s @{
        slot = 'gpurack'; role = 'GPU Rack (standard)'; primary_mesh = 'assets/source/obj/GPU_Farm_Static.obj'
        alt_source = 'assets/source/blend/gpu_crypto_farm.blend'
        notes = @('No static FBX in Fab pack — static OBJ + blend are source of truth'; 'Anim FBX archived under assets/source/fbx/_reference_anim for fan study only')
        issues = @('Confirm static OBJ vs blend export for ModelDoc body')
    }
}

Normalize-Slot 'lpbitcoin\advancedgpurack' {
    param($s,$fbx,$blend,$obj,$tex)
    $src = Join-Path $Root 'lpbitcoin\gpurack'
    Copy-IfExists (Join-Path $src 'extracted\gpu_farm\GPU_Farm\GPU_Farm_Stacked_Anim.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $src 'gpu_crypto_farm.blend') $blend | Out-Null
    Copy-Tree2K (Join-Path $src 'extracted\gpu_farm\GPU_Farm') $tex | Out-Null
    Write-SlotManifest $s @{
        slot = 'advancedgpurack'; role = 'Advanced GPU Rack (stacked)'; primary_mesh = 'assets/source/fbx/GPU_Farm_Stacked_Anim.fbx'
        sourced_from = 'lpbitcoin/gpurack (same Fab Crypto Farm pack)'
        notes = @('Stacked variant split from gpurack slot'; 'Use static body in ModelDoc — not anim rig as body')
        issues = @('Stacked anim FBX only — may need static stacked export from blend')
    }
}

# --- lphacker ---
Normalize-Slot 'lphacker\hackerhub' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\servers\Servers\Model\Servers.fbx') $fbx | Out-Null
    $altDir = Join-Path $s 'assets\source\fbx\_alt'
    Ensure-Dir $altDir
    Copy-IfExists (Join-Path $s 'extracted\servers\Servers\Model\Servers_Rows.fbx') $altDir | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\servers\Servers\Texture') $tex
    $glass = Join-Path $s 'extracted\glass_cover_material\Glass_Cover_Material\2K'
    if (Test-Path $glass) {
        Get-ChildItem $glass -File | ForEach-Object { Copy-Item $_.FullName (Join-Path $tex $_.Name) -Force; $tn++ }
    }
    Write-SlotManifest $s @{
        slot = 'hackerhub'; role = 'Hacker HUB'; primary_mesh = 'assets/source/fbx/Servers.fbx'
        texture_files = $tn; notes = @('Glass cover 2K maps merged into assets/textures')
        issues = @()
    }
}

Normalize-Slot 'lphacker\hackerterminal' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\fbx\Computer.fbx') $fbx | Out-Null
    $partsDir = Join-Path $s 'assets\source\fbx\_parts'
    Ensure-Dir $partsDir
    Get-ChildItem (Join-Path $s 'extracted\fbx') -Filter *.fbx -File | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $partsDir $_.Name) -Force
    }
    Copy-IfExists (Join-Path $s 'computer_retro.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\textures') $tex
    Write-SlotManifest $s @{ slot = 'hackerterminal'; role = 'Hacker Terminal'; primary_mesh = 'assets/source/fbx/Computer.fbx'; texture_files = $tn; issues = @() }
}

Normalize-Slot 'lphacker\advancedhackerhub' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\sci-fi-servers\source\Servers.fbx') $fbx | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\sci-fi-servers\textures') $tex
    Write-SlotManifest $s @{ slot = 'advancedhackerhub'; role = 'Advanced Hacker HUB'; primary_mesh = 'assets/source/fbx/Servers.fbx'; texture_files = $tn; issues = @() }
}

Normalize-Slot 'lphacker\advancedhackerterminal' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\fbx\PC_all_in_one.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'extracted\computer_all_in_one\Computer_all_in_one.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\textures') $tex
    Write-SlotManifest $s @{ slot = 'advancedhackerterminal'; role = 'Advanced Hacker Terminal'; primary_mesh = 'assets/source/fbx/PC_all_in_one.fbx'; texture_files = $tn; issues = @() }
}

# --- police / gov ---
Normalize-Slot 'lppolice\policehackerhub' {
    param($s,$fbx,$blend,$obj,$tex)
    $nestedObj = Join-Path $s 'extracted\sci-fi-server-rack\source\Sci_fi_server_rack\Sci_fi_server_rack.obj'
    if (-not (Test-Path $nestedObj)) {
        $zip = Join-Path $s 'extracted\sci-fi-server-rack\source\Sci_fi_server_rack.zip'
        if (Test-Path $zip) {
            $dest = Split-Path $nestedObj -Parent
            Ensure-Dir $dest
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $dest)
        }
    }
    Copy-IfExists $nestedObj $obj | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\sci-fi-server-rack\textures') $tex
    Write-SlotManifest $s @{
        slot = 'policehackerhub'; role = 'Police HUB'; primary_mesh = 'assets/source/obj/Sci_fi_server_rack.obj'
        issues = @('Fab nested pack = OBJ only, no FBX — OK for ModelDoc OBJ import or re-export FBX from Fab')
    }
}

Normalize-Slot 'lppolice\policehackerterminal' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\fbx\Terminal_TH.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'extracted\terminal_th\Terminal_TH.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\textures') $tex
    Write-SlotManifest $s @{ slot = 'policehackerterminal'; role = 'Police Terminal'; primary_mesh = 'assets/source/fbx/Terminal_TH.fbx'; texture_files = $tn; issues = @() }
}

Normalize-Slot 'lpgovernment\governmenthub' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\sci-fi-server-rack\source\Server_pillar.fbx') $fbx | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\sci-fi-server-rack\textures') $tex
    Write-SlotManifest $s @{ slot = 'governmenthub'; role = 'Government HUB'; primary_mesh = 'assets/source/fbx/Server_pillar.fbx'; texture_files = $tn; issues = @() }
}

Normalize-Slot 'lpgovernment\governmentterminal' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'sm_computer_console_01.fbx') $fbx | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\sci_fi_computer_console_textures\tex') $tex
    Write-SlotManifest $s @{ slot = 'governmentterminal'; role = 'Government Terminal'; primary_mesh = 'assets/source/fbx/sm_computer_console_01.fbx'; texture_files = $tn; issues = @() }
}

# --- black market ---
Normalize-Slot 'lpblackmarket\blackmarkethub' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\safe_vault (1)\Safe_Vault\Model\Safe_Vault_TRIO.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'safe_bullion.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\safe_vault (1)\Safe_Vault\Texture') $tex
    Write-SlotManifest $s @{ slot = 'blackmarkethub'; role = 'Black Market Hub (Vault)'; primary_mesh = 'assets/source/fbx/Safe_Vault_TRIO.fbx'; texture_files = $tn; issues = @() }
}

Normalize-Slot 'lpblackmarket\blackmarketterminal' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\retro_crt_terminal\CRT COMPUTER.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\retro_crt_terminal\TEXTURES') $tex
    Write-SlotManifest $s @{
        slot = 'blackmarketterminal'; role = 'Black Market Terminal'; primary_mesh = 'assets/source/blend/CRT COMPUTER.blend'
        issues = @('No FBX in pack — export FBX from blend before ModelDoc OR import blend via pipeline')
    }
}

Normalize-Slot 'lpblackmarket\blackmarketregister' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'assets\source\CashRegister-00.blend') (Join-Path $blend 'CashRegister-00.blend') | Out-Null
    Copy-IfExists (Join-Path $s 'CashRegister-00.blend') (Join-Path $blend 'CashRegister-00.blend') | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'assets\textures') $tex
    if (-not $tn) { $tn = Copy-Tree2K (Join-Path $s 'textures') $tex }
    Write-SlotManifest $s @{
        slot = 'blackmarketregister'; role = 'Black Market Register (BTC checkout → DXRP market grant)'
        primary_mesh = 'assets/source/blend/CashRegister-00.blend'
        issues = @('No FBX in pack — export FBX from blend before ModelDoc OR import blend via pipeline')
    }
}

Normalize-Slot 'lpblackmarket\blackmarketlocker' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\locker-19\source\SF_Locker_19.fbx') $fbx | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\locker-19\textures') $tex
    Write-SlotManifest $s @{ slot = 'blackmarketlocker'; role = 'Black Market Locker (weapon storage / customization)'; primary_mesh = 'assets/source/fbx/SF_Locker_19.fbx'; texture_files = $tn; issues = @() }
}

# --- banker ---
Normalize-Slot 'lpbanker\bankerhub' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\fbx\Safe_all.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'extracted\safe\Safe.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\textures\textures4k') $tex
    Write-SlotManifest $s @{
        slot = 'bankerhub'; role = 'Banker Hub (Safe/Vault)'; primary_mesh = 'assets/source/fbx/Safe_all.fbx'
        owner_confirmed = 'safe/vault'; issues = @('4K TGA dupes in source - assets/textures has first-pass 2K/png subset only')
    }
}

Normalize-Slot 'lpbanker\bankerterminal' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\fbx\Computer.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'retro_computer.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\textures\textures4k') $tex
    Write-SlotManifest $s @{ slot = 'bankerterminal'; role = 'Bank Terminal'; primary_mesh = 'assets/source/fbx/Computer.fbx'; texture_files = $tn; issues = @() }
}

Normalize-Slot 'lpbanker\bankeratm' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\atm_modern_01_fbx\ATM_Modern_01_FBX\SM_ATM_Modern_01.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'extracted\atm_modern_01_blender\ATM_Modern_01_Blender\SM_ATM_Modern_01.blend') $blend | Out-Null
    $texSrc = Join-Path $s 'extracted\atm_modern_01_fbx\ATM_Modern_01_FBX\Textures'
    Ensure-Dir $tex
    if (Test-Path $texSrc) {
        Get-ChildItem $texSrc -File | ForEach-Object { Copy-Item $_.FullName (Join-Path $tex $_.Name) -Force }
    }
    Write-SlotManifest $s @{ slot = 'bankeratm'; role = 'Banker ATM'; primary_mesh = 'assets/source/fbx/SM_ATM_Modern_01.fbx'; issues = @() }
}

# --- flash drive ---
Normalize-Slot 'lpflashdrive\usbflashdrive' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\fbx\USB_flash.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'usb_flash_drive.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\textures\unity') $tex
    Write-SlotManifest $s @{
        slot = 'usbflashdrive'; role = 'USB Flash Drive (all color variants in textures)'
        primary_mesh = 'assets/source/fbx/USB_flash.fbx'
        notes = @('8/16/256 GB color maps in source textures'; 'bitcoinusb + hackerusb = future gameplay splits, same mesh family')
        issues = @()
    }
}

Normalize-Slot 'lpflashdrive\electronicstable' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\solder_kit\Solder_Kit\Model\Soldering_Kit.fbx') $fbx | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\solder_kit\Solder_Kit\Textures') $tex
    Write-SlotManifest $s @{ slot = 'electronicstable'; role = 'Electronics / upgrade table'; primary_mesh = 'assets/source/fbx/Soldering_Kit.fbx'; texture_files = $tn; issues = @() }
}

# Placeholder lanes — documented, not missing downloads
foreach ($placeholder in @(
    @{ rel = 'lpflashdrive\bitcoinusb'; note = 'Gameplay lane placeholder — mesh/textures live in ../usbflashdrive (civilian BTC storage variants)' }
    @{ rel = 'lpflashdrive\hackerusb'; note = 'Gameplay lane placeholder — mesh/textures live in ../usbflashdrive (malware/raid variants WIP)' }
)) {
    $p = Join-Path $Root $placeholder.rel
    Ensure-Dir $p
    Ensure-Dir (Join-Path $p 'docs')
    Ensure-Dir (Join-Path $p 'audit')
    @"
# $($placeholder.rel)

$($placeholder.note)

Canonical assets: lpflashdrive/usbflashdrive/assets/
"@ | Set-Content -LiteralPath (Join-Path $p 'docs\README.md') -Encoding UTF8
    Write-SlotManifest $p @{ slot = (Split-Path $placeholder.rel -Leaf); role = 'placeholder'; issues = @($placeholder.note) }
    Write-Host "  OK $($placeholder.rel) (placeholder doc)" -ForegroundColor DarkGray
}

# --- weapons ---
Normalize-Slot 'lpweapons\ak47military' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'extracted\ak47_fbx\AK47 FBX\AK47.fbx') $fbx | Out-Null
    Copy-IfExists (Join-Path $s 'extracted\ak47_blend\AK47.blend') $blend | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\textures\textures') $tex
    Write-SlotManifest $s @{ slot = 'ak47military'; role = 'AK-47 weapon'; primary_mesh = 'assets/source/fbx/AK47.fbx'; issues = @('Parallel weapon track — not cyber prop Phase 1') }
}

Normalize-Slot 'lpweapons\ar15military' {
    param($s,$fbx,$blend,$obj,$tex)
    Copy-IfExists (Join-Path $s 'ar_15.fbx') $fbx | Out-Null
    $tn = Copy-Tree2K (Join-Path $s 'extracted\ar_15_gltf\textures') $tex
    Write-SlotManifest $s @{ slot = 'ar15military'; role = 'AR-15 weapon'; primary_mesh = 'assets/source/fbx/ar_15.fbx'; issues = @('Parallel weapon track'; 'glb/usdz/gltf kept in slot root as reference only') }
}

# Master summary
$issues = @()
Get-ChildItem $Root -Recurse -Filter manifest.json -File | Where-Object { $_.FullName -match '\\audit\\manifest\.json$' } | ForEach-Object {
    $m = Get-Content $_.FullName -Raw | ConvertFrom-Json
    if ($m.issues -and @($m.issues).Count -gt 0) {
        foreach ($i in @($m.issues)) {
            if ($i) { $issues += "$(Split-Path (Split-Path $_.FullName -Parent) -Parent | Split-Path -Leaf): $i" }
        }
    }
}

$summaryPath = Join-Path $Root 'audit\NORMALIZE_SUMMARY.md'
Ensure-Dir (Join-Path $Root 'audit')
@"
# Normalize summary — $(Get-Date -Format 'yyyy-MM-dd HH:mm')

All slots now have ``assets/source/`` + ``assets/textures/`` + ``audit/manifest.json``.
Original zips and ``extracted/`` preserved.

## Slots ready for ModelDoc (FBX primary)
Most cyber props — see per-slot manifest.json

## Open issues
$(if ($issues.Count) { ($issues | ForEach-Object { "- $_" }) -join "`n" } else { '- None blocking audit pass' })

## Placeholder folders (not missing downloads)
- lpflashdrive/bitcoinusb — points to usbflashdrive
- lpflashdrive/hackerusb — points to usbflashdrive

## Advanced GPU rack
Populated from lpbitcoin/gpurack (GPU_Farm_Stacked_Anim.fbx) — same Fab Crypto Farm pack.
"@ | Set-Content -LiteralPath $summaryPath -Encoding UTF8

Write-Host "`nSummary: $summaryPath" -ForegroundColor Cyan
