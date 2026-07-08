# LIFEPUNCH Stream Deck setup (Galleon 100 SD)

Use one PowerShell launcher so every key stays stable:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\jared\Projects\lifepunch\lifepunch\scripts\Invoke-LifePunchDeckAction.ps1 -Action <ACTION>
```

## 1. Copilot/lane control

| Key label | Action | Command |
|---|---|---|
| LP Repo | Open monorepo root | `... -Action OpenRepo` |
| LP Bitcoin Files | Open primary lpbitcoin UI files in VS Code | `... -Action OpenLpBitcoinFiles` |

## 2. s&box loop

| Key label | Action | Command |
|---|---|---|
| Start DXRP Editor | Run full DXRP editor boot path | `... -Action StartSboxEditor` |
| Sync Addons | Sync `lpbitcoin` + `adminmenu` into DXRP runtime | `... -Action SyncAddons` |

## 3. MCP ops

| Key label | Action | Command |
|---|---|---|
| MCP Health | Checks `sbox-editor`, `cornerman-lm` via CVL probe | `... -Action McpHealth` |

## Portal quick access

| Key label | Action | Command |
|---|---|---|
| DXRP Portal | Open `https://dxrp.net/portal` in Google Chrome | `... -Action OpenDxrpPortalChrome` |

## 4. Git safety

| Key label | Action | Command |
|---|---|---|
| Git Status | Branch, working tree, staged diff stat | `... -Action GitStatus` |
| Pull Rebase | Run `git pull --rebase` in repo root | `... -Action GitPullRebase` |

## 5. CVL observability

| Key label | Action | Command |
|---|---|---|
| CVL Health | VENGEANCE memory/bloat health + CVL connectivity checks | `... -Action CvlObservability` |

## Recommended first 10 keys

1. LP Repo
2. LP Bitcoin Files
3. Start DXRP Editor
4. Sync Addons
5. DXRP Portal (Chrome)
6. MCP Health
7. Git Status
8. Pull Rebase
9. CVL Health
10. Start LifePunch Day (`powershell -File C:\Users\jared\Projects\lifepunch\lifepunch\scripts\Start-LifePunchDay.ps1`)
