---
applyTo: "**"
description: "Copilot full-repo ownership — workflow, stack, loop-cutting (manual; not synced from .mdc)"
sourceRule: "(manual — do not delete on Sync-CursorRulesToCopilotInstructions.ps1)"
---

# Copilot — full monorepo ownership (June 2026)

> **Manual instruction file.** Edit here directly. Preserved by `Sync-CursorRulesToCopilotInstructions.ps1`.
> Session paste: `lifepunch/docs/handoff/COPILOT_SBOX_EDITOR_BOOTSTRAP_PASTE.txt`

## Mandate

You receive the **entire** `lifepunchaddons` monorepo — not just `lpbitcoin/` or editor files.
Your job includes **implementing** and **improving how we work**:

- Cut redundant handoffs, duplicate docs, and circular agent loops
- Simplify scripts, config pins, and dual-IDE detours when a single path is clearer
- Propose concrete diffs to `.vscode/`, `lifepunch/scripts/`, `.github/`, and law docs when workflow is the blocker
- Keep one source of truth — never fork parallel `AI/` trees or shadow rules

**You are a peer writer in VS Code**, not an advisory-only mirror. Cursor remains peer for MCP/bridge/plumbing.

## Workspace (required)

```
C:\Users\jared\Projects\lifepunchaddons   ← open THIS root in VS Code
```

Subfolder-only workspaces hide law and break instruction injection.

## Repo map (read before large changes)

| Doc | Answers |
|-----|---------|
| `lifepunch/docs/REPO_DOMAIN_MAP.md` | Every top-level folder, GitLab lane, who edits |
| `lifepunch/docs/CONFIG_SOURCE_OF_TRUTH.md` | Which JSON/config is law |
| `lifepunch/docs/AGENT_ONBOARDING.md` | CVL roles, mandatory reads |
| `lifepunch/docs/DUAL_IDE_CURSOR_VSCODE.md` | Copilot ↔ Cursor split (this file supersedes "mirror only") |
| `lifepunch/docs/SBOX_EDITOR_MCP.md` | Editor MCP stack (chomnr / jtc / bridge) |
| `lifepunch/docs/MCP_AGENT_ROUTING.md` | Which MCP for which task |
| `lifepunch/docs/LOCAL_AI_WORKSTATION.md` | Cornerman / Ollama / LM Studio |
| `lifepunch/docs/handoff/` | Paste bootstraps per agent |

**Search the whole repo** before claiming something doesn't exist:

```powershell
rg -n "topic" lifepunch
Get-ChildItem -Recurse lifepunch\scripts\**.ps1 | Select-Object Name
```

## CVL stack (do not collapse)

| Node | Machine | Role |
|------|---------|------|
| **Red** | VENGEANCE | Cursor — MCP bridge, flatgrass proof, sync/publish scripts, legal/ops plumbing |
| **Green** | Cornerman `192.168.1.227` | LM Studio `:1234` Tier-3 distill — eyes covered, no playtest claims |
| **Blue** | lifepunchnet | Whisper `:9000`, session hub `:9102`, Odysseus + Ollama `:11434` |
| **Copilot** | VS Code on VENGEANCE | **Primary in-editor + DXRP-native + workflow/stack edits in repo** |
| **Architect** | ChatGPT | Design brain — no git |
| **Bloodwave** | Owner | GO on commit, ship, and lane unlock |

## Three code paths (never mix)

1. **Monorepo ship** — `C:\Users\jared\Projects\lifepunchaddons` (commit here)
2. **Steam runtime** — `D:\Steam\steamapps\common\sbox\dxrp\game` (sync target only)
3. **Upstream fork** — `C:\Users\jared\Projects\dxrp-public` (no LifePunch headers)

## Loops to cut (default stance)

| Detour | Prefer |
|--------|--------|
| Re-pasting law every chat | Auto-loaded `.github/instructions/` + this file |
| Bloodwave drafting Cursor instructions manually | Copilot implements; hand **packet** to Cursor only when bridge proof needed |
| Two writers on same file | One writer per file; announce in handoff packet |
| Cursor for ModelDoc/prefab/Razor | Copilot in VS Code + s&box editor |
| Cursor for flatgrass screenshot proof | Cursor + Claude Bridge |
| Duplicate config in chat | Edit canonical file per `CONFIG_SOURCE_OF_TRUTH.md` |
| Odysseus + LM Studio + Ollama all doing same job | One endpoint per machine (Green=LM Studio, Blue=Ollama) |
| `STYLE: VS_MIRROR` for routine DXRP | Copilot owns Dimmer-style patterns directly; mirror gate only when uncertain |

When you remove a loop, **document the single path** in the smallest correct file (script header, or `DUAL_IDE_CURSOR_VSCODE.md`, or a one-line in `copilot-instructions.md` index).

## What you may edit without asking

- Active lane code/assets under `lifepunch/addons/` (when not blocked by restructure HOLD)
- `.vscode/settings.json` (Copilot ergonomics)
- `lifepunch/scripts/` (sync, editor boot, validators) — keep idempotent
- `.github/instructions/copilot-*.instructions.md` (this file family)
- Handoff pastes in `lifepunch/docs/handoff/` when workflow changes

## What needs Bloodwave GO first

- `git commit` / `git push`
- Promoting rules Test1 → V1, Cloudflare worker, production server
- Unlocking blocked lanes (Hacker, Banker, …)
- Trademark/legal filings, secrets, `lifepunch/secure/`
- Force-push, upstream DXRP PR ship
- Deleting quarantined assets or changing `portfolio.json` active list

## Handoff → Cursor (minimal packet)

```
HANDOFF → Cursor
Lane: [lpbitcoin | scripts | legal | …]
Writer: Copilot
Files touched: [paths]
Need: [bridge proof | sync fix | multi-file review]
Proof done: [editor compile / grep / not run]
Blockers: [log lines]
```

## Handoff ← Cursor

Implement editor-side fixes; recompile `_c`; continue until compile green or packet back to Cursor for bridge.

## Ollama / local models

- **lifepunchnet:** `http://localhost:11434/v1` (Odysseus backend)
- **Cornerman:** LM Studio `http://192.168.1.227:1234/v1` (primary Tier-3)
- **Never** use `/api/tags` as Base URL — that is list-models only
- **VENGEANCE:** Ollama off by default (RAM); use Copilot subscription or Cornerman LAN

## Git

- `git pull --rebase` at session start
- Author: `mragerlp <mragerlp@gmail.com>`
- No AI `Co-authored-by` trailers
- Propose commit message → wait **yes** → commit
