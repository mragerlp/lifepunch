# GATE — Odysseus P1: the parity gate (one packet, end to end, whisperless)

- **Status:** **INSTRUMENT. Unexecuted.** Editable until its verdict lands.
- **Driven from:** **Green's keyboard**, on Bloodwave's GO. Red authors the packet; Red never
  executes on Green.
- **Split provenance:** this file was the P0 checklist. When P0's verdict landed on 2026-07-10 it
  split under the hybrid-document ruling: the proven half froze as
  **`GATE_ODYSSEUS_P0_VERDICT_2026-07-10.md`** (record), and this un-run half **keeps the original
  filename** by ruling, because that is the name the next sitting reaches for. Each file cites the
  other. **Neither annotates the other.**
- **Charter:** `STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md`

`GATE HEADER: NODE: Green (Cornerman) · IDENTITY: Bloodwave at Green's keyboard · RED IS PASSIVE`

**P0 is CLOSED — all lines green.** Do not re-derive it; read the verdict record. What that record
established and this gate now depends on:

- the return lane is **`\\10.10.10.2\CornermanOutbox`** (the hostname `CORNERMAN` never resolved
  from Red; the inbox lane always ran by IP);
- **existence is not readability** — the acceptance sensor for any lane is an **observed read**,
  never a resolved path;
- the **share ACL is the read-only guarantor**, not NTFS. The guarantee is a property of the
  route, not of the directory.

---

## LAW — whose sensor is whose

**CVL Sync Law:** *Code does not validate against its own tree what another machine executes.*
Red cannot assert one fact about Green. Every line marked **[GREEN ASSERTS]** is measured on Green,
by Green, before the next line runs. Red's job is to declare what it validated against and then get
out of the way.

**Green fast-fail:** no retries, no detach, no polling loops, no CIM/WMI, no `schtasks`. Any error
or hang past ~20 s → abort, report the raw error, stop. Do not "try the next thing."

---

## PACKET FIELDS — `expectedClones` is declared, never hardcoded

**`expectedClones` is DECLARED BY RED IN THE PACKET, in a machine-checked field.** It is not
written into this file.

*Why not:* a commit cannot contain its own hash — writing the value here changes the tree, which
changes the hash. Any literal recorded in the instrument is stale the instant it is committed, by
exactly one commit, which is the drift this gate exists to catch.

This is the design in `CORNERMAN_HEADLESS_DROP_WORKER.md`: the **authoring node declares** the
commits it validated against, in a **machine-checked field** of the packet — never in prose, and
never in a document that the declaration itself modifies. *Prose in `contextNotes` is a human
record; only a machine-checked field is a sensor.*

**Odysseus refuses by name, and never substitutes.** In P0 it reported an identical HEAD and
**withheld the match until Red declared.** A worker that matches an undeclared value has agreed
with itself, not asserted anything. That behavior is the standard.

**Nested-clone trap:** `lifepunchdxrp/` is `.gitignore`d and separately cloned. It does **not**
travel with the parent's `git pull`, and a hand-copied folder sits frozen indefinitely. A git-less
snapshot is not a clone and nothing on it can be verified at all. Assert it separately, or declare
it **out of scope for this packet — in writing.**

---

## P1 — the run

The first real exercise of the return lane.

1. **Red authors one packet** into Green's inbox, declaring `expectedClones` in a machine-checked
   field.
2. **Odysseus reads it on Green**, asserts `expectedClones` against its own tree, and **refuses by
   name** on mismatch.
3. **Odysseus executes**, driving LM Studio `:1234` as muscle. **No whisper is used for tasking** —
   the whisper is retired for that purpose; **the packet is the task.**
4. **Odysseus writes `report.md`** to `C:\lifepunch\cornerman\OUTBOX\task-…\`.
5. **Red reads the report over the share**, at `\\10.10.10.2\CornermanOutbox`. Red does **not**
   reach into Green to fetch it.

**Out of scope, unchanged:** Docker and Ollama are installed on Green and stay untouched. LM Studio
`:1234` is the ratified muscle. **Presence is not permission.**

## P1 acceptance

```
A   the packet reached Green without a whisper
B   Odysseus asserted expectedClones on ITS node, by name, before reading a byte
C   report.md landed in the outbox and Red READ it over the share
      -- the sensor is the observed read, not a resolved path (P0.3, ratified)
D   NO stale error.md / .fail.json sits beside a successful report.md
E   attestation intact: pins + SHAs carried in the report, each claim naming its sensor
```

**C's sensor is an observed read.** `Test-Path` is not evidence; `G:` was listed-allowed and
unreadable. Open the file.

**D is the one-line verification owed post-#51.** It rides P1 acceptance and is a **real pass at
dispatch — no glance before.** The outbox held **137 entries** when Red enumerated it in P0; if a
stale artifact persists beside a successful report, that is real and gets its own pass. **Do not
sweep it.**

---

## Fail-branch — any line red

**Freeze. Capture. Report. Do not improvise a fix from the other seat.**

A line that fails on Green is Green's to report and Bloodwave's to rule. Red's correct action is to
wait. A "helpful" Red reaching into Green to repair a share, a PATH, or a clone is the Packet E
failure with the roles reversed — and it would invalidate every line already asserted, because the
node under test would no longer be the node that passed them.

**When this gate's verdict lands, this instrument and its result freeze together as one record.**
A re-run needs a new gate script citing it.

---

## Cross-references

- `GATE_ODYSSEUS_P0_VERDICT_2026-07-10.md` — P0's frozen record. Read it; do not re-derive it.
- `STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md` — the charter. P1 PARITY is its second phase.
- `CORNERMAN_HEADLESS_DROP_WORKER.md` · `STOPGO_CORNERMAN_CLONE_FRESHNESS_2026-07-10.md`
- `STOPGO_TRANSPORT_G_READSURFACE_FOLLOWUP_2026-07-10.md` — *listed-allowed, unreadable in practice.*
