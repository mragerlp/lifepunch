# Bitminer dual rack spec (distill)

**Status:** Green complete (2026-06-11) · Red ships `gpu-rack-stacked.vmdl` + economy  
**Canon brief:** `briefs/BITMINER_DUAL_RACK_BRIEF.md`

---

## Asset inventory

| Asset | Repo path | Approx role | Notes |
|-------|-----------|-------------|-------|
| Small static | `gpu-rack/source/gpu-rack-static.obj` | Base rack | Shipped → `gpu-rack.vmdl` |
| Small anim | `gpu-rack/source/gpu-rack-anim.fbx` | `power_on` / `power_off` | BITMINER-01 — not on vmdl yet |
| Large stacked | `gpu-rack/source/gpu-rack-stacked-anim.fbx` | Expansion rack | **vmdl TODO** — shares Cord/PSU/Rack/Motherboard/GPU slots |
| CRT terminal | `bitcoin-terminal/source/computer.fbx` | Control station | `bitcoin-terminal.vmdl` shipped; **vmats TODO** (see `BITMINER_VMAT_AUDIT.md`) |

Archive mirror: `C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/GPU_Farm_Stacked_Anim.fbx` (not on Green disk)

### Height / bounds (Green audit)

| Mesh | Method | Size (Blender units, XYZ) | Height (Z) |
|------|--------|---------------------------|------------|
| Small static OBJ | Vertex scan | `0.47 × 0.31 × 0.77` | **0.77** |
| Large stacked FBX | TBD — Red ModelDoc | — | **TBD — Red editor verify** (expect ~1.5–2.0× small; filename + shared fan object names imply double stack) |

**Origin note:** Terminal FBX uses `align_origin_z_type = Bottom` + `import_scale = 39.37`. Stacked FBX likely needs same Z align — flag if large rack floats/sinks beside small rack.

---

## Economy

### Current (shipped `BitminerEntity.MineBitcoin`)

```text
BTC per 60s tick = ClockSpeed × BaseSpeed(0.005) × CoreCount
Display BTC/min  = same (rate label)
```

Example @ defaults (2.44 GHz, 1 core): `0.0122` BTC per tick / min.

### Proposed dual-rack

| Field | Type | Notes |
|-------|------|-------|
| `RackExpansionLevel` | `[Sync] int` 0–1 | 0 = large visible, offline; 1 = large contributes |
| `RackYield` | derived | `1.0 + RackExpansionLevel × 1.0` |

```text
BTC per tick = ClockSpeed × 0.005 × CoreCount × RackYield
```

| State | RackYield | Example @ 2.44 GHz, 1 core |
|-------|-----------|------------------------------|
| Starter (large offline) | ×1.0 | 0.0122 BTC/min |
| Expansion active | ×2.0 | 0.0244 BTC/min |

### Rack Expansion upgrade

| Tier | Proposed cost | Effect |
|------|---------------|--------|
| 1 (one-time) | **$250,000** | `RackExpansionLevel` 0→1; large rack anim + yield |

**Balance rationale:** CPU clock tier 1 = $2k; core tier 1 = $50k; core max = $175k. Rack expansion **doubles all mining** — priced above max core tier but below “buy everything” grind. **TBD — Red economy playtest.**

**Enum:** add `BitminerUpgradeType.Rack` (Red/Opus in `BitminerEntity.cs`).

---

## Visual states

| RackExpansionLevel | IsMining | Small rack | Large rack |
|--------------------|----------|------------|------------|
| 0 | false | idle | visible, dim/off emission |
| 0 | true | `power_on` | visible, dim/off |
| 1 | false | idle | idle/off |
| 1 | true | `power_on` | `power_on` (sync sequences) |

Large rack GPU emission: full when `RackExpansionLevel == 1 && IsMining`; dim when expansion owned but idle; off when not purchased (optional — still visible mesh).

---

## Prefab hierarchy (target)

```text
bitcoin-miner (root, scale ~1.11)
├── ModelRenderer          → gpu-rack.vmdl              (SMALL)
├── computer_terminal      → bitcoin-terminal.vmdl
│   └── lcd_text           → TextRenderer
├── gpu_rack_large         → gpu-rack-stacked.vmdl      (LARGE — NEW child)
├── fan_placeholder*       → deprecate when anims wired
└── BitminerEntity
```

### First-pass `gpu_rack_large` transform (Red tune)

Mesh forward axis assumed same as small rack (Blender −Y depth ≈ 0.31 BU on small).

```text
Name:     gpu_rack_large
Position: 0, -32, 0        # behind small rack (negative Y); TBD — Red editor verify
Rotation: 0, 0, 0, 1
Scale:    1, 1, 1
Model:    addons/lifepunch/bitcoinmining/models/.../gpu-rack-stacked.vmdl
```

If stacked FBX origin is center-mass not floor-aligned, set ModelDoc `align_origin_z_type = Bottom` like terminal.

---

## Terminal / LCD copy

### `status` / `info` lines

```text
RACKS   1× SMALL (active) + 1× LARGE (offline|active)
YIELD   ×{RackYield:0.0}
```

### Upgrade panel — third row

| Row | Label | Detail string | Button |
|-----|-------|---------------|--------|
| 3 | **RACK EXPANSION** | `Lv 0/1 — $250,000 — doubles mining yield` | PURCHASE |

- Disabled when `RackExpansionLevel >= 1` or wallet &lt; cost.
- Confirm copy: `Purchase large rack expansion? Doubles mining yield.`
- CLI alias: `upgrade rack` (text) + clickable row (Red wires after enum exists).

Phase 1 upgrade overlay (CPU/CORES) shipped; Phase 2 **Upgrades** module per `BITMINER_PHASE2_WIREFRAME.md` — Red adds rack row + `RequestUpgrade(Rack)`.

---

## ModelDoc checklist (Red)

1. Import `gpu-rack-stacked-anim.fbx` → new `gpu-rack-stacked.vmdl`.
2. Remap five slots → existing `gpu-rack-*.vmat` (stacked FBX already names Cord, FanBlades*, etc.).
3. Add sequences `power_on` / `power_off` (sync timing with small rack).
4. Compile; add `gpu_rack_large` child on `bitcoin-miner.prefab`.
5. Wire `RackExpansionLevel`, `RackYield`, `PurchaseUpgrade(Rack)` in `BitminerEntity.cs`.
6. Play-test: both racks visible; yield doubles after purchase; LCD + `upgrade` panel show rack state.

---

## Related

- `BITMINER_UX_SPEC.md` §2 economy, §3d rack anim
- `gpu-rack/MODEL_BUILD.md`
- `cornerman/outbox/BITMINER_VMAT_AUDIT.md` — CRT materials (parallel blocker)
- `TECH_DEBT.md` BITMINER-01
