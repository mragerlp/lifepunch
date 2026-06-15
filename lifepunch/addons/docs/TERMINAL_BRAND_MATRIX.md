# LifePunch terminal brand matrix

**“Terminal”** = placeable entity with an ops program UI attached — not a generic prop name. Player commands run only in the **in-fiction ops console** after **USE** on the entity. **Not** the s&box developer `>` console. Canon: `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`.

In-game terminals mirror **LifePunch Ops** machine uniforms (`branding/lifepunch-ops/THEME.md`).

| Tier | Machine | Job / role | Program | Accent | Prompt | Terminal entity | Hub entity |
|------|---------|------------|---------|--------|--------|-----------------|------------|
| Hacker Terminal (starter) | **Cornerman** | Hacker | `cornerman.exe` | `#00FF7F` green | `cornerman@terminal:~$` | `hacker-terminal` | `server-rack` |
| Advanced Hacking Terminal (purchased) | **VENGEANCE** | Hacker (elevated) | `vengeance.exe` | `#E4002B` red | `vengeance@terminal:~$` | `advanced-hacker-terminal` | `advanced-server-rack` |
| Government Terminal | **lifepunchnet** | Police, FBI, Mayor, Gov jobs | `lifepunch-ops.exe` | `#00D4FF` cyan | `lifepunch@lifepunch.net:~$` | `police-terminal` | `government-server-rack` |
| Player Bitcoin Miner | **hashd** | Civilian + most jobs *(not gov/LE)* | hashd rig control | `#f0a500` amber | `rig0>` | `bitcoin-terminal` | `bitcoin-miner` |
| Government Data Center | *(city rig)* | Map treasury — autonomous miner | `treasuryd` (TBD) | `#00D4FF` blue console | N/A — LCD only | — | `government-data-center` |

**Starter vs purchased (hacker):** green rack + terminal = **job starter** (low cost, less secure, wallet hacks). Red rack + terminal = **purchased upgrade** (expensive, complex commands, higher rewards — player miners, bank, govdb).

**lifepunchbitcoin access:** every job may spawn/USE hashd hub + terminal + racks **except Government / Law Enforcement** — city uses Government Data Center only.

## Capabilities by terminal

| Terminal | Primary loop | Economy touch |
|----------|----------------|---------------|
| Hacker (standard / starter) | `scan` → `hack` wallet puzzles | Wallet theft (Phase 2 Opus); cheap kit, weaker security |
| Hacker (advanced / purchased) | `govdb` → `infil`; breach miners + bank + gov nodes | High-reward targets; complex puzzles |
| Government (lifepunchnet) | Trace alerts, audit miners, counter large-scale breaches | City funds read / counter-hack vs red tier |
| Government Data Center | Always mine BTC → tax % (0–30%) → city cash | Server-only treasury; parallel to mayor rate |
| Bitcoin mining hub | Power, link racks, buy upgrades | Terminal `sell` → player `PayHost`; **blocked for gov/LE jobs** |

## Editor helpers (place entities — not player gameplay)

```text
lp_spawn_hacker_terminal / lp_spawn_server_rack   # place hacker kit
lp_spawn_bitcoin_miner_hub / lp_spawn_gpu_rack    # place mining kit
lp_cornerman_ui / lp_vengeance_ui                  # UI compile smoke only
```

Real playtests: **USE the world terminal / hub.** No job verbs in the developer console.

## UI layout families (two surfaces — do not mix)

LifePunch uses **two UI surfaces**. They are different products, not skins of each other.

| Surface | What it is | Interaction law | Visual |
|---------|------------|-----------------|--------|
| **Physical terminal** | CRT / desk prop — in-fiction **ops program** | **Type commands as text** — primary loop is prompt + scrollback + executing real command strings. Optional **sidebar** for command reference / module navigation; sidebar helps, it does **not** replace typing. Harder by design than hub menus. | **Old-school terminal** — per-job accent from matrix below. Greenfield code only — better than v1, not copy-paste. |
| **Hub admin panel** | USE on **Ophion hub** | **Fully clickable** — power, linking info, per-rack upgrades. No mine/stop/sell on hub. | **Modern dashboard** — `LpHashdPanel` |
| **Bitcoin CRT terminal** | USE on **terminal prop** or **GPU rack** | **Type commands** — `mining start`, `sell`, etc.; optional sidebar lists commands only. | **Gray CRT** (`lp-ops-crt--gray`) · prompt `rig0>` |

**Rule of thumb:** Hub = easy ops. Terminal = power-user / roleplay authenticity via **text commands**.

**Bitcoin v2:** USE **hub** → modern **admin** dashboard (power + upgrades). USE **terminal** or **rack** → gray CRT (`rig0>`). Hacker green CRT layout saved as `lp-ops-crt--hacker` — see `branding/OPS_CRT_TERMINAL_THEMES.md`.

**Hub panel:** `LpHashdPanel` · **Bitcoin CRT:** `LpBitcoinTerminalPanel` (`--gray`) · **Hacker CRT (future):** `lp-ops-crt--hacker`

| Layout (terminals only) | Terminals | Spec |
|--------|-----------|------|
| **Ops CRT** (sidebar + typed prompt) | Bitcoin gray · Hacker green · Vengeance red · Gov cyan · Banker `#000080` · Black market `#000000` · Casino `#FF00FF` | `branding/OPS_CRT_TERMINAL_THEMES.md` |
| **Ops Console** (legacy hacker modules) | Hacker until CRT migration | `HACKER_OPS_CONSOLE_SPEC.md` |
| **LCD summary** | Gov tax miner blue console | `governmentdatacenter/docs/GOVERNMENT_TAX_MINER_BUILD.md` |

## Cybersecurity Officer

Owner builds separately — not in this matrix yet.

## SWAT job

Future — CS2 model study pipeline (`CS2_WEAPON_HARVEST.md` pattern). See `SWAT_JOB_SPEC.md`.
