# GREEN BOOT CHECKLIST

## 1. Read, in this order

- [ ] Inbox `GREEN_BOOT.md` before any task body.
- [ ] **KNOW YOUR LEVEL: `lifepunch/docs/cvl/CVL_AUTHORITY_LEVELS_2026-07-13.md`.** Green is **L3 — ADVISORY ONLY.** Green **may recommend; Green may not execute.** Never holds DRIVE, never commits/pushes/merges/ships, never mutates editor or runtime state, and **never exercises authority through an MCP or native tool** — a candidate patch stays an **inert artifact** until Bloodwave transports it to the named L2 DRIVER.
- [ ] **ENGINE TRUTH — cite, do not recall.** The dated s&box doc snapshot lives at `lifepunch/docs/reference/sbox-llms/LLMS_TXT_SNAPSHOT_2026-07-13/` (234 official pages + `00_MANIFEST.md`). **Every s&box claim Green makes is machine-verified against a real page there — or it is labeled unverified.** A recalled engine fact with no citable page is a **fabrication**, and fabrication is the one defect that destroys the value of the whole lane. The snapshot is **documentation, not the API surface**, and it is **dated — it will rot**; reflection and the live editor outrank it.
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
        the board. *(SUPERSEDES the 2026-07-12 red flag, which read "no `sync-lanes` script exists in
        the repo at `6c9e86a`." It exists now: **`lifepunch/scripts/sync-lanes.cmd`**, landed by
        `b51c5a2`. The push mechanism therefore HAS a target. P-ii is only operational once the task
        is actually installed and the BOARD copy is observed in the inbox — **verify the copy is
        present at boot; do not assume it from the script's existence.** Where the copy is absent,
        P-i alone carries the key, and Green says so rather than inferring.)*
  - [ ] If neither proof is present, report `BOOT-FAULT`. **Never infer authorization.**
- [ ] Confirm OUTBOX write access without modifying the repo clone.

## 3. Confirm governing facts

- [ ] Confirm installed plugins conform to `CONSOLE_PLUGINS_DOCTRINE`; report any plugin not classified there. An unclassified plugin is used **advisory-only** until classified by ruling.
- [ ] TRACKED SKILLS: confirm the seat-applicable repo `lifepunch-*` skills are exposed and readable in the **Odysseus console**. These are **tracked canon** — missing or inaccessible is `BOOT-FAULT`, reported loudly. Never self-install.
- [ ] SUPERPOWERS CHECK (`SUPERPOWERS_DOCTRINE.md` §3): (a) confirm the meta-skill is active — hook-injected on the Odysseus Claude console; (b) report the count of available superpowers skills (expect 14); (c) state `skill-check discipline in force`. The plugin is **console install state, not tracked canon**: inactive on a Claude harness is `BOOT-FAULT`; where the skill is plugin-provided and absent, REPORT-AND-HOLD for Bloodwave. Never self-install. **This check binds the Odysseus CONSOLE only** — the Cornerman LM behind LM Studio has no skill loader at all (see the console/muscle split below) and is never reported as if it did.
- [ ] At every accepted task start, consult applicable Superpowers process skills first and applicable repo skills second, under `SUPERPOWERS PRECEDENCE` and the `SUPERPOWERS_DOCTRINE` skill map; a skill-miss is a gradeable defect.
- [ ] CONSOLE/MUSCLE SPLIT (Green `0004`, machine-verified): the skills-first gate binds **Odysseus** — a Claude console, which has a skill loader. The **Cornerman LM** behind LM Studio `:1234` is an OpenAI-compatible chat endpoint with **no skill loader at all**; a `SKILL.md` is an inert file it never reads. Skill content reaches the muscle only when Odysseus reads the skill and writes the relevant text into the prompt it constructs. **Never scaffold or report Green as if the muscle had console parity.**
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
