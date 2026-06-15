# ACTIVE WORKSTREAM — production gate (owner law)

**Status:** HARD GATE — not a suggestion. Every agent session **starts here**.  
**Canonical path:** `lifepunch/addons/docs/ACTIVE_WORKSTREAM.md`

---

## 1. Single active lane

```text
ACTIVE PROJECT:
lifepunchbitcoin

REPO IDENT:
bitcoinmining

S&BOX PACKAGE:
lifepunch.bitcoin

CURRENT PHASE:
Phase A — Hub Polish

NEXT PHASE (locked until Phase A sign-off):
Phase B — Terminal Polish

THEN:
Phase C — GPU Rack Polish

BLOCKED (no production work):
Hacker
Banker
Government
Casino
Drug Chemist
Black Market
All new cyber lanes
All quarantined idents (see QUARANTINE_REGISTER.md)

UNLOCK CONDITION:
Flatgrass proof + owner sign-off on Phases A → B → C
(See §8 Owner sign-off criteria)
```

**Agents:** If work does not directly improve **Hub**, **Terminal**, or **GPU Rack** for `lifepunchbitcoin`, **stop** and park the idea in `BACKLOG_PARKING_LOT.md`.

---

## 2. Define "done" before touching anything

Scope creep happens when "finished" is undefined. **No new task starts until the current phase DONE criteria are written and understood.**

### Phase A — Hub (Ophion) — DONE WHEN

```text
☐ Correct scale
☐ Correct collider
☐ Idle state readable
☐ Active state readable
☐ USE feedback readable
☐ Night visibility verified
☐ Branding verified (BTC mark + amber HASHD admin)
☐ Screenshot proof captured (see §3)
```

**Law:** Phase B (Terminal) does **not** start until **every** Phase A box is checked **and** owner signs H10.

**Checklist IDs:** H1–H10 in `bitcoinmining/docs/BITCOINMINING_POLISH_CHECKLIST.md`  
**Owner tracker:** `addons/docs/OWNER_PROGRESS_TRACKER.txt`

### Phase B — Terminal — DONE WHEN

```text
☐ World mesh compiles (no ERROR)
☐ CRT UI matches ops gray theme
☐ Boot graphic + rig0 command loop proven
☐ Hub-off blocks terminal authority
☐ Screenshot + 30s clip captured
```

**Law:** Phase C does not start until T1–T6 signed off.

### Phase C — GPU Rack — DONE WHEN

```text
☐ Small + large meshes compile clean
☐ Mining on/off obvious per rack
☐ Hub link radius correct
☐ Full kit hero on flatgrass (hub + 3 small + 1 large)
☐ Owner sign-off R8
```

---

## 3. Require play proof

A visual pass is **not** complete because it "looks good in editor."

### Proof package (required per phase sign-off)

```text
Proof Package:
- Screenshot #1: Day
- Screenshot #2: Night
- Screenshot #3: USE state
- Screenshot #4: Citizen scale comparison
- 30-second gameplay clip
```

**Play law:** `game.scene` → Host Play (wait 2–5 min cold) → `lp_map_flatgrass` → spawn kit/hub.  
**Never** sign off from prefab tabs or editor-only preview alone.

```text
If proof doesn't exist:
  Status = NOT DONE
```

Store proof paths or filenames in the polish checklist **Sign-off log** when owner approves.

---

## 4. Freeze new concepts — parking lot

Excitement about Hacker upgrades, banking, crypto exchanges, government terminals, etc. **does not enter production.**

**Park here:** `lifepunch/addons/docs/BACKLOG_PARKING_LOT.md`

Agents **append** parked ideas; they do **not** implement them until Bitcoin unlock.

---

## 5. Promotion pipeline (nothing skips stages)

```text
IDEA
 ↓
Prototype
 ↓
Polish
 ↓
Play Test
 ↓
Proof (§3)
 ↓
Owner Sign-Off
 ↓
Reference Quality
 ↓
Clone Pattern Elsewhere
```

