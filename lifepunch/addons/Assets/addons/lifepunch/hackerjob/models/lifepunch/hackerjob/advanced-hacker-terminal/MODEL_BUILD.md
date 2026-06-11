# advanced-hacker-terminal — Vengeance CRT (vengeance.exe)

**Slug:** `advanced-hacker-terminal`  
**Source:** `source/computer.fbx` (same base mesh; red skin in materials)  
**Target:** `advanced-hacker-terminal.vmdl`  
**Brand:** `#E4002B` per `TERMINAL_BRAND_MATRIX.md`

## Seed

Same script as standard tier — copies FBX into this folder:

```powershell
powershell -File lifepunch/addons/scripts/Seed-HackerTerminalCrt.ps1
```

## ModelDoc

1. Open `advanced-hacker-terminal.vmdl`.
2. Duplicate / retint materials for Vengeance red accents.
3. Compile → build advanced prefab (`ENTITY_PREFAB_BUILD.md`).

## Dev

```text
lp_spawn_advanced_hacker_terminal
```
