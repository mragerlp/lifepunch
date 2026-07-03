# uranium-circuit-card

**Pack:** LowPoly SciFi Pack B 001 Â· **Source FBX:** `source/uranium-circuit-card.fbx`  
**Role:** Circuit card  
**Target vmdl:** `uranium-circuit-card.vmdl` (ModelDoc TODO)

## ModelDoc

1. Import `source/uranium-circuit-card.fbx` (prefer FBX over OBJ for s&box).
2. Material slots are **procedural** (no texture PNGs) â€” see `../MATERIAL_SLOTS.md`.
3. Create vmats under `materials/` or per-slot `complex.shader` baselines.
4. Compile `uranium-circuit-card.vmdl` â†’ pull `_c` via `Pull-DxrpCompiledAssetsToRepo.ps1`.
5. Wire prefab under `entities/uranium-circuit-card/` when gameplay is scoped.

## Scale

Tune `import_scale` in ModelDoc against a DXRP citizen (~64â€“72 units tall). Reactor is the scale reference for the job line.