# GPU rack fan spin — Evo Bitminer pattern (Jun 2026)

**You do not need new models.** Fans spin as **child GameObjects** with their own `ModelRenderer`, same as the Evo Bitminer in Downloads.

## What is already wired

| Asset | Role |
|-------|------|
| `gpu-rack.vmdl` | Body only — fan **blades excluded** via import filter |
| `gpu-rack-rack-fan.vmdl` | One rack fan blade mesh (clone per socket) |
| `gpu-rack-gpu-fan.vmdl` | One GPU card fan blade mesh |
| `gpu-rack.prefab` | 11 `fan_spin_*` children with renderers |
| `LpBitcoinRackVisuals.cs` | Evo spin: `Vector3.Forward` + tilt correction |

## Your 5-minute checklist (s&box editor)

1. **Open DXRP project** (already synced if you pulled latest).
2. **ModelDoc** — double-click these in Asset Browser (Project: DXRP):
   - `addons/lifepunch/bitcoinmining/models/.../gpu-rack/gpu-rack.vmdl`
   - `gpu-rack-rack-fan.vmdl`
   - `gpu-rack-gpu-fan.vmdl`
3. **Compile each** (Ctrl+S or Compile button). If filter names fail, see Troubleshooting below.
4. **Open prefab** `entities/gpurack/gpu-rack.prefab`.
5. **Select `fan_spin_rack_1`** — move/rotate until the blade sits in the front-left rack fan cage. Copy offsets to other `fan_spin_rack_*` if needed (or nudge one at a time).
6. **Play** → console: `lp_bitcoin_spawn_kit` then `lp_bitcoin_playtest_mining`.

## Dev commands

| Command | Purpose |
|---------|---------|
| `lp_bitcoin_spawn_kit` | Hub + terminal + 4 racks |
| `lp_bitcoin_playtest_mining` | Power hub + start mining |
| `lp_bitcoin_fan_tune` | Log each `fan_spin_*` local transform (after you move fans in prefab) |

## Troubleshooting ModelDoc filters

If body compiles **empty** or fan vmdls **missing mesh**, FBX object names may differ. In ModelDoc mesh import node, check the dropdown list of mesh groups and update `exception_list` in the `.vmdl` text to match.

Blades to **exclude** from body: `FanBlades.005` … `.009`, `GPU_Fan_1` … `_6`.

## Prefab wireframes (white vs green)

In the prefab editor, the **white** box is the rendered mesh bounds; the **green** box is the hand-authored **`BoxCollider`**. They should match — bake center/scale from `model.Bounds` (or run `lp_bitcoin_scale_audit` in play mode and copy logged values). A stacked **`import_translation`** on the vmdl also shifts the mesh away from the prefab pivot — keep it **`[0,0,0]`** unless ModelDoc tuning requires otherwise.

## Hub (bitcoin-miner) — separate asset

Hub uses the same **Evo child-GO fan spin** pattern (`bitcoin-miner-fan.vmdl` on `fan_spin_hub`). See `bitcoin-miner/HUB_FAN_SETUP.md`.

Reference Evo vmdl (study only, never ship):  
`Downloads/EVO BITMINER ASSETS AND CODE DO NOT SAVE TO REPO/models/.../bitminer.vmdl`
