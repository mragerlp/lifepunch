# hacker-terminal — standard CRT (cornerman.exe)

**Slug:** `hacker-terminal`  
**Source:** `source/computer.fbx` (seeded from bitminer CRT family via `Seed-HackerTerminalCrt.ps1`)  
**Target:** `hacker-terminal.vmdl`  
**UI:** `Code/Addons/lifepunch/hackerjob/HackerTerminal.razor` (overlay — not this mesh)

## Seed

```powershell
powershell -File lifepunch/addons/scripts/Seed-HackerTerminalCrt.ps1
```

## ModelDoc

1. Open `hacker-terminal.vmdl` → verify FBX import scale (~39.37, match bitminer terminal).
2. Note material slots → fill `material-map.json`.
3. Compile; fix missing vmats (no checkerboard in publish).
4. Build prefab per `hackerjob/docs/ENTITY_PREFAB_BUILD.md`.

## Dev

```text
lp_spawn_hacker_terminal
```
