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

### 3d. Dual rack mesh + power animation

**Owner decision (2026-06-11):** Small + large racks on one prefab; yield scales when large rack expansion is active.

| Rack | Mesh | Yield |
|------|------|-------|
| Small | `gpu-rack.vmdl` | Base `×1.0` |
| Large | `gpu-rack-stacked.vmdl` | +bonus when expansion active (proposed `×2.0` total) |

Distill: `docs/reference/BITMINER_DUAL_RACK_SPEC.md` · `briefs/CORNERMAN_BITMINER_DUAL_RACK_TASK.md`.

- **Power states:** `power_on` loop while `IsMining`; `power_off` when stopped.
- **Deprecate Evo pattern:** remove `BitminerFan*` child spin when vmdl anim wired (`TECH_DEBT` BITMINER-01).

### 3e. Terminal prop

| Ship target | `Code/Addons/lifepunch/bitcoinmining/BitminerTerminal.razor` |
| Prop mesh | `bitcoin-terminal.vmdl` from `computer.fbx` (CRT on rig) |

Separate addon from `hackerjob`; shared CRT mesh family, **different** palette and program.

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
