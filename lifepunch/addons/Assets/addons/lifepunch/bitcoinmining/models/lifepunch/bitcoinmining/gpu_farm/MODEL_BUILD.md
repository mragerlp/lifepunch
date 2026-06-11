# GPU Farm — Bitminer world model

LifePunch-owned mesh for the in-house **Bitminer** entity (replaces third-party reference geometry).

## Active source

```text
source/GPU_Farm_Static.obj
source/GPU_Farm_Anim.fbx
source/GPU_Farm_Stacked_Anim.fbx
source/<texture folders>/
```

## Target

```text
models/lifepunch/bitcoinmining/bitminer/bitminer.vmdl
entities/bitminer/bitminer.prefab
```

Pattern reference only: `reference/evo-bitminer/` (do not ship evo assets).

## Blender → FBX

1. Import `GPU_Farm_Static.obj` (or FBX if rig/anim needed).
2. Apply scale/rotation; match DXRP entity footprint vs `reference/evo-bitminer` prefab.
3. Export `bitminer.fbx` → `source/bitminer.fbx` when ready for ModelDoc.
4. Build `.vmat` from texture sets under `source/GPU_*`, `Motherboard`, etc.

## Cornerman intake

Mirror also lives on Green: `C:\lifepunch\reference-intake\bitcoinmining\gpu-farm\`
