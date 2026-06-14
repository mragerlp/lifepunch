# hacker-terminal — standard CRT (cornerman.exe)

> **World mesh (Jun 2026):** Prefab uses shared **`bitcoin-terminal.vmdl`** from `bitcoinmining` — same computer prop as hashd terminals. Gameplay/UI stays `cornerman.exe`. Local `hacker-terminal.vmdl` is **deprecated** (do not ship).

**Slug:** `hacker-terminal`  
**World model:** `addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-terminal/bitcoin-terminal.vmdl`  
**Prefab:** `entities/hacker-terminal/hacker-terminal.prefab`  
**UI overlay:** `HackerTerminal.razor` (cornerman.exe console — not baked into mesh)

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-HackerTerminalModel.ps1
```

Archive: `C:\lifepunch\reference-intake\hackerjob\hackerterminal-v2`

## ModelDoc

No local vmdl — world mesh is **`bitcoin-terminal.vmdl`** (see `bitcoinmining/.../bitcoin-terminal/MODEL_BUILD.md`). LCD child matches bitcoin-terminal prefab (`lcd_screen` @ `0,18,3.5`).

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
