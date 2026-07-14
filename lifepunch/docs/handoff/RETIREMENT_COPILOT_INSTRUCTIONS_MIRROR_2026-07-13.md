# RETIREMENT — the Cursor→Copilot instructions mirror

**Class:** RETIREMENT RECORD (write-once) · **Date:** 2026-07-13 · **Author:** Red (Claude Code Opus)
**Authority:** Bloodwave ruling, relayed 2026-07-13 — *"RETIRE the Cursor→Copilot sync pipeline."*
**Task basis:** `comms\fable\0029_FABLE3_COPILOT-INSTRUCTIONS-STALE-DISPATCH_2026-07-13.md`

---

## 1. WHY

`.github/copilot-instructions.md` (dated 2026-07-08) and the 22 files in `.github/instructions/`
were **auto-loaded by VS Code into every Copilot request** in this workspace — unprompted, on every
turn. They described a **superseded law system**:

- `.cursor/rules` as the source of truth (CLAUDE.md is now the canon of record)
- an **"Active lane" gate** — *"lifepunchbitcoin/lpbitcoin only … Blocked: Hacker, Banker,
  Government, Casino"* (June 2026; long overtaken)
- a **Copilot ↔ Cursor handoff model** (Cursor is retired from the standard loop)
- `START_HERE_AGENTS.md` as the first read (still exists, but is now subordinate to `CLAUDE.md`)

This is the **same stale-boot failure class** the seat boot files fixed for Red, Codex, and Green —
here for a fourth, unmanaged agent surface that nobody was watching.

## 2. WHAT WAS REMOVED

| Removed | Count |
|---|---|
| `.github/instructions/*.instructions.md` | **22** (21 generated mirrors + `copilot-repo-ownership`, the hand-written one) |
| `lifepunch/scripts/Sync-CursorRulesToCopilotInstructions.ps1` | **1** (the generator) |

`.github/copilot-instructions.md` was **rewritten**, not removed — VS Code still auto-loads it, so it
is the one file guaranteed to reach a Copilot session. It now points at real canon (`CLAUDE.md` →
`lifepunch/docs/cvl/`) and states Copilot's actual standing: **not a ratified seat; advisory-only per
`CONSOLE_PLUGINS_DOCTRINE` §3.7; never commits, pushes, merges, edits autonomously, or touches the
editor.** Author stays `mragerlp`, zero AI attribution.

**Verified before carrying forward** (rather than blind-copied): the repo-root path, the monorepo
folder map, and the *"never mix `dxrp-public` with this repo"* warning are all still accurate —
except that **`dxrp-public` is not a folder in this repo at all** (it is a separate clone elsewhere),
and **`lifepunchdxrp/` is untracked** (`.gitignore:2`). Both corrections are in the new file. The
`DECISIONS/` directory named in the old law hierarchy **does not exist** and was dropped.

## 3. WHAT WAS **NOT** REMOVED, AND WHY — `.cursor/rules/` (21 files) IS RETAINED

The ruling named *"script + 21 rules + 22 mirrors."* **The 21 `.cursor/rules/*.mdc` are load-bearing
well beyond Copilot, and deleting them was held for its own ruling.** They are:

- **Injected as the grounding bundle into EVERY GitLab lane export** —
  `lifepunch/scripts/Export-GitLabLane.ps1:33` and `lifepunch/scripts/setup-gitlab-projects.ps1:198`
  both hardcode `$Grounding = @('.cursor/rules', 'lifepunch/docs')`, and
  `lifepunch/docs/gitlab-projects.json:16-18, 37` lists `.cursor/rules`, `.cursor/hooks.json`, and
  `.cursor/hooks` in the `groundingBundle`. **Deleting the rules would silently strip grounding from
  every future lane export** — the clones would stop being self-grounding and nothing would say so.
- **Cited as "repo law" by ~40 canon documents**, including `START_HERE_AGENTS.md:6,29`,
  `CVL_AGENT_ONBOARDING.md:96,379`, `AGENT_ONBOARDING.md:11,64,260`, `AGENT_PROMPT.md:69,90`,
  `OPUS_USAGE_LAW.md:206-207`, `ARCHITECT.md:37,138`, `OWNERSHIP_MATRIX.md:55`,
  `REPO_DOMAIN_MAP.md:39,146,151`, `TRADEMARK_AND_IP.md:4`, `CONFIG_SOURCE_OF_TRUTH.md:94`, and the
  root `README.md:32`. **Deleting the rules orphans all of them at once.**

**Retiring the Copilot mirror achieves the ruling's stated goal** — it stops stale law auto-loading
into Copilot. **Retiring `.cursor/rules` is a different and much larger slice**, and it needs its own
ruling with the blast radius above on the table, plus a decision about what grounds the GitLab lane
exports afterwards. **That question is OPEN and OWED to Bloodwave.**

## 4. KNOWN STALE POINTERS LEFT BEHIND (reported, not silently fixed)

Two documents still describe the retired mirror as live. They are **prose docs, not write-once
records**, and fixing them is a trivial follow-up — but they are named here rather than left to rot:

- `lifepunch/docs/COPILOT_AGENT_ONBOARDING.md:5` — *"`.github/instructions/*.instructions.md`
  auto-loads all 20 rules."* **No longer true.**
- `lifepunch/docs/DUAL_IDE_CURSOR_VSCODE.md:12, 30, 90, 138` — describes the Copilot↔Cursor mirror
  workflow and `copilot-repo-ownership.instructions.md`, now deleted.

They were left **out of this slice deliberately**: this PR is scoped to the Copilot auto-load
surface, and rewriting the dual-IDE onboarding docs is a judgment call about whether the Cursor lane
is being retired at all — which is exactly the open question in §3. **Fixing them before that ruling
would be guessing at its answer.**

## 5. SENSOR NOTE

The `.cursor/rules` blast radius was found by grepping **every reference to the things being deleted
before deleting them**. That check is in this record because the last canon PR (#77) shipped a
dangling path precisely because its path sweep only looked where it expected to find paths. **A
deletion is a claim that nothing depends on the thing — and that claim needs a sensor like any
other.**

FROM: Red (Claude Code Opus)
