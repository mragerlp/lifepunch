# SciFi Pack B — shared material slots

All 12 props use the same **procedural** MTL slots (no external texture PNGs in the pack).

| Slot | Use | vmat target (TODO) |
|------|-----|-------------------|
| `M_Cyan` | Glowing cyan panels / uranium accent | `materials/uranium-scifi-cyan.vmat` |
| `M_Gris_Metal` | Brushed metal body | `materials/uranium-scifi-metal.vmat` |
| `M_Noir_Bleute` | Dark blue-grey housing (pack: M_Noir_Bleute) | `materials/uranium-scifi-dark.vmat` |
| `M_Noir_Profond` | Deep black trim | `materials/uranium-scifi-black.vmat` |
| `M_Orange` | Warning / hazard accent | `materials/uranium-scifi-orange.vmat` |

Start with `complex.shader` baselines tinted to match MTL `Kd`/`Ke` from any `source/*.mtl` file.

**License:** Pack_SciFi_B_001 — commercial use in projects OK; no redistribution of raw FBX/OBJ. See `intake-raw/pack-scifi-b-001/04_DOCS/LICENSE.txt`.
