# GPU rack — world model (Bitcoin Miner entity)

Two names, two jobs:

| Layer | Name | Repo slug | Ships |
|-------|------|-----------|-------|
| **Entity** | Bitcoin Miner | `bitcoin-miner` | prefab, code, sounds, terminal UI |
| **World mesh** | GPU rack | `gpu-rack` | this folder → `gpu-rack.vmdl` |

No underscores in ship slugs (`gpu-rack`, not `gpu_rack` or `GPU_Farm`).

## Ship tree (publish)

```text
models/lifepunch/bitcoinmining/gpu-rack/
  source/
    gpu-rack-static.obj          ← primary ModelDoc import
    gpu-rack-anim.fbx            ← optional rack fan motion
    gpu-rack-stacked-anim.fbx    ← optional stacked variant
  textures/
    cord/        OBJ usemtl Cord       (Wires_Cord)
    psu/         OBJ usemtl PSU        (PSU_Power)
    rack/        OBJ usemtl Rack       (frame + 5 fan boxes + blades)
    motherboard/ OBJ usemtl Motherboard (Motherboard_Base)
    gpu/         OBJ usemtl GPU        (graphics card + 6 card fans)
  materials/
    gpu-rack-cord.vmat
    gpu-rack-psu.vmat
    gpu-rack-rack.vmat
    gpu-rack-motherboard.vmat
    gpu-rack-gpu.vmat
  gpu-rack.vmdl                  ← compile output
  material-map.json              ← Blender object → slot → textures
```

```text
entities/bitcoin-miner/bitcoin-miner.prefab   ← points at gpu-rack.vmdl
sounds/bitcoin-miner/                         ← hum, keyboard, etc.
```

## Why one vmdl, five materials

The OBJ is **one assembled rack** (21 Blender objects) collapsed into **5 material slots**:

1. **Cord** — cable harness only  
2. **PSU** — power supply block  
3. **Rack** — steel frame + all rack cooling fans (shared PBR set)  
4. **Motherboard** — board  
5. **GPU** — graphics cards + per-card fans (emission map for LED glow)

Do **not** split into separate vmdls per fan — fans are part of the rack assembly.

## Materials quick reference (ModelDoc)

**You only create 5 `.vmat` files** — not one per PNG. The OBJ already groups 21 parts into 5 slots (`Cord`, `PSU`, `Rack`, `Motherboard`, `GPU`).

| # | ModelDoc material slot (from OBJ) | `.vmat` to create | Base color | Normal | AO | Metal | Rough | Extra |
|---|-----------------------------------|-------------------|------------|--------|----|-------|-------|-------|
| 1 | **Cord** | `materials/gpu-rack-cord.vmat` | `textures/cord/Wires_Cord_BaseColor.png` | — | `Wires_AO.png` | `Wires_Cord_Metallic.png` | `Wires_Cord_Roughness.png` | |
| 2 | **PSU** | `materials/gpu-rack-psu.vmat` | `textures/psu/PSU_BaseColor.png` | `PSU_Normal_GL.png` | `PSU_AO.png` | `PSU_Metallic.png` | `PSU_Roughness.png` | |
| 3 | **Rack** | `materials/gpu-rack-rack.vmat` | `textures/rack/Rack_BaseColor.png` | `Rack_Normal_GL.png` | `Rack_AO.png` | `Rack_Metallic.png` | `Rack_Roughness.png` | frame + 5 fan boxes + blades |
| 4 | **Motherboard** | `materials/gpu-rack-motherboard.vmat` | `textures/motherboard/Motherboard_BaseColor.png` | `Motherboard_Normal_GL.png` | `MotherB_AO.png` | `Motherboard_Metallic.png` | `Motherboard_Roughness.png` | |
| 5 | **GPU** | `materials/gpu-rack-gpu.vmat` | `textures/gpu/GPU_BaseColor.png` | `GPU_Normal_GL.png` | `GPU_AO.png` | `GPU_Metallic.png` | `GPU_Roughness.png` | **`GPU_Emission.png`** (mining glow) |

**Ignore in ModelDoc (duplicates / wrong convention):**

