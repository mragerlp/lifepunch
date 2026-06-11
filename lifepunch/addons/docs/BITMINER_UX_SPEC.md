# LIFEPUNCH Bitcoin Miner — UX & Economy Spec

**Status:** Phase 1 HASHD rig control shipped (`3633fb8`+); Phase 2 module menu drafted (`BITMINER_PHASE2_WIREFRAME.md`).  
**Study source:** `reference/evo-bitminer/` — mechanics and DXRP seams only; **never ship** Evo mesh, sounds, or UI copy.  
**Visual source (shipped Phase 1):** **HASHD RIG CONTROL** — amber mining ops (`#f0a500` on `#12100c`), left telemetry rail + right command log, `rig0>` prompt. **Distinct from** hacker-job green/red ops console and lifepunchnet cyan police shell.  
**World mesh:** LifePunch-owned **GPU rack** (`gpu-rack/`; raw export at `reference-intake/gpu-rack-export`).

---

## 1. Product pitch

A placeable **GPU mining rig** players buy, place, upgrade, and run to earn **sellable BTC** (cash via `PayHost`). The UI looks like a **mining rig control console** (amber HASHD), not the hacker job terminal.

Evo proved the economy loop works. We keep the loop, own the art, and ship a **better UX**.

### Rollout phases

| Phase | Owner | UX |
|-------|-------|-----|
| **1 — HASHD CLI + rail** | Shipped | `hashd` / `mine` opens rig; telemetry rail + `rig0>` log; upgrade overlay; `menu` opens upgrades. |
| **2 — Module menu** | VENGEANCE (Opus) | Rail + **Dashboard / Wallet / Upgrades / Log / About** modules; confirm modals; remove full-screen upgrade overlay. |

Phase 1 task: `docs/briefs/CORNERMAN_BITMINER_TERMINAL_TASK.md`  
Phase 2 draft: `docs/briefs/BITMINER_PHASE2_WIREFRAME.md` + `BITMINER_PHASE2_TOKENS.scss`

---

## 2. Economy loop (server-authoritative)

All payouts and charges go through **host RPCs** + `player.PayHost` / `player.ChargeHost` (see `BitminerEntity.cs`).

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

**Sell:** `bitcoin sell` → `RequestSellBitcoin()` → `PayHost`, zero balance.  
**Upgrades:** `RequestUpgrade(Cpu|Cores)` — charge on host; fail closed if `ChargeHost` fails.

**Synced state (`[Sync]`):** `IsMining`, `BitcoinAmount`, `CpuUpgradeLevel`, `CoreUpgradeLevel`, `ClockSpeed`, `CoreCount`, `MiningProgress`.

**World feedback:** fan/sequence anim, server hum, `TextRenderer` LCD, smoke + explosion on destroy.

**Pocket rule:** no mining/hum while entity has pocket tag.

---

## 3. UX — HASHD rig control

### 3a. Boot

On open (`hashd` / `mine`, or optional use-key):

```text
>> hashd init — LIFEPUNCH mining daemon
>> linking gpu-rack telemetry bus ... OK
>> syncing payout ledger (60s tick) ... OK
>> rig interface ready — telemetry rail active (left)
```

Phase 2: after boot, default module **Dashboard** (see wireframe).

### 3b. Phase 2 main window (module panes)

Reuse **ops-console platform shape** from `HACKER_OPS_CONSOLE_SPEC.md` (rail + modules + command line) with **amber** tokens only.

| Module | Purpose |
|--------|---------|
| **Dashboard** | Live cards + TICK bar + **START / STOP** → `SetMiningState` |
| **Wallet** | Balance + **SELL ALL** confirm → `RequestSellBitcoin()` |
| **Upgrades** | CPU / Cores rows + **INSTALL** → `RequestUpgrade`; rack row when dual-rack ships |
| **Log** | `rig0>` scrollback (Phase 1 console) |
| **About** | LIFEPUNCH™ only — **no** Evo / Spl Mute / BitOS credits |

**Chrome:** `#12100c` bg, `#3d3420` / `#5c4a22` borders, accent **`#f0a500`**, error `#e44b2a`. Font: Mina. Bottom-left 960×640. Auto-close if viewer > 150m.

Detail: `briefs/BITMINER_PHASE2_WIREFRAME.md` · tokens: `briefs/BITMINER_PHASE2_TOKENS.scss`

### 3c. In-world screen (`TextRenderer`)

- Accent: **`#f0a500`** amber (not Evo blue `#44aaff`, not hacker green `#00FF7F`)
- Labels: `LIFEPUNCH hashd`, `₿ balance`, `HASH`, `CORES`, progress bar

### 3d. Rack meshes + power animation (three entities)

**Owner canon (2026-06-11):** Small and advanced racks are **separate placeables**; terminal controls them remotely.

| Entity | Mesh | Yield (`BitminerEntity`) |
|--------|------|--------------------------|
| `bitcoin-miner` | `gpu-rack.vmdl` | `AdvancedRack=false` → `×1.0` |
| `advanced-bitcoin-miner` | `gpu-rack-stacked.vmdl` | `AdvancedRack=true` → `×2.0` |

