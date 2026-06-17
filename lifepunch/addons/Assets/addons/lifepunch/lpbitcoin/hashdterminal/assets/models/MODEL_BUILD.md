# HASHD Terminal — ModelDoc foundation pass

**Source:** `assets/source/fbx/PC.fbx`  
**vmdl:** `assets/models/hashd-terminal.vmdl`  
**Phase:** B — Terminal (Model Foundation)

## ModelDoc settings (v1)

| Field | Value |
|-------|--------|
| import_scale | 0.0272 (legacy seed — tune vs citizen after compile) |
| import_rotation | 0,0,0 |
| align | Center / Center / Bottom |
| Materials | Monitor + Keyboard_mause remaps (audit extra slots in ModelDoc) |
| CRT glow | `hashd-terminal-monitor.vmat` — amber self-illum baseline |

## Compile order

1. Open `hashd-terminal.vmdl` in ModelDoc
2. Recompile vmats first, then vmdl
3. Fix slot remaps if ModelDoc shows unmapped materials
4. Scene proof: `_dev/scenes/lifepunch-modeldoc.scene`

## Sign-off gate (Phase B)

- [ ] Compiles with zero ERROR
- [ ] Monitor glow readable at night
- [ ] Scale vs hub + citizen reference
- [ ] Owner OK before prefab wire
