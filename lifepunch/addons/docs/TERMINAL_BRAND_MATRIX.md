# LifePunch terminal brand matrix

**“Terminal”** = placeable entity with an ops program UI attached — not a generic prop name. Player commands run only in the **in-fiction ops console** after **USE** on the entity. **Not** the s&box developer `>` console. Canon: `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`.

In-game terminals mirror **LifePunch Ops** machine uniforms (`branding/lifepunch-ops/THEME.md`).

| Tier | Machine | Job / role | Program | Accent | Prompt | Terminal entity | Hub entity |
|------|---------|------------|---------|--------|--------|-----------------|------------|
| Hacker Terminal | **Cornerman** | Hacker | `cornerman.exe` | `#00FF7F` green | `cornerman@terminal:~$` | `hacker-terminal` | `hacker-server-rack` |
| Advanced Hacking Terminal | **VENGEANCE** | Hacker (elevated) | `vengeance.exe` | `#E4002B` red | `vengeance@terminal:~$` | `advanced-hacker-terminal` | `advanced-hacker-server-rack` |
| Government / Police Terminal | **lifepunchnet** | Police, Mayor, Gov jobs | `lifepunch-ops.exe` | `#00D4FF` cyan | `lifepunch@lifepunch.net:~$` | `police-terminal` | *(TBD)* |
| Player Bitcoin Miner | **hashd** | Civilian economy | hashd rig control | `#f0a500` amber | `rig0>` | `bitcoin-miner` | `gpu-rack` / `large-gpu-rack` |
| Government Tax Miner | *(city rig)* | City treasury | `treasuryd` (TBD) | `#00D4FF` blue console | N/A — LCD only | `government-tax-miner` | — |

## Capabilities by terminal

| Terminal | Primary loop | Economy touch |
|----------|----------------|---------------|
| Hacker (standard) | `scan` → `hack` wallet puzzles | Wallet theft (Phase 2 Opus) |
| Hacker (advanced) | `govdb` → `infil` node puzzles | Govdb breach (Phase 2 Opus) |
| Police | Trace alerts, audit miners, warrants (TBD) | City funds read / counter-hack |
| Gov tax miner | Always mine BTC → hourly tax % → city cash | Server-only treasury |
| Bitcoin mining hub | Mine → upgrade → sell | Player `PayHost` |

## Editor helpers (place entities — not player gameplay)

```text
lp_spawn_hacker_terminal / lp_spawn_server_rack   # place hacker kit
lp_spawn_bitcoin_miner_hub / lp_spawn_gpu_rack    # place mining kit
lp_cornerman_ui / lp_vengeance_ui                  # UI compile smoke only
```

Real playtests: **USE the world terminal / hub.** No job verbs in the developer console.

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
