# police-terminal — lifepunchnet cyan CRT

**Slug:** `police-terminal`  
**Source:** `source/police-terminal.obj` + `source/textures/*` (`Intake-GovernmentTerminal.ps1`)  
**Target:** `police-terminal.vmdl`  
**Prefab:** `entities/police-terminal/police-terminal.prefab` (TODO)  
**UI art:** `ui/lifepunchnet/*.png`  
**Accent:** `#00D4FF` per `GovernmentDatacenter.TerminalAccentHex`

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-GovernmentTerminal.ps1
```

## ModelDoc

1. Open `police-terminal.vmdl` (create stub mirroring hacker-terminal pattern).
2. Import `source/police-terminal.obj`; map hologram_glass + table slots from textures.
3. Compile → unblocks vengeance `govdb` scan against real tax miner nodes.
