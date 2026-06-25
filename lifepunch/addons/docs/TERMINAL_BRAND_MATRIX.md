# LifePunch terminal brand matrix

**“Terminal”** = placeable entity with an ops program UI attached — not a generic prop name. Player commands run only in the **in-fiction ops console** after **USE** on the entity. **Not** the s&box developer `>` console. Canon: `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`.

> **Visual identity law:** See `CYBER_VISUAL_IDENTITY_DOCTRINE.md` (2026-06-25). Green (Cornerman), Red (VENGEANCE), Cyan (lifepunchnet), and Amber (HASHD) are locked role identities — not interchangeable cosmetics. HASHD donor themes on Bitcoin surfaces must stay within the allowed amber/gold range. Full green/red/cyan impersonation of other lanes is prohibited.

In-game terminals mirror **LifePunch Ops** machine uniforms (`branding/lifepunch-ops/THEME.md`).

| Tier | Machine | Job / role | Program | Accent | Prompt | Terminal entity | Hub entity | Lane status |
|------|---------|------------|---------|--------|--------|-----------------|------------|-------------|
| Hacker Terminal (starter) | **Cornerman** | Hacker | `cornerman.exe` | `#00FF7F` green | `cornerman@terminal:~$` | `hacker-terminal` | `server-rack` | Quarantined / legacy reference |
| Advanced Hacking Terminal (purchased) | **VENGEANCE** | Hacker (elevated) | `vengeance.exe` | `#E4002B` red | `vengeance@terminal:~$` | `advanced-hacker-terminal` | `advanced-server-rack` | Quarantined / legacy reference |
| Government Terminal | **lifepunchnet** | Police, FBI, Mayor, Gov jobs | `lifepunch-ops.exe` | `#00D4FF` cyan | `lifepunch@lifepunch.net:~$` | `police-terminal` | `government-server-rack` | Future / blocked |
| Bitcoin Operator Terminal | **hashd** | Civilian + most jobs *(not gov/LE)* | hashd rig control | `#f0a500` amber | `rig0>` | `hashdterminal` | `bitcoinhub` | **Active lane / in progress** |
| Government Data Center | *(city rig)* | Map treasury — autonomous miner | `treasuryd` (TBD) | `#00D4FF` blue console | N/A — LCD only | — | `government-data-center` | Future / blocked |

**Starter vs purchased (hacker):** green rack + terminal = **job starter** (low cost, less secure, wallet hacks). Red rack + terminal = **purchased upgrade** (expensive, complex commands, higher rewards — player miners, bank, govdb).

**lifepunchbitcoin access:** every job may spawn/USE hashd hub + terminal + racks **except Government / Law Enforcement** — city uses Government Data Center only.

## HASHD Terminal commands (Bitcoin — `hashdterminal`)

Player-facing typed commands at `rig0>`:

- `help` · `status` · `racks` · `select` · `link`
- `mining start` · `mining stop` · `deposit` · `send`

Legacy compatibility: `sell` may exist in code paths — **new copy uses `deposit` and Hub Wallet `cashout`**, not terminal sell.

## Hub administration (`LpHashdPanel` on `bitcoinhub`)

- Power · PIN/authentication · overview/status · wallet · BTC **cashout to DXRP bank**
- Transfers view · Hub upgrades · per-rack hardware upgrades · logs/settings

**No mining start/stop or P2P command entry on the Hub panel.** Wallet cashout remains on the Hub Wallet tab.

**Deposit** may be initiated from HASHD Terminal `deposit` or Hub Servers/Rack UI when dual-command-surface design applies — both call the same authoritative Hub RPC (`BITCOIN_DATA_FLOW.md`).

## Physical terminal rule (Bitcoin)

- **One HASHD Terminal per player** — operator command console (`hashdterminal`).
- **GPU Rack** = worker (`gpurack`) — not a second full Terminal owner.
- Rack USE may show telemetry or direct the player to HASHD; if current code opens the shared CRT from rack USE, treat as **implementation quick-access delegation**, not rack-owned terminal authority. Do not change code in doc-only passes.

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
| **Hub admin panel** | USE on **Bitcoin Hub** (`bitcoinhub`) | **Fully clickable** — power, linking, wallet cashout, upgrades | **Modern dashboard** — `LpHashdPanel` |
| **HASHD Terminal CRT** | USE on **`hashdterminal`** only | **Type commands** — `mining start/stop`, `deposit`, `send`, etc. | **Gray CRT** (`lp-ops-crt--gray`) · prompt `rig0>` |

**Rule of thumb:** Hub = easy ops. Terminal = power-user / roleplay authenticity via **text commands**.

**Bitcoin v2:** USE **hub** → modern **admin** dashboard (power, wallet, upgrades). USE **HASHD Terminal** → gray CRT (`rig0>`). Rack USE = worker telemetry / quick-access only — not a second Terminal product surface.

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
