# Bitcoin ship roadmap — step-by-step to portal + community package order

**Status:** OWNER LAW — mandatory read for every Bitcoin lane agent (handoff-safe).  
**Parent gate:** `ACTIVE_WORKSTREAM.md` · **Laws:** `CYBER_REFERENCE_LAWS.md` · **Tracker:** `OWNER_PROGRESS_TRACKER.txt`  
**Gameplay:** `lifepunch/docs/LIFEPUNCH_GAMEPLAY_LAWS.md` · **Player design:** `BITCOIN_PLAYER_DESIGN.md`  
**Design canon:** `BITCOIN_CONTROLLER_PATTERN.md`, `BITCOIN_UPGRADE_TAXONOMY.md`, `BITCOIN_DATA_FLOW.md`, `DECISION-0010` (Universal Upgrades Home), `CYBER_VISUAL_IDENTITY_DOCTRINE.md`, `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md`  
**Checklist IDs:** `bitcoinmining/docs/BITCOINMINING_POLISH_CHECKLIST.md`  
**Post-Bitcoin portfolio:** `JOB_PORTFOLIO_ROADMAP.md`  
**Economy rails:** `CYBER_ECONOMY_RAILS.md`

**Last updated:** 2026-06-25 (Phase A gate order; H4/H5 before H10; v1.0/v1.1 scope flag)

---

## Why this doc exists

Cursor sessions reset. Agents must not re-derive schedule or quality from chat history.

The **Hub admin UI alone** took substantial owner time and API spend to reach the current bar. That is intentional: LifePunch ships **reference-quality** cyber machines, not high-volume low-quality addons. Other servers stack weak props; our systems (machine stack, economy rails, flatgrass proof, one-slice workflow) are the moat.

**Rule:** One checklist ID → one slice → flatgrass proof → owner OK → commit (with consent) → next. No "while we're here."

---

## Quality bar (non-negotiable)

| Principle | Meaning |
|-----------|---------|
| **Machine, not prop** | Model → collision → attachments → lights → anim → sound → state → gameplay (`LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`) |
| **Flatgrass is truth** | Editor screenshots and preview ConCmds do not count as done (`CYBER_REFERENCE_LAWS.md` Law 5) |
| **Reference first** | Before code: what will Hacker / Banker / Government reuse? (`Law 1`) |
| **Honest baselines** | Interim hacks OK if labeled in `TECH_DEBT.md`; spaghetti is not |
| **Opus discipline** | Plan → one slice → proof → Architect Review → owner sign-off (`OPUS_USAGE_LAW.md`, `ARCHITECT.md`) |
| **Proof package** | Day, night, USE, citizen scale, 30s clip per phase sign-off (`ACTIVE_WORKSTREAM.md` §3) |

Hub UI polish (wallet, settings, overview, PIN flow, hub status tiles) is **Phase A admin shell** — not Law 10 ship. Treat unlinked hub UI owner sign-off as progress on **H7 / H10**, not as "Bitcoin shipped."

---

## Current position (June 2026)

| Area | Status |
|------|--------|
| Hub admin UI (`LpHashdPanel`) — unlinked | Owner signed off — wallet, settings, overview, PIN change UX |
| Hub world mesh / LED / audio | **Phase A in progress** — tracker H1–H6, H8–H10 |
| Terminal CRT + `rig0>` commands | **Phase B locked** — starts only after H10 owner sign-off |
| GPU rack link + full kit UI | **Phase C locked** — follows Terminal T1–T6 proof |
| Economy send/receive + bank cashout | Integration slice after B + C baseline |
| Law 10 publish loop | Blocked until A + B + C + economy proof |

**Current executable slice:** `OWNER_PROGRESS_TRACKER.txt` — Phase A Hub (next unchecked H* ID).  
**Phase B Terminal** begins only after **H10 owner sign-off** (`ACTIVE_WORKSTREAM.md` §2).

**Planned after Phase A (not current):** Terminal commands + hub-off gate (T1–T6), then linked full-rack UI on Overview/Racks (H8 + R1–R8).

---

## Phase A gate order (before H10)

Complete Hub checklist IDs in gate order. **H4/H5 (hub fan/LED state feedback) finish before H10** — not deferred to post-Terminal work.

| Gate | Work | ID | Done when |
|------|------|-----|-----------|
| Mesh / collision / scale | Hub P0 foundation | H1–H3 | Flatgrass citizen comparison, honest collider |
| State feedback | Hub fan + LED readability | **H4–H5** | Power on/off visibly communicated on hub |
| Admin shell | `LpHashdPanel` polish | H6–H7 | Wallet, settings, overview, PIN — owner sign-off path |
| Linked kit UI | Overview/racks when linked | H8 | Correct with real linked racks (may overlap late A) |
| Proof package | Law 5 flatgrass bundle | H9–H10 | Day/night/USE/30s clip — **H10 owner sign-off unlocks Phase B** |

---

## Post-H10 roadmap (Phases B → C → economy → publish)

Owner seven-item list, reordered for **ship risk** after Phase A H10:

