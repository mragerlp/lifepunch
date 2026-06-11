# Hacker Job — editor playtest (with bots)

**Red runbook:** `addons/docs/RED_HACKER_JOB_BUILD.md` (Step 0 smoke).

Solo editor testing uses **`StaffMenuTestBots`** (`adminmenu/StaffMenuTestBots.cs`) — same bots as staff menu / waypoint tests. No second human required.

## Setup (host, editor play)

```text
lifepunch_spawn_testbot Greg
lifepunch_spawn_testbot
```

Or a full roster row:

```text
lifepunch_spawn_rankbots
```

Bots register in `GameNetworkManager.Players` with real or fake SteamIds and **`WalletBalance`** (wallet cash — bank is separate and untouchable by design).

Cleanup when done:

```text
lifepunch_clear_testbots
```

## Hacker terminal — standard (green)

```text
lp_cornerman_ui
scan
```

`scan` lists **live players** (bots included). Copy a SteamId from the list — not the old stub ids unless no bots are spawned.

```text
hack <steamid from scan>
```

Solve the puzzle (e.g. `drain(wallet);`, `cornerman_bypass`, or `1`).

**Pass:** Greg / Test Dummy appears in scan with wallet $ (bots init with wallet via `InitalizeHost`); puzzle completes; bypass stub prints.

## Hacker terminal — advanced (red)

```text
lp_vengeance_ui
govdb
infil govdb-tax-01
govdb_breach
```

Govdb node list is still stub until tax miners ship on map.

## Bot commands reference

| Command | Purpose |
|---------|---------|
| `lifepunch_spawn_testbot [name]` | One targetable dummy near you |
| `lifepunch_spawn_rankbots` | Rank ladder + Greg (owner mirror) |
| `lifepunch_spawn_rankbots false` | Rank bots only — no Greg |
| `lifepunch_botsay "Greg hi"` | Bot chat for RP smoke |
| `lifepunch_clear_testbots` | Despawn all test bots |

## Sync before play

```powershell
powershell -File lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon hackerjob,adminmenu
```

`adminmenu` carries `StaffMenuTestBots.cs` — required for bot spawn commands.
