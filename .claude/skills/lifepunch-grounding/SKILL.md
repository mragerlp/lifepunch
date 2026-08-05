---
name: lifepunch-grounding
description: STEP 0 for every LIFEPUNCH session — the grounding ritual before any task. Use at session bootstrap, on "onboard/ground yourself", before filing an arrival report, or whenever you are unsure what canon governs a task. Covers the read order (CLAUDE.md first), tree-state verification, the Sensor Law (FRESH = log postdates write + positive code-string ID), honest "unverified" usage, and the CVL HANDOFF/relay schema. This skill points at canon; it does not restate it.
---

# LIFEPUNCH grounding — STEP 0

**This skill points at canon. Read the cited file before acting.** Nothing here is a
substitute for the doctrine it cites.

## 1. READ ORDER

Ground in this order — each narrows the last:

1. **`CLAUDE.md`** (repo root) — roles, model routing, Transport Law, Hard rules, the
   grounding order itself. The first read, every session.
2. **`lifepunch/docs/START_HERE_AGENTS.md`** → **`lifepunch/docs/CVL_AGENT_ONBOARDING.md`**
   — the CVL onboarding path and the HANDOFF/relay schema (§4).
3. **`lifepunch/docs/DXRP_PLATFORM_DOCTRINE.md`** §1–22 — the platform model, publish lanes,
   config layers, economy spine. CHECK THE PORTAL before declaring a platform gap (§1).
4. **`lifepunch/docs/OPUS_USAGE_LAW.md`** — routing/cost discipline (routing authority now
   lives in `CLAUDE.md`; this is the four-phase spirit).
5. **The task-relevant doctrine** — the specific `lifepunch/docs/…` law for the surface you
   touch, then **the active brief** in `lifepunch/docs/handoff/`.

`lifepunch/docs/handoff/` is **CANON** (tracked, write-once). `handoff/` at repo root is
**SCRATCH** (untracked proof). Only the former is grounding material (`CLAUDE.md` → Grounding order).

## 2. TREE-STATE VERIFICATION (arrival ritual)

Before editing anything, report and hold: **branch · HEAD · clean/dirty · intended files ·
forbidden files** — then wait for GO (`CLAUDE.md` → Transport Law). At session bootstrap, the
Session Start Rule (`EDITOR_LAUNCH_LAW_2026-07-11.md` → "Session Start Rule") fires **ONLY**
against a tree the dispatch names by path. There is no bootstrap fetch on an unnamed tree and
none is implied by default. If no dispatch names one, the rule does not fire and that is
**REPORTED**, never silently skipped. In a dispatch-named tree, run `git fetch origin`, then
report the tips and behind-counts as evidence. Pull, merge, rebase, and push stay **BARRED**;
**never** auto-merge upstream on `dxrp-public`.

## 3. SENSOR DISCIPLINE — the spine of every claim

**Every claim carries its sensor** (`CLAUDE.md` → Hard rules, Sensor Law). A **FRESH**
assertion needs two facts together:

1. the compile/parser log timestamp **POSTDATES** the file write, **and**
2. a **positive code-string ID** — a string that exists nowhere except your edit appears in
   the log or tool result, proving the compiler read the new bytes.

When no sensor reads the thing under test, **build one**. A behavioral change only the new
code could produce is itself a positive ID. Editor/runtime proof discipline lives in the
`lifepunch-editor-gate` skill.

**Say "unverified" plainly.** An unproven claim is labeled, never rounded up to "done." A red
result with an unverified tree is an unknown wearing a result's clothes.

## 4. THE CVL SYNC LAW (the trap that names most of them)

No actor issues instructions against a state it has not observed (`CLAUDE.md` → Hard rules,
CVL Sync Law). Code's response **is** the sensor; instructions authored before it arrive
stale. One relay per state change; no relay before the state is reported. The live exception:
Bloodwave-at-the-keyboard debugging is real-time, human-as-sensor.

## 5. HANDOFF / RELAY SCHEMA

Structured CVL handoff and relay format: **`CVL_AGENT_ONBOARDING.md`** (§ HANDOFF). Transport
Law (`CLAUDE.md`): **PASTE** for one-screen state changes (CVL RELAY format); **FILE** a
tracked `lifepunch/docs/handoff/CLAUDE_CODE_BRIEF_<TASK>_<DATE>.md` for anything longer or
re-read later. A closed session is an erased one — see the **CANON PERSISTENCE LAW** in
`CLAUDE.md`: no session closes holding unwritten canon.
