# `handoff/` — decision records (CANON)

**Two folders share the name `handoff`. They are not the same thing.**

| Folder | Status | Contents | Read by a cold session? |
|--------|--------|----------|-------------------------|
| **`lifepunch/docs/handoff/`** (this one) | **CANON** — tracked, committed | STOP-GOs, rulings, recon briefs, diagnoses, gate scripts, banked design passes | **YES** — it is in the grounding order in `CLAUDE.md` |
| **`handoff/`** (repo root) | **SCRATCH** — untracked, never committed | Gate logs, screenshots, ledger backups, transient run captures | **NO** — nothing grounding reads it |

## The rule

**A decision record lives in canon. Run evidence lives in scratch.**

- **Decision record** — anything a future session must read to avoid **re-deriving or
  re-litigating** a conclusion: a STOP-GO, a ruling, a recon brief, a diagnosis, a gate
  script, a banked design pass, a parking lot of deferred items. → **here, tracked.**
- **Run evidence** — the proof a gate produced: logs, screenshots, ledger backups,
  captures. It is *proof*, not *canon*. It supports a decision record; it does not replace
  one. → **root `handoff/`, untracked.**

If you are unsure: ask whether a session that never saw this conversation would have to
redo the work without it. If yes, it is canon.

## Handoff files are WRITE-ONCE

Once a brief is committed, it is a historical record. **Do not edit it, do not annotate it,
do not add status banners to it.** Write-once means write-once — annotating history is still
editing it. Supersede a record with a *new* record that cites the old one by filename.

(The one exception, and it is narrow: a document still in its own authoring session, before
it has been committed, is still being written. After that, never.)

## Why this rule exists — the hazard, 2026-07-10

`CLAUDE.md`'s grounding order points at **`lifepunch/docs/handoff/`**. It has never pointed at
the root `handoff/`. Yet an entire session's rulings — STOP-GOs, a money-duplication
diagnosis, two recon briefs, the banked `[Sync]` gate — had accumulated in root `handoff/`,
untracked. A session grounding cold would have walked straight past every one of them.

Worse, it was already load-bearing: **`LIFEPUNCH_UI_STANDARD.md`, tracked canon, cited
`ULX_STYLE_TOKENS_2026-07-07.md`** — a file that lived only in untracked scratch. Canon was
citing a document no cold session could open.

The law it produced:

> **Write-once canon that the grounding order does not read is canon nobody reads.**

A decision record that is not on the grounding path is not a record. It is a note to
yourself, and you will not be the one who reads it.

## Naming

Prefix by kind so the folder sorts into its own index:

| Prefix | Kind |
|--------|------|
| `STOPGO_` | a proposal awaiting Bloodwave GO, or the record of one |
| `RECON_` | read-only investigation; every claim carries its sensor |
| `GATE_` | a gate script or its driver |
| `ARCHITECT_` / `CLAUDE_CODE_BRIEF_` | inbound briefs from the planning layer |

Filenames are referenced by name in commits, memories, and relays. **Preserve them on move.**

## Example of a canon decision record

`STOPGO_EXCALIDRAW_MCP_CONNECTOR_2026-07-10.md` — the first external connector brief under the
CVL doctrine. It ships as canon, **UNEXECUTED**: it wires nothing and touches no MCP config.
A fresh session reads it, proposes the config change, and STOPs for GO. That is the shape:
the brief is the durable record; the execution is a later, separately-approved act.

## Related

- `CLAUDE.md` — grounding order, Transport Law, Sensor Law, CVL Sync Law
- `ARCHITECT_HANDOFF_README.md` — the architect-lane continuity kit (predates this split)
- `../PROOF_ENVIRONMENT_DOCTRINE.md` — the Sensor Law and its worked examples