| Stage | Gate |
|-------|------|
| Prototype | Owner brief or ChatGPT Step 1 |
| Polish | Active workstream only |
| Play Test | flatgrass + ConCmd kit |
| Proof | §3 package exists |
| Owner sign-off | Explicit OK in chat + tracker checkbox |
| Reference quality | Bitcoin Phases A–C complete |
| Clone elsewhere | `JOB_PORTFOLIO_ROADMAP.md` Tier 1+ unlock |

Quarantined code is **not** a shortcut to Prototype — read for context only (`QUARANTINE_REGISTER.md`).

---

## 6. Bitcoin is the template (not just a product)

**Goal is not:** ship a Bitcoin miner in isolation.

**Goal is:** create the **cyber-job reference architecture**.

When Bitcoin is excellent, every future lane inherits:

- Terminal standards (`LpOpsCrtTerminal.scss` themes)
- Interaction standards (USE, hub authority, terminal commands)
- Branding standards (LIFEPUNCH™ source, palette per lane)
- Progression standards (hub → terminal → rack)
- Visual standards (scale, collider, day/night, proof)

**One polished lane > five unfinished lanes.**

> Do not build the best Bitcoin miner. Build the **standard** every future cyber profession inherits.

**Production laws (mandatory):** `CYBER_REFERENCE_LAWS.md`  
**Bible on sign-off:** `BITCOIN_REFERENCE_IMPLEMENTATION.md`

---

## 7. Session rule (every contributor)

Before beginning work, answer:

```text
Does this directly improve:

  A) Hub
  B) Terminal
  C) GPU Rack

for lifepunchbitcoin?
```

| Answer | Action |
|--------|--------|
| **Yes** | Proceed — one checklist ID only |
| **No** | Defer → `BACKLOG_PARKING_LOT.md`; do not edit blocked lanes |

---

## 8. Owner sign-off criteria

Do **not** sign off because it feels done.

Sign off when the player can complete this loop **without explanation**:

```text
Acquire miner
  → Place hub
  → Operate terminal
  → Connect / upgrade rack
  → Observe production
  → Understand status at a glance
  → Complete full loop
```

**Proof:** flatgrass host play + §3 package + tracker checkboxes A–C.

Only then does Bitcoin become the **canonical cyber lane** and Tier 1 jobs (Hacker, Banker, …) enter active development per `JOB_PORTFOLIO_ROADMAP.md`.

---

## Session start checklist (agents)

1. Read **this file** (ACTIVE_WORKSTREAM.md).
2. Read `CYBER_REFERENCE_LAWS.md` — Laws 1–10 (reference-first, flatgrass truth, no "while we're here").
3. Read `OWNER_PROGRESS_TRACKER.txt` — note current unchecked ID.
4. Read `BITCOINMINING_POLISH_CHECKLIST.md` — **only** that ID's "Done when" + proof.
5. Confirm §7 gate (Hub / Terminal / Rack only).
6. Answer Law 1 reuse question before coding.
7. Execute **one** ID → play proof → wait for owner OK → check box → next.

**Detail docs (downstream, not substitutes for this gate):**

- `CYBER_REFERENCE_LAWS.md` — production laws 1–10
- `BITCOIN_REFERENCE_IMPLEMENTATION.md` — bible stub (populate on sign-off)
- `TERMINAL_BRAND_MATRIX.md` — Law 7 brand verification
- `bitcoinmining/docs/BITCOINMINING_POLISH_CHECKLIST.md`
- `bitcoinmining/docs/BITCOINMINING_PLAYTEST.md`
- `addons/docs/JOB_PORTFOLIO_ROADMAP.md`
- `addons/docs/CYBER_JOBS_POLISH_CHECKLIST.md` (blocked lanes — read only)

**Last updated:** 2026-06-15
