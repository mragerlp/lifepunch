# STOP-GO — Cornerman worker clone-freshness precondition

**Propose-and-STOP. Not built.** Today's Packet E failure class, and the precondition that would
have caught it before a Green run was wasted.

## The failure class (stated for canon)

1. **The worker's clone is a SENSOR, and it was reading a different world than Red validated
   against.** Red validated the 12 input paths against Red's tree; the worker reads Green's clone.
   Different checkouts, different freshness. A packet that is correct on Red can fail closed on
   Green with "input not found."
2. **Nested repos do not travel with the monorepo pull.** Green's `lifepunchdxrp/` was a
   **git-less snapshot** (no `.git`) for an unknown duration — frozen at the last hand-copy. A
   `git pull` on the monorepo main never updates it, because `lifepunchdxrp/` is `.gitignore`d in
   the monorepo (`/lifepunchdxrp/`) and is a **separate clone of dxrp-public**. So the vanilla-DXRP
   inputs were silently stale, and 5 of them didn't exist at all.

## Proposed precondition (runs on GREEN, before the worker reads inputs)

Refuse to run — clear message, non-zero exit — unless ALL hold:

1. **Monorepo clone resolves, is clean, remotes match the profile registry** — the worker already
   does this (`CornermanDropWorker.Lib.ps1` ~line 329). Keep.
2. **Monorepo HEAD contains the packet's monorepo pin** —
   `git -C <clone> merge-base --is-ancestor <pin> HEAD`. Catches a stale main (today's
   ECONOMY_DOCTRINE miss).
3. **The nested `lifepunchdxrp/` is a REAL clone, not a snapshot** — assert `<clone>\lifepunchdxrp\.git`
   exists. This is the check that would have caught today's root cause directly.
4. **The nested clone's HEAD is the commit the packet names** —
   `git -C <clone>\lifepunchdxrp rev-parse HEAD` equals the packet's declared dxrp-public commit.

Requires a **machine-checkable field**, not free-text `contextNotes`. Proposed schema addition
(`cornerman-task-packet.schema.json`, minor version bump):

```json
"expectedClones": {
  "type": "object",
  "description": "Per-clone commit the worker must assert before reading inputs. Keys are clone roots relative to the monorepo (e.g. '.' for the monorepo, 'lifepunchdxrp' for the nested dxrp-public clone). Values are the full commit SHA the inputs were validated against.",
  "additionalProperties": { "type": "string", "pattern": "^[0-9a-f]{7,40}$" }
}
```
For Packet E: `{ ".": "987ac89…", "lifepunchdxrp": "b9d6068…" }`.

## Where it lives (my recommendation — your ruling)

- **Worker startup (`Invoke-CornermanWorkerOnce` / `Invoke-CornermanDropWorker`) — REQUIRED.**
  This is the only place with access to Green's actual clones. It is the honest sensor location.
- **`Send-CornermanTaskPacket` pre-flight — NO.** It runs on Red before transport and cannot see
  Green's clone state; a check there would be a false reassurance (the exact bug class we're
  fixing). It MAY warn if the packet lacks `expectedClones`, but must not claim to verify Green.
- **`New-CornermanTaskPacket` — light assist.** When authoring, it can auto-populate
  `expectedClones` from the authoring machine's `git rev-parse` of each cited clone root, so the
  attestation is captured at author time rather than typed.

## Interim (until built)

The `expectedClones` data already lives in Packet E's `contextNotes` as prose (monorepo pin
`987ac89`, dxrp-public `b9d6068`). Until the precondition ships, freshness is verified by the
manual Green checklist Red hands over per run (the numbered commands). That is the gap this
proposal closes.

## Interaction with the dirty-tree gate (added 2026-07-10, post-GO)

Bloodwave's Green run surfaced it: **the worker's clean-check counts untracked as dirty, and
`lifepunchdxrp_stale` tripped it.** Red had previously asserted the rename was harmless because
`lifepunchdxrp/` is `.gitignore`d — that was **wrong**. The pattern `/lifepunchdxrp/` is anchored
to that exact name, so the `_stale` sibling is untracked, not ignored.

