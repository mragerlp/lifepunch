# GREEN BOOT CHECKLIST

## 1. Read, in this order

- [ ] Inbox `GREEN_BOOT.md` before any task body.
- [ ] `CLAUDE.md`, `lifepunch/docs/START_HERE_AGENTS.md`, and the current Cornerman charter from the Green clone.
- [ ] Mirrored `COMMS_PROTOCOL.md`, `STACK_ARCHITECTURE.md`, and `STATUS_JSON_SCHEMA.md` supplied with the packet.
- [ ] The candidate Green dispatch and its supplied FABLE BOARD authorization evidence.
- [ ] The complete, finished input packet or round report. Never inspect Red's live or mid-round tree.

## 2. Run R7 freshness and access checks

- [ ] Require the dispatch to state target branch, full expected SHA, and every `expectedClones` entry. Missing data is `BOOT-FAULT`.
- [ ] Run one non-forcing fetch in each expected clone.
- [ ] Record clone path, branch, `HEAD`, `origin/<target>`, and fast-forward/identity result.
- [ ] Require every clone read point to equal the dispatch's expected SHA. Do not substitute another clone or silently update expectations.
- [ ] Apply Green fast-fail: no retries, detach, polling loop, CIM/WMI, or scheduled task; any error or hang near 20 seconds aborts with the raw error.
- [ ] Validate the dispatch's Fable author and exact `AUTHORIZED: Bloodwave GO <UTC>` header.
- [ ] Validate the matching FABLE BOARD line. **RULING P (ratified 2026-07-12)** resolves how, and
      it takes BOTH halves — they are cheap and they are belt-and-braces:
  - [ ] **(P-i) Packaged proof.** Every Green dispatch packet carries, inside itself, its own
        `AUTHORIZED: Bloodwave GO <UTC>` line **and the matching FABLE BOARD line verbatim**. Green
        validates the third dispatch key from the packet alone, with no cross-machine read.
  - [ ] **(P-ii) Read-only BOARD copy.** The lane-sync push additionally delivers a **read-only copy
        of `BOARD.md`** to Green's inbox, so Green can independently verify the packaged line against
        the board. *(Red flag, machine-verified 2026-07-12: no `sync-lanes` script exists in the repo
        at `6c9e86a`. P-ii has no target yet — the push mechanism must be authored before P-ii is
        operational. Until then P-i alone carries the key, and that is stated here rather than
        assumed.)*
  - [ ] If neither proof is present, report `BOOT-FAULT`. **Never infer authorization.**
- [ ] Confirm OUTBOX write access without modifying the repo clone.

## 3. Confirm governing facts

- [ ] Confirm installed plugins conform to `CONSOLE_PLUGINS_DOCTRINE`; report any plugin not classified there. An unclassified plugin is used **advisory-only** until classified by ruling.
- [ ] Green/Cornerman is static-only bulk audit and recon: flags, never decides.
- [ ] Every output opens `ADVICE, NOT A WORK ORDER`.
- [ ] Green reads completed drops cold, never Red's live state, and never pushes.
- [ ] Green's eyes are covered: static code cannot verify runtime, visuals, replication, scale, materials, collider, animation, portal, or deployed state.
- [ ] Green facts are Green's to assert; cross-seat repair is forbidden without Bloodwave's explicit relay.
- [ ] Green writes only to its OUTBOX. **Green's OUTBOX record IS its filing** (Ruling P). Green does
      not append to `BOARD.md` — Fable appends Green's BOARD line marked **`via mirror`** at each read
      cycle. That is **mechanical transport, not a transfer of authority**: the record is Green's, the
      board entry is Fable's clerical act.

## 4. Report loudly, then stop

- [ ] Write a real-UTC OUTBOX boot record with the packet identity and exact clone sensors.
- [ ] Report exactly `BOOT-CLEAN - GREEN` or `BOOT-FAULT - GREEN` before the task body.
- [ ] Include dispatch three-key result, each clone SHA, OUTBOX access, and every raw failure.
- [ ] Perform no task-body work until Bloodwave accepts `BOOT-CLEAN`.
