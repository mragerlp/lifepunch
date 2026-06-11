# Cyber ecosystem — asset audit (2026-06-11)

**Addons:** `hackerjob` · `bitcoinmining` · `governmentdatacenter`  
**Verdict summary:** hacker **BLOCKED** (_c) · bitcoin **PARTIAL** (hub + sounds) · gov **EMPTY**

---

## hackerjob

| Asset | Intaken | Ship path | Blocker |
|-------|---------|-----------|---------|
| Standard CRT mesh | ✅ | `hacker-terminal/source/hacker-terminal.fbx` | ModelDoc + `_c` |
| Advanced CRT mesh | ✅ | `advanced-hacker-terminal/source/hacker-terminal.fbx` | ModelDoc + `_c` |
| Vengeance UI PNGs | ✅ | `ui/vengeance/*.png` | Not wired in Razor yet |
| Cornerman UI PNGs | ❌ | — | Owner pack has PNGs; Red intake pending |
| Commodore PET.blend | ❌ ship | Owner `addon stuff\...\Hacker Terminal\` | Export FBX for new standard mesh |
| Basic server rack DAE | ✅ | `server-rack/source/server-rack.dae` | **Textures folder empty** · ModelDoc + `_c` |
| Advanced server rack OBJ | ✅ | `advanced-server-rack/source/*.obj` | **No vmdl/prefab/entity** (Red scaffold pending) |
| Keyboard SFX | ❌ | `sounds/hacker-terminal/` missing | Owner WAV intake |
| Prefabs | ✅ ×3 | terminals + basic rack | **prefab_c = 0** |
| vmdl | ✅ ×3 | all scaffolds | **vmdl_c = 0** |
| vmat | ❌ | 0 in tree | ModelDoc author |

**Code (Phase 1):** UI shell, rack menu, dev spawns, security seams — **done**.  
**Code (Phase 2):** wallet transfer, host scan, job gate — **Opus, owner sign-off**.

**Playtest today:** `lp_cornerman_ui` / `lp_vengeance_ui` **YES** (no prefab). World CRT + rack **NO** until `_c`.

---

## bitcoinmining

| Asset | Intaken | `_c` | Blocker |
|-------|---------|------|---------|
| `gpu-rack.vmdl` | ✅ | ✅ | vmats baseline — playtest OK |
| `gpu-rack-stacked.vmdl` | ✅ | ✅ | same |
| `bitcoin-terminal.vmdl` | ✅ | ✅ | deprecated — hub owns HASHD |
| `bitcoin-miner` hub (Ophion) | ✅ source | ❌ | **Hub ModelDoc + vmat** |
| Sounds | ❌ | — | `sounds/bitcoinminer/README.md` only — owner intake |
| Prefabs | ✅ ×3 | 2/3 `_c` | hub prefab `_c` if hub vmdl uncompiled |

**Playtest today:** `lp_spawn_gpu_rack` + `lp_hashd_preview` **PARTIAL** — racks yes; hub power gate blocked on hub `_c`.

---

## governmentdatacenter

| Asset | Status |
|-------|--------|
| Ship tree | `.gitkeep` only |
| Owner pack | `addon stuff\...\governmentterminal\` (Stol2.obj + lifepunchnet PNGs) — **not intaken** |
| Desktop drop | `governmentdatacenter\` folder — empty until owner drops |
| Code | `GovernmentTaxMiner.cs`, `PoliceTerminal.cs` constants only |

**Blocked on:** `Intake-GovernmentDatacenter.ps1` after owner drop + Red entity/prefab scaffold.

---

## Owner action list (when back from legal)

1. ModelDoc compile pass (see `MODELDOC_CHECKLIST_CYBER_2026-06-11.md`)
2. Export `Commodore PET.blend` → `hacker-terminal.fbx` (optional mesh refresh)
3. Drop gov art in `Desktop\governmentdatacenter\`
4. Bitcoin sounds → owner intake script
5. Say **"scaffold advanced server rack"** to Red if not merged yet

## Red action list (no legal needed)

- Advanced server rack scaffold
- Cornerman UI intake
- Gov terminal intake from addon stuff pack
- Server-rack texture intake fix
- Commit bundle (owner approves)
