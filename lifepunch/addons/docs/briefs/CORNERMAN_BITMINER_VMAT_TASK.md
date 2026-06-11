# Cornerman task — Bitminer vmat audit + prefab scaffold (draft)

**Lane:** Tier-3 prep · **Red** runs ModelDoc on VENGEANCE  
**Issued:** 2026-06-11  
**UPDATE 2026-06-11:** Red completed vmats + `gpu-rack.vmdl` + `bitcoin-miner.prefab`. **Skip this task.** Go to `CORNERMAN_BITMINER_PHASE2_MENU_TASK.md` only.

---

## Goal

Validate the gpu-rack material map against on-disk PNGs, confirm the five pre-authored `.vmat` files match `material-map.json`, and draft the `bitcoin-miner.prefab` JSON shell for Red to wire in editor.

**You do NOT:** open s&box, ModelDoc, compile vmdl, or push to GitHub.

---

## Read first

| Path | Why |
|------|-----|
| `models/.../gpu-rack/material-map.json` | Canonical slot → texture map |
| `models/.../gpu-rack/BITMINER_VMAT_OWNER_GUIDE.md` | Folder-by-folder PNG guide for Red |
| `models/.../gpu-rack/materials/gpu-rack-*.vmat` | Pre-wired vmats (5 files) |
| `Code/Addons/lifepunch/bitcoinmining/Bitminer.cs` | Prefab + model paths |
| `reference/evo-bitminer/` (study) | Evo prefab scale ~1.11, component names |

---

## Deliverable 1 — Vmat audit report

Create `lifepunch/addons/docs/briefs/BITMINER_VMAT_AUDIT.md`:

1. Table: each of 5 materials → every PNG in its folder → channel (Color/Normal/AO/Metal/Rough/Emission) → used or skip (`_DX`).
2. Flag any missing PNG vs `material-map.json`.
3. Confirm each `.vmat` `Texture*` path resolves under `addons/lifepunch/bitcoinmining/models/.../gpu-rack/`.
4. One paragraph: why 21 Blender objects still = 5 materials.

---

## Deliverable 2 — Prefab scaffold draft

Create `lifepunch/addons/docs/briefs/BITMINER_PREFAB_SCAFFOLD.md`:

- Root GameObject name: `Bitcoin Miner`
- Components Red must add: `BitminerEntity`, `ModelRenderer` → `gpu-rack.vmdl`, `TextRenderer` (LCD), collider
- Path constants from `Bitminer.cs` (`WorldPrefabPath`, `WorldModelPath`, sound paths)
- Scale note from Evo study (~1.11)
- **Do not** commit a `.prefab` binary — markdown scaffold only unless Red asks for JSON

---

## Deliverable 3 — RAG outbox

Copy audit summary to `C:\lifepunch\cornerman\outbox\BITMINER_VMAT_AUDIT.md`.

---

## Deliverable 4 (if coke/deagle blocked)

Continue `CORNERMAN_WORK_QUEUE.md` priority 1–2; this task is **parallel** when those stall.

---

## Commit (local)

```text
docs(bitcoinmining): vmat audit + prefab scaffold draft
```

Ping Red: `vmat audit ready — 5 vmats pre-authored in repo materials/`
