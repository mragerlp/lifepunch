# bitcoin-terminal — in-world CRT / computer prop

**Slug:** `bitcoin-terminal`  
**Source:** `source/computer.fbx` (from owner `hackerterminal/source/bitcointerminal`)  
**Target:** `bitcoin-terminal.vmdl` in this folder  
**Razor UI:** `Code/Addons/lifepunch/bitcoinmining/BitminerTerminal.razor` (screen overlay — separate from this mesh)

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-BitcoinTerminalAssets.ps1
```

Archive (blend only): `C:/lifepunch/reference-intake/bitcoinmining/bitcoin-terminal-export/`

## DXRP editor

```powershell
lifepunch/scripts/Start-SboxDxrpEditor.ps1 -SyncAddon bitcoinmining
```

## ModelDoc

1. Import `computer.fbx`; note material slots → fill `material-map.json`.
2. Compile `bitcoin-terminal.vmdl`.
3. On `bitcoin-miner.prefab`: child mesh for terminal screen area OR separate prop parented to rack.
4. `TextRenderer` on rig screen can stay for in-world LCD summary; Razor terminal opens on interact.

## Relation to gpu-rack

| Asset | Role |
|-------|------|
| `gpu-rack.vmdl` | World mining rack; `power_on` / `power_off` anim |
| `bitcoin-terminal.vmdl` | CRT/computer prop on or near rack |
