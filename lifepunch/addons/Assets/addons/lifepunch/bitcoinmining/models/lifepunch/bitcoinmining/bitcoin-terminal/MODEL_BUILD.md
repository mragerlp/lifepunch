# bitcoin-terminal — in-world CRT / computer prop

**Slug:** `bitcoin-terminal`  
**Source:** `source/computer.fbx` (from owner `hackerterminal/source/bitcointerminal`)  
**Target:** `bitcoin-terminal.vmdl` in this folder  
**Razor UI:** `Code/Addons/lifepunch/bitcoinmining/HashdTerminal.razor` (screen overlay — separate from this mesh)

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
2. **`import_scale = 0.0272`**, **`import_rotation = [0, 0, 0]`**, align **Center / Center / Bottom** (Jun 2026 — drop stale `-90` pitch; it laid the CRT on its side). Prefab root **`1,1,1`**.
3. Compile `bitcoin-terminal.vmdl`.
3. **Separate entity** `entities/bitcoin-terminal/bitcoin-terminal.prefab` — not a child of `bitcoin-miner`.
4. `lcd_screen` `TextRenderer` on terminal; `BitcoinTerminalProp` auto-links to nearest rig + opens hashd on USE.
5. **Compile in ModelDoc (required — ERROR mesh until `_c` exist):**
   - Open `bitcoin-terminal.vmdl` in **DXRP** project scope (not standalone `addons.sbproj`).
   - Compile each `materials/bitcoin-terminal-*.vmat` (six files).
   - Compile `bitcoin-terminal.vmdl` → produces `bitcoin-terminal.vmdl_c`.
6. **Prefab collider:** `BoxCollider` **Center** + **Scale** must equal **`model.Bounds`** (white wireframe in prefab editor). Copy from `lp_bitcoin_scale_audit` log line `modelBounds center=… size=…` — **not** `GetBounds()` world render bounds. `LpBitcoinTerminalEntity.OnAwake` auto-syncs green box from `model.Bounds` when the prefab loads. **Unique prefab GUIDs** — never reuse `bitcoin-miner` placeholder guids.
7. **Pull compiled into monorepo** (repo→DXRP `/MIR` deletes `_c` if missing from git):
   ```powershell
   powershell -File lifepunch/scripts/Pull-DxrpCompiledAssetsToRepo.ps1
   ```
   `Start-SboxDxrpEditor.ps1` runs this automatically before sync.

## Relation to gpu-rack

| Asset | Role |
|-------|------|
| `gpu-rack.vmdl` | World mining rack; `power_on` / `power_off` anim |
| `bitcoin-terminal.vmdl` | CRT/computer prop on or near rack |
