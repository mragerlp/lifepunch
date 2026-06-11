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
3. **Separate entity** `entities/bitcoin-terminal/bitcoin-terminal.prefab` — not a child of `bitcoin-miner`.
4. `lcd_screen` `TextRenderer` on terminal; `BitminerTerminalProp` auto-links to nearest rig + opens hashd on USE.
5. **Compile in ModelDoc (required — ERROR mesh until `_c` exist):**
   - Open `bitcoin-terminal.vmdl` in DXRP project scope.
   - Compile each `materials/bitcoin-terminal-*.vmat` (six files).
   - Compile `bitcoin-terminal.vmdl` → produces `bitcoin-terminal.vmdl_c`.
   - Sync compiled `_c` back to monorepo before publish.

## Relation to gpu-rack

| Asset | Role |
|-------|------|
| `gpu-rack.vmdl` | World mining rack; `power_on` / `power_off` anim |
| `bitcoin-terminal.vmdl` | CRT/computer prop on or near rack |
