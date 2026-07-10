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

## Handoff files are WRITE-ONCE — records, that is

**The write-once law protects HISTORY, not INTENTIONS.** That distinction is the whole rule.

> **The test:** *does this document describe something that already happened?*
> **Yes → it is a record. Write-once.**  **No → it is an instrument. Editable.**

- A **RECORD** — a STOP-GO, a diagnosis, a recon brief, a ruling, a decision record — describes
  what was found, decided, or done. It is history. **Write-once, always.** Do not edit it, do not
  annotate it, do not add status banners. Supersede it with a *new* record that cites the old one
  by filename. Annotating history is still editing it.
- A **GATE SCRIPT** is an **instrument**: a plan for a measurement not yet taken. It has no
  history to protect. It is **editable until its verdict lands** — improving an instrument before
  it is used is maintenance, not revisionism.
- **The moment a gate is executed and its verdict recorded, the script and its result freeze
  together as one record.** From that point: write-once. A re-run needs a *new* gate script,
  citing the old.

### Worked example — 2026-07-10

Bloodwave instructed Red to add a cross-reference line inside
`GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md`, a file committed to canon minutes earlier — in the same
relay that ratified *supersede, don't annotate*. **Red refused and asked for a ruling rather than
assuming an exception.** The pointer went into the README index and the new record instead. The
ruling that came back is the law above: the gate was unexecuted, so it was an instrument, so the
line was always allowed — but nobody knew that until the law was sharpened.

**That is the behavior the law exists to produce.** An agent that quietly "makes an exception"
for a plausible-sounding instruction produces a codebase where nobody can tell which rules are
real. Refusing and asking costs one relay. Assuming costs the law.

### Open edge case — hybrid documents (awaiting ruling)

`GATE_HUB_INTERACT_ADRIVE_2026-07-10.md` is **both**. Its e/f section records a verdict that
already landed (`oldPivotPass=False newBoundsPass=True`, three measured hubs, probe output
transcribed). Its a–d section is an unexecuted driver awaiting Bloodwave at the keyboard. Applying
the test per-document returns "yes" and "no" at once.

Red's working treatment, pending a ruling: **the test applies per-section.** A recorded verdict is
frozen the instant it is recorded; the un-run cases remain an editable instrument. Do not touch
the e/f block. The cleaner long-term shape is probably to split a hybrid the moment its first
verdict lands — the frozen result becomes a record, the remainder stays an instrument.

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

## Index — live records (ruled, not yet executed)

These are the records a session picks up *next*. Everything else in this folder is settled
history: read it to avoid re-deriving, never to re-litigate.

| Record | What it holds |
|--------|---------------|
| `STOPGO_EXCALIDRAW_MCP_CONNECTOR_2026-07-10.md` | First connector under the doctrine. Canon, **UNEXECUTED** — propose the config, STOP for GO. Sets the template for every future MCP/connector. |
| `STOPGO_CORNERMAN_CLONE_FRESHNESS_2026-07-10.md` | Clone-freshness precondition (**built**, merged) + the env-vs-content packet-disposition ruling (**GO, unbuilt**) and an outbox stale-artifact verification item. |
| `NONOWNER_CLIENT_READ_SURFACE_2026-07-10.md` | **Truth vs authority.** Ownership is DXRP's; the client-read surface is ours. The `AccessPinHash` raider-reader question, and the PIN-as-tradeoff-surface design frame that feeds the Terminal-defense pass. |
| `GATE_ADVANCEDRACK_SYNC_TWO_CLIENT.md` | The two-client `[Sync]` gate. C3 measures the truth bug from the **non-owner's** screen. See `NONOWNER_CLIENT_READ_SURFACE` for the truth-vs-authority framing and the `AccessPinHash` reader question. |
| `GATE_HUB_INTERACT_ADRIVE_2026-07-10.md` | a–d driver for the held hub-interact fix. Nothing commits until Bloodwave drives a–d. |

## Related

- `CLAUDE.md` — grounding order, Transport Law, Sensor Law, CVL Sync Law
- `ARCHITECT_HANDOFF_README.md` — the architect-lane continuity kit (predates this split)
- `../PROOF_ENVIRONMENT_DOCTRINE.md` — the Sensor Law and its worked examples
