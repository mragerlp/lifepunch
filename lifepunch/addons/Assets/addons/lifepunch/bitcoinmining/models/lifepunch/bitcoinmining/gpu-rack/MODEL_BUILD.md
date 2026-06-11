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

## Archive (do not upload)

```text
C:/lifepunch/reference-intake/bitcoinmining/gpu-rack-export/
```

Raw export keeps Blender names (`GPU_Farm_Static.obj`, `GPU_GraphicsCard/`, etc.).

## Reorganize after a fresh export

```powershell
powershell -File lifepunch/addons/scripts/Reorganize-BitcoinMinerGpuRack.ps1 -SourceRoot "C:\path\to\export"
```

## ModelDoc checklist

1. Import `source/gpu-rack-static.obj`.
2. Assign five vmats per `material-map.json`.
3. Compile `gpu-rack.vmdl` in this folder.
4. Prefab `entities/bitcoin-miner/bitcoin-miner.prefab` — scale reference ~1.11 vs Evo study prefab.
