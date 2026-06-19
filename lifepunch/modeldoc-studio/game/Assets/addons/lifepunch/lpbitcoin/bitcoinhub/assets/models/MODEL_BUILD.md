# Bitcoin Miner hub — Steam Machine world model

**Entity slug:** `bitcoinhub` · **Disk folder:** `lpbitcoin/bitcoinhub/assets/entities/`  
**Source:** owner `bitcoinminer.blend` → `steam-machine.fbx` + `sm_*` textures

## Ship tree

```text
models/lifepunch/bitcoinmining/bitcoinhub/
  NAV.md                  ← start here (what to open in editor)
  bitcoinhub.vmdl      ← chassis ModelDoc
  bitcoinhub-fan.vmdl  ← fan mesh ModelDoc
  materials/              ← bitcoinhub-sm-*.vmat only (5)
  source/
    bitcoinminer.blend    ← owner archive
    steam-machine.fbx     ← Blender export
  _archive/               ← Ophion era + duplicates (not shipped)
  MODEL_BUILD.md

lpbitcoin/bitcoinhub/assets/entities/
  bitcoinhub.prefab
  textures/               ← 18 sm_* PNG (ship)
  textures/_archive/      ← Ophion + jpeg dupes
```

## ModelDoc import (initial — verify on flatgrass)

| Field | Value | Why |
|-------|-------|-----|
| **Mesh** | `source/steam-machine.fbx` | Replaces static Ophion gaming PC |
| **Import scale** | `0.152` (Custom) | **`base_body` only (Phase 1 idle)** → ~**29 × 30 × 32**; full static hull after re-export |
| **Import translation** | `0, 0, 0` | `align_origin_z_type = Bottom` — ground contact verified flatgrass |
| **Import rotation** | `0, 0, 0` *(tune — see §Orientation)* | FBX export: `axis_forward=-Z`, `axis_up=Y` |
| **Align origin Z** | Bottom | Sit on ground at prefab root |

## Orientation (P0 — before DXRP sync)

**Law** (`MODEL_FOUNDATION_PASS.md` row 6): the **interactive front** (`sm_panel_mat`, ports, USE side) must face the **buyer** when spawned from the DXRP **Market** tab.

**How DXRP market spawn works** (`GameManager.PurchaseMarketItemHost`): position = `GameUtils.GetSpawnPosition( player.AimRay )` (where you aim + 30u off the surface). **Rotation is NOT set** — prefab stays **`Rotation = identity`**. Facing is **100% `import_rotation`** on the vmdl, never prefab root yaw and never dev-only spawn hacks.

**Hands / build tool** (separate path): `BaseConstructTool` uses `MathUtils.CalculateSurfaceFlatRotation( surfaceNormal, toPlayer )` — panel should still end up toward the placer after import bake is correct.

**Current bake:** `import_rotation = [0, 270, 0]` — flips Steam Machine 180° from the Y=90 pass so **panel (front)** faces the buyer at identity rotation, **fan (back)** away.

**Tuning loop:**

1. ModelDoc preview — panel (`sm_panel_mat`) toward **entity -Right** at identity (market spawn).
2. Play → aim at floor → `lp_bitcoin_spawn_hub` (now mirrors market position + identity rot) → panel toward you.
3. `lp_bitcoin_hub_orient_audit` — want `panelDot < -0.7`.
4. If backward: nudge Y by 180° (`lp_bitcoin_hub_yaw_test 180`) then bake into vmdl.

**Sibling reference:** GPU rack Sketchfab family uses `import_rotation = [0, 90, 0]` — Steam Machine is a **different** export; do not copy blindly.

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
| BoxCollider Scale | `29.36, 30.4, 31.97` |
| BoxCollider Center | `18.46, 0.07, 14.01` |

Measured mesh @ `import_scale 0.152`, **`base_body` only** (flatgrass audit, 2026-06-19): **~29 × 30 × 32**.

Reference: DXRP `gameplay/entities/printer/printer.prefab` — `BoxCollider` from model feet; hub collider matches `Model.Bounds`.

## Material slots (FBX)

| FBX slot | vmat |
|----------|------|
| `sm_body_mat` | `bitcoinhub-sm-body.vmat` |
| `sm_details_one_mat` | `bitcoinhub-sm-details-one.vmat` |
| `sm_details_two_mat` | `bitcoinhub-sm-details-two.vmat` |
| `sm_panel_mat` | `bitcoinhub-sm-panel.vmat` |
| `sm_fence_led_mat` | `bitcoinhub-sm-fence-led.vmat` (emissive) |

