# Workstream restart workflow (parallel work → resume active lane)

**Status:** Canon — reuse for every lane handoff (Bitcoin, ULX, future addons, upstream bounties).  
**First exercised:** 2026-06-29 — DXRP #73 closeout → lpbitcoin resume.  
**Related:** `CORNERMAN_DROP_WORKFLOW.md` · `DXRP_CONTRIBUTOR_LANE.md` · `AGENT_ONBOARDING.md` · `lifepunch-commit-hygiene` rule

---

## Problem this solves

LifePunch runs **parallel work** (upstream DXRP bounties, partner lanes, doc passes) while one **active production gate** owns Red ship time (`ACTIVE_WORKSTREAM.md`). When parallel work closes, agents must not:

- Mix repos, branches, or commits across lanes
- Jump straight to implementation without repo/canon grounding
- Burn Opus re-deriving context every session

This workflow standardizes: **close parallel work → sync CVL → Green restart packet → Red report-first → Architect/Codex plan → owner GO → one slice**.

---

## The five-step loop

```text
1. CLOSE parallel work (separate repo/branch — e.g. dxrp-public PR)
        ↓
2. SYNC CVL — Red push monorepo; Green MonorepoPull (Send-CornermanWorkflow.ps1)
        ↓
3. GREEN restart packet — read-only distill → outbox RESTART_PACKET_<lane>_<date>.md
        ↓
4. RED report-first — sync, separation check, canon read, packet summary, ONE slice rec — NO CODE
        ↓
5. OWNER GO → implement one slice → flatgrass proof → commit (consent) → next slice
```

**Architect / Codex** sit between steps 4 and 5: turn the packet + Red report into an approved execution plan.

---

## Lane separation (hard law)

| Work type | Clone | Commit? | Mix into monorepo? |
|-----------|-------|---------|-------------------|
| **LifePunch addon ship** | `lifepunchaddons` | Yes (owner GO) | N/A |
| **DXRP upstream bounty** | `dxrp-public` | Yes (bounty branch) | **Never** |
| **Cornerman distill** | Green read-only clone | **No push** | Briefs only; no code |

Before any lpbitcoin (or other active-lane) session after upstream work:

1. Confirm parallel PR/branch is closed or parked in its **own repo**
2. `git grep` active lane for foreign identifiers (e.g. no `PartySystem` in monorepo after DXRP party bounty)
3. Read `ACTIVE_WORKSTREAM.md` — only the gated lane gets implementation

Detail: `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`

---

## Step 2 — CVL sync commands (Red)

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
git fetch
git pull --rebase
git status -sb

