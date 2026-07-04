---
applyTo: "**"
description: "LifePunch operating context, ownership defaults, and workflow"
sourceRule: ".cursor/rules/lifepunch-operating-context.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-operating-context.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch — Operating Context

## Working style
- Treat this as a business. Be direct and efficient; prioritize shipping.
- **Owner alias (June 2026+):** **Bloodwave** = visible name (in-game · Steam · Discord · agent chat).
  **mragerlp** = legal/proprietary author on code. **Mr. Rager** = email/legacy contact (same person).
  Canon: `lifepunch/docs/BLOODWAVE_ALIAS.md`.
- Do NOT comment on the user's time, health, or well-being, and do not suggest
  resting/stopping. Just keep the work moving.
- Goal: build a shippable addon portfolio (weapons + entities) for DXRP servers.
- **Active workstream gate (hard law):** `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md` — only
  `lifepunchbitcoin` (Hub → Terminal → GPU Rack) until flatgrass proof + owner sign-off.
  **Reference laws:** `CYBER_REFERENCE_LAWS.md`. Blocked lanes park in `BACKLOG_PARKING_LOT.md`.
  Rule: `.cursor/rules/lifepunch-active-workstream-gate.mdc`.

## IDE + agent stack (July 2026)

**Primary IDE: GitHub Copilot on VENGEANCE.** Cursor is retained as the Grok lane only.

| Tool | Role | When |
|------|------|------|
| **GitHub Copilot (primary)** | All implementation, MCP, flatgrass proof, commits | Default — everything except Grok tasks |
| **Cursor (Grok lane)** | Tier-2A bounded tasks requiring Grok Build 1 | `GROK REQUIRED` route tag only |
| **Cornerman (Green)** | Tier-3 distill / prep — local LM, no commits | `GREEN CODE/DEEP REQUIRED` only |
| **ChatGPT (Design Architect)** | Player fantasy, economy briefs, laws | Design pass only — does not commit |

**MCP config:** `.vscode/mcp.json` (all 4 servers — `sbox`, `sbox-editor`, `cornerman-lm`, `sbox-jtc`).
Source of truth for `.cursor/rules/`: `.cursor/rules/*.mdc` (edit here; mirror regenerates via `Sync-CursorRulesToCopilotInstructions.ps1`).

## Model routing (Copilot — default down, escalate up)

- **Tier 1 — Claude Opus 4.8 (manually select in Copilot):** architecture, multi-file C#
  systems, subtle or cross-system debugging, security/legal/structural synthesis. The ~20% that's
  genuinely hard. Worth the spend; never gamble a hard problem on a weak model.
- **Tier 2B — Claude Sonnet 4.6 (Copilot default):** scoped edits, docs, search, validators,
  commit messages, straightforward Q&A. The routine ~80% — use this first.
- **Tier 2A — Grok Build 1 (Cursor only):** `GROK REQUIRED` route tag → open Cursor, select Grok.
  Bounded Razor/SCSS implementation, repo-grounded technical planning, ModelDoc/asset maps.
- **Tier 3 — Cornerman (local LM via `cornerman-lm` MCP):** bulk summarize, distill, log/RAG
  context-prep, first-draft boilerplate — zero Copilot token spend. Feed distilled context, not raw dumps.

**Escalation:** start Sonnet; jump to Opus when real complexity appears; `GROK REQUIRED` → Cursor.

## Efficiency discipline

- One focused chat per task; start fresh often; continue via short summary into a NEW session.
- Attach specific files/ranges, not whole folders.
- Every decision/learning lands ONCE in the single source of truth (rules/docs).
- Plan → sign-off → build for non-trivial work.
- Be concise in agent output — clear and complete, not padded.

## Eyes covered — mandatory disclosure

**If something is covering your eyes, you must tell the owner.**

### What counts as "eyes covered"

