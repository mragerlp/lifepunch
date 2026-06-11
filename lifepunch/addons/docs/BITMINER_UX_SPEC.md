# LIFEPUNCH Bitcoin Miner — UX & Economy Spec

**Status:** Greenlit concept for build (assets in repo; code port next on VENGEANCE).  
**Study source:** `reference/evo-bitminer/` — mechanics and DXRP seams only; **never ship** Evo mesh, sounds, or UI copy.  
**Visual source:** LifePunch **Cornerman Hacker Terminal** outfit (`#00FF7F` on `#0a0f0a`, `cornerman@rig:~$` voice).  
**World mesh:** LifePunch-owned **GPU rack** (`gpu-rack/`, 34 publish files; raw export at `reference-intake/gpu-rack-export`).

---

## 1. Product pitch

A placeable **GPU mining rig** players buy, place, upgrade, and run to earn **sellable BTC** (cash via `PayHost`). The UI *looks and feels* like the **Cornerman hacker terminal** — boot sequence, green phosphor, ops chrome.

Evo proved the economy loop works. We keep the loop, own the art, and ship a **better UX**.

### Rollout phases

| Phase | Owner | UX |
|-------|-------|-----|
| **1 — CLI + command gate** | Cornerman (Qwen 2.5) | Type `hashd` or `mine` in-game to **open** the terminal on the nearest rig; run Evo-style commands (`mining start`, `upgrade cpu`, …). `menu` command stubs Phase 2. |
| **2 — Tabbed menu** | VENGEANCE (Opus) | `menu` (or boot completion) opens Dashboard / Wallet / Upgrades tabs; optional Terminal tab keeps CLI. |

Phase 1 task: `docs/briefs/CORNERMAN_BITMINER_TERMINAL_TASK.md`

---

## 2. Economy loop (keep from Evo — server-authoritative)

All payouts and charges go through **host RPCs** + `player.PayHost` / `player.ChargeHost` (see `BitminerEntity.cs` in reference).

| Constant | Value | Notes |
|----------|-------|-------|
| `BaseSpeed` | `0.005` BTC per tick unit | × clock × cores |
| `MiningInterval` | `60` seconds | One payout tick per minute while mining |
| `BitcoinValue` | `$1500` / BTC | Sell multiplier |
| Start clock | `2.44 GHz` | |
| Start cores | `1` | |
| CPU upgrade | +`1.5 GHz` per level | Costs `2k → 128k` (7 tiers) |
| Core upgrade | +`2` cores per level | Costs `50k / 100k / 175k` (3 tiers) |

**Per-minute rate (display):** `ClockSpeed × 0.005 × CoreCount` BTC/min  
**Payout each tick:** same formula once per 60s while `IsMining`.

**Sell:** `bitcoin sell` → `uint(BitcoinAmount × 1500)` via `PayHost`, then zero balance.  
**Upgrades:** charge player on host; fail closed if `ChargeHost` fails.

**Synced state (`[Sync]` from host):** `IsMining`, `BitcoinAmount`, `CpuUpgradeLevel`, `CoreUpgradeLevel`, `ClockSpeed`, `CoreCount`, `MiningProgress` (0–1 within 60s window).

**World feedback (keep):** fan spin ramp, server hum, `TextRenderer` on rig screen, smoke + explosion on destroy (60 dmg AoE on ship build).

**Pocket rule:** no mining/hum while entity has pocket tag.

---

## 3. UX — LifePunch terminal shell + real menu

### 3a. Boot (Cornerman aesthetic)

On **open** (`hashd` / `mine` command, or optional use-key on rig), play a **short boot sequence** (2–4s, skippable):

```text
LIFEPUNCH hashd v1.0
[ OK ] memory 256mb
[ OK ] gpu-rack mesh
[ OK ] mounting /dev/rig0
starting mine.exe ...
```

Then transition to **main UI** (not a blank CLI). Optional **Terminal** tab keeps CLI for power users.

### 3b. Main window (StaffMenu-style structure)

Reuse patterns from `StaffMenu.razor`: title bar, tabs, icon buttons, confirm dialogs.

| Tab | Purpose |
|-----|---------|
| **Dashboard** | Live cards: mining on/off indicator, BTC balance, USD value, progress bar (60s), hash rate, clock, cores. Primary **START / STOP** toggle (big). |
| **Wallet** | Balance + **SELL ALL** button → confirm modal → `RequestSellBitcoin()`. Show estimated `$` before confirm. |
| **Upgrades** | Two rows: **CPU Clock** and **GPU Cores** — current level, next cost, **[Purchase]** button (disabled if maxed or unaffordable). No typing `upgrade cpu`. |
| **Terminal** | Optional retro pane: scrollback + `cornerman@rig:~$` prompt; maps same commands as Evo (`help`, `status`, `mining`, `bitcoin`, `upgrade`, `clear`). Keyboard SFX on type. |
| **About** | LIFEPUNCH™ attribution — **no** Evo/Spl Mute credits. |

