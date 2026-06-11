# hacker-terminal — standard CRT (cornerman.exe)

**Slug:** `hacker-terminal`  
**Source:** `source/hacker-terminal.fbx` (owner pack — `Intake-HackerTerminalModel.ps1`)  
**Target:** `hacker-terminal.vmdl`  
**Prefab:** `entities/hacker-terminal/hacker-terminal.prefab`  
**UI overlay:** `HackerTerminal.razor` (cornerman.exe console — not baked into mesh)

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-HackerTerminalModel.ps1
```

Archive: `C:\lifepunch\reference-intake\hackerjob\hackerterminal-v2`

## ModelDoc

1. Open `hacker-terminal.vmdl` — import `source/hacker-terminal.fbx`.
2. Start `import_scale` at **39.37** (match bitminer terminal); tune to desk height vs citizen.
3. Note material slots from import → fill `material-map.json` + author vmats (green `#00FF7F` monitor accent).
4. Compile → `Pull-DxrpCompiledAssetsToRepo.ps1`.

## Screen + console (prefab — no ModelDoc required for UI)

| Layer | What |
|-------|------|
| **World LCD** | Child `lcd_screen` + `TextRenderer` wired to `HackerTerminalEntity.ScreenText` |
| **Console UI** | USE interact or `cornerman` → `HackerTerminal.razor` overlay |

**Owner tune after compile:** nudge `lcd_screen` Position/Rotation on the prefab so text sits on the monitor glass.

## Dev smoke

```text
lp_spawn_hacker_terminal
lp_cornerman_preview
```
