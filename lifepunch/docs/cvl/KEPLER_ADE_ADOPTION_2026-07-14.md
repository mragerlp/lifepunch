# KEPLER ADE ADOPTION - 2026-07-14

**STATUS: PROPOSED, pending Fable review Thursday.**
**Authored by the Fable seat (Copilot harness, orchestrator grant per comms `copilot\0007`).**

## What Kepler is

GitKraken Kepler is an **Agentic Development Environment** (ADE) — a task orchestration
surface that manages multiple AI coding agents across repos with per-task Git worktrees.
It replaces the manual paste-relay workflow between chat windows.

Site: https://help.gitkraken.com/kepler/kepler-getting-started/

## Why LIFEPUNCH adopts it

Tonight's CVL session (PRs #81-86) required manual copy-paste relays between Copilot,
Codex, and Cursor chat windows. Every task brief, round report, GO call, and review
handoff was a clipboard operation through Bloodwave. Kepler eliminates this by routing
tasks directly to agents, each in an isolated worktree.

## CVL classification

**Class B plugin** under `CONSOLE_PLUGINS_DOCTRINE.md` — network-accessing, read-only
on external services (GitHub API for PRs/issues), local-write via agent worktrees.
Capability, not authority. All CVL constraints survive:

- Merge/push/tag = Bloodwave only (unchanged)
- TRIP subordination banners govern every agent session (unchanged)
- Sensor Law applies to all agent output (unchanged)
- Transport Law: Kepler replaces the clipboard, not Bloodwave's authority
- DRIVE grant: board-named per slice (unchanged)

## Agent mapping

| Kepler agent | CVL seat | TRIP role | When to use |
|---|---|---|---|
| Codex CLI | Implementer (DRIVE holder) | TRIP-2-implement | Code slices |
| Claude Code | Red (when available) | TRIP-2-implement | Code slices (Claude usage) |
| Copilot CLI | Fable / orchestrator | TRIP-1-plan | Planning, orchestration |
| Cursor | Reviewer + PR maker | codex-code-review | Cold review, PR creation |
| OpenCode | Flexible harness (any provider incl. local CORNERMAN) | TRIP-2 (Build) / OBSERVE (Plan) | Model-agnostic slices; governed by repo-root `opencode.json` |

OpenCode's Plan/Build modes map to OBSERVE/DRIVE: **Plan = OBSERVE** (read-only),
**Build = DRIVE** (only on an explicit board-named grant + GO). Its repo-root
`opencode.json` grounds every session in CLAUDE.md and hard-denies push/merge/tag.

## Kepler settings for LIFEPUNCH

```
Settings -> General:
  Default Repositories Folder: C:\Users\jared\Projects
  Default Worktrees Folder:    C:\Users\jared\Projects\kepler-worktrees\<REPOSITORY_NAME>

Settings -> Agents:
  Codex CLI:    Connect (implementer)
  Copilot CLI:  Connect (orchestrator)
  Cursor:       Connect (reviewer)
  Claude Code:  Connect when available (Red)

Settings -> Provider Integrations:
  GitHub:       Connect -> mragerlp/lifepunch
```

## Classification: CONTROL PLANE, not authority seat

Kepler is the **CVL control plane** — it hosts and supervises L2 agent sessions
(task control, worktree isolation, session visibility, diffs). It is NOT an L2 seat
itself: it issues no GO words and decides nothing about what becomes canon. Authority
levels (`CVL_AUTHORITY_LEVELS_2026-07-13.md`) are unchanged; a Kepler task inherits
only the grant of the seat driving it (L4 tool law).

## MANDATORY: experimental features OFF

Kepler ships two experimental features that directly conflict with CVL law:

- **AI Sync** — lets agents perform branch rebases and merges. **OFF.**
- **Compose** — lets agents reorganize changes into commits. **OFF.**

`Settings -> Features -> AI Sync: OFF, Compose: OFF`. Both stay off until explicit
CVL law rules otherwise. Agents must never merge, rebase, or manufacture commit
history — those are Bloodwave key actions.

## Task creation pattern

Each TRIP slice = one Kepler Task:

- **Task Name:** `TRIP: <slice-name>`
- **Repository:** `mragerlp/lifepunch`
- **Agent:** per seat mapping above
- **Prompt:** grounding prompt (CLAUDE.md -> ARCHI.md -> TRIP adoption -> skill)

Kepler creates an isolated worktree per task. The agent reads the repo's grounding
files and TRIP skills automatically. No paste relay needed.

## What Kepler replaces

| Before | After |
|---|---|
| 3+ chat windows with paste relays | 1 Kepler task list |
| Manual worktree creation | Auto worktree per task |
| Clipboard-mediated seat handoffs | Agent routing |
| Manual `gh pr checks` | Integrated PR status |
| Bloodwave as paste operator | Bloodwave as Kepler operator |

## What Kepler does NOT replace

- VS Code (code editing, MCP surfaces, Copilot chat for ad-hoc questions)
- s&box editor (compile, playtest, bridge — runtime truth)
- CVL law (authority model, merge gates, Sensor Law)
- TRIP skills (workflow discipline, testing gates)
- Cornerman consult (10.10.10.2:1234, ask-cornerman.ps1)
- The comms lane (records of decisions, BOARD.md)

## Grounding prompt template (for Kepler task prompts)

```
GROUNDING -- LIFEPUNCH CVL IMPLEMENTER

READ THESE FILES FIRST, IN ORDER:
1. CLAUDE.md -- canon of record
2. ARCHI.md -- architecture snapshot (subordinate to CLAUDE.md)
3. lifepunch/docs/cvl/TRIP_ADOPTION_2026-07-14.md -- TRIP workflow law
4. .claude/skills/TRIP-2-implement/SKILL.md -- your build workflow

CONSTRAINTS:
- Author: mragerlp <mragerlp@gmail.com>. Zero AI trailers.
- You may write files. You may NOT push, merge, or open PRs.
- Sensor Law: test output is your sensor.
- s&box editor MCPs: sbox-native (127.0.0.1:7269/mcp),
  sbox-editor (127.0.0.1:9090/sbox-mcp)
- Cornerman: lifepunch/scripts/ask-cornerman.ps1 (10.10.10.2:1234)

Confirm grounding, then await task.
```

## Follow-up work

- [ ] PowerShell port of TRIP codex-implement scripts (start/resume/reset)
- [ ] Verify Codex CLI binary on PATH and model ID compatibility
- [ ] Context7 MCP integration for live doc lookup in agent sessions
- [ ] Kepler task templates for common LIFEPUNCH slice types
- [ ] Evaluate Kepler remote environments for CORNERMAN offload

## Supersession

This record supersedes nothing; it is additive. Write-once.
