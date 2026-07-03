# CVL RELAY BATON — current work state (read after CVL_AGENT_ONBOARDING.md)

> **Purpose:** a fresh chat on any node reads `CVL_AGENT_ONBOARDING.md` + this baton and knows exactly
> **where the work stands and what to do next** — so Bloodwave never re-steers a new session.
> **Update law:** Red owns this file; whoever finishes a slice proposes the new baton, Bloodwave approves,
> Red commits it. Cornerman writes candidates to `cornerman-outbox/`; Red absorbs into one commit.

---

## ON PULL — DO THIS FIRST (every node)

**Pulling a change to `CVL_AGENT_ONBOARDING.md` or this baton means the ground moved.** On every node
(Red, Cornerman Green B, **Mac Green A**), after `git fetch`:

1. **`git pull --rebase`** — Red/Mac on **`develop`**; Cornerman distill on **`main`** (see `BRANCH_MODEL.md`).
2. **Re-read `lifepunch/docs/CVL_AGENT_ONBOARDING.md` in full**, then your lane's **mandatory reads (§12)**.
3. Only then resume work. Do **not** act on stale grounding or continue an old chat past a pull.

---

## LATEST BATON

<!-- CVL_BATON_LATEST_START -->

```text
── CVL HANDOFF ──
FROM:   Red/Cursor/Auto
LANE:   LIFEPUNCH repo hygiene — main + develop branch model
DID:    GitHub default = develop. main = truth (ruleset: pattern main, no delete/force-push, PR required).
        Docs: BRANCH_MODEL.md · NEW_CHAT_BRANCH_LAW_PASTE.txt · handoffs rebased off checkpoint-* retirement.
        Blue server import e827512 on develop. MCP sbox.game URLs canon. Stale copilot/* branches deleted.
STATE:  develop = daily test lane (Red push). main = protected truth (PR develop→main on owner GO).
        Cornerman pulls main for distill. Red tunnel :9090 OFF when Green uses local chomnr.
NEXT:   ALL NODES: git fetch --prune · re-read CVL_AGENT_ONBOARDING.md + this baton.
        Red/Mac: checkout develop && git pull --rebase origin develop.
        Cornerman: checkout main && git pull origin main (path C:\Projects\lifepunch on Green).
        New chat: paste handoff/NEW_CHAT_BRANCH_LAW_PASTE.txt first.
        Ship: open PR develop → main when lane clean (main ruleset blocks direct push).
TO:     Mac · Cornerman · Architect — branch law changed; do not use checkpoint-* branches.
PASTE:  handoff/NEW_CHAT_BRANCH_LAW_PASTE.txt · lifepunch/docs/BRANCH_MODEL.md
COMMIT: docs(cvl): main ruleset + CVL handoff rebase for develop/main
```

<!-- CVL_BATON_LATEST_END -->

---

## BATON HISTORY (most recent first)

<!-- CVL_BATON_HISTORY_START -->

### 2026-07-03 02:35
```text
── CVL HANDOFF ──
FROM:   Red/Cursor/Auto
LANE:   LIFEPUNCH lpbitcoin Phase A — Green A (MacBook) OUT OF WORKFLOW
DID:    Bloodwave reports MacBook Air M2 dead (no power, stiff trackpad, was charging, no liquid).
        Suspected battery/hardware — unplugged, Apple repair pending. CVL continues on Red + Cornerman only.
STATE:  Green A OFFLINE — superseded 2026-07-03: charger failed, Mac back online.
NEXT:   (historical)
TO:     ALL AGENTS: Mac is out of the web until further notice. Red owns editor truth + push.
PASTE:  lifepunch/docs/handoff/CVL_RELAY_BATON.md
COMMIT: d3d53b9 era baton — do not use for current Green A status.
```

### 2026-07-02 21:32
```text
── CVL HANDOFF ──
FROM:   Red/Cursor/Auto
LANE:   LIFEPUNCH lpbitcoin Phase A — AUTOPILOT ACTIVE (owner GO 2026-07-02 ~18:06 ET)
DID:    Sync lpbitcoin→dxrp; flatgrass H4/H5 partial proof (spawn, power toggle, material/LED audit);
        Universal Upgrades home UI preview; fixed ARCHITECT_CURRENT_STATE H4/H5 doc drift;
        wrote AUTOPILOT_BITCOIN_2026-07-02.md. Party/staff lane unchanged (standby, uncommitted).
STATE:  Bloodwave AWAY — review on return. Red may automate safe Phase A slices (H2/H6 proof, docs,
        screenshots, tracker notes). NO push. NO dxrp-public commit. NO new H4/H5 hub code unless
        owner paste locks LED/point-light decisions on return.
NEXT:   Red: finish H6 prefab audit + screenshot recapture + review package in proof folder.
        Cornerman/Mac: pull when baton commits — read-only prep/distill only until push.
        Bloodwave return: ear-check fan audio, LED/point-light call, approve commit scope + push.
TO:     Red: lifepunch/docs/handoff/AUTOPILOT_BITCOIN_2026-07-02.md + ARCHITECT_CURRENT_STATE.md
        Cornerman: eyes covered — no playtest claims; inbox distill if asked.
        Party lane: still STANDBY — DXRP_PARTY_STAFF_STANDBY.md unchanged.
PASTE:  lifepunch/docs/handoff/AUTOPILOT_BITCOIN_2026-07-02.md
COMMIT: local only pending Bloodwave review (baton + autopilot docs + prior adminmenu ahead 2).
```