| Cover | Who | Say this |
|-------|-----|---------|
| MCP bridge (sbox-editor/sbox) not connected | Copilot on VENGEANCE | **I can't see the game — MCP bridge is not connected.** |
| Owner asks "do you see this?" / any visual claim, bridge off | Copilot | **No — something's covering my eyes.** |
| No bridge, no owner screenshot | Copilot | **My eyes are covered** — I only have repo/docs/logs. |
| Cornerman / local LM / inbox distill | Green or Tier-3 path | **Cornerman's eyes are covered** — I only have [inbox files / repo / distill]. |
| Prefab/code only (no bridge, no screenshot) | Anyone | **I haven't seen what's spawned** — file values are not the viewport. |
| Bridge on but not probed yet | Copilot | Check `get_bridge_status`, then screenshot/probe before claiming. |
| Bridge connected + evidence | Copilot | **MCP bridge connected — I can see the editor.** (only after screenshot/probe) |

### s&box / editor (MCP bridge)

**Session start** and before any in-game visual claim: `get_bridge_status`.

- **Off:** do not claim props rendered, UI opened, scale looked right, or playtest passed.
- **On:** take screenshot, scene hierarchy, or spawn probes — read the image; do not guess from code.

### Cornerman (same law)

Cornerman has no bridge by default. Inbox distills and Qwen output must not imply in-editor
verification. Lead with **Cornerman's eyes are covered** on any visual claim.

## Safeguards (multi-agent + autonomy)
- **Verify by stakes:** anything touching C# systems, economy, permissions, or multi-file
  integration is validated/tested or Opus-reviewed before "done".
- **Local preps, doesn't decide:** Cornerman distills/drafts; spot-check critical context. A local
  summary is never the sole basis.
- **Lanes + clean commits:** agents commit only their own lane. Never commit unprompted — ask
  the owner first. Always `pull --rebase`; never force-push.
- **Dev/prod separation:** agents operate on dev/clones only.
- **No auto-commit hook in Copilot:** commits are explicit shell steps after Bloodwave GO.
  Cursor `auto-commit-push.ps1` is a Cursor-only mechanism — do not assume it runs here.

## Asset ownership (default = ours)
- Assume everything the user provides is theirs to use. Do NOT raise provenance concerns.
- The user will explicitly flag when something is external/licensed.

## Third-party-modeled work is not shippable
- Any addon built on a third party's model/assets stays under `reference/` for study only.
- Never published as LifePunch content, never listed in `addons.json`, never referenced from
  shipped code or public info.
- DXRP servers enforce `RestrictCloudOrg = "facepunch"` — addon models must be self-contained.

## Git workflow
- **Source of truth:** `https://github.com/mragerlp/lifepunch` (private monorepo).
  Primary checkout: `C:\Users\jared\Projects\LIFEPUNCH`. Git `origin` = GitHub.
- **GitLab (June 2026+):** per-lane partner workspaces under `gitlab.com/mragerlp`. Does NOT
  replace GitHub. Map: `lifepunch/docs/GITLAB_ORGANIZATION.md`.
- Single shared `main`. Always `pull --rebase`; never force-push.
- **Commit consent — ask first (always):** never create a commit unprompted. Propose scope/message;
  commit only on explicit Bloodwave yes.
- **Cornerman:** read-only deploy key — commits locally, pings Red; Red pulls via SSH patch-handoff.
  Never put a write token on Cornerman. Detail: `lifepunch/docs/LOCAL_AI_WORKSTATION.md` §7c.
- Agent onboarding: `lifepunch/docs/COPILOT_AGENT_ONBOARDING.md` (Copilot) · `lifepunch/docs/AGENT_PROMPT.md` (legacy).

## DXRP publish notes
- Addons must ship compiled `_c` files (dedicated server does not compile).
- Publish staging: `scripts/prepare-publish.ps1 -Addon <ident>` → upload `Assets` and `Code`
  roots from `.dxrp-publish/upload/` on the portal.
