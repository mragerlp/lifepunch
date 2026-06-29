# Cornerman drop workflow (Tier-3 external AI box)

**Role:** Green = **cheap bulk prep** — inbox brief in, distilled outbox out.  
**Not:** ship authority, playtest, git push, or s&box editor.

Canon: `CORNERMAN_MODEL_ROUTING.md` · `CORNERMAN_OFF_CURSOR_HANDOFF.md` · `LOCAL_AI_WORKSTATION.md` §7c

---

## The loop (memorize)

```text
VENGEANCE (Red)                    CORNERMAN (Green)
     │                                    │
     │  1. Warm model                     │
     │  Send-CornermanWorkflow.ps1        │
     │ ───────────────────────────────►  │  lms serve :1234
     │                                    │
     │  2. Drop brief                     │
     │  Push-Cornerman*.ps1 / inbox JSON  │
     │ ───────────────────────────────►  │  C:\lifepunch\cornerman\inbox\
     │                                    │
     │                                    │  3. Qwen distill (manual or LM)
     │                                    │     → outbox\
     │                                    │
     │  4. Pull / read outbox             │
     │ ◄───────────────────────────────  │
     │                                    │
     │  5. Cursor implement + prove       │
     │  6. Owner sign-off → commit        │
```

**Hermes / lifepunchnet (optional later):** may **read** `outbox/` and format daily status — does **not** replace Green distill.

---

## Green paths

| Path | Purpose |
|------|---------|
| `C:\lifepunch\cornerman\inbox\` | Briefs + directives Red pushes |
| `C:\lifepunch\cornerman\outbox\` | **Drops** — distills, summaries, paste-ready packets |
| `C:\lifepunch\cornerman\outbox\workflow-ack.ndjson` | Warm/sync ack log |
| `C:\Projects\lifepunch\` | Read-only monorepo clone (sync before distill) |
| `C:\Projects\cornerman-rag\outbox\` | Legacy RAG lane outbox (some sweeps still here) |
| `C:\lifepunch\cornerman\idle\sessions\` | Candidate **files** when owner away (not default) |

**Repo mirror on Red:** `lifepunch/docs/handoff/cornerman-outbox/` after pull scripts.

---

## When to use Cornerman (vs Opus / Auto)

| Send to Green | Keep on Red (Auto/Opus/Codex) |
|---------------|-------------------------------|
| Canon distill, decision tables, audit reports | Multi-file C#, economy, `[Sync]`, RPCs |
| Paste-ready **Cursor brief** drafts | Implement + flatgrass proof |
| GitHub issue / PR summary drafts | DXRP upstream commits |
| Log dumps, repo maps, ModelDoc asset maps | Razor/SCSS ship after brief approved |
| Overnight **read-only** research | Anything needing Bridge eyes |

**Route tags on every brief:**

| Tag | Warm on Green |
|-----|----------------|
| `GREEN DEEP REQUIRED` | `WarmDistill` or load `qwen/qwen3.6-27b` |
| `GREEN CODE REQUIRED` | `WarmCoder` |
| default distill | `WarmDistill` (Daily + embed) |

---

## Red commands (VENGEANCE — copy/paste)

```powershell
cd C:\Users\jared\Projects\lifepunchaddons\lifepunch\scripts

# 0. Probe + warm (do before every drop batch)
powershell -File ..\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
powershell -File Send-CornermanWorkflow.ps1 -Action WarmDistill
# Heavy / long canon only:
# powershell -File Send-CornermanWorkflow.ps1 -Action FullPerformance

# 1. Sync Green clone + refresh directive
powershell -File Send-CornermanWorkflow.ps1 -Action MonorepoPull
powershell -File Push-CornermanWorkflowDirective.ps1

# 2. Drop a task (pick existing script or generic text push)
powershell -File Push-CornermanInventoryProject.ps1   # example
# Or one-off:
# Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\MY_BRIEF.md' -Text (Get-Content .\my-brief.md -Raw)

# 3. Ack / status
powershell -File Get-CornermanWorkflowStatus.ps1

# 4. Pull outbox to repo handoff folder (after Green writes files)
powershell -File Pull-CornermanGreenfieldSweep.ps1   # template — extend file map as needed
# Or manual: ssh cornerman + read C:\lifepunch\cornerman\outbox\*.md
```

**Interactive distill from Cursor (no inbox file):** use **`cornerman-lm` MCP** on Red — same `:1234`, eyes still covered on visuals.

---

## Inbox brief template (every drop)

Save as `lifepunch/addons/docs/briefs/CORNERMAN_<TASK>.md` or push directly to inbox.

```markdown
# CORNERMAN — <one-line task>