Textures live under `lpbitcoin/bitcoinhub/assets/entities/textures/` (intake copies from `Downloads\bitcoinminer\textures`).  
**Compile note:** BaseColor maps must be `.png` — s&box texture compiler rejects `.jpeg` on `TextureColor`.

## Phase 1 — static idle chassis (2026-06-19)

**Ship a single rigid hull — no animations, no skinned body, no hanging parts.**

| Layer | Rule |
|-------|------|
| **FBX export** | `Export-BitcoinMinerSteamMachineFbx.py` **static mode (default)** — meshes only, **no armature**, `bake_anim=False`. Legacy `--rigged` flag is Phase 2 only. |
| **ModelDoc import** | `base_body` only until static re-export verified; then add `front_panel` + `back_body` from static FBX |
| **Renderer** | `ModelRenderer` only — never `SkinnedModelRenderer` on body |
| **Prefab** | `fan_spin_hub` **disabled** until Phase 2 |

**Status LED:** `LpBitcoinHubVisuals` — green ON / red OFF (fence emissive + PointLight).

**Why:** rigged FBX + baked actions separated `front_panel` / `back_body` from the chassis in play (floating “hanging” parts). Static export restores assembled idle box.

### Re-export after blend edits

```powershell
powershell -File lifepunch\addons\scripts\Export-BitcoinMinerSteamMachineFbx.ps1
```

Then recompile `bitcoinhub.vmdl` in ModelDoc and widen `import_filter` to `front_panel` + `back_body` once static FBX is verified.

## Fan spin (Phase 2 — deferred)

**Only the fan moves.** Chassis, front panel, and back body are static.

| vmdl | Role |
|------|------|
| `bitcoinhub.vmdl` | Body — imports `base_body`, `front_panel`, `back_body` only (fan mesh excluded) |
| `bitcoinhub-fan.vmdl` | Fan blade mesh only (`fan` from FBX) |

**Prefab:** `fan_spin_hub` child with `ModelRenderer` → `bitcoinhub-fan.vmdl`. Code spins the child GO when hub is powered (`LpBitcoinHubVisuals`).

**ModelDoc:** No `AnimationList`, no `BoneMarkup`, no `animated_model`. Same import scale/rotation as before (`0.152`, bottom align).

If fan sits wrong in the cage: open `bitcoinhub.prefab`, select `fan_spin_hub`, nudge position/rotation, run `lp_bitcoin_fan_tune` to log coords.

### Legacy (do not use for ship)

`fanAction` / `front_panelAction` on a skinned `bitcoinhub.vmdl` separated hull parts — replaced by child fan spin above.

## Animations (owner blend — DO NOT SHIP for Phase 1)

Blender actions exist in the FBX but **do not star-add or play them on the hub body vmdl** — that path broke the assembled mesh. Phase 2 fan motion = child GO spin only (`HUB_FAN_SETUP.md`).

| Action | Phase 1 | Phase 2+ |
|--------|---------|----------|
| `fanAction` | **Do not use on body vmdl** | Child `fan_spin_hub` GO rotation |
| `front_panelAction` | **Do not use** | Parked |
| `bindPose` | N/A | N/A |

**Legacy (caused breakage):** `SkinnedModelRenderer`, `AnimationList`, `model_archetype = animated_model`, `LpBitcoinPowerAnim` on body — see `BITCOINMINING_PROP_BASELINE.md` §What we are NOT doing again.

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

In editor: compile `bitcoinhub.vmdl` + vmats → `Pull-DxrpCompiledAssetsToRepo.ps1`  
**Compiled (Jun 2026):** all 5 `bitcoinhub-sm-*.vmat_c` + `bitcoinhub.vmdl_c` in repo. Recompile after vmdl import_filter edits.
Dev spawn: `lp_map_flatgrass` → `lp_bitcoin_spawn_hub` → `lp_bitcoin_scale_audit` — verify ~59×31×34, collider match, status LED toggle.

## Superseded

Ophion `Ophion.fbx` + ambientCG vmats remain in repo history only; hub product read is **Steam Machine** industrial miner, not Raijintek gaming PC.
