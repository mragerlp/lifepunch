# Cornerman task — Bitminer dual rack (small + large → BTC yield)

**Lane:** Tier-3 prep · **Priority:** **#4** (after Phase 2 menu draft — **unblocked**)  
**Issued:** 2026-06-11 · **Red:** implements mesh + code on VENGEANCE after distill  
**Prerequisite:** `BITMINER_PHASE2_WIREFRAME.md` ✅ (rack row in Upgrades module)

---

## Goal

Owner wants **both racks visible** on the Bitcoin Miner — small + large — with **production tied to which racks are active**. You distill the spec; Red ships vmdl + prefab + economy code.

**You do NOT:** edit `BitminerEntity.cs` for ship, open ModelDoc, or `git push`.

---

## Read first

| Doc | Why |
|-----|-----|
| `briefs/BITMINER_DUAL_RACK_BRIEF.md` | Identity + proposed formula |
| `BITMINER_UX_SPEC.md` | §2 economy, §3d rack anim |
| `gpu-rack/MODEL_BUILD.md` | Static vs stacked FBX |
| `gpu-rack/material-map.json` | Shared material slots |
| `BitminerTerminal.razor` | Upgrade panel (add 3rd row spec) |
| `reference/evo-bitminer/entities/bitminer/bitminer.prefab` | Evo big/small **fan** placement study only |

---

## Task 1 — Asset inventory

Append section to `docs/reference/BITMINER_DUAL_RACK_SPEC.md`:

| Asset | Path | Approx role | Notes |
|-------|------|-------------|-------|
| Small static | `gpu-rack-static.obj` | Base rack | Shipped as `gpu-rack.vmdl` |
| Small anim | `gpu-rack-anim.fbx` | power_on/off | BITMINER-01 |
| Large stacked | `gpu-rack-stacked-anim.fbx` | Expansion rack | Needs `gpu-rack-stacked.vmdl` |
| Terminal | `computer.fbx` | CRT prop | `bitcoin-terminal.vmdl` |

If Blender/archive available on Green, note bounding-box / height delta between static vs stacked (mm or Blender units).

---

## Task 2 — Economy distill

In `BITMINER_DUAL_RACK_SPEC.md` section **## Economy**:

1. Restate current formula from `BitminerEntity.MineBitcoin`.
2. Propose `RackYield` multiplier table (starter ×1.0, expansion ×2.0 — or alternate if you find better game balance).
3. Propose **Rack Expansion** upgrade:
   - One-time vs multi-tier?
   - Suggested cost (compare Core tier 1 = $50k — rack expansion should feel **major**).
4. Map upgrade to **visual state**: large rack emission/anim off when `RackExpansionLevel == 0`.
5. LCD + terminal strings for `status`, `info`, upgrade panel.

Mark uncertain values `TBD — Red editor verify`.

---

## Task 3 — Prefab wireframe

ASCII hierarchy + suggested **first-pass** local transform for `gpu_rack_large` child (Red will tune in editor):

```text
bitcoin-miner
  gpu-rack (small)     — root ModelRenderer (existing)
  gpu_rack_large       — child ModelRenderer → gpu-rack-stacked.vmdl
  computer_terminal    — existing
```

Propose offset e.g. large rack **behind** small (`Position` +Y or +X depending on mesh forward axis). Note if stacked FBX origin differs from static — flag for ModelDoc `align_origin_z_type`.

---

## Task 4 — Upgrade UI spec

Extend `BITMINER_PHASE2_WIREFRAME.md` **or** add subsection in dual-rack spec:

- Third row in upgrade panel: **RACK EXPANSION**
- Button disabled when maxed
- Confirm copy: "Purchase large rack expansion? Doubles mining yield."
- CLI: `upgrade rack` alias

---

## Task 5 — ModelDoc checklist (for Red)

Numbered steps to compile `gpu-rack-stacked.vmdl`:

1. Import `gpu-rack-stacked-anim.fbx`
2. Remap same 5 material slots → existing vmats
3. Sequences `power_on` / `power_off` (sync with small rack)
4. Compile; add child to prefab
5. Play-test: both racks visible; yield doubles after purchase

---

## Task 6 — RAG outbox

Copy `BITMINER_DUAL_RACK_BRIEF.md` + completed spec to `C:\lifepunch\cornerman\outbox\`.

---

## Commit + ping

```text
docs(bitcoinmining): dual rack economy + prefab wireframe distill
```

Ping Red: `dual rack spec on Green — subjects: ...`
