# LifePunch terminal brand matrix

In-game terminals mirror **LifePunch Ops** machine uniforms (`branding/lifepunch-ops/THEME.md`).

| Tier | Machine | Job / role | Program | Accent | Prompt | Entity |
|------|---------|------------|---------|--------|--------|--------|
| Hacker Terminal | **Cornerman** | Hacker | `cornerman.exe` | `#00FF7F` green | `cornerman@terminal:~$` | `hacker-terminal` |
| Advanced Hacking Terminal | **VENGEANCE** | Hacker (elevated) | `vengeance.exe` | `#E4002B` red | `vengeance@terminal:~$` | `advanced-hacker-terminal` |
| Government / Police Terminal | **lifepunchnet** | Police, Mayor, Gov jobs | `lifepunch-ops.exe` | `#00D4FF` cyan | `lifepunch@lifepunch.net:~$` | `police-terminal` |
| Player Bitcoin Miner | *(player rig)* | Civilian economy | `hashd` / `mine.exe` | `#f0a500` amber | `rig0>` | `bitcoin-miner` |
| Government Tax Miner | *(city rig)* | City treasury | `treasuryd` (TBD) | `#00D4FF` blue console | N/A — LCD only | `government-tax-miner` |

## Capabilities by terminal

| Terminal | Primary loop | Economy touch |
|----------|----------------|---------------|
| Hacker (standard) | `scan` → `hack` wallet puzzles | Wallet theft (Phase 2 Opus) |
| Hacker (advanced) | `govdb` → `infil` node puzzles | Govdb breach (Phase 2 Opus) |
| Police | Trace alerts, audit miners, warrants (TBD) | City funds read / counter-hack |
| Gov tax miner | Always mine BTC → hourly tax % → city cash | Server-only treasury |
| Bitcoin mining hub | Mine → upgrade → sell | Player `PayHost` |

## Dev smoke commands

```text
lp_cornerman_ui          # standard hacker (green)
lp_vengeance_ui            # advanced hacker (red)
lp_lifepunch_ops_ui        # police terminal (Phase 2)
lp_spawn_hacker_terminal           # standard world entity (prefab TBD in editor)
lp_spawn_advanced_hacker_terminal  # red-tier world entity
```

## UI layout families

| Layout | Terminals | Spec |
|--------|-----------|------|
| **Ops Console** (rail + modules + command line) | Hacker green/red · Police cyan (Phase 4) | `HACKER_OPS_CONSOLE_SPEC.md` · `reference/GOVERNMENT_DATABASE_TERMINAL_SPEC.md` |
| **HASHD rig control** (telemetry rail + `rig0>`; Phase 2 + module panes) | Bitcoin mining hub amber `#f0a500` | `BITCOINMINING_UX_SPEC.md` · `briefs/BITCOINMINING_PHASE2_WIREFRAME.md` |
| **LCD summary** | Gov tax miner blue console | `governmentdatacenter/docs/GOVERNMENT_TAX_MINER_BUILD.md` |

## Cybersecurity Officer

Owner builds separately — not in this matrix yet.

## SWAT job

Future — CS2 model study pipeline (`CS2_WEAPON_HARVEST.md` pattern). See `SWAT_JOB_SPEC.md`.
