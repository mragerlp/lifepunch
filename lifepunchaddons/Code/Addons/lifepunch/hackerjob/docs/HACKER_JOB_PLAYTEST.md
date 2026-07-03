# Hacker Job — editor playtest (with bots)

**Red runbook:** `addons/docs/RED_HACKER_JOB_BUILD.md` (Step 0 smoke).

**Scale / map (Jun 2026):** `facepunch.flatgrass` + `addons/docs/MODEL_SCALE_DOCTRINE.md`. Prefab root **1.0**; shared `bitcoin-terminal.vmdl` **`import_scale` 0.0195** (was giant @ 1.0). Never default **39.37**. Recompile vmdl after edits.

Solo editor testing uses **`StaffMenuTestBots`** (`Code/_dev/StaffMenuTestBots.cs`) — same bots as staff menu / waypoint tests. No second human required.

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

**Production path:** **Hacker job** → powered CRT → **USE to log in** (or `cornerman` at the entity) → type `scan` / `hack` at **`cornerman@terminal:~$`** in the ops console only. Not the s&box developer `>` console.

**Dev smoke test** (login without world CRT):

```text
lp_hacker_kit_preview
```

Then **USE** the cornerman CRT, or `lp_cornerman_ui` for a floating dev stub only.

**Inside the terminal UI** (not the game console):

```text
scan
hack <steamid from scan output>
```

`scan` lists **live players** (bots included). Copy a SteamId from the list — not the old stub ids unless no bots are spawned.

Solve the puzzle in the terminal prompt (e.g. `drain(wallet);`, `cornerman_bypass`, or `1`).

**Pass:** Greg / Test Dummy appears in scan with wallet $ (bots init with wallet via `InitalizeHost`); puzzle completes; bypass stub prints.

## Server racks

```text
lp_spawn_server_rack
lp_spawn_advanced_server_rack
lp_hacker_kit_preview
```

`lp_hacker_kit_preview` places **basic rack + cornerman** on the left and **advanced rack + vengeance** on the right (both powered). Interact each rack for upgrades — advanced rack has higher detection/puzzle tier caps.

Terminals within ~8m of a powered rack come online; registry prefers tier-matched rack (cornerman → basic, vengeance → advanced).

## Hacker terminal — advanced (red)

```text
lp_vengeance_ui
govdb
infil govdb-tax-01
govdb_breach
```

Govdb node list is stub until `governmentdatacenter` tax miners compile on map (`Intake-GovernmentTerminal.ps1` intaken).

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

`Code/_dev/` carries `StaffMenuTestBots.cs` — editor-only; not in lifepunchulx publish. Required for bot spawn commands during playtest.
