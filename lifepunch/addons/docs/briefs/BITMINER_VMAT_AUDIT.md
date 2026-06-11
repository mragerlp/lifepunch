# Bitcoin Miner — V-Mat audit (auto, 2026-06-11)

**Status:** All five `.vmat` files pre-authored in repo. Red compiles via editor / s&box bridge.

## Why 21 Blender parts = 5 materials

The OBJ collapses parts by `usemtl` slot: Cord, PSU, Rack (frame + 5 fans), Motherboard, GPU (cards + 6 fans). One PBR texture set per slot.

## Folder audit

### `textures/cord/` (4 PNGs — all used)

| PNG | Channel | In `gpu-rack-cord.vmat` |
|-----|---------|-------------------------|
| `Wires_Cord_BaseColor.png` | Color | Yes |
| `Wires_AO.png` | AO | Yes |
| `Wires_Cord_Metallic.png` | Metalness | Yes |
| `Wires_Cord_Roughness.png` | Roughness | Yes |

### `textures/psu/` (6 PNGs — use 5)

| PNG | Channel | In vmat |
|-----|---------|---------|
| `PSU_BaseColor.png` | Color | Yes |
| `PSU_Normal_GL.png` | Normal | Yes |
| `PSU_AO.png` | AO | Yes |
| `PSU_Metallic.png` | Metalness | Yes |
| `PSU_Roughness.png` | Roughness | Yes |
| `PSU_Normal_DX.png` | — | **Skip** |

### `textures/rack/` (6 PNGs — use 5)

| PNG | Channel | In vmat |
|-----|---------|---------|
| `Rack_BaseColor.png` | Color | Yes |
| `Rack_Normal_GL.png` | Normal | Yes |
| `Rack_AO.png` | AO | Yes |
| `Rack_Metallic.png` | Metalness | Yes |
| `Rack_Roughness.png` | Roughness | Yes |
| `Rack_Normal_DX.png` | — | **Skip** |

### `textures/motherboard/` (6 PNGs — use 5)

| PNG | Channel | In vmat |
|-----|---------|---------|
| `Motherboard_BaseColor.png` | Color | Yes |
| `Motherboard_Normal_GL.png` | Normal | Yes |
| `MotherB_AO.png` | AO | Yes |
| `Motherboard_Metallic.png` | Metalness | Yes |
| `Motherboard_Roughness.png` | Roughness | Yes |
| `Motherboard_Normal_DX.png` | — | **Skip** |

### `textures/gpu/` (7 PNGs — use 6)

| PNG | Channel | In vmat |
|-----|---------|---------|
| `GPU_BaseColor.png` | Color | Yes |
| `GPU_Normal_GL.png` | Normal | Yes |
| `GPU_AO.png` | AO | Yes |
| `GPU_Metallic.png` | Metalness | Yes |
| `GPU_Roughness.png` | Roughness | Yes |
| `GPU_Emission.png` | Self Illum | Yes (`F_SELF_ILLUM`) |
| `GPU_Normal_DX.png` | — | **Skip** |

## Path check

All `Texture*` paths in `materials/gpu-rack-*.vmat` resolve under:

`addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/`

`gpu-rack.vmdl` remaps OBJ slots Cord/PSU/Rack/Motherboard/GPU → matching vmats.

## Cornerman

**Vmat lane closed** — do Phase 2 menu wireframe only (`CORNERMAN_BITMINER_PHASE2_MENU_TASK.md`).
