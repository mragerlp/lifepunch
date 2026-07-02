# Agent grounding index — Red · Cornerman · Mac (Cursor + Copilot)

> **July 2026.** Paste **one file** at session start for your machine + IDE.
> **First-time / full grounding on any node or IDE: paste `lifepunch/docs/CVL_AGENT_ONBOARDING.md`** (the
> single master doc). The per-machine files below are the shorter per-surface pastes that build on it.
> Canon workflow: `lifepunch/docs/GREEN_EXECUTION_MODEL.md` · `MACHINE_CAST.md`
> Branch: `checkpoint-lpbitcoin-pre-sleep-20260701` (full checkout — do not cherry-pick alone)

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
