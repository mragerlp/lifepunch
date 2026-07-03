# Hacker Job — assets

**Package:** `lifepunch.hackerjob` · **Portal:** `019e448c-4958-77d1-84b7-c7ec3f1bc328`

| Path | Purpose |
|------|---------|
| `models/.../hacker-terminal/` | Standard CRT (cornerman.exe green) |
| `models/.../advanced-hacker-terminal/` | Advanced CRT (vengeance.exe red) |
| `entities/hacker-terminal/` | World prefab (editor build — see `ENTITY_PREFAB_BUILD.md`) |
| `entities/advanced-hacker-terminal/` | Red-tier world prefab |
| `ui/cornerman/` | Cornerman console / loading / terminal art |
| `ui/vengeance/` | Vengeance console / loading / terminal art |
| `entities/advanced-server-rack/` | Vengeance-tier rack prefab |
| `models/.../advanced-server-rack/` | Advanced rack OBJ + vmdl stub |
| `sounds/hacker-terminal/` | Keyboard SFX (optional) |

**Red runbook:** `addons/docs/RED_HACKER_JOB_BUILD.md`

**Seed CRT mesh:**

```powershell
powershell -File lifepunchaddons/scripts/Intake-HackerTerminalModel.ps1
```

Standard CRT: `Intake-HackerTerminalModel.ps1` · Advanced: `Intake-AdvancedHackerTerminal.ps1` (owner pack `addon stuff\hackerjobassets\...\advancedhackerterminal`).
