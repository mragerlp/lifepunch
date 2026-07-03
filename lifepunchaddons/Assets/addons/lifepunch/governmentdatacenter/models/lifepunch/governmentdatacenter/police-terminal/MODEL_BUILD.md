# police-terminal — lifepunchnet cyan CRT

**Slug:** `police-terminal`  
**Source:** `source/police-terminal.obj` + `source/textures/*` (`Intake-GovernmentTerminal.ps1`)  
**Target:** `police-terminal.vmdl`  
**Prefab:** `entities/police-terminal/police-terminal.prefab`  
**UI art:** `ui/lifepunchnet/*.png`  
**Accent:** `#00D4FF` per `GovernmentDatacenter.TerminalAccentHex`

**Compiled (Jun 2026):** `police-terminal.vmdl_c` + vmats + `police-terminal.prefab_c` in repo.  
**Scale:** `import_scale = 39.37` (meter OBJ → hammer units).  
**Flatgrass audit (Jun 2026):** bounds ~80×40×55 @ prefab 1,1,1 — matches desk terminal target; collider 50×70×40 is close (width tune optional).

## Intake

```powershell
powershell -File lifepunchaddons/scripts/Intake-GovernmentTerminal.ps1
```

## ModelDoc

1. Open `police-terminal.vmdl` (create stub mirroring hacker-terminal pattern).
2. Import `source/police-terminal.obj`; map hologram_glass + table slots from textures.
3. Compile → unblocks vengeance `govdb` scan against real tax miner nodes.