cd lifepunch\scripts
powershell -File Get-CvlConnectivityStatus.ps1 -Pretty
powershell -File Send-CornermanWorkflow.ps1 -Action MonorepoPull -Message "Post-<parallel-work> closeout — sync before <lane> restart"
```

Green must be at the same `main` HEAD (or report behind/dirty and stop).

---

## Step 3 — Green restart packet

**Template:** `lifepunch/docs/handoff/templates/CORNERMAN_RESTART_PACKET_BRIEF.md`  
**Example output:** `lifepunch/docs/handoff/cornerman-outbox/LPBITCOIN_RESTART_PACKET_2026-06-29_1035.md`

### Inbox drop (Red)

Push brief + JSON directive to `C:\lifepunch\cornerman\inbox\`:

- `CORNERMAN_<LANE>_RESTART_PACKET.md`
- `CORNERMAN_<LANE>_RESTART_DIRECTIVE.json`

Use `Push-CornermanText` via a lane-specific `Push-Cornerman*.ps1` or inline from `Cornerman-Workflow.ps1`.

### Green mode (non-negotiable)

- Read-only distill · **no code** · **no commits** · **no push**
- **Eyes covered** — label `NEEDS SBOX RUNTIME PROOF` for anything visual
- Output: `C:\lifepunch\cornerman\outbox\RESTART_PACKET_<lane>_<YYYY-MM-DD>_<HHmm>.md`
- Mirror on Red: `lifepunch/docs/handoff/cornerman-outbox/` (commit mirror after owner review optional)

### Required packet sections

1. Current repo state (HEAD, branch, dirty, parallel-work separation)
2. Current lane state (canon + code; label every claim)
3. **ONE** recommended next Red slice (do not invent new direction)
4. File map for next slice (if applicable)
5. Model route table (GREEN / AUTO / OPUS / owner GO)
6. Paste-ready VENGEANCE resume block

### Completion signal

```text
OK cornerman <lane>-restart-packet complete @<time>
head=<commit>
outputs=1
eyes=covered
no-code
no-commit
```

---

## Step 4 — Red report-first (VENGEANCE)

**Template:** `lifepunch/docs/handoff/templates/VENGEANCE_RESUME_REPORT_TEMPLATE.md`

Run **before any edit** when resuming the active lane. Reply with the 12-section format (git state, separation, canon summary, packet summary, implementation checks, conflicts, ONE action, files, proof, routing, blockers, waiting for GO).

End every report with:

```text
No implementation performed. Waiting for Bloodwave GO.
```

---

## Step 5 — Plan layer (Architect / Codex)

**Codex template:** `lifepunch/docs/handoff/templates/CODEX_LANE_PLAN_PASTE.md`

Codex turns packet + Red report into a numbered execution plan (boot commands, proof script, screenshot checklist, commit template, HOLD list, single GO line). **No code until owner GO on a named slice.**

---

## Slice order pattern (Bitcoin reference — adapt per lane)

| Order | Slice | Route |
|-------|-------|-------|
| 1 | **Flatgrass proof** of UI/navigation already in repo | AUTO + bridge |
| 2 | **Commit cleanup** from proof nits (Razor/SCSS/copy only) | AUTO; owner commit GO |
| 3 | **Plan-only** for next canon milestone (e.g. U1 Servers read-only) | Architect / GREEN DEEP |
| 4 | **Implement plan** after explicit GO | AUTO for UI; OPUS for economy/Sync/RPC |
| HOLD | Economy, persistence, migration, cascade | OPUS + owner |

Adjust slice names for other addons (e.g. ULX = panel proof → publish staging proof).

---

## Commit / push hygiene (all lanes)

- **Cursor Settings → Agent → Attribution:** Commit + PR **OFF**
- Install hook: `powershell -File lifepunch\scripts\Install-CommitHygieneHook.ps1`
- Author: `mragerlp <mragerlp@gmail.com>` only — no AI co-author trailers
- Reference issues in **PR body**, not every commit subject
- Law: `.cursor/rules/lifepunch-commit-hygiene.mdc`

---

## Adapting for a new addon lane

When `ACTIVE_WORKSTREAM.md` moves to a new package (e.g. `lifepunchulx`, future hacker lane):

1. Copy `CORNERMAN_RESTART_PACKET_BRIEF.md` → fill **FOCUS**, canon doc list, code paths, slice IDs
2. Update `ACTIVE_WORKSTREAM.md` + ship roadmap before Green runs
3. Drop Green brief; wait for outbox packet
4. Run VENGEANCE resume template with lane-specific canon reads
5. Codex plan paste with lane ground truth
6. Owner GO → one checklist ID → proof → commit

**Do not** reuse another lane's packet verbatim — swap doc paths, entity names, and proof commands.

---

## Reference instance (2026-06-29)

| Step | Artifact |
|------|----------|
| Parallel closeout | DXRP PR #77 · `dxrp-public` · commit-hygiene rule @ `732fc40` |
| Green packet | `LPBITCOIN_RESTART_PACKET_2026-06-29_1035.md` |
| Red recommendation | Slice A — flatgrass proof Universal Upgrades navigation |
| Next after GO | U1 Servers status conversion (plan first) |

---

## Related files

| File | Role |
|------|------|
| `lifepunch/docs/handoff/templates/CORNERMAN_RESTART_PACKET_BRIEF.md` | Green inbox template |
| `lifepunch/docs/handoff/templates/VENGEANCE_RESUME_REPORT_TEMPLATE.md` | Red report-first template |
| `lifepunch/docs/handoff/templates/CODEX_LANE_PLAN_PASTE.md` | Codex plan builder skeleton |
| `lifepunch/docs/CORNERMAN_DROP_WORKFLOW.md` | Daily drop loop + MonorepoPull |
| `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md` | Upstream fork separation |
| `lifepunch/addons/docs/ACTIVE_WORKSTREAM.md` | Single active production gate |
