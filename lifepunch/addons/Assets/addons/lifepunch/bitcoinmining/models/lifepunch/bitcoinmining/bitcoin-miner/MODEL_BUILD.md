# Bitcoin Miner hub — Steam Machine world model

**Entity slug:** `bitcoin-miner` · **Disk folder:** `entities/bitcoinminer/`  
**Source:** owner `bitcoinminer.blend` → `steam-machine.fbx` + `sm_*` textures

## Ship tree

```text
models/lifepunch/bitcoinmining/bitcoin-miner/
  source/
    bitcoinminer.blend      ← owner archive
    steam-machine.fbx       ← Blender export (Intake -ExportFbx or Export-BitcoinMinerSteamMachineFbx.ps1)
    textures/               ← sm_* / sc_* PBR from intake
  bitcoin-miner.vmdl        ← steam-machine.fbx + sm_* material remaps
  materials/                ← bitcoin-miner-sm-*.vmat
  MODEL_BUILD.md

entities/bitcoinminer/
  source/bitcoinminer.blend
  textures/
  bitcoin-miner.prefab      ← ModelRenderer + LpBitcoinHubEntity
```

## ModelDoc import (initial — verify on flatgrass)

| Field | Value | Why |
|-------|-------|-----|
| **Mesh** | `source/steam-machine.fbx` | Replaces static Ophion gaming PC |
| **Import scale** | `0.152` (Custom) | Bridge-tuned Jun 2026 @ prefab `1,1,1` → mesh ~32×30×29 vs collider 32×20×28 |
| **Import translation** | `0, 0, 0` | `align_origin_z_type = Bottom` — ground contact verified flatgrass |
| **Import rotation** | `0, 0, 0` | FBX export axis: -Z forward, Y up |
| **Align origin Z** | Bottom | Sit on ground at prefab root |
## Export law (Jun 2026 fix)

`Export-BitcoinMinerSteamMachineFbx.py` must:

1. Export **only** `Steam_Machine` collection meshes (no camera/lights/`more`).
2. Parent `fan`, `front_panel`, `back_body` under `base_body` **with world transform kept**.
3. **Never** `transform_apply` per-mesh before parenting — that detaches parts in-engine.

```powershell
powershell -File lifepunch\addons\scripts\Export-BitcoinMinerSteamMachineFbx.ps1
```

## Prefab collider (gameplay hammer)

| Field | Value |
|-------|-------|
| Root scale | `1,1,1` |
| BoxCollider Scale | `32, 20, 28` |
| BoxCollider Center | `0, 0, 14` |

Measured mesh @ `import_scale 0.152`: **31.97 × 30.4 × 29.36** (flatgrass `lp_bitcoin_scale_audit`).

## Material slots (FBX)

| FBX slot | vmat |
|----------|------|
| `sm_body_mat` | `bitcoin-miner-sm-body.vmat` |
| `sm_details_one_mat` | `bitcoin-miner-sm-details-one.vmat` |
| `sm_details_two_mat` | `bitcoin-miner-sm-details-two.vmat` |
| `sm_panel_mat` | `bitcoin-miner-sm-panel.vmat` |
| `sm_fence_led_mat` | `bitcoin-miner-sm-fence-led.vmat` (emissive) |

Textures live under `entities/bitcoinminer/textures/` (intake copies from `Downloads\bitcoinminer\textures`).  
**Compile note:** BaseColor maps must be `.png` — s&box texture compiler rejects `.jpeg` on `TextureColor`.

## Animations (owner blend)

Blender actions baked into FBX:

| Action | Hub power use |
|--------|----------------|
| `fanAction` | **ON** — primary loop (`LpBitcoinPowerAnim`) |
| `front_panelAction` | Optional panel motion (fallback candidate) |
| `bindPose` | **OFF** |

**ModelDoc:** After reimport, **AnimationList → Add Simple Animations** (star) from `steam-machine.fbx`; ensure `fanAction` + `front_panelAction` compile. Rename to `power_on` / `power_off` only if you want canonical names — code already resolves `fanAction`.

## Intake commands

```powershell
# Export FBX (needs Blender 5.x)
lifepunch\addons\scripts\Export-BitcoinMinerSteamMachineFbx.ps1

# Copy blend, fbx, textures into repo
lifepunch\addons\scripts\Intake-BitcoinMinerHub.ps1 -ExportFbx
```

## Compile + playtest

```powershell
lifepunch\scripts\Start-SboxDxrpEditor.ps1 -PreflightFix -SyncAddon bitcoinmining
```

In editor: compile `bitcoin-miner.vmdl` + vmats → `Pull-DxrpCompiledAssetsToRepo.ps1`  
**Compiled (Jun 2026):** all 5 `bitcoin-miner-sm-*.vmat_c` + `bitcoin-miner.vmdl_c` in repo. `bitcoin-miner.vmdl` includes `fanAction` (take 0) + `front_panelAction` (take 1) from `steam-machine.fbx`; recompile after vmdl edits.
Dev spawn: `lp_map_flatgrass` → `lp_bitcoin_spawn_hub` — verify scale, collider, fan anim on power toggle.

## Superseded

Ophion `Ophion.fbx` + ambientCG vmats remain in repo history only; hub product read is **Steam Machine** industrial miner, not Raijintek gaming PC.
