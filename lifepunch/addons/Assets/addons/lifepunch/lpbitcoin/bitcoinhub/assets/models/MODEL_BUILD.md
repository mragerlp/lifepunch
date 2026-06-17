# Bitcoin hub (CPU GAMER) — ModelDoc foundation pass

**Source:** `game/source/fbx/cpu_gamer.fbx` (Fab — solid vertex colors, no textures)  
**vmdl:** `cpu-gamer.vmdl`  
**Phase:** Foundation only — no prefab / entity code until owner sign-off.

## ModelDoc settings (v1)

| Field | Value |
|-------|--------|
| import_scale | 1.0 (tune vs citizen ~64–72u after first spawn) |
| import_rotation | 0,0,0 |
| align | Center / Center / Bottom |
| Materials | `materials/default.vmat` baseline — remap Fab slots after mesh group audit |
| Animation | **Do not** use rigged body — fan spin = child GO Phase 2 |

## Sign-off gate

- [ ] Mesh upright, feet on ground in `lifepunch-modeldoc.scene`
- [ ] Scale vs dev plane / citizen reference
- [ ] No explode / missing parts
- [ ] Owner OK before promote to `bitcoinmining` ship tree
