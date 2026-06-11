# LIFEPUNCH Uranium Specialist Job — spec (foundation)

**Package:** `lifepunch.uraniumspecialist` · **Status:** assets intake only  
**Assets:** LowPoly SciFi Pack B (`Pack_SciFi_B_001_V1.0`) — 12 power/energy props

## Scope (TBD — owner sign-off before Opus economy pass)

DXRP job line using placeable sci-fi power props: reactor processing, enrichment, sell loop (mirror bitminer/hacker job patterns where it fits).

**P0 assets (intake done):**

- `uranium-reactor` — centerpiece
- `uranium-control-panel` — operator station
- `uranium-energy-cell` / `uranium-cell` — material props

**P1 set dressing:** cabinet, junction, fuse box, battery, capacitor, circuit card, switch, cooling fan.

## Asset paths

See `Assets/addons/lifepunch/uraniumspecialist/ASSET_INVENTORY.md`

## Intake / re-run

```powershell
powershell -File lifepunch/addons/scripts/Intake-UraniumSpecialistScifiPack.ps1
```

## ModelDoc gate

1. Compile `uranium-reactor.vmdl` → establish `import_scale`
2. Shared vmats from `MATERIAL_SLOTS.md` (procedural colors — no pack textures)
3. Prefabs under `entities/<slug>/` after `_c` in repo

## Not in scope yet

- DXRP job definition / paycheck
- Economy RPCs
- Portal `dxrpAddonId`
