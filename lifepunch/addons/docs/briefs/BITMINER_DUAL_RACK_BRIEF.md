# Bitcoin Miner — dual rack economy brief (small + large yield)

**Issued:** 2026-06-11 · **Lane:** Green distill → Red builds on VENGEANCE  
**Superseded layout:** ~~both racks + CRT on one `bitcoin-miner` prefab~~ → **three separate placeables** (`BITMINER_THREE_ENTITY_ARCH.md`)

---

## Goal

**Two rack types** with different yield — as **separate entities**, not children on one prefab:

| Rack | Entity slug | Asset | Role |
|------|-------------|-------|------|
| **Small** | `bitcoin-miner` | `gpu-rack.vmdl` | Base `×1.0` yield |
| **Large** | `advanced-bitcoin-miner` | `gpu-rack-stacked.vmdl` | `AdvancedRack` → `×2.0` yield |

**Bitcoin Terminal** (`bitcoin-terminal`) is a **third placeable** — hashd control station; links racks remotely (`BITMINER_REMOTE_RACK_SPEC.md`).

---

## Production model (proposed)

Current formula (`BitminerEntity.MineBitcoin`):

```text
BTC per 60s tick = ClockSpeed × BaseSpeed(0.005) × CoreCount
```

**Proposed dual-rack multiplier:**

```text
RackYield = SmallRackBase(1.0) + (LargeRackActive ? LargeRackBonus(1.0) : 0)
BTC per tick = ClockSpeed × BaseSpeed × CoreCount × RackYield
```

| State | Small visible | Large visible | Large animating | RackYield | Example @ 2.44 GHz, 1 core |
|-------|---------------|---------------|-----------------|-----------|----------------------------|
| Starter | ✓ | ✓ (idle/dim) | ✗ | 1.0 | 0.0122 BTC/min |
| Expansion purchased | ✓ | ✓ (powered) | ✓ when mining | 2.0 | 0.0244 BTC/min |

**New synced field:** `RackExpansionLevel` (0/1) or `bool HasLargeRackActive`  
**New upgrade track:** **Rack Expansion** — one-time purchase (Cornerman proposes cost tier).

Display rate everywhere: `ClockSpeed × 0.005 × CoreCount × RackYield`.

---

## Prefab layout (obsolete — do not ship)

~~Single prefab with `computer_terminal` + `gpu_rack_large` children~~ — replaced by:

```text
entities/bitcoin-terminal/bitcoin-terminal.prefab   ← CRT + BitminerTerminalProp
entities/bitcoin-miner/bitcoin-miner.prefab       ← small rack only
entities/advanced-bitcoin-miner/...                 ← stacked rack only
```

See `BITMINER_THREE_ENTITY_ARCH.md` + `BITMINER_REMOTE_RACK_SPEC.md`.

---

## Terminal / upgrade UI

Extend clickable **UPGRADE** panel (already shipped Phase 1.5):

| Row | Action | RPC |
|-----|--------|-----|
| CPU CLOCK | existing | `RequestUpgrade(Cpu)` |
| CPU CORES | existing | `RequestUpgrade(Cores)` |
| **RACK EXPANSION** | new | `RequestUpgrade(Rack)` or `RequestRackExpansion()` |

LCD + CLI `status` / `info` should list:

```text
RACKS   1× SMALL (active) + 1× LARGE (offline|active)
YIELD   ×1.0 | ×2.0
```

---

## Assets on disk

| File | Repo path | Status |
|------|-----------|--------|
| Small static | `gpu-rack/source/gpu-rack-static.obj` | **Shipped** → `gpu-rack.vmdl` |
| Small anim | `gpu-rack/source/gpu-rack-anim.fbx` | TODO power_on/off on small vmdl |
| Large stacked | `gpu-rack/source/gpu-rack-stacked-anim.fbx` | **Not compiled** — needs `gpu-rack-stacked.vmdl` |
| Archive mirror | `reference-intake/.../GPU_Farm_Stacked_Anim.fbx` | Same file |

Reuse **same five vmats** on stacked mesh (material slots should match Cord/PSU/Rack/Motherboard/GPU).

---

## Cornerman deliverable

`docs/reference/BITMINER_DUAL_RACK_SPEC.md` — full distill (economy table, prefab offsets proposal, upgrade costs first pass, terminal copy, ModelDoc checklist).

**Red does not wait** on Green for prefab offsets — but economy numbers should be Green-distilled before Opus tunes `BitminerEntity.cs`.

---

## Related

- `BITMINER_UX_SPEC.md` §2 economy
- `CORNERMAN_BITMINER_DUAL_RACK_TASK.md`
- `gpu-rack/MODEL_BUILD.md`
- `reference/evo-bitminer/` — dual fan scale study only (do not ship Evo meshes)