| Step | Work | Phase / ID | Done when |
|------|------|------------|-----------|
| **1** | Terminal UI + commands function correctly | **B** T1–T6 | `rig0>` loop, hub off blocks terminal, CRT theme, flatgrass proof — **after H10** |
| **2** | Full GPU rack link + hub UI when linked | **C** R1–R8 + H8 polish | Overview/racks/status correct with real linked kit |
| **3** | Send/receive BTC (test compute nodes / wallet targets) | Economy + Law 10 slice | Wallet, transfers, hub cashout → **bank** per `CYBER_ECONOMY_RAILS.md` |
| **4** | Rack/advanced animation polish | **C** R4, R6, R7 | Rack LED/fan parity with hub baseline where applicable |
| **5** | Extended upgrades (full five-by-five tree, VIP/EVIP cosmetic lighting) | **v1.0 vs v1.1 — owner decision pending** | See open question below — park in `BACKLOG_PARKING_LOT.md` until decided |
| **6** | Max racks + small economy soak + bugfix | Law 10 exit | New player path, no dev ConCmds, full kit hero, proof package |
| **7** | Publish → populate bible → next job | Portal + Law 8 | `prepare-publish.ps1 -Addon lpbitcoin` · `BITCOIN_REFERENCE_IMPLEMENTATION.md` |

### Publish v1.0 vs v1.1 — **owner question (unresolved)**

Is the **full five-by-five-by-five upgrade tree** (Hub controller + Terminal defense + Rack hardware) required for v1.0, or is part/all of it a v1.1 portal revision per DECISION-0010? Current roadmap allows extended upgrades as a fast follow — **Bloodwave must confirm** before economy implementation.

Universal Upgrades home lives in LpHashdPanel (sub-tabs: HUB · TERMINAL · GPU RACK). Terminal never mines.

**Baseline v1.0 path:** steps 1 → 2 → 3 → 4 (rack animation baseline) → 6 → 7, with step 5 scope per owner answer.

---

## Agent workflow (every slice)

```text
1. READ  — ACTIVE_WORKSTREAM → CYBER_REFERENCE_LAWS → this file → OWNER_PROGRESS_TRACKER (one ID)
2. PLAN  — One ID only; Law 1 reuse sentence; definition of done; risks
3. BUILD — One focused change; flat SCSS rules for s&box; no unrelated batching
4. PROOF — lp_map_flatgrass + real spawn (not prefab tab only); screenshot; disclose if bridge off
5. REVIEW— Owner OK before next ID; propose commit scope; never commit unprompted
```

**Dev ConCmds (playtest only):** `lp_bitcoin_preview_hub` · `lp_bitcoin_preview_hub_wallet` · `lp_bitcoin_spawn_kit` — not Law 10 proof.

**Sync after code touch:** `lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin` · Stop → Play after `.razor.scss` edits.

---

## Law 10 — Bitcoin publish gate

A **brand-new player** must complete without help:

```text
Acquire hub (DXRP market — not dev spawn)
  → Place hub
  → Power on
  → Operate terminal (rig0>)
  → Link rack(s) in range
  → Observe mining / status at a glance
  → Hub wallet → bank cashout (economy rail)
  → Full loop understood
```

Only then: populate `BITCOIN_REFERENCE_IMPLEMENTATION.md` and unlock Tier 1 job **production** work.

---

## Community server addon package — order after Bitcoin

**Do not lead with Hacker or Government complexity.** Economy and reuse drive the sequence.

| Order | Package | Why after Bitcoin |
|-------|---------|-------------------|
| **1** | `lifepunchbitcoin` | Reference machine stack + `CYBER_ECONOMY_RAILS.md` |
| **2** | `lifepunchbanker` | Bank invest / passive growth — extends **bank rail**; ties RP purpose to economy fixes |
| **3** | `lifepunchgovernment` | Regulation, gov task payouts (bank cashout rail) |
| **4** | `lifepunchhacker` | Wallet-only PvP, puzzles, infra — hardest UX; needs stable Bitcoin patterns first |
| **5+** | Black market, chemist, casino, … | Parked until Law 10 clones exist |

**Banker before Hacker (owner law, June 2026):** Bitcoin defines where money lives; Banker extends bank-side behavior without opening wallet-attack surfaces first.

**Hacker planning in parallel:** Cornerman distill / docs OK — **no production code** until Bitcoin Law 10 sign-off.

**Do not "hard stuff first" for production:** Shipping Hacker/Gov before a clean Bitcoin loop debugs economy and UX across three lanes at once.

---

## Session boot (agents — paste into fresh chats)

```text
Active lane: lifepunchbitcoin only.
Read: ACTIVE_WORKSTREAM.md → CYBER_REFERENCE_LAWS.md → BITCOIN_SHIP_ROADMAP.md → OWNER_PROGRESS_TRACKER.txt
Execute ONE tracker ID (H*, T*, or R*) → flatgrass proof → stop for owner OK.
Park everything else in BACKLOG_PARKING_LOT.md.
```

---

## Progress log

| Date | Milestone |
|------|-----------|
| 2026-06-24 | Owner roadmap captured; hub admin UI (unlinked) signed off; Banker-before-Hacker Tier 1 order locked |
| 2026-06-24 | Hub UI commits: wallet tiles, settings layout, PIN early validation, hub status icon tiles (`9c8135b`) |