- `*_Normal_DX.png` — use the matching `*_Normal_GL.png` (OpenGL normals for s&box).
- Extra PNGs not listed above — already folded into the five PBR sets.

**ModelDoc order:**

1. Import `source/gpu-rack-static.obj`.
2. Confirm five material slots appear (Cord, PSU, Rack, Motherboard, GPU).
3. For each slot, create the `.vmat` in `materials/` and assign textures from the table.
4. Compile `gpu-rack.vmdl`.

Canonical JSON: `material-map.json` in this folder.

## Archive (do not upload)

```text
C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/
```

Raw export keeps Blender names (`GPU_Farm_Static.obj`, `GPU_GraphicsCard/`, etc.).

## Reorganize after a fresh export

```powershell
powershell -File lifepunch/addons/scripts/Reorganize-BitcoinMinerGpuRack.ps1 -SourceRoot "C:\path\to\export"
```

## Editor project (required — not `addons.sbproj`)

ModelDoc, prefab wiring, play-test, and `PayHost` economy all need the **DXRP game project**
with the **server API token** applied. The standalone LifePunch `addons.sbproj` compiles
`LIFEPUNCH_LOCAL` stubs only — no real DXRP data, entities, or portal sync.

**Launch (VENGEANCE):**

```powershell
powershell -File lifepunch/scripts/Start-SboxDxrpEditor.ps1
```

Uses `lifepunch/scripts/dxrp-editor.local.json` → `rp.sbproj` + `+authorize <token>`.
Wait until compile finishes; bridge/host play should show `HasAuthorizationKey=true`.

**Work path in DXRP install** (typical):

```text
D:/Steam/steamapps/common/sbox/dxrp/game/
  Assets/addons/lifepunch/bitcoinmining/   ← must match repo tree
  Code/Addons/lifepunch/bitcoinmining/
```

Repo source of truth: `lifepunch/addons/` in the monorepo. **Before ModelDoc**, mirror into DXRP:

```powershell
powershell -File lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1
# or launch editor (syncs bitcoinmining by default):
powershell -File lifepunch/scripts/Start-SboxDxrpEditor.ps1
```

After editor work, sync compiled outputs (`gpu-rack.vmdl`, `_c`, vmats, prefab) **back into the monorepo** paths above.

See `lifepunch/addons/docs/SBOX_EDITOR_REFERENCE.md` §0–1.

## Power animation (on / off)

Rack fans and card LEDs **only run while mining** — idle when powered off.

| Sequence | When | Source |
|----------|------|--------|
| `power_on` | `IsMining == true` | Loop from `source/gpu-rack-anim.fbx` |
| `power_off` | `IsMining == false` | Hold first frame / wind-down from same FBX |

`gpu-rack-stacked-anim.fbx` is a layout reference only unless art needs the stacked variant.

**Code:** `BitminerEntity.SetMiningState` switches vmdl sequence (replaces Evo `BitminerFan*` child spin — see `TECH_DEBT` BITMINER-01).

## Terminal prop (separate from rack vmdl)

**Intaked:** `models/.../bitcoin-terminal/` (`computer.fbx` → `bitcoin-terminal.vmdl`).  
Re-run: `addons/scripts/Intake-BitcoinTerminalAssets.ps1`  
Archive: `C:/lifepunch/reference-intake/bitcoinmining/bitcoin-terminal-export/`

Razor UI ships under `Code/Addons/lifepunch/bitcoinmining/` — author in Downloads `bitcointerminal/` lane.

## ModelDoc checklist (inside DXRP project)

1. Asset Browser → **Project scope "DXRP"** → `addons/lifepunch/bitcoinmining/models/.../gpu-rack/`.
2. Import `source/gpu-rack-static.obj` in ModelDoc.
3. Import `source/gpu-rack-anim.fbx`; define `power_on` (loop) + `power_off` (idle) sequences.
4. Create five vmats per `material-map.json` (GPU slot uses emission).
5. Compile `gpu-rack.vmdl` in this folder; recompile after external edits.
6. Prefab `entities/bitcoin-miner/bitcoin-miner.prefab` — scale ~1.11 vs Evo study prefab; wire anim driver to `BitminerEntity`.
7. Play-test: `mining start` → rack anim + hum; `mining stop` → power down.
