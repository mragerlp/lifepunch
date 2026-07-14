# GREEN AUTONOMOUS SCAN — 2026-07-14

**STATUS: RATIFIED** (Bloodwave GO 2026-07-14).
**Lane record:** `C:\lifepunch\comms\copilot\0013_COPILOT_GREEN-AUTONOMOUS-SCAN-RULING_2026-07-14.md`
**Instrument:** `lifepunch/scripts/cornerman-scan.ps1`

## Ruling (verbatim from copilot\0013)

Green/OpenCode on CORNERMAN is authorized to run **scheduled read-only repo
scans** on an interval. This amends the Corner Loop charter's "no schedulers,
no background loops" prohibition for this specific, bounded use case.

### Scope

1. **Read-only.** Scans may read any tracked file in the Green clone. They
   may NOT edit, commit, push, merge, tag, or delete any file in the repo.
2. **OUTBOX egress only.** Scan results are written to
   `C:\lifepunch\cornerman\OUTBOX\scans\` as timestamped markdown files.
   No writes anywhere else.
3. **Model:** `qwen3.6-27b` (smaller, faster — reserve `qwen2.5-coder-32b`
   for interactive sessions). Live LM Studio id on CORNERMAN:
   `qwen/qwen3.6-27b`.
4. **Interval:** configurable, default every **15 minutes**. Minimum 5 minutes.
   Each scan must complete before the next starts — no overlapping runs.
5. **Fast-fail.** Any error, timeout (>120s), or model hang → abort that scan,
   write a one-line error to the OUTBOX, wait for next interval.
6. **Every scan result opens with:** `ADVICE, NOT A WORK ORDER`
7. **No autonomous action.** Scans produce findings. Findings are not work
   orders. A human or authorized seat acts on them through the normal CVL loop.

### Scan types (initial set, extensible by Bloodwave GO)

- **Stale doc detection** — files referencing superseded paths, roles, or canon
- **Pattern lint** — AI attribution markers, credential patterns, banned terms
- **Skill health** — paired-surface parity (`.claude/skills/` vs `.agents/skills/`)
- **Branch hygiene** — stale remote branches, merge conflicts on develop

### What this does NOT authorize

- Background loops on VENGEANCE (this is CORNERMAN-only)
- Any write to the repo (commits, edits, branch operations)
- Any network calls beyond localhost LM Studio
- Autonomous patch generation or application
- Running while the 32B model is serving an interactive session (GPU contention)

### Implementation

`lifepunch/scripts/cornerman-scan.ps1`:

1. Pulls latest on the Green clone (`git pull --rebase origin develop`)
2. Runs each scan type via the LM Studio API (`127.0.0.1:1234/v1`)
3. Writes results to `OUTBOX\scans\SCAN_<TYPE>_<UTCDATE>.md`
4. Can be scheduled via Windows Task Scheduler on CORNERMAN, or run with
   `-Once` / looping `-Interval`

Green does not write its own scanner — implementer lane owns the script.

## Related canon

- Corner Loop: `lifepunch/docs/handoff/STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md`
- Consult doctrine: `lifepunch/docs/cvl/CORNERMAN_CONSULT_DOCTRINE.md`
- OpenCode harness: `lifepunch/docs/cvl/OPENCODE_HARNESS_ADOPTION_2026-07-14.md`
- CORNERMAN setup instrument: `comms\copilot\0012`
