# lifepunch.bitcoin — greenfield rebuild (June 2026)

**Law:** Concepts from specs stay. **v1 code/assets are reference-only** — not compiled, not spawned.

| Keep (words) | Drop (implementation) |
|--------------|----------------------|
| Economy constants (`BITCOINMINING_UX_SPEC.md`) | v1 `HashdTerminal`, hub spaghetti, broken vmats |
| HASHD amber UI (`#f0a500` / `#12100c`) Phase 2 modules | v1 Phase 1 overlay + material remap debt |
| Hub + rack + USE → ops console | Deprecated standalone terminal UX |
| Cyber-ecosystem identity (criminal lane) | Copy-paste from hacker/gov UI colors |
| Placement caps (hub 2, rack 3+1) | Old prefab collider / spin hacks |

**Package:** `lifepunchbitcoin` · **s&box:** `lifepunch.bitcoin` · **repo folder:** `bitcoinmining/`

## Two UI surfaces (law)

| Surface | Opens from | Interaction | Look |
|---------|------------|-------------|------|
| **Hub admin** | USE Ophion hub | **Click-first** — power, rack info, paid upgrades | Modern dashboard (`LpHashdPanel`) |
| **CRT terminal** | USE terminal prop or GPU rack | **Type commands** — mine/stop/sell; optional command sidebar | Retro terminal (`LpBitcoinTerminalPanel`) |

Hub = admin. Terminal = mine/stop/sell via typed commands (authentic, less hand-holding). BTC accrues on **GPU racks**, not the hub.

---

## MCP tool routing (greenfield)

### Runtime — `sbox` (192 tools)

| Task | Tools |
|------|-------|
| Play proof | `console_run`, `editor_is_playing` (editor), `read_log` |
| Spawn / place | `spawn_model`, `create_gameobject`, `create_interactable` |
| Screenshots | `screenshot_orbit`, `take_screenshot`, `frame_camera` |
| UI hotload | `trigger_hotload`, `create_razor_ui` |
| Economy scaffold | `create_economy_wallet` (study pattern — hub uses DXRP `PayHost`) |
| Debug | `get_scene_hierarchy`, `execute_csharp`, `describe_type` |

### Editor — `sbox-editor` (74+ imported)

| Task | Tools |
|------|-------|
| New prefab / scene | `gameobject_create`, `prefab_create_from_gameobject`, `scene_open` |
| ModelDoc / vmat | `modeldoc_create_from_mesh`, `modeldoc_set`, `material_create`, `asset_compile` |
| Code | `code_write_file`, `code_get_compile_errors`, `editor_run_console_command` |
| Shader (post-P0) | `shadergraph_get/set`, imported `ShaderTemplate.*` |
| UI designer (optional) | imported `SuiDocument.*` from `kikozl.sbox_ui_designer` |

### Imported library tools

Enable when lane needs them. **P0:** skip shader_graph_extras unless leaving `complex.shader`. **UI:** SUI designer optional if Razor module menu is faster (owner choice).

---

## Build order (v2)

| Step | Deliverable |
|------|-------------|
| **0** | v1 code → `reference-intake/`; v2 compiles clean |
| **1** | `LpBitcoinHub` + modern ops UI (`LpHashdPanel`) + dev spawn placeholders |
| **2** | Host economy loop (90s tick, sell, upgrades) wired to UI |
| **3** | `LpBitcoinRack` link + yield; flatgrass full-kit proof |
| **4** | New prefabs + owner Ophion re-intake (fresh ModelDoc, no v1 vmats) |
| **5** | Power/emissive/audio; visual pass brief sign-off |

---

## Dev commands (v2)

```text
lp_map_flatgrass
lp_bitcoin_spawn_kit        # hub + 3 small + 1 large (placeholders until new prefabs)
lp_bitcoin_spawn_hub        # hub only
```

---

## Canon refs

- `BITCOINMINING_UX_SPEC.md` — economy numbers
- `briefs/BITCOINMINING_PHASE2_WIREFRAME.md` — UI modules
- `briefs/BITCOIN_OPHION_VISUAL_PASS_BRIEF.md` — world-first proof
- `LIFEPUNCH_CYBER_ECOSYSTEM.md` — lane context
