# LPBITCOIN RESTART PACKET — read-only distill

**Generated:** 2026-06-29 (Cornerman prep — eyes covered)  
**Monorepo:** `C:\Users\jared\Projects\lifepunchaddons` (Green clone synced @ `732fc40`)  
**Mode:** read-only · no code · no commits · no compile/editor/flatgrass claims  
**Author:** Cornerman distill (Tier-3) — not ship authority

---

## 1. Current repo state

| Field | Value | Label |
|-------|-------|-------|
| **HEAD** | `732fc409c5a24a8aa459f5a38e46e2dc194257aa` (`732fc40`) | VERIFIED FROM REPO |
| **Branch** | `main` · tracking `origin/main` | VERIFIED FROM REPO |
| **Dirty state** | Clean tracked tree; untracked only: `lifepunch/docs/handoff/dxrp/*`, `Push-CornermanDxrp73ReviewDistill.ps1` | VERIFIED FROM REPO |
| **Recent commits (relevant)** | `732fc40` commit-hygiene rule + hook · prior bitcoin/lpbitcoin UI canon commits through `6eb2c74` GO DOCS reconciliation | VERIFIED FROM REPO |
| **DXRP #73 separation** | Party bounty lives in **`C:\Users\jared\Projects\dxrp-public`** (`bounty/73-party-system`, PR #77). **No party system code in monorepo.** | VERIFIED FROM REPO |

---

## 2. Current lpbitcoin state (code + canon)

### Active lane (canon)

| Item | Status | Label |
|------|--------|-------|
| Single active workstream | `lifepunchbitcoin` / repo ident `bitcoinmining` / staging `lpbitcoin/*` | VERIFIED FROM CANON |
| Phase | **Phase A Hub polish** — H10 blocks Phase B Terminal | VERIFIED FROM CANON |
| Three-surface upgrades | DECISION-0010: Universal Upgrades home → HUB / TERMINAL / GPU RACK | VERIFIED FROM CANON |
| Upgrades = purchase surface only | Canon law; Servers tab should become read-only status (U1) | VERIFIED FROM CANON |
| Economy / five-track purchases | **HOLD** — cost curves, migration, Opus route | VERIFIED FROM CANON |
| Hub admin UI (unlinked) | Owner signed off 2026-06-24 | VERIFIED FROM CANON |
| Hub world mesh / H10 | **Not complete** — flatgrass proof open | VERIFIED FROM CANON |

### Static Upgrades shell (Universal Upgrades tab)

| Item | Status | Label |
|------|--------|-------|
| `LpHashdPanel.razor` static shell present | Yes — comments at ~997–1111: "UI-only shell", "no economy/persistence yet" | VERIFIED FROM REPO |
| Tier I–V tier-line UI | Yes — Tier I = `BASE`, II–V = `PLANNED` | VERIFIED FROM REPO |
| Purchase banner | `"PURCHASES NOT YET ENABLED"` lock banner on path detail | VERIFIED FROM REPO |
| Fake buy buttons in Universal path | **None** — path buttons open static tier line only; no `Buy $` in universal drill-in | VERIFIED FROM REPO |
| Fake prices in Universal path | **None** — code comment: "No prices: purchases not yet enabled" | VERIFIED FROM REPO |
| Track data | Static `HubUpgradeTracks`, `TerminalUpgradeTracks`, `GpuRackUpgradeTracks` shells | VERIFIED FROM REPO |

### 3-box Universal Upgrades home

| Item | Status | Label |
|------|--------|-------|
| Three surface launcher boxes | **Present** — HUB / TERMINAL / GPU RACK (`EnterUpgradeSurface`) | VERIFIED FROM REPO |
| Foot meta | Each box shows `5 tracks · PLANNED` (GPU: `3 racks · 5 tracks · PLANNED`) | VERIFIED FROM REPO |
| Sub-navigation back stack | `BackToUpgradesHome`, `BackFromPathList`, `_inUpgradeSurface` flag | VERIFIED FROM REPO |
| SCSS for upgrade-home-grid | Present in `LpHashdPanel.razor.scss` (~5886+) | VERIFIED FROM REPO |
| Runtime navigation proof | Not verified this session | NEEDS SBOX RUNTIME PROOF |

### GPU Rack target-home launcher

| Item | Status | Label |
|------|--------|-------|
| Rack target selection step | **Present** — after GPU RACK surface: 3 boxes (GPU RACK 1, GPU RACK 2, ADVANCED GPU RACK) | VERIFIED FROM REPO |
| `_rackTargetSelected` gate | Yes — must pick rack before track list | VERIFIED FROM REPO |
| Per-rack section headline | `UpgradeRackSelectorHeadline()` drives GPU track section title | VERIFIED FROM REPO |
| Runtime proof | Not verified this session | NEEDS SBOX RUNTIME PROOF |

