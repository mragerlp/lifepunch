# Agent grounding index — Red · Cornerman · Mac

> **Doctrine 2026-07-09 (`CLAUDE.md`).** **Claude Code** grounds by READING files from the repo, in order:
> `CLAUDE.md` → `lifepunch/docs/START_HERE_AGENTS.md` → `lifepunch/docs/CVL_AGENT_ONBOARDING.md` → the
> active handoff brief. It does **not** rely on pasting — long pastes are a known hazard (Transport Law).
>
> **Handoff-file pattern (replaces paste-based handoffs):** briefs live as write-once repo files at
> `lifepunch/docs/handoff/CLAUDE_CODE_BRIEF_<TASK>_<DATE>.md`. Claude Code receives only a short paste
> pointing at the file, then reports branch · HEAD · clean/dirty · intended files · forbidden files and
> waits for GO. Screenshots and attachments remain valid transport.
>
> Canon workflow: `CLAUDE.md` · `GREEN_EXECUTION_MODEL.md` · `MACHINE_CAST.md` · `BRANCH_MODEL.md`.
> Branches: **`develop`** = test (Red daily) · **`main`** = truth (Cornerman distill).
>
> *The Cursor/Copilot paste table below is LEGACY — secondary IDEs, on request only. Kept for reference.*

---

## Quick pick

| You are on… | IDE | Paste this file |
|-------------|-----|-----------------|
| **VENGEANCE (Red)** | Cursor | `RED_CURSOR_GROUNDING_PASTE.txt` |
| **VENGEANCE (Red)** | Copilot | `RED_COPILOT_GROUNDING_PASTE.txt` |
| **Cornerman (Green B)** | Cursor | `GREEN_CORNERMAN_CURSOR_GROUNDING_PASTE.txt` |
| **Cornerman (Green B)** | Copilot | `GREEN_CORNERMAN_COPILOT_GROUNDING_PASTE.txt` |
| **MacBook (Green A)** | Cursor | `MAC_GREEN_CURSOR_GROUNDING_PASTE.txt` |
| **MacBook (Green A)** | Copilot | `MAC_GREEN_COPILOT_GROUNDING_PASTE.txt` |
| **MacBook (Green A)** | **ChatGPT Design Architect** | `ARCHITECT_ONBOARDING_PASTE.txt` |

---

## Short first messages (optional)

| Surface | File |
|---------|------|
| Red Cursor | `RED_SESSION_FIRST_MESSAGE.txt` |
| Red Copilot | `RED_COPILOT_SESSION_FIRST_MESSAGE.txt` |
| Cornerman Cursor | `GREEN_SESSION_FIRST_MESSAGE.txt` |
| Cornerman Copilot | `GREEN_COPILOT_SESSION_FIRST_MESSAGE.txt` |
| Mac (either IDE) | `MAC_SESSION_FIRST_MESSAGE.txt` |

---

## Full depth bootstraps

| When | File |
|------|------|
| Red Cursor (full) | `CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt` |
| Red Copilot (full) | `COPILOT_NEW_SESSION_BOOTSTRAP.txt` |
| Cornerman Cursor (full) | `GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt` |

---

## Step guides

| Guide | Purpose |
|-------|---------|
| `MACBOOK_GREEN_QUICKSTART.md` | Mac → RDP → Cornerman **Cursor** |
| `MACBOOK_GREEN_COPILOT_QUICKSTART.md` | Mac → RDP → Cornerman **Copilot** |
| `MACBOOK_CORNERMAN_MOBILE.md` | Mac roles + RDP setup |
| `GREEN_SMB_BOOT_PASTE.md` | Cornerman Map/Tunnel/SMB law |
| `GREEN_PATCH_HANDOFF_QUICKREF.txt` | Cornerman → Red publish |
| `RED_FULL_CAPACITY_BOOT.md` | Red editor + bridge boot |
| `../CORNERMAN_HEADLESS_DROP_WORKER.md` | Headless drop worker (Slice 1 dry-run) — packet schema v2 + repo profiles |

---

## Sync reminder

After heavy work on **Cornerman**: Red pulls or runs `Pull-CornermanPatches.ps1 -Push` before orchestrate/proof/push.

After heavy work on **Red** or **Mac push**: Cornerman + Mac `git pull --rebase`.

---

## AGENT_PROMPT blocks

- **Block 0** — universal preamble
- **Block A** — Red / VENGEANCE
- **Block D** — Cornerman / Green B
- **Block M** — MacBook / Green A

Path: `lifepunch/docs/AGENT_PROMPT.md`
