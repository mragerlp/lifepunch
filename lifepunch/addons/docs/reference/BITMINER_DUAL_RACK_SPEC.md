# Bitminer dual rack spec (scaffold)

**Status:** Cornerman fills — small + large rack visible, yield tied to expansion  
**Canon brief:** `briefs/BITMINER_DUAL_RACK_BRIEF.md`

---

## Asset inventory

| Asset | Repo path | Role | Status |
|-------|-----------|------|--------|
| Small static | `gpu-rack/source/gpu-rack-static.obj` | Base rack mesh | `gpu-rack.vmdl` shipped |
| Small anim | `gpu-rack/source/gpu-rack-anim.fbx` | Mining power anim | TODO on vmdl |
| Large stacked | `gpu-rack/source/gpu-rack-stacked-anim.fbx` | Expansion rack | **vmdl TODO** |
| CRT terminal | `bitcoin-terminal/source/computer.fbx` | Control station | `bitcoin-terminal.vmdl` shipped |

Archive: `C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/GPU_Farm_Stacked_Anim.fbx`

---

## Economy

### Current (shipped)

```text
BTC per 60s tick = ClockSpeed × 0.005 × CoreCount
Display BTC/min  = ClockSpeed × 0.005 × CoreCount
```

### Proposed dual-rack

| Field | Type | Notes |
|-------|------|-------|
| `RackExpansionLevel` | `[Sync] int` 0–1 | 0 = large rack visible but offline; 1 = large rack contributes |
| `RackYield` | derived | `1.0 + RackExpansionLevel × LargeRackBonus` |

```text
LargeRackBonus = TBD (propose 1.0 → doubles yield)
BTC per tick = ClockSpeed × 0.005 × CoreCount × RackYield
```

### Rack Expansion upgrade

| Tier | Cost | Effect |
|------|------|--------|
| 1 | TBD | Enable large rack yield + power anim |

Compare to Core upgrade tier 1 ($50,000) — rack expansion should feel **bigger** than CPU clock, smaller than max core tier?

---

## Visual states

| RackExpansionLevel | IsMining | Small rack | Large rack |
|--------------------|----------|------------|------------|
| 0 | false | idle | visible, dim/off |
| 0 | true | power_on | visible, dim/off |
| 1 | false | idle | idle/off |
| 1 | true | power_on | power_on |

---

## Prefab hierarchy (target)

```text
bitcoin-miner
├── ModelRenderer (small) → gpu-rack.vmdl
├── computer_terminal → bitcoin-terminal.vmdl
│   └── lcd_text
├── gpu_rack_large → gpu-rack-stacked.vmdl
└── BitminerEntity
```

**Suggested large rack offset:** TBD (Red ModelDoc / editor tune)

---

## Terminal / LCD copy

```text
RACKS   1× SMALL + 1× LARGE (OFFLINE|ACTIVE)
YIELD   ×{RackYield}
```

Upgrade panel row: **RACK EXPANSION** — PURCHASE button → `RequestUpgrade(Rack)` (enum TBD).

---

## ModelDoc checklist

- [ ] Create `gpu-rack-stacked.vmdl` from `gpu-rack-stacked-anim.fbx`
- [ ] Remap 5 materials to existing vmats
- [ ] `power_on` / `power_off` sequences
- [ ] Add `gpu_rack_large` child on `bitcoin-miner.prefab`
- [ ] Wire `RackExpansionLevel` + `RackYield` in `BitminerEntity.cs` (Red/Opus)
- [ ] Third upgrade button in `BitminerTerminal.razor` (Red)

---

## Related

- `BITMINER_UX_SPEC.md`
- `gpu-rack/MODEL_BUILD.md`
- `TECH_DEBT.md` BITMINER-01