**Chrome:** dark panel `#0a0f0a`, border `#1a3a2a`, accent `#00FF7F`, error `#E4002B`. Font: Mina or repo terminal stack. Close ✕ top-right. Auto-close if viewer > 150m (keep Evo rule).

### 3c. In-world screen (`TextRenderer`)

Keep Evo's on-rig LCD summary but re-skin copy:

- Accent color: `#00FF7F` (not Evo blue `#44aaff`)
- Labels: `LIFEPUNCH hashd`, `₿ balance`, `HASH`, `CORES`, progress bar

### 3d. GPU rack mesh + power animation

- World model: compiled `gpu-rack.vmdl` from **gpu-rack** source tree (`gpu-rack-static.obj` + materials).
- **Power states (owner decision):** rack **animates when turned on** (`IsMining == true`) and **powers down when turned off** — no always-on idle spin.
- ModelDoc: bake `source/gpu-rack-anim.fbx` into the vmdl with two sequences — **`power_on`** (loop while mining) and **`power_off`** (idle/stopped). `BitminerEntity.SetMiningState` drives which sequence plays.
- **Emission** on GPU cards: brighter while mining (shader param or material toggle at mine start/stop).
- **Deprecate Evo pattern:** drop `BitminerFan` / `BitminerFan2` / `BitminerFan3` child spinners once vmdl anim is wired on the prefab (`TECH_DEBT` BITMINER-01).

### 3e. Terminal UI + prop intake

| Lane | Path |
|------|------|
| **Razor authoring (owner)** | `C:\Users\jared\Downloads\newaddons\hackerterminal\source\bitcointerminal\` |
| **Ship target (repo)** | `Code/Addons/lifepunch/bitcoinmining/BitminerTerminal.razor` + `.razor.scss` |
| **Terminal prop mesh (in intake folder)** | `computer.fbx` / `computer.blend` — in-world CRT/terminal prop on the rig (ModelDoc TBD) |

Cornerman Phase 1 CLI already lives in the repo; owner-authored tabbed UI replaces/extends it from the bitcointerminal lane. Shared hacker-terminal **skin** with Hacker Job — separate addons, separate prefabs.

---

## 4. What we improve vs Evo

| Evo | LIFEPUNCH |
|-----|-----------|
| CLI-only BitOS terminal | Tabbed menu + optional CLI tab |
| `root@bitminer` / BitOS 1.0 | `cornerman@rig` / `LIFEPUNCH hashd` / `mine.exe` |
| Blue terminal chrome | Cornerman green hacker terminal |
| Cloud `models/bitminer` mesh | Own gpu-rack vmdl |
| Third-party sound pack | Own/licensed sounds |
| `credits` → Spl Mute | LIFEPUNCH proprietary footer |
| Info command wrong rate (`0.05`) | Display uses correct `0.005` formula |

---

## 5. Code architecture (port plan)

| File | Action |
|------|--------|
| `Bitminer.cs` | ✅ scaffolded — local model paths |
| `BitminerEntity.cs` | Port from reference; keep simulation/RPCs; namespace `LifePunch.DXRP.Addons.BitcoinMining` |
| `BitminerTerminalHost.cs` | Port mount/close; `LIFEPUNCH_LOCAL` branches |
| `BitminerTerminal.razor` | Author in `Downloads/.../bitcointerminal/` → ship tabbed UI per §3b; boot per §3a |
| `BitminerTerminal.razor.scss` | Cornerman palette tokens from `lifepunch-ops/THEME.md` |
| `bitcoin-miner.prefab` | Clone reference; swap model path; wire fans/TextRenderer |
| Sounds | New assets under `sounds/bitcoin-miner/` |

Dual-build: `LIFEPUNCH_LOCAL` — see `RUNTIME_PATTERN.md`. **Tier-1 (Opus)** for entity + economy; UI can follow in same pass.

---

## 6. Relation to Hacker Job

| | **Bitminer** (`bitcoinmining`) | **Hacker Job** (`hackerjob`) |
|--|-------------------------------|------------------------------|
| Entity | GPU rig, economy generator | CRT terminal, job ability |
| UI skin | Same **hacker terminal** family | `cornerman.exe` fiction, wallet steal puzzle |
| Economy | Mine → sell BTC for cash | Steal wallet cash (draft, not built) |

Shared SCSS tokens; **separate addons**, separate prefabs.

---

## 7. Build order

1. ModelDoc: gpu-rack → `gpu-rack.vmdl` + 5 materials (VENGEANCE editor)
2. Prefab: wire entity, fans, screen, collider (VENGEANCE editor)
3. Code port: `BitminerEntity` + new tabbed `BitminerTerminal` (VENGEANCE Cursor, Opus)
4. Sounds + compile `_c`
5. Portal package + `prepare-publish.ps1 -Addon bitcoinmining`

---

## 8. Cornerman (Tier-3)

Distill this spec + `BITMINER_ENTITY_BRIEF.md` for Red; **no** editor work on Green.