The two gates therefore interact:

- The **freshness** gate wants the old clone gone or replaced.
- The **dirty-tree** gate refuses if the swap leaves anything untracked behind.

**Law: any clone-swap procedure must leave zero untracked debris.** Move the retired clone
*outside* the repo; do not park it alongside under a `_stale`/`_old` name. Do NOT broaden the
`.gitignore` pattern to `/lifepunchdxrp*/` — that would silently permit debris and blind the
clean-check. Fail-closed beats convenient.

Pinned as an assertion in `Test-CdwExpectedClones.ps1` (Case 9), so a future "helpful" widening
of the ignore pattern breaks a gate instead of a run.

## RIDER (filed 2026-07-10, NOT built) — environment failures consume the packet

Observed on Green: the clean-check failure **consumed** Packet E. The worker moved it to
`history/` as `fail` and wrote an outbox error folder; the inbox no longer held it, so a later
run errored `packet file not found`. The packet was never wrong — the *environment* was. Yet the
retry cost a full manual re-delivery from Red (re-author, drop to `G:\`, re-SHA, re-hand the run
command), and every future environment failure will cost the same.

**Proposed distinction** (propose-only, no GO sought yet):

| Class | Examples | Disposition |
|-------|----------|-------------|
| **Environment failure** — the packet is valid, the node is not | dirty clone, untracked debris, missing/snapshot clone, stale commit (`expectedClones`), missing input file, registry missing | **Leave the packet in the inbox.** Write the error artifact + ack, do NOT move to history. Fix the node, re-fire — no re-delivery. |
| **Content failure** — the packet itself is wrong | schema invalid, forbiddenScope hit, packet self-contradiction, `mode: candidate-patch`, path traversal, no-IP scan hit | **Consume.** Move to history as `fail`. Re-firing an invalid packet can never succeed; it must be re-authored. |

Rationale: a packet is a *work order*, not a *run attempt*. Consuming it on an environment fault
conflates the two, and punishes the operator for the node's state. The retry loop should be "fix
the clone, re-run the worker" — which is exactly what the freshness precondition tells you to do.

### RULED by Bloodwave 2026-07-10 — GO to build next session (propose-and-STOP as usual)

The split is accepted, **and the rationale is the ruling**: *a packet is a work order, not a run
attempt.* Environment faults leave it in the inbox; content faults consume it.

Both open questions, answered:

- **Retry counter: NO.** Green fast-fail forbids it. The packet sits until a human fixes the node
  and re-fires. **State this explicitly in the doc — the absence of a counter is a decision, not
  an oversight.**
- **Ack: PER ATTEMPT.** Every run appends an ack line. A packet that fails environment three times
  leaves three acks and one packet. **The ndjson is a run log, not a packet ledger.**

### Verification item to fold into that slice (from the Packet E live run)

Packet E succeeded (`status ok`, `failureStage: ""`, zero failures, `ack ok:true`), but its outbox
folder *also* held an `error.md` reading `pre-model-validation: clone dirty (lifepunchdxrp_stale)`
plus a `history/*.fail.json`. Both are **fossils from the earlier failed attempt**: the worker
writes into `outbox\<taskId>\` and does not clear a prior run's artifacts. This is the same
stale-artifact-leak class Red hit and fixed inside the gate harness while building
`Test-CdwExpectedClones.ps1` (`Invoke-Once` had to clear `outbox\*` recursively, or a previous
run's `error.md` leaked into the next run's verdict) — the fix was never carried into the worker.

**Not a diagnosis — a one-line verification.** Green has now pulled #51. On the next fresh run,
confirm no stale `error.md` or `.fail.json` sits beside a successful `report.md`. If it persists,
it is a real bug and gets its own pass.

**Filed. Not built. GO given for next session, not tonight.**

## Status

**BUILT (2026-07-10), gate green, awaiting commit GO.** Ruled by Bloodwave: worker-startup is
the correct location; `Send-CornermanTaskPacket` pre-flight is the wrong place (runs on Red,
cannot see Green's clone — false reassurance, the exact failure class). Fail-closed and loud,
no auto-pull, no self-healing.