### 2026-07-02 18:06
```text
── CVL HANDOFF ──
FROM:   Red/Cursor
LANE:   DXRP OFFICIAL (party-browse) + LifePunch adminmenu (#126) — STANDBY
DID:    Merged origin/develop into party-browse (local); P0 staff menu party-purple tokens + /menu /adminmenu /staffmenu commands; wrote DXRP_PARTY_STAFF_STANDBY.md.
STATE:  STAND BY — no push, no dxrp-public commit until flatgrass proof.
NEXT:   Bloodwave return → vanilla dxrp-vanilla Host Play → prove /party (Browse + current/max) + /menu|/adminmenu|/staffmenu; then owner GO to commit party-browse.
TO:     ALL AGENTS: read lifepunch/docs/handoff/DXRP_PARTY_STAFF_STANDBY.md — warm UI only, no ship.
PASTE:  lifepunch/docs/handoff/DXRP_PARTY_STAFF_STANDBY.md
COMMIT: lifepunch only (this baton + adminmenu); dxrp-public uncommitted.
```

### 2026-07-02 03:04
```text
── CVL HANDOFF ──
FROM:   Red / Cursor / Opus
LANE:   LIFEPUNCH (docs / onboarding — no gameplay code this pass)
DID:    Authored CVL_AGENT_ONBOARDING.md (single grounding paste: history, 2 lanes,
        hardware/AI/MCP/LLM stacks, the orchestra + handoff baton) and this baton file;
        mirrored the onboarding doc to the Vengeance desktop.
STATE:  PLAN/DOCS ONLY — no code. Repos synced (lifepunch 0/0 origin; dxrp develop a132116).
NEXT:   ALL OTHER NODES (Cornerman Green B, Mac Green A): `git pull --rebase`, then RE-READ
        CVL_AGENT_ONBOARDING.md in full + your lane mandatory reads (§12) BEFORE any work.
        Then resume active lane: lpbitcoin Phase A — awaiting `GO H4/H5 HUB STATE` (+ route tag).
TO:     Cornerman + Mac: pull + re-ground. Red: implement H4/H5 on owner GO.
PASTE:  New / refreshed sessions → lifepunch/docs/CVL_AGENT_ONBOARDING.md (whole file).
COMMIT: committed + pushed to checkpoint-lpbitcoin-pre-sleep-20260701 (see `git log`).
```

---

## PIN — OFFLOAD SIGNAL (Cornerman Green B)

- **Law:** `lifepunch/docs/handoff/CVL_OFFLOAD_SIGNAL.md` — agents **toast + chat** when triggers fire.
- **Command:** `powershell -File lifepunch\scripts\Send-CvlOffloadSignal.ps1 -Reason "<why>"`
- **Right now (party PR verify):** **NO OFFLOAD** — Bloodwave on Red flatgrass; Cornerman idle is OK.
- **Spin up Cornerman when toast says:** GREEN CODE candidate, distill/kit, heavy parallel slice, or Tier-3 only.

## PIN — Green A (MacBook) — BACK ONLINE

- **Status:** **ONLINE** (2026-07-03). Prior no-power episode was a **failed charger**, not dead Mac hardware. Replace charger; monitor battery health.
- **CVL impact:** Green A **rejoins the web** — mobile Architect, native Green Cursor/Copilot, git pull on checkpoint branch. Still **no editor/MCP truth on Mac** (Red owns s&box + push).
- **Design Architect:** Mac ChatGPT **or** Red browser — owner choice.
- **Boot paste:** `handoff/MAC_GREEN_CURSOR_GROUNDING_PASTE.txt` · `handoff/MACBOOK_GREEN_QUICKSTART.md`

## PIN — active lane

- **Lane:** **DXRP party** — PR `mragerlp-party-browse-tab` stacks #115; Bloodwave flatgrass verify on **dxrp-vanilla**.
- **Cornerman:** idle OK until **OFFLOAD SIGNAL** toast.

## PIN — DXRP official lane (parallel, separate brain)

- **Fork:** `mragerlp/dxrp-public` → PR `dxura/dxrp:develop`. Upstream current at `a132116`.
- **Tracker:** Party Phase 2 (#111) on `mragerlp-party-phase-2` — implement only after Dxura GO on slice 1.

## Where newer truth lives

- Dated product state: `handoff/ARCHITECT_CURRENT_STATE.md`
- Evergreen alignment paste: `AGENT_SYNC_BROADCAST.txt`
- Master onboarding: `lifepunch/docs/CVL_AGENT_ONBOARDING.md`