- **Route tag:** GREEN DEEP REQUIRED | GREEN CODE REQUIRED | AUTO OK (distill only)
- **FOCUS:** LifePunch | DXRP upstream (never both in one brief)
- **Slice ID:** H10 / party #73 / etc. (one item)
- **Do:** (bulleted inputs — file paths in monorepo)
- **Deliverable:** exact outbox filename(s) + format
- **Do NOT:** C# ship, git push, playtest claims, secrets
- **Owner gate:** DECISION-#### if canon locked

## Inputs
- `lifepunch/addons/docs/...`
- `lifepunch/docs/DECISIONS/...`

## Output (write to outbox)
- `outbox/<NAME>_CURSOR_BRIEF.md` — paste-ready for VENGEANCE
- `outbox/<NAME>_OPEN_QUESTIONS.md` — OWNER DECISION REQUIRED only
```

---

## Outbox naming

| Pattern | Example |
|---------|---------|
| Cursor handoff | `to-vengeance-<slice>.md` |
| Distill rollup | `<TOPIC>_SUMMARY_YYYY-MM-DD.md` |
| **Lane restart** | `RESTART_PACKET_<lane>_YYYY-MM-DD_HHmm.md` |
| DXRP lane | `DXRP_<issue>-<topic>.md` |
| Status ack | `SWEEP_STATUS.json` |

Every drop footer (required):

```text
Cornerman's eyes are covered — distill from repo/inbox only; not playtest or viewport verified.
```

---

## Pickup on VENGEANCE

1. Read `C:\lifepunch\cornerman\outbox\<file>` via SSH or pulled copy under `lifepunch/docs/handoff/cornerman-outbox/`.
2. Paste **Cursor brief section** into new Cursor chat with **FOCUS** + **route tag**.
3. Implement on Red; **do not** treat Qwen output as done.
4. Flatgrass proof when gameplay/UI; owner approves commit.

**Patch handoff (legacy):** Green read-only key — `Pull-CornermanPatches.ps1` only if Green had local commits (avoid; Red commits directly).

---

## Two lanes — never mix in one drop

| FOCUS | Clone / paths | Outbox prefix |
|-------|---------------|---------------|
| **LifePunch** | `lifepunchaddons`, proprietary OK in brief | `LP_` / `BITCOIN_` / task name |
| **DXRP upstream** | `dxrp-public` only, **no** LIFEPUNCH headers | `DXRP_` / `#73` |

See `DXRP_CONTRIBUTOR_LANE.md`.

---

## Lane restart (after parallel work closes)

When upstream or side work finishes and the **active workstream** resumes (e.g. DXRP bounty closed → lpbitcoin):

1. Red closes/parks parallel repo work (separate clone — never mix commits).
2. `MonorepoPull` on Green + drop restart brief from `lifepunch/docs/handoff/templates/CORNERMAN_RESTART_PACKET_BRIEF.md`.
3. Green writes `outbox/RESTART_PACKET_<lane>_*.md` (read-only; eyes covered).
4. Red runs report-first using `lifepunch/docs/handoff/templates/VENGEANCE_RESUME_REPORT_TEMPLATE.md` — **no code until owner GO**.
5. Architect/Codex plan via `CODEX_LANE_PLAN_PASTE.md` → owner GO → one slice.

**Canon:** `lifepunch/docs/WORKSTREAM_RESTART_WORKFLOW.md` · example packet: `handoff/cornerman-outbox/LPBITCOIN_RESTART_PACKET_2026-06-29_1035.md`

---

## Session checklist (Bloodwave)

**Before drops:**

- [ ] `cornerman.ssh` + `tier3Api` + `tier3Serve` green
- [ ] `WarmDistill` (or `WarmCoder` if brief says so)
- [ ] `MonorepoPull` on Green if brief cites repo paths

**After drops:**

- [ ] Outbox file exists + ack in `workflow-ack.ndjson`
- [ ] Pull or read on VENGEANCE
- [ ] New Cursor chat with route tag — **not** Opus for the whole day

---

## What maximizes the box

1. **Batch overnight:** one inbox directive + 2–3 briefs → outbox by morning; Red ships one slice.
2. **Always one slice per brief** — owner law.
3. **Distill before Opus** — Green shrinks context; Opus plans one slice only.
4. **Use Green Code sparingly** — candidate patches only; Red rewrites + proves.
5. **Keep GPU hot** — watchdog + Daily embed; Deep/Coder on demand, not 24/7 all four unless needed.

---

## Related scripts

| Script | Use |
|--------|-----|
| `Send-CornermanWorkflow.ps1` | Warm, MonorepoPull, checkpoint |
| `Push-CornermanWorkflowDirective.ps1` | Refresh `GREEN-WORKFLOW-DIRECTIVE.json` |
| `Push-Cornerman*.ps1` | Task-specific inbox drops |
| `Get-CornermanWorkflowStatus.ps1` | Ack tail |
| `Pull-CornermanIdle.ps1` | Owner-return idle sessions |
| `Fix-CornermanLmServe.ps1` | Cold start / serve recovery |
