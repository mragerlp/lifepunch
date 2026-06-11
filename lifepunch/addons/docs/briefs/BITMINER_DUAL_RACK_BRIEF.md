# Bitcoin Miner — dual rack brief (small + large)

**Issued:** 2026-06-11 · **Lane:** Green distill → Red builds on VENGEANCE  
**Owner ask:** Show **both** the large and small bitcoin rack on the entity; tie visible racks to **BTC production**.

---

## Goal

One placeable **Bitcoin Miner** prefab shows:

| Rack | Asset | Role |
|------|-------|------|
| **Small** | `gpu-rack.vmdl` (`gpu-rack-static.obj`) | Starter unit — always visible, base hash contribution |
| **Large** | `gpu-rack-stacked.vmdl` (`gpu-rack-stacked-anim.fbx` → static + anim) | Expansion unit — visible on prefab; **yields BTC only when expansion is owned/active** |

Plus **`computer_terminal`** (CRT + LCD) — already wired 2026-06-11.

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

## Prefab layout (target)

```text
bitcoin-miner (root)
├── ModelRenderer          → gpu-rack.vmdl          (SMALL — primary collider anchor)
├── computer_terminal      → bitcoin-terminal.vmdl
│   └── lcd_text           → TextRenderer
├── gpu_rack_large         → gpu-rack-stacked.vmdl    (LARGE — offset beside/behind small)
├── fan placeholders       → deprecate when stacked anim ships
└── BitminerEntity
```

Red tunes `gpu_rack_large` **Position / Rotation / Scale** in editor so both racks read clearly in third person.

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
