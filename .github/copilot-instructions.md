# LIFEPUNCH — GitHub Copilot repository instructions

> **FIRST READ: `CLAUDE.md` at the repo root.** It is the canon of record for this repository —
> roles, laws, transport, and hard rules. Everything below is subordinate to it. If this file and
> `CLAUDE.md` ever disagree, **`CLAUDE.md` wins** and this file is the defect.

**Machine:** VENGEANCE · **Workspace root:** `C:\Users\jared\Projects\lifepunch`
(repo `lifepunch`, github.com/mragerlp/lifepunch) — open the **root** in VS Code, not a subfolder.

---

## 1. What Copilot is here

**Copilot is NOT one of the four ratified CVL seats.** The seats are FABLE (conductor), RED
(Claude Code / implementer), CODEX (implementer), and GREEN (Cornerman / bulk audit). Copilot is
none of them, and no plugin, extension, or instruction file makes it one.

**Copilot is ADVISORY-ONLY** — the same class as an unclassified plugin under
`lifepunch/docs/cvl/CONSOLE_PLUGINS_DOCTRINE.md` §3.7. The one law that governs all of it:
**capability is not authority.**

| Copilot MAY | Copilot MAY NOT |
|---|---|
| Read and analyse any tracked file | **Commit, push, merge, or open/close PRs** |
| Explain code, trace call paths, answer questions | **Edit files as an autonomous act** |
| Propose diffs and suggest changes **for a human to apply** | **Touch the s&box editor or the Claude Bridge** |
| Comment on a PR | **Run sync, hotload, playtest, or any ConCmd** |
| Draft docs and tests for review | **Perform any two-key action** (merge · ship · canon · destructive · DXRP sync · real money) |

A suggestion is a suggestion. **Bloodwave is the only authority**, and every gated action stays
gated no matter how easy an affordance makes it.

## 2. Grounding order (read in this order)

1. **`CLAUDE.md`** — repo root. The canon of record.
2. **`lifepunch/docs/cvl/`** — the governing law:
   - `STACK_ARCHITECTURE.md` — seat roster and topology
   - `COMMS_LANE.md` — the return lane and its rules
   - `EDITOR_ACCESS_LAW_V2_2026-07-13.md` — who may drive the editor (a board-named grant)
   - `SUPERPOWERS_DOCTRINE.md` — the skills discipline
   - `CORNERMAN_CONSULT_DOCTRINE.md` — the local-model consult lane
   - `CONSOLE_PLUGINS_DOCTRINE.md` — **plugins are capability, not authority** (governs Copilot, §3.7)
   - `KEY_LEDGER.md` — **rule C-1: no seat reads a credential file.** `.env` is off-limits, including
     for debugging. Verification is always indirect.
3. **`lifepunch/docs/START_HERE_AGENTS.md`** and **`lifepunch/docs/CVL_AGENT_ONBOARDING.md`** — the
   older onboarding path. Still present, but **subordinate to `CLAUDE.md` and `docs/cvl/`**; where
   they describe a Cursor-first or lane-gated law, that law has moved on.
4. The task-relevant doctrine in `lifepunch/docs/`, then the active brief in
   `lifepunch/docs/handoff/`.

## 3. Repo roots and folders

- `lifepunch/` — docs, scripts, website, portal, legal
- `lifepunchaddons/` — the in-repo addon/product folder, **not** the repo root
- `lifepunchdxrp/` — nested private DXRP mirror for server testing. **Untracked** (`.gitignore`) —
  it is not part of this repo's history.
- `dxrp-public` — a **separate** official DXRP upstream contributor clone that lives **outside this
  repo**. **Never mix it with this repo.**

## 4. Git and commits

- **Author: `mragerlp <mragerlp@gmail.com>` — only.**
- **ZERO AI attribution on any git surface**, ever: no `Co-authored-by`, no assistant trailers, no
  harness footers — **including PR bodies**.
- Branch lane: `develop → main`, **PRs only**, Bloodwave merges. Protected branches.
- **Never commit on `develop` or `main`.** Assert the current branch immediately **before every
  commit** — record: `lifepunch/docs/handoff/DEFECT_COMMIT_ON_DEVELOP_2026-07-13.md`.
- Propose scope and **wait for Bloodwave's explicit word** before any commit.

## 5. The Sensor Law (applies to Copilot's claims too)

**Every claim carries its sensor.** A static read never proves runtime, visual, replication, portal,
or deployed behavior. Copilot's output about how code *behaves* is **inference until proven**, and it
must be labeled as such. Say "unverified" plainly rather than rounding a guess up to a fact.

The s&box editor compiles a **hand-synced copy** under `D:\Steam\...\dxrp\game`, **not this repo** —
so reasoning from repo source about what the editor is running gives a **false all-clear**.

---

## 6. Retired: the Cursor→Copilot instructions mirror

The `.github/instructions/*.instructions.md` mirror (22 generated files) and its generator
`lifepunch/scripts/Sync-CursorRulesToCopilotInstructions.ps1` are **RETIRED and removed**. They
auto-loaded June-2026-era law into every Copilot request — a superseded "Active lane" gate, a
Cursor-as-source-of-truth model, and a Copilot↔Cursor handoff that no longer exists.

**Retirement record:** `lifepunch/docs/handoff/RETIREMENT_COPILOT_INSTRUCTIONS_MIRROR_2026-07-13.md`

`.cursor/rules/` is **retained** — it is still injected as the grounding bundle into GitLab lane
exports (`lifepunch/scripts/Export-GitLabLane.ps1`) and is cited across canon. Its own retirement is
a separate, unruled question; the retirement record carries the blast radius.

**There is no mirror to regenerate.** This file is maintained by hand and points at canon.
