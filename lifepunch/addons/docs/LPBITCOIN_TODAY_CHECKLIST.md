# LPBITCOIN — today execution checklist (2026-06-10)

**Gate:** `ACTIVE_WORKSTREAM.md` — Model Foundation only. No legacy `bitcoinmining/models/` polish.

**Prep done while you were away:** vmdl + vmat scaffolding for all 4 entity slots is in repo staging. s&box bridge was offline — compile happens when you're back at the editor.

---

## 0. Start (5 min)

```powershell
# Repo already has ModelDoc files — do NOT full MIR sync from thin Desktop lpbitcoin
powershell -File lifepunch\scripts\Prepare-LpBitcoinModelDoc.ps1

# If DXRP mounts are stale:
powershell -File lifepunch\scripts\Set-DxrpLifepunchModelDocLane.ps1
```

Open DXRP project → scene `_dev/scenes/lifepunch-modeldoc.scene`

**ModelDoc files to open (in order):**

| Phase | Path |
|-------|------|
| A Hub | `addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/cpu-gamer.vmdl` |
| B Terminal | `addons/lifepunch/lpbitcoin/hashdterminal/assets/models/hashd-terminal.vmdl` |
| C Small rack | `addons/lifepunch/lpbitcoin/gpurack/assets/models/gpu-rack.vmdl` |
| C Stacked | `addons/lifepunch/lpbitcoin/advancedgpurack/assets/models/gpu-rack-stacked.vmdl` |

---

## Phase A — Hub (CPU GAMER) — ~45 min

**Done when:** ACTIVE_WORKSTREAM §2 Phase A all boxes + H10 sign-off.

1. Compile `cpu-gamer.vmdl` (vertex colors → `materials/default.vmat` baseline).
2. Tune `import_scale` vs citizen (~64–72u tall); start at **1.0**, adjust in ModelDoc.
3. Verify **SingleHull** physics (16 verts) — feet on ground, no explode.
4. Drop in review scene; day + night screenshots.
5. Branding pass: BTC mark + amber HASHD admin readable (mesh audit, not code yet).

**Blocker watch:** Fab mesh has no textures — if slots appear in ModelDoc, remap or keep global default.

---

## Phase B — Terminal — ~60 min

**Done when:** T1–T6 in polish checklist + Phase B boxes in ACTIVE_WORKSTREAM.

1. Compile vmats first (`hashd-terminal-monitor.vmat`, `hashd-terminal-keyboard.vmat`).
2. Compile `hashd-terminal.vmdl` — fix remaps if PC.fbx slots differ from Monitor / Keyboard_mause.
3. Tune scale (seed **0.0272** from legacy — likely needs adjustment vs hub).
4. CRT glow: monitor emissive readable at night (amber HASHD).
5. **Stop at mesh** — CRT UI / rig0 loop is code phase after mesh sign-off.

---

## Phase C — GPU Racks — ~90 min

**Done when:** R8 + Phase C boxes (small + stacked + flatgrass kit).

### Small rack (`gpu-rack.vmdl`)

1. Compile 5 vmats under `gpurack/assets/models/materials/`.
2. Compile vmdl — source `source/fbx/gpu-rack-anim.fbx`, scale **0.395**, rot **0,90,0**.
3. GPU emission on = mining readable.

### Stacked rack (`gpu-rack-stacked.vmdl`)

1. Reuses gpurack vmats (advancedgpurack has no texture dupes).
2. Compile stacked vmdl — verify `power_on` + `Mining_Rig_Stacked` anims.
3. Tune translation/scale if mesh floats (legacy seeds in vmdl).

### Kit proof

- Hub + 3× small + 1× stacked on flatgrass (after `lp_authorize` — owner manual).
- Screenshot hero kit day/night.

---

## What was scaffolded (repo)

| Entity | vmdl | vmats | FBX canonical |
|--------|------|-------|---------------|
| bitcoinhub | `cpu-gamer.vmdl` | default.vmat | `source/fbx/cpu_gamer.fbx` |
| hashdterminal | `hashd-terminal.vmdl` | monitor + keyboard | `source/fbx/PC.fbx` |
| gpurack | `gpu-rack.vmdl` | 5 slot vmats | `source/fbx/gpu-rack-anim.fbx` (copied) |
| advancedgpurack | `gpu-rack-stacked.vmdl` | shares gpurack | `source/fbx/gpu-rack-stacked-anim.fbx` |

Each entity has `assets/models/MODEL_BUILD.md` + `material-map.json` where applicable.

---

## Do NOT today

- Full `Sync-LifepunchDesktopToStaging.ps1 /MIR` on lpbitcoin (wipes repo vmdl work; Desktop is thin).
- Polish `bitcoinmining/models/` legacy meshes.
- Start hacker/banker/other lp* packages.
- Portal publish / `prepare-publish.ps1` until Model Foundation sign-off per entity.

---

## After Model Foundation sign-off

1. Promote vmdl paths into `bitcoinmining` ship tree (code/UI already there).
2. Wire prefabs to new meshes.
3. Play proof: hub → terminal → racks USE loop.
4. `prepare-publish.ps1 -Addon bitcoinmining` for `_c` compile + portal upload.

---

## Cornerman / weapons (parked)

- Weapon vmdls were wiped by earlier MIR — rebuild after lpbitcoin today.
- Sweep script list formatting bug — fix when convenient.

**Owner tracker:** `addons/docs/OWNER_PROGRESS_TRACKER.txt`
