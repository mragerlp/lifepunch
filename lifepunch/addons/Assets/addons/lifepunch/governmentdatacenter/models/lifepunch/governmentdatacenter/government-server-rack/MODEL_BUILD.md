# government-server-rack — FBI / government cyber hub (Fab DataCenter)

**Slug:** `government-server-rack`  
**Addon:** `governmentdatacenter`  
**Source:** Fab [Servers (DataCenter)](https://www.fab.com/listings/ab865a8b-c6c8-4362-8998-50bc8239277d) — same mesh family as criminal hacker rack; FBI lane drop is separate for tint/variant work later.  
**Target:** `government-server-rack.vmdl`

## OneDrive drop

`OneDrive\Desktop\LIFEPUNCH*\addons\lifepunchhacker\fbi\governmentserverrack`

Glass textures: `Materials\materials\Glass_Cover_*.png` inside the rack folder (or sibling glass pack).

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-GovernmentServerRack.ps1
```

Archive: `C:\lifepunch\reference-intake\governmentdatacenter\government-server-rack`

## ModelDoc

| Slot | vmat |
|------|------|
| `Server_Trim` | `government-server-rack-trim.vmat` |
| `Glass` / `Glass.002` | `government-server-rack-glass.vmat` |

1. Import `source/government-server-rack.fbx` — start `import_scale` **1.0**.
2. Compile trim + glass vmats (2K paths under `source/textures/`).
3. Prefab + `GovernmentServerRackEntity` gameplay = Phase F (after Hacker Job ship).

**Compiled (Jun 2026):** `government-server-rack.vmdl_c` + vmats + `government-server-rack.prefab_c` in repo.

## Lane split (Jun 2026)

| Lane | Package folder | Rack | Terminal |
|------|----------------|------|----------|
| Criminal | `lifepunchhacker\hacker\` | `serverrack` | `hackerterminal` |
| Government | `lifepunchhacker\fbi\` | `governmentserverrack` | `governmentterminal` |

Advanced / Vengeance tier racks and terminals are **parked** — not in active intake.
