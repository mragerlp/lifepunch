# hacker-terminal — criminal CRT (cornerman.exe)

**Slug:** `hacker-terminal`  
**Addon:** `hackerjob` (criminal lane)  
**World model:** `hacker-terminal.vmdl`  
**Prefab:** `entities/hacker-terminal/hacker-terminal.prefab`  
**UI overlay:** `HackerTerminal.razor` (cornerman.exe console — not baked into mesh)

## OneDrive drop

`OneDrive\Desktop\LIFEPUNCH*\addons\lifepunchhacker\hacker\hackerterminal\`

| File | Role |
|------|------|
| `source/computer thing.blend` | Authoring mesh (export to FBX) |
| `BM_BAKE_5.png` | Bake reference |
| `internal_ground_ao_texture.jpeg` | Ground AO |

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-HackerTerminalModel.ps1 -ExportFbx
```

Exports `hacker-terminal.fbx` via Blender when the drop has blend only. Archive: `C:\lifepunch\reference-intake\hackerjob\hackerterminal-v2`

## ModelDoc

1. Import `source/hacker-terminal.fbx` — **`import_scale` 0.0195** (same CRT prop family as bitcoin-terminal).
2. Material remaps in `hacker-terminal.vmdl` (Monitor/Keyboard/Cable/CPU/Black/White + green aliases).
3. LCD child on prefab (`lcd_screen`) — tune after compile.

**Compiled (Jun 2026):** `hacker-terminal.vmdl_c` + 6 `hacker-terminal-*.vmat_c` + `hacker-terminal.prefab_c` in repo.

## Lane split (Jun 2026)

| Lane | Terminal drop | Console brand |
|------|---------------|---------------|
| Criminal | `hacker\hackerterminal` | cornerman.exe (green) |
| Government | `fbi\governmentterminal` | lifepunchnet (cyan) — `governmentdatacenter` addon |

Advanced / Vengeance **terminal** tier is **parked** — advanced **server rack** is active.

## Dev smoke

```text
lp_spawn_hacker_terminal
lp_cornerman_preview
```
