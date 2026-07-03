# Bitcoin Miner — V-Mat guide for Jared (ModelDoc)

**You have 5 texture folders, not 5 materials per PNG.** Each folder is one PBR **set** for one part of the rack. ModelDoc needs **5 `.vmat` files** total — already written in `materials/`.

---

## The mental model

```
textures/cord/        →  ONE material  →  OBJ slot "Cord"        →  gpu-rack-cord.vmat
textures/psu/         →  ONE material  →  OBJ slot "PSU"         →  gpu-rack-psu.vmat
textures/rack/        →  ONE material  →  OBJ slot "Rack"        →  gpu-rack-rack.vmat
textures/motherboard/ →  ONE material  →  OBJ slot "Motherboard" →  gpu-rack-motherboard.vmat
textures/gpu/         →  ONE material  →  OBJ slot "GPU"         →  gpu-rack-gpu.vmat
```

Every PNG in a folder is a **channel** on that one material — not a separate material.

| PNG suffix in filename | Material Editor slot | Notes |
|------------------------|----------------------|-------|
| `*_BaseColor.png` | **Color** | Main albedo |
| `*_Normal_GL.png` | **Normal** | Use `_GL`, not `_DX` |
| `*_AO.png` or `Wires_AO` | **Ambient Occlusion** | Cord uses `Wires_AO.png` |
| `*_Metallic.png` | **Metalness** | Tick "Metalness Texture" in PBR |
| `*_Roughness.png` | **Roughness** | |
| `GPU_Emission.png` | **Self Illum** (GPU only) | Tick "Selfillum" in Material Editor |

**Ignore:** `*_Normal_DX.png` — duplicate normals for DirectX; s&box wants `_GL`.

---

## Folder-by-folder (what each PNG is for)

### `textures/cord/` (4 PNGs → cord vmat)

| File | Channel |
|------|---------|
| `Wires_Cord_BaseColor.png` | Color |
| `Wires_AO.png` | AO |
| `Wires_Cord_Metallic.png` | Metalness |
| `Wires_Cord_Roughness.png` | Roughness |

No normal map — cord uses engine default flat normal.

### `textures/psu/` (6 PNGs, use 5)

| File | Channel |
|------|---------|
| `PSU_BaseColor.png` | Color |
| `PSU_Normal_GL.png` | Normal |
| `PSU_AO.png` | AO |
| `PSU_Metallic.png` | Metalness |
| `PSU_Roughness.png` | Roughness |
| ~~`PSU_Normal_DX.png`~~ | **Skip** |

### `textures/rack/` (6 PNGs, use 5)

Covers steel frame **and** all 5 rack fans (one shared look).

| File | Channel |
|------|---------|
| `Rack_BaseColor.png` | Color |
| `Rack_Normal_GL.png` | Normal |
| `Rack_AO.png` | AO |
| `Rack_Metallic.png` | Metalness |
| `Rack_Roughness.png` | Roughness |
| ~~`Rack_Normal_DX.png`~~ | **Skip** |

### `textures/motherboard/` (6 PNGs, use 5)

| File | Channel |
|------|---------|
| `Motherboard_BaseColor.png` | Color |
| `Motherboard_Normal_GL.png` | Normal |
| `MotherB_AO.png` | AO (note: short name) |
| `Motherboard_Metallic.png` | Metalness |
| `Motherboard_Roughness.png` | Roughness |
| ~~`Motherboard_Normal_DX.png`~~ | **Skip** |

### `textures/gpu/` (7 PNGs, use 6)

Covers graphics cards **and** all 6 card fans.

| File | Channel |
|------|---------|
| `GPU_BaseColor.png` | Color |
| `GPU_Normal_GL.png` | Normal |
| `GPU_AO.png` | AO |
| `GPU_Metallic.png` | Metalness |
| `GPU_Roughness.png` | Roughness |
| `GPU_Emission.png` | Self Illum (LED glow) |
| ~~`GPU_Normal_DX.png`~~ | **Skip** |

---

## ModelDoc steps (VENGEANCE)

### 0. Sync into DXRP

```powershell
powershell -File lifepunch/scripts/Start-SboxDxrpEditor.ps1
# or:
powershell -File lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
```

Work path: `D:/Steam/steamapps/common/sbox/dxrp/game/Assets/addons/lifepunch/bitcoinmining/models/.../gpu-rack/`

### 1. Open / import the OBJ

1. Asset Browser → scope **DXRP** (not Cloud).
2. Navigate to `addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/source/`.
3. Double-click `gpu-rack-static.obj` → ModelDoc opens.
4. In the materials list you should see **5 slots**: `Cord`, `PSU`, `Rack`, `Motherboard`, `GPU`.

### 2. Assign the pre-built vmats (easiest path)

The repo already has wired vmats in `materials/`:

- `gpu-rack-cord.vmat`
- `gpu-rack-psu.vmat`
- `gpu-rack-rack.vmat`
- `gpu-rack-motherboard.vmat`
- `gpu-rack-gpu.vmat`

For **each** material slot in ModelDoc:

1. Click the **magnifying glass** next to the slot name.
2. Pick the matching `gpu-rack-*.vmat` from `materials/`.
3. If preview is pink/missing, open the vmat in **Material Editor** → verify paths → Save → compile.

**Slot → vmat cheat sheet:**

| ModelDoc slot | Pick this file |
|---------------|----------------|
| Cord | `gpu-rack-cord.vmat` |
| PSU | `gpu-rack-psu.vmat` |
| Rack | `gpu-rack-rack.vmat` |
| Motherboard | `gpu-rack-motherboard.vmat` |
| GPU | `gpu-rack-gpu.vmat` |

### 3. Compile the model

1. ModelDoc → **Compile** (or F9).
2. Output: `gpu-rack.vmdl` in the gpu-rack folder.
3. Preview in viewport — rack should be fully textured.

### 4. Optional: build vmats by hand in Material Editor

If you prefer clicking textures instead of using the pre-authored files:

1. Right-click `materials/` → Create Material → name `gpu-rack-psu` (etc.).
2. Shader: **Complex**.
3. PBR: tick **Specular** + **Metalness Texture**.
4. Drag PNGs from the table above into Color / Normal / AO / Metalness / Roughness.
5. GPU only: tick **Selfillum** → assign `GPU_Emission.png`.

---

## After vmats: prefab + play-test

1. Create `entities/bitcoin-miner/bitcoin-miner.prefab` with `GpuRackEntity` + model `gpu-rack.vmdl`.
2. Place in map → console `hashd` or `mine` within 8m.
3. Terminal: `mining start` / `mining stop`.

Defer: fan animation FBX, sounds, bitcoin-terminal prop vmdl.

---

## Sync back to monorepo

Copy from DXRP `game/Assets/addons/lifepunch/bitcoinmining/` back into `lifepunchaddons/Assets/addons/lifepunch/bitcoinmining/`:

- `gpu-rack.vmdl` + `_c` siblings
- compiled vmats
- `bitcoin-miner.prefab`
