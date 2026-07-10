# STOP-GO — DXRP fork re-pin: MERGE (ruled), mechanics queued behind the chair

**Status:** **RULED 2026-07-11 — MERGE.** The decision is a RECORD (write-once).
The **mechanics are UNEXECUTED**: the merge + pin-file reconciliation is its own
gated task, queued **behind the chair**. Nothing in `dxrp-public` or
`lifepunchdxrp` is touched by this document. The `-WhatIf` invocation is proposed
**after** the chair sitting, separately gated.

## The ruling (Bloodwave, via Fable, 2026-07-11)

- **MERGE, not rebase.** `b9d6068` is a **load-bearing sensor pin** — Packet E,
  Packet G, and the P1 verdict all cite "measured at `b9d6068`" **by hash**. A merge
  keeps it reachable in ancestry, so those frozen records stay valid. A rebase would
  orphan it and force-rewrite two shared clones (`origin/develop` + the
  `lifepunchdxrp` mirror) — the cross-surface desync the CVL laws guard against.
- **Canonical pin, three-way split ended in one pass:**
  - the **post-merge commit** becomes the **OPERATIONAL pin** going forward;
  - **`b9d6068`** remains the **frozen historical pin** — the records cite it by
    hash and ancestry preserves them;
  - **`dxrp-upstream-pin.json`** reconciles to the **new post-merge tip** in the
    same pass, ending the `0ee91dd` (file) / `b9d6068` (operational) / `0ee91dd`
    (local HEAD) split.
- **Mechanics DEFERRED.** Keyboard time outranks catch-up. This record ships now
  (one docs commit, push). The merge + pin-file pass runs as its own gated task
  after the chair; `Ensure-DxrpUpstreamCurrent.ps1 -Sync -UpdatePin -SyncSteam`
  is proposed `-WhatIf`-first at that time.

## The divergence map (sensor-backed, measured on Red in `C:\Users\jared\Projects\dxrp-public`)

Upstream fetched fresh 2026-07-10 23:05 +1000. All counts from `git rev-list`.

```
upstream/develop  1be75cb  "Add pallet to testing scene"
        |  114 upstream commits ahead of the merge-base, incl. the pallet family:
        |    0643468 Add Pallet Entity (holds bulk weed for drug drop)
        |    b656173 Add pallet description
        |    a83528e Fix pallet collision
        |    b73a2b0 Fix pallet bug desync
        |    1be75cb Add pallet to testing scene
merge-base  49e09e4  "Recompiling"  (2026-07-02 21:15:53 +1000)
        |  11 fork commits (4 merges, 9 non-merge):
        |    party Browse tab / PR #115 polish (feat/fix party), and a
        |    Discord-CI workflow ADDED then REMOVED (chore(ci): remove...)
origin/develop = lifepunchdxrp mirror pin = b9d6068  "Merge branch 'develop'"
        <- THE operational pin: Packet E, Packet G, the P1 verdict measured here
```

Key measurements (key: value):

- fork.tip: b9d6068 (origin/develop; lifepunchdxrp mirror pin)
- upstream.tip: 1be75cb "Add pallet to testing scene" (as of 2026-07-10 23:05 fetch)
- merge_base: 49e09e4 "Recompiling" (2026-07-02) — CONFIRMED against the relay
- b9d6068_vs_upstream.ahead: 11
- b9d6068_vs_upstream.behind: 114
- pallet_family_present_at_b9d6068: NO (upstream-only — this is what E2b needs)
- pin_file.sha (dxrp-upstream-pin.json): 0ee91dd "Fix tool list items... build menu" (synced 2026-07-08)
- pin_file.sha_vs_upstream: 0 ahead / 35 behind (a clean upstream ancestor)
- local_develop.HEAD: 0ee91dd
- local_develop_vs_origin: 79 ahead / 11 behind
- fork.tree: clean

## The conductor's-mirror correction (ratified into the record)

The bootstrap relay's TREE FACTS read **"+116/+13"** for `b9d6068` vs upstream. The
measured value is **11 ahead / 114 behind** — the pair was **transposed and off by
~2**. Merge-base `49e09e4` and upstream tip `1be75cb` were correct. **The error was
the conductor's** (ratified 2026-07-11). The inversion matters: this is a large
**catch-up** (upstream raced ahead 114 since 2026-07-02), not a large fork lead —
which is exactly why MERGE-to-catch-up is the shape, and why the mechanics can wait
behind the chair without the fork drifting further on our side (our side moved only 11).

## Why the three-way split existed, and how the merge closes it

- `dxrp-upstream-pin.json` recorded `0ee91dd` (a clean upstream ancestor), while the
  operational pin the packets measured is `b9d6068`. The local `dxrp-public` checkout
  also sits on `0ee91dd` — 79 ahead / 11 behind `origin/develop`, i.e. on a different
  lineage than the published fork tip.
- The merge pass reconciles all three to a single new tip: the merge commit contains
  both the 11 fork commits (b9d6068 reachable) and the 114 upstream commits (pallet
  family included); the pin file is rewritten to that tip in the same commit.

## Caveat, not action

The Discord-CI commits (added then removed inside the 11-ahead range) are dead weight
in the fork. **Leave them** — cleanup is orthogonal to the re-pin and rebasing to drop
them is the very history rewrite this ruling declined.

## Cross-references

- `GATE_ODYSSEUS_P1_VERDICT_2026-07-10.md` — measured "at b9d6068"; the frozen pin.
- `STOPGO_LAW2_ENFORCEMENT_SURFACE_2026-07-10.md` — E2b pallets **parked** on a
  re-pin past `b9d6068`; this ruling is what unparks them once the mechanics run.
- `PACKET_E_FINDINGS_2026-07-09.md` — E2b (pallets absent at `b9d6068`).
- `lifepunch/config/dxrp-upstream-pin.json` — the pin file that reconciles post-merge.
- `lifepunch/scripts/Ensure-DxrpUpstreamCurrent.ps1` — the gate script (GO-required).
- `CLAUDE.md` — Sensor Law, CVL Sync Law, Conductor's Mirror.