### Servers / Racks tab (legacy vs U1 target)

| Item | Status | Label |
|------|--------|-------|
| Tab label | **"Servers"** (`OpsTab.Racks`) | VERIFIED FROM REPO |
| Home grid | **3 rack slots only** (GPU Rack 1, GPU Rack 2, Advanced) — reuses `upgrade-home-box` pattern | VERIFIED FROM REPO |
| **Missing vs U1 spec** | No **Bitcoin HUB** or **HASHD Terminal** status cards on Servers home | VERIFIED FROM REPO · **GAP vs canon** |
| Drill-in detail | Per-rack stats tiles (balance, hardware, mining) when linked | VERIFIED FROM REPO |
| **Legacy purchase entry** | Linked racks show **Upgrade** button → `OpenRackUpgrades` → **legacy CPU/Core buy UI** on Upgrades tab with real `Buy $` + `RequestUpgradeCpu/Cores` | VERIFIED FROM REPO |
| Intro copy | Still says "open its hardware upgrades" on Servers home | VERIFIED FROM REPO |
| U1 read-only conversion | **Not started** | VERIFIED FROM CANON + REPO |

### Legacy CPU/Core drill-in (conflicts with DECISION-0010 direction)

| Item | Status | Label |
|------|--------|-------|
| Legacy path location | `GetUpgradeRack().IsValid()` branch at top of Upgrades tab — CPU clock + Core count tracks | VERIFIED FROM REPO |
| Real economy wired | `UpgradeCpu` / `UpgradeCores` → `_hub.RequestUpgradeCpu/Cores` → host methods on `LpBitcoinHubEntity` | VERIFIED FROM REPO |
| Rack sync fields | `CpuUpgradeLevel`, `CoreUpgradeLevel`, `ClockGhz`, `CoreCount` on `LpBitcoinRackEntity` | VERIFIED FROM REPO |
| Canon direction | DECISION-0010: purchases from Universal Upgrades only; Servers read-only; CPU/Core → Compute Profile migration later | VERIFIED FROM CANON |
| Remove/hide legacy path timing | **OWNER DECISION REQUIRED** — keep for playtest until U1 + migration plan? | OWNER DECISION REQUIRED |

### Fake price / fake buy grep (bitcoin lane)

| Pattern | Result | Label |
|---------|--------|-------|
| `fake` in lpbitcoin/bitcoinmining UI | No fake-price/fake-buy helpers in bitcoin UI code | VERIFIED FROM REPO |
| Universal Upgrades | Static shell only — no purchase RPCs | VERIFIED FROM REPO |
| Legacy Servers→CPU/Core | **Real** prices from `LpBitcoinEconomy.CpuUpgradeCosts` / `CoreUpgradeCosts` — functional buys, not placeholder | VERIFIED FROM REPO |
| StaffMenu `fakedisconnect` / test bots | Unrelated quarantined/dev paths only | VERIFIED FROM REPO |

### Entity / code layout

| Component | Path | Label |
|-----------|------|-------|
| `LpHashdPanel` | `lpbitcoin/bitcoinhub/code/ui/` | VERIFIED FROM REPO |
| `LpBitcoinHubEntity` | `lpbitcoin/bitcoinhub/code/components/` | VERIFIED FROM REPO |
| `LpBitcoinRackEntity`, `LpBitcoinEconomy`, Terminal stack | Still under `bitcoinmining/` ident (playtest path) | VERIFIED FROM REPO |
| `LpBitcoinTerminalEntity` + CRT UI | `bitcoinmining/LpBitcoinTerminal*.cs/.razor` | VERIFIED FROM REPO |

### Canon contradictions (repo vs direction)

| Topic | Finding | Label |
|-------|---------|-------|
| Universal vs legacy purchases | Canon: one purchase surface. Code: **dual path** — static universal shell + live legacy CPU/Core buys from Servers | VERIFIED FROM REPO + CANON |
| Servers tab role | Canon (U1): read-only status dashboard incl. Hub + Terminal + 3 racks. Code: rack-only grid + upgrade CTA | GAP — U1 not started |
| ARCHITECT_CURRENT_STATE date | Generated 2026-06-25 — still accurate on phase/H10; may understate DECISION-0010 UI shell progress | INFERRED |

---

## 3. Next likely Red action (ONE slice — no new direction)

**Recommend:** **Prove static Universal Upgrades shell in flatgrass** (navigation only: 3-box home → each surface → GPU rack target-home → path list → tier-line detail → back stack). Capture screenshot package. **No economy commits.**

**Why this slice first:**
- DECISION-0010 UI shell appears **implemented in repo** but lacks runtime proof label.
- Does not require economy/RPC/`[Sync]` migration decisions.
- De-risks before U1 Servers conversion (which touches legacy purchase removal — Opus/owner gated).
- Aligns with Phase A: H7 partial done, H8/H10 still open — UI proof supports H7/H8 without jumping economy HOLD.

