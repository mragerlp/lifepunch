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

Reference: DXRP `gameplay/entities/printer/printer.prefab` — `BoxCollider` from model feet; hub collider matches `Model.Bounds`.

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

## Fan spin (Evo pattern — Jun 2026)

**Only the fan moves.** Chassis, front panel, and back body are static.

| vmdl | Role |
|------|------|
| `bitcoin-miner.vmdl` | Body — imports `base_body`, `front_panel`, `back_body` only (fan mesh excluded) |
| `bitcoin-miner-fan.vmdl` | Fan blade mesh only (`fan` from FBX) |

**Prefab:** `fan_spin_hub` child with `ModelRenderer` → `bitcoin-miner-fan.vmdl`. Code spins the child GO when hub is powered (`LpBitcoinHubVisuals`).

**ModelDoc:** No `AnimationList`, no `BoneMarkup`, no `animated_model`. Same import scale/rotation as before (`0.152`, bottom align).

If fan sits wrong in the cage: open `bitcoin-miner.prefab`, select `fan_spin_hub`, nudge position/rotation, run `lp_bitcoin_fan_tune` to log coords.

### Legacy (do not use for ship)

`fanAction` / `front_panelAction` on a skinned `bitcoin-miner.vmdl` separated hull parts — replaced by child fan spin above.

## Animations (owner blend — reference only)

Blender actions baked into FBX:

| Action | Hub power use |
|--------|----------------|
| `fanAction` | **ON** — primary loop (`LpBitcoinPowerAnim`) |
| `front_panelAction` | Optional panel motion (fallback candidate) |
| `bindPose` | **OFF** |

**ModelDoc:** After reimport, set **Archetype → Animated Model** (kv3: `model_archetype = "animated_model"`). **AnimationList → Add Simple Animations** (★ star) from `steam-machine.fbx`; ensure `fanAction` + `front_panelAction` compile. Rename to `power_on` / `power_off` only if you want canonical names — code already resolves `fanAction`.

**Prefab renderer:** Use **`SkinnedModelRenderer`** (not `ModelRenderer`) — prop sequences play via `Sequence.Name`, same as ModelDoc preview.

**FBX rig (Jun 2026):** Owner blend has object actions, not an armature. `Export-BitcoinMinerSteamMachineFbx.py` builds `SteamMachineRig` (bones: `base_body`, `fan`, `front_panel`, `back_body`) and bakes actions before export. Without `LimbNode` data in FBX, compiled vmdl stays `bones=0`.

**If fan still static after compile:** open **Compiled Preview Outliner → Skeleton**. Empty skeleton = re-run export script or star-add anims from FBX. Add **BoneMarkupList → BoneMarkup** on `fan` with **Do Not Discard** if bones get culled.

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
