# Bitcoin Miner — Entity Build Brief (gpu-rack intake)

**Issued:** 2026-06-11 · **Assets:** LifePunch-owned GPU rack mesh  
**Reference study only:** `reference/evo-bitminer/` — **never ship** Evo models, sounds, or compiled `_c` from that tree.

---

## Naming (two layers)

| What players see | Repo slug | Ships |
|------------------|-----------|-------|
| **Bitcoin Miner** (entity) | `bitcoin-miner` | prefab, code, sounds, terminal |
| **GPU rack** (world mesh) | `gpu-rack` | `gpu-rack.vmdl` + textures/materials |

No underscores in ship slugs (`gpu-rack`, not `GPU_Farm` or `gpu_farm`).

---

## Raw export (32 files → archive only)

Blender export names (`GPU_Farm_*`, nested `GPU_GraphicsCard/` folders):

| Group | Role |
|-------|------|
| `GPU_Farm_Static.obj` + 2 anim FBX | Assembled rack meshes |
| `GPU_GraphicsCard/` | Card PBR + **Emission** |
| `GPU_Rack/` | Frame + rack fans |
| `Motherboard/` | Board |
| `Power_Supply/` | PSU |
| `Wires/` | Cord harness |

**Archive:** `C:\lifepunch\reference-intake\bitcoinmining\gpu-rack-export\`  
**Reorganize:** `addons/scripts/Reorganize-BitcoinMinerGpuRack.ps1`

---

## Publish tree (grouped for ModelDoc)

```text
models/lifepunch/bitcoinmining/gpu-rack/
  source/
    gpu-rack-static.obj
    gpu-rack-anim.fbx
    gpu-rack-stacked-anim.fbx
  textures/
    cord/         ← OBJ Cord (Wires_Cord)
    psu/          ← OBJ PSU
    rack/         ← OBJ Rack (frame + 5 fan boxes + blades)
    motherboard/  ← OBJ Motherboard
    gpu/          ← OBJ GPU (cards + 6 card fans)
  materials/gpu-rack-*.vmat
  gpu-rack.vmdl
  material-map.json   ← full Blender object → slot map

entities/bitcoin-miner/bitcoin-miner.prefab
sounds/bitcoin-miner/
```

**One vmdl, five materials** — do not split fans into separate models.

---

## Product goal

Placeable **Bitcoin Miner** for DXRP — **not** the Hacker Job terminal.

**Canon UX:** `addons/docs/BITMINER_UX_SPEC.md` — tabbed hashd terminal; Evo mining economy server-side.

- Boot: `LIFEPUNCH hashd` / `mine.exe` (Cornerman green `#00FF7F`)
- In-world **gpu-rack** mesh (no cloud `models/bitminer` path)
- Economy: mine → upgrade → sell (`PayHost` / `ChargeHost`)

---

## Build lanes

| Lane | Machine | Work |
|------|---------|------|
| **Assets** | VENGEANCE | ModelDoc → `gpu-rack.vmdl` + 5 vmats from `material-map.json` |
| **Prefab** | VENGEANCE | `bitcoin-miner.prefab` → local vmdl; wire `BitminerEntity` |
| **Code** | VENGEANCE (Opus) | Port entity + terminal; rebrand UI |
| **Sounds** | VENGEANCE | `sounds/bitcoin-miner/` — no Evo audio |
| **Tier-3** | Cornerman | Distill brief; no ModelDoc |

---

## ModelDoc checklist (VENGEANCE)

1. Import `source/gpu-rack-static.obj`.
2. Five materials per `material-map.json` (GPU emission for LED glow).
3. Compile `gpu-rack.vmdl`.
4. Prefab scale ~1.11 vs Evo study prefab.
5. Optional: `gpu-rack-anim.fbx` for fan motion.

**WorldModelPath:**  
`addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/gpu-rack.vmdl`

---

## Publish gate

```powershell
powershell -File lifepunch/addons/scripts/validate-layout.ps1
powershell -File lifepunch/addons/scripts/prepare-publish.ps1 -Addon bitcoinmining
```
