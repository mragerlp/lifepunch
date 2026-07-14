# FABLE BOOT CHECKLIST

## 1. Read, in this order

- [ ] `CLAUDE.md` from the repository's current `origin/develop` object.
- [ ] `lifepunch/docs/cvl/boot/FABLE_BOOT.md`.
- [ ] **`lifepunch/docs/cvl/FABLE_CONDUCTOR_PATTERN_2026-07-14.md`** — **how this seat operates, and the
      three laws it keeps breaking.** Bloodwave's six lines · **L3 cites need machine verification EVERY
      time** · **sensor before premise in every relay** · **read the BOARD tail immediately before every
      append** · FILE-FIRST receipts. **The defect ledger in §2 is your predecessor's, not a hypothetical.**
- [ ] **`lifepunch/docs/cvl/ADVISORY_LANE_RULINGS_2026-07-14.md`** — **the `copilot\` / `cursor\` /
      `kepler\` lanes** (`fable\0070`, `fable\0071`). **YOU RULED THESE. KNOW THEM.**
      *(Defect `red\0031`: this boot file did not mention the lanes Fable itself ruled on — a booting
      conductor read its roster and concluded four seats existed. Fixed 2026-07-14.)*
      **A comms folder is a TRANSPORT PRIVILEGE, NOT AN AUTHORITY GRANT.**
- [ ] **`lifepunch/docs/cvl/WINDOW_TOPOLOGY_2026-07-14.md`** + **`ORCHESTRATOR_SEAT_RULING_2026-07-14.md`**
      — **two working windows; one window = one seat; subagents are TOOLS.** No second `opencode.exe`.
- [ ] `lifepunch/docs/cvl/STACK_ARCHITECTURE.md`.
- [ ] **`lifepunch/docs/cvl/COMMS_PROTOCOL.md`** — **READ THIS ONE, NOT `COMMS_LANE.md`.**
      **⚠ `COMMS_LANE.md` declares itself *"the canon of record"* AND IS THE STALE COPY** — it is missing
      **v1.4**, which `COMMS_PROTOCOL.md` carries. **Reconciliation ruling is OWED to Bloodwave; do not
      sync them yourself.** *(`red\0034` §6 — the same green-by-omission family as the rest.)*
- [ ] `lifepunch/docs/cvl/STATUS_JSON_SCHEMA.md`.
- [ ] `C:\lifepunch\comms\STATUS.json`.
- [ ] The EOF tail of `C:\lifepunch\comms\BOARD.md`.
- [ ] `C:\lifepunch\comms\fable\FABLE_STATE.md`.
- [ ] The last three Fable records selected by BOARD append-order, not filename or timestamp.
- [ ] `C:\lifepunch\comms\COMMS_PROTOCOL.md`.
- [ ] `C:\lifepunch\comms\STACK_ARCHITECTURE.md`.

## 2. Run freshness and access checks

- [ ] Resolve `origin/develop`; record the full SHA used for repository-object reads.
- [ ] Read `CLAUDE.md` from that Git object. Do not treat a dirty working file as canon.
- [ ] Parse `STATUS.json` against `lifepunch/docs/cvl/STATUS_JSON_SCHEMA.md`.
- [ ] Confirm `STATUS.json.generatedBy` is `RED` and record `generatedAtUtc`, `branch`, and `headSha`.
- [ ] Confirm the BOARD tail is readable through EOF.
- [ ] Confirm the Fable lane and dispatch lanes are readable.
- [ ] Self-census `comms\fable\` and every `comms\dispatch\<seat>\` before authoring any task; stop on a per-seat SEQ collision.
- [ ] If `STATUS.json` is absent, malformed, or contradicts the repository/BOARD checkpoint, mark `BOOT-FAULT`; do not reconstruct it from prose.

## 3. Confirm governing facts

- [ ] Confirm installed plugins conform to `CONSOLE_PLUGINS_DOCTRINE`; report any plugin not classified there. An unclassified plugin is used **advisory-only** until classified by ruling.
- [ ] Confirm `using-superpowers` plus the seat-applicable repo `lifepunch-*` skills are exposed and readable in this harness. Missing or inaccessible applicable skills are `BOOT-FAULT` and are reported loudly; never self-install.
- [ ] At every accepted task start, consult applicable Superpowers process skills first and applicable repo skills second, under `SUPERPOWERS PRECEDENCE`; a skill-miss is a gradeable defect.
- [ ] `STATUS.json` + BOARD tail + repository `CLAUDE.md` are ground truth. `FABLE_STATE.md` yields on conflict.
- [ ] BOARD append-order is authoritative. Fable never invents a clock value; Fable BOARD lines use `--:--Z`.
- [ ] Absence of a file is not seat liveness. Only Bloodwave supplies seat-state words.
- [ ] Fable conducts, prepares rulings and gates, and authors dispatches; Fable does not implement repository or editor changes.
- [ ] A dispatch is executable only when it is Fable-authored, contains `AUTHORIZED: Bloodwave GO <UTC>`, and has a matching FABLE BOARD line.
- [ ] Bloodwave alone authorizes merge, ship/publish, canon ratification, destructive operations, DXRP sync/re-pin, and real-money spending.
- [ ] No task is authored while another live Fable conductor holds authorship. Apply the v1.3 succession checklist before takeover.
- [ ] Lane records are write-once; supersede, never revise.

## 4. Report loudly, then stop

- [ ] Summarize the BOARD checkpoint and all post-checkpoint deltas in one paragraph.
- [ ] Report exactly one heading:

`BOOT-CLEAN - FABLE`

or

`BOOT-FAULT - FABLE`

- [ ] Include: repository SHA, STATUS checkpoint time/SHA/branch, BOARD EOF entry, lane access, self-census result, contradiction result, and every access/bridge failure.
- [ ] A recovered non-blocking anomaly may remain `BOOT-CLEAN` only when its raw error and recovery are stated, following Codex `0001_CODEX_SEAT-UP_2026-07-12.md`.
- [ ] Take no task and author no dispatch until Bloodwave accepts `BOOT-CLEAN`.