Distill: `BITMINER_THREE_ENTITY_ARCH.md` · `BITMINER_DUAL_RACK_SPEC.md` (economy) · `BITMINER_REMOTE_RACK_SPEC.md` (multi-rig UX).

- **Power states:** `power_on` loop while `IsMining`; `power_off` when stopped.
- **Deprecate Evo pattern:** remove `BitminerFan*` child spin when vmdl anim wired (`TECH_DEBT` BITMINER-01).

### 3e. Terminal prop (control station — not on rack)

| Ship target | `BitminerTerminal.razor` + `BitminerTerminalProp` |
| Entity | `entities/bitcoin-terminal/bitcoin-terminal.prefab` |
| Prop mesh | `bitcoin-terminal.vmdl` from `computer.fbx` — **separate placeable** beside racks |

Separate addon from `hackerjob`; shared CRT mesh family, **different** palette and program (`hashd` / amber).

### 3f. Remote multi-rack hashd UX (Phase 2)

When terminal registers multiple `BitminerEntity` rigs in range:

**Telemetry rail:**

```text
RACKS   2 linked (1× SMALL · 1× ADVANCED)
ACTIVE  rig-0 SMALL · MINING
        rig-1 ADVANCED · IDLE
SELECT  rig-0
```

**CLI (spec):** `racks` · `select <id>` · `mining start [id|all]` · `mining stop [id|all]`

**Upgrades:** CPU/Cores apply to **selected rig** (per-rig economy on each `BitminerEntity`).

Full spec: `docs/reference/BITMINER_REMOTE_RACK_SPEC.md`.

---

## 3g. Player experience (three placeables)

1. **Place** a **Bitcoin Terminal** (CRT) within ~4 m of one or more racks — **Bitcoin Miner** (small) and/or **Advanced Bitcoin Miner** (stacked, 2× yield).
2. **Open hashd** — USE the terminal or type `hashd` / `mine` while near a rig (≤8 m).
3. **Register racks** — telemetry rail shows linked rigs; type `racks` for the list.
4. **Mine** — `mining start all` or `select <id>` then `mining start`; rail **START** / **STOP** toggles the selected rig.
5. **Upgrade** — `upgrade` / `menu` for CPU and cores on the **selected** rig (per-rig economy).
6. **Cash out** — `bitcoin sell` (Phase 1 CLI) or **Wallet → SELL ALL** when Phase 2 modules ship.

Fast editor preview: `lp_hashd_preview` (console opens without waiting on CRT ModelDoc compile).

---

## 4. What we improve vs Evo

| Evo | LIFEPUNCH |
|-----|-----------|
| CLI-only BitOS terminal | HASHD modules + `rig0>` log |
| `root@bitminer` / BitOS 1.0 | `rig0>` / `hashd` / `mine.exe` |
| Blue terminal chrome `#44aaff` | Amber HASHD `#f0a500` |
| Cloud `models/bitminer` mesh | Own gpu-rack vmdl |
| Third-party sound pack | Own/licensed sounds |
| `credits` → Spl Mute | LIFEPUNCH™ About only |
| Info wrong rate (`0.05`) | Display uses `0.005` formula (fix `info` command on Red if still wrong) |

---

## 5. Code architecture

| File | Status |
|------|--------|
| `Bitminer.cs` | ✅ package identity |
| `BitminerEntity.cs` | ✅ economy + RPCs |
| `BitminerTerminalHost.cs` | ✅ dual-build mount |
| `BitminerTerminal.razor` | ✅ Phase 1 HASHD; Phase 2 modules per wireframe |
| `BitminerTerminal.razor.scss` | ✅ amber tokens |

Dual-build: `LIFEPUNCH_LOCAL` — see `RUNTIME_PATTERN.md`.

---

## 6. Relation to other terminals

| | **Bitminer** | **Hacker Job** | **Police** |
|--|--------------|----------------|------------|
| Accent | Amber `#f0a500` | Green / red | Cyan `#00D4FF` |
| Program | `hashd` | `cornerman.exe` / `vengeance.exe` | `lifepunch-ops.exe` |
| Layout | HASHD rig (+ modules) | Ops console | Ops console (Phase 4) |
| Matrix | `TERMINAL_BRAND_MATRIX.md` | same | same |

**Not** the same UI skin — shared platform *patterns* only (`HACKER_OPS_CONSOLE_SPEC.md`).

---

## 7. Build order

1. ModelDoc: gpu-rack + materials (VENGEANCE)
2. Prefab: entity, screen, collider
3. Phase 2 UI merge (Opus) + protection fixes (`BITMINER_PROTECTION_CHECKLIST.md`)
4. Sounds + compile `_c`
5. `prepare-publish.ps1 -Addon bitcoinmining`

---

## 8. Cornerman (Tier-3)

Distill for Red; no editor work on Green. Protection audit: `briefs/BITMINER_PROTECTION_CHECKLIST.md`.