**Alternatives (only if Bloodwave overrides):**
- **B)** Commit static shell/navigation cleanup after flatgrass proof + owner GO.
- **C)** U1 Servers status conversion — **plan only** first (file map below); implementation needs explicit GO + likely legacy Upgrade button removal decision.
- **Hold** economy, Universal track purchases, CPU/Core → Compute Profile migration — all **HOLD / OPUS REQUIRED**.

---

## 4. U1 Servers status prep — file map

**Goal:** Servers/Racks tab → read-only status dashboard (no purchase CTAs).

| Expected card | Current in `LpHashdPanel.razor` | Work |
|---------------|----------------------------------|------|
| Bitcoin HUB | Hub status on **Overview** only (`HubPowerStatusLabel`, wallet stats) — **not on Servers home** | Add Servers home card; wire `Hub?.IsPowered`, owner link state |
| HASHD Terminal | Terminal link UI on **Overview** intro — **not on Servers home** | Add Servers card; `HasLinkedTerminal()`, link status label |
| GPU Rack 1 | Servers home box exists | Keep; strip Upgrade CTA on drill-in |
| GPU Rack 2 | Servers home box exists | Keep; strip Upgrade CTA |
| Advanced GPU Rack | Servers home box exists | Keep; strip Upgrade CTA |

**Must show (real state only):**
- Hub power → `LpBitcoinHubEntity.IsPowered` · **VERIFIED FROM REPO**
- Terminal linked → existing `HasLinkedTerminal()` helpers · **VERIFIED FROM REPO**
- Rack linked/unlinked/mining/BTC/hashrate → `GetServersRackSlots()`, `RackBtcTileValue`, `RackYieldLabel`, `HashRateLabel()` · **VERIFIED FROM REPO**
- Legacy CPU/Core levels → `rack.ClockGhz`, `CoreCount`, upgrade levels on linked racks · **VERIFIED FROM REPO** (display-only OK for U1)

**Must NOT do in U1 slice:**
- New economy · purchase RPCs · migration · power/link cascade · fake five-track state · Hub/Terminal upgrade purchases · cosmetics · commit without GO

**Primary touch files:**
- `lifepunch/addons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor`
- `lifepunch/addons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor.scss`
- Possibly retire or gate: `OpenRackUpgrades`, legacy `GetUpgradeRack()` CPU/Core block (~435–521)

**Route:** Plan = GREEN DEEP / Architect · Implementation = AUTO OK for Razor/SCSS **after GO** · Legacy removal + economy = **OPUS REQUIRED**

---

## 5. Model route recommendation

| Task | Route |
|------|-------|
| This packet / canon distill | **GREEN DEEP** ✓ (done) |
| Flatgrass navigation proof | **Red + sbox bridge** — AUTO OK to drive; Opus if Razor blocker |
| Razor/SCSS shell polish after proof | **AUTO OK** |
| U1 Servers conversion (remove legacy buy path) | **AUTO OK** UI if plan locked; **OPUS** if touching hub RPC/economy |
| Economy, persistence, `[Sync(FromHost)]`, CPU/Core → Compute Profile | **OPUS REQUIRED** |
| Commit / push | **BLOODWAVE** GO only |

---

## 6. Paste-ready next prompt for VENGEANCE

```text
VENGEANCE — RESUME LPBITCOIN AFTER DXRP #73 CLOSEOUT

1. cd C:\Users\jared\Projects\lifepunchaddons && git fetch && git pull --rebase && git status -sb
2. Confirm DXRP bounty is closed on dxrp-public only (PR #77) — do not mix into monorepo work
3. Read: ACTIVE_WORKSTREAM.md, BITCOIN_SHIP_ROADMAP.md, ARCHITECT_CURRENT_STATE.md, DECISION-0010, DECISION-0007
4. Read Cornerman outbox: LPBITCOIN_RESTART_PACKET_2026-06-29_1035.md
5. Report (no edits until GO):
   - Universal Upgrades static shell + 3-box home + GPU rack target-home: present in repo, needs flatgrass proof
   - Servers tab: 3 rack cards only; legacy CPU/Core Upgrade button still live; U1 Hub+Terminal cards missing
   - No fake buys in Universal path; legacy path has real CPU/Core purchases
6. Recommend ONE slice: flatgrass proof of Universal Upgrades navigation (screenshots)
7. Label claims: VERIFIED FROM REPO vs NEEDS SBOX RUNTIME PROOF
8. No commit until Bloodwave GO

Eyes covered until bridge/flatgrass run.
```

---

## Completion signal

```text
OK cornerman lpbitcoin-restart-packet complete @2026-06-29T10:35-04:00
head=732fc40
outputs=1
eyes=covered
no-code
no-commit
```
