# Bitcoin mining props — collision-first baseline (Jun 2026)

**Do not start over on code.** Hub/rack/terminal entities, economy, terminal UI, and networking stay.
Reset only the **prop layer** (vmdl + prefab + fan child GOs) using this order.

## Why it looks horrible

Animation work (rigged FBX, bone spin, vmdl `power_on` sequences) ran **before** collision and origin were locked.
That stacked broken mesh orientation, guessed BoxColliders, and detached fan parts. The game code is fine; the visuals/physics baseline is not.

## Canonical pattern (Evo Bitminer — study only in Downloads)

| Layer | Rule |
|-------|------|
| **Body vmdl** | Static mesh only. Fan blades **excluded** via ModelDoc import filter. No `AnimationList` / bone spin on body. |
| **Fan vmdl(s)** | Separate small vmdls (`*-fan.vmdl`). |
| **Prefab** | `ModelRenderer` on root. One child GO per fan (`fan_spin_*`) with its own `ModelRenderer`. |
| **Code** | `LpBitcoinHubVisuals` / `LpBitcoinRackVisuals` — `LocalRotation *= Rotation.FromAxis(Vector3.Forward, speed)`. |
| **Collider** | `BoxCollider` **Center (X,Y,Z)** + **Scale (X,Y,Z)** = `model.Bounds` — must match the **white** mesh wireframe on **all three axes**. In the prefab editor the Box gizmo shows **red / green / blue** edges for the collider volume; that entire box must sit on the white box (not just one axis). `OnAwake` → `LifePunchPropPhysics.SyncBoxColliderFromModel`. |
| **Ground** | Host spawn → `LifePunchGroundContact.AlignMeshBottom` (mesh `Bounds.Mins.z` → surface). |
| **Scale** | Prefab root **`1,1,1`**. Tune **`import_scale`** in vmdl only. |

## Phase checklist (do in order — skip phase 2 until phase 1 is green)

### Phase 1 — Collision + feet (all props)

1. ModelDoc: `import_translation = [0,0,0]` unless bridge proves otherwise. Align **Center / Center / Bottom** (hub + rack).
2. Compile body vmdl. Open prefab tab → **white wireframe** = compiled mesh bounds. Select **BoxCollider** → **Center X,Y,Z** and **Scale X,Y,Z** must match `model.Bounds` so the **red/green/blue** collider box fully overlaps white (no offset on any axis).
3. `OnAwake` sync on entity (hub, rack, terminal) — already wired Jun 2026.
4. Play flatgrass → `lp_bitcoin_spawn_hub` / `lp_bitcoin_spawn_kit` → props sit on ground, no fall-through.
5. `lp_bitcoin_scale_audit` → log line `modelBounds center=… size=…` matches BoxCollider fields.

| Prop | Prefab | Body vmdl |
|------|--------|-----------|
| Hub | `entities/bitcoinminer/bitcoin-miner.prefab` | `bitcoin-miner/bitcoin-miner.vmdl` |
| GPU rack | `entities/gpurack/gpu-rack.prefab` | `gpu-rack/gpu-rack.vmdl` |
| Advanced rack | `entities/advancedgpurack/advanced-gpu-rack.prefab` | `gpu-rack/gpu-rack-stacked.vmdl` |
| Terminal | `entities/bitcoin-terminal/bitcoin-terminal.prefab` | *(owner replacing model — pause)* |

### Phase 2 — Fans (after phase 1 sign-off)

1. Enable **`fan_spin_hub`** (hub) — nudge in prefab editor until blade sits in cage.
2. Enable **`fan_spin_rack_1`** first (rack) — clone offsets to siblings.
3. Play → `lp_bitcoin_playtest_mining` → only blades spin; chassis stays rigid.
4. Clone Evo pattern to **advanced-gpu-rack** (still on legacy placeholders).

### Phase 3 — Polish (defer)

- Fence LEDs, hub admin UI chrome, RGB gpu vmats, terminal LCD tune.
- New terminal model intake when owner ships replacement FBX.

## What we are NOT doing again

- Rigged fan FBX as body `RenderMeshFile`
- `LpBitcoinSkinnedFanSpin` / `SetBoneTransform` fan hacks
- Hand-authored BoxCollider guesses (`25×20×36`, `0,0,9`, etc.)
- vmdl `power_on` / `power_off` sequences on rack body until static baseline ships

## Dev commands

| Command | When |
|---------|------|
| `lp_bitcoin_scale_audit` | After vmdl compile — copy `modelBounds` to prefab if needed |
| `lp_bitcoin_fan_tune` | After nudging `fan_spin_*` in prefab editor |
| `lp_bitcoin_playtest_mining` | Fan spin + mining smoke test |
| `lp_bitcoin_spawn_kit` | Hub + terminal + racks |

## Start over?

**No full restart.** Keep all C# under `Code/Addons/lifepunch/bitcoinmining/`.
If a prefab is beyond repair, delete **only** that prefab + body vmdl filter nodes and rebuild from this doc + Evo reference — reattach the same entity components.

---

## Model intake queue (owner drops — Jun 2026)

**Full folder map:** `addons/docs/MODEL_INTAKE_DROP_MAP.md`

Drop FBX packs under OneDrive `LIFEPUNCH*\addons\` (or send any path + entity name). Colors irrelevant. Code + prefab entity components stay; Phase 1 collision on all axes before fans/LEDs.

**GPU racks:** no new mesh — collision-only on existing art.

