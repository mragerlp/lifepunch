# CVL RELAY BATON — current work state (read after CVL_AGENT_ONBOARDING.md)

> **Purpose:** a fresh chat on any node reads `CVL_AGENT_ONBOARDING.md` + this baton and knows exactly
> **where the work stands and what to do next** — so Bloodwave never re-steers a new session.
> **Update law:** Red owns this file; whoever finishes a slice proposes the new baton, Bloodwave approves,
> Red commits it. Cornerman writes candidates to `cornerman-outbox/`; Red absorbs into one commit.

---

## ON PULL — DO THIS FIRST (every node)

**Pulling a change to `CVL_AGENT_ONBOARDING.md` or this baton means the ground moved.** On every node
(Cornerman Green B, Mac Green A, Red), after `git fetch`:

1. **`git pull --rebase`** — full rebase onto the latest branch tip (`checkpoint-lpbitcoin-pre-sleep-20260701`).
2. **Re-read `lifepunch/docs/CVL_AGENT_ONBOARDING.md` in full**, then your lane's **mandatory reads (§12)**.
3. Only then resume work. Do **not** act on stale grounding or continue an old chat past a pull.

---

## LATEST BATON

<!-- CVL_BATON_LATEST_START -->

```text
── CVL HANDOFF ──
FROM:   Red/Cursor/Opus
LANE:   LIFEPUNCH (docs/tooling - CVL signal bus)
DID:    Wired git-based signal bus: Send-CvlHandoff.ps1 + CVL_FIRST_BROADCAST.txt + baton LATEST/HISTORY markers.
STATE:  DOCS+TOOLING ONLY - no gameplay code.
NEXT:   Bloodwave sends handoff/CVL_FIRST_BROADCAST.txt to Cornerman + Mac; they git pull --rebase + re-read CVL_AGENT_ONBOARDING.md before any work.
TO:     Cornerman + Mac: pull + re-ground. Red: implement H4/H5 on owner GO.
PASTE:  lifepunch/docs/handoff/CVL_FIRST_BROADCAST.txt
COMMIT: in this push
```

<!-- CVL_BATON_LATEST_END -->

---

## BATON HISTORY (most recent first)

<!-- CVL_BATON_HISTORY_START -->

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

## PIN — active lane

- **Lane:** `lifepunchbitcoin` / `lpbitcoin` — **Phase A Hub polish**.
- **Next slice:** **H4 + H5** (world power / audio). **Owner GO required before code:**
  `GO H4/H5 HUB STATE — World LED: … Point light: … Route: GROK REQUIRED | AUTO OK | OPUS REQUIRED. H4+H5 one commit.`
- **Locked:** Phase B Terminal until H10 · economy overhaul HOLD.
- **Branch:** `checkpoint-lpbitcoin-pre-sleep-20260701`.
- **Proof:** flatgrass Host Play on Red + `sbox` screenshot.

## PIN — DXRP official lane (parallel, separate brain)

- **Fork:** `mragerlp/dxrp-public` → PR `dxura/dxrp:develop`. Upstream current at `a132116`.
- **Tracker:** Party Phase 2 (#111) on `mragerlp-party-phase-2` — implement only after Dxura GO on slice 1.

## Where newer truth lives

- Dated product state: `handoff/ARCHITECT_CURRENT_STATE.md`
- Evergreen alignment paste: `AGENT_SYNC_BROADCAST.txt`
- Master onboarding: `lifepunch/docs/CVL_AGENT_ONBOARDING.md`
