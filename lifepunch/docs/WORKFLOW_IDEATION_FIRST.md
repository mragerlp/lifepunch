# Workflow — ideation before build (anti-spaghetti)

**Law:** When Bloodwave is all over the place, starting a **new** product, or mixing
infra + UX + code in one rant → **Architect Step 1 first**, then Cursor Integrator. No exceptions.

---

## Bloodwave (2 messages — no file editing)

1. Open **ChatGPT → LIFEPUNCH™ Project → New chat** (role: **Architect**)
2. Paste **entire** file: `lifepunch/docs/handoff/CHATGPT_STEP1_PASTE.txt` → Send
3. Second message — **one line only**, e.g. `Product: Bitcoin miner hub player UX`
4. Copy Architect's filled **CURSOR BRIEF** block
5. Open **Cursor on VENGEANCE** → new chat → paste brief → add: `Map to repo and start.`

**Voice:** use **Cursor mic plugin** in chat for ideation. Whisper / desk PTT lanes are **deferred**.

Done. You never edit template files.

---

## Cursor agent (after brief arrives)

1. Treat brief as **ideation** — verify against `addons.json`, `config/portfolio.json`, `QUARANTINE_REGISTER.md`, existing docs
2. Ground gameplay: `LIFEPUNCH_GAMEPLAY_LAWS.md`, `PATTERN_LIBRARY.md`, lane `BITCOIN_*` pattern docs when relevant
3. **Active addons only:** `adminmenu` + `bitcoinmining` unless owner promotes from quarantine
4. **Quarantined idents:** concepts/context only — cite in briefs if useful; **never** copy code/prefabs into active trees
5. If building in editor: `Test-PreLaunchCheckup.ps1 -Fix` first — bar in `SBOX_EDIT_STANDARDS.md`
6. Reply with: **exists / net-new / P0 steps / which MCP** (`sbox`, `sbox-editor`, `cornerman-lm`)
7. Ask Bloodwave for Architect Step 1 if message is spaghetti with no brief

---

## Ship loop (after slice + flatgrass proof)

```text
Architect Step 1 → Integrator slice → Playtest (flatgrass)
        → Fantasy Check (one question — LIFEPUNCH_FEEL.md)
        → Architect Review (full drift — LIFEPUNCH_GAMEPLAY_LAWS.md, major slices)
        → Owner sign-off → commit consent
```

**Fantasy Check** is mandatory before owner sign-off — not compile/perf/bugs alone.  
**Architect Review** is the full checklist; required for major features.

---

## When to skip Architect Step 1

- Fix compile error, red MCP, spawn command, git, commit
- Continuing same task with brief already in chat
- Owner says "skip ideation — execute X"

---

## Files (do not duplicate)

| File | Role |
|------|------|
| `ARCHITECT.md` | **Architect canon** — CVL design brain on Red |
| `handoff/ARCHITECT_ONBOARDING_PASTE.txt` | **Bloodwave copies to ChatGPT Project** — custom instructions |
| `handoff/ARCHITECT_PROJECT_INSTRUCTIONS.txt` | Short Architect project instructions |
| `handoff/CHATGPT_STEP1_PASTE.txt` | Product ideation → CURSOR BRIEF |
| `handoff/CHATGPT_VISUAL_PASS_PASTE.txt` | Visual/asset pass brief (Ophion-style) |
| `handoff/CHATGPT_SBOX_EDIT_SESSION_PASTE.txt` | Pre-editor session checklist (advisory) |
| `handoff/CHATGPT_ADDON_SHIP_CHECKLIST_PASTE.txt` | Portal ship advisory |
| `handoff/BLANK_CURSOR_BRIEF.txt` | Blank form — upload to ChatGPT Project knowledge |
| `SBOX_EDIT_STANDARDS.md` | VENGEANCE editor hardware/software bar |
| `WORKFLOW_IDEATION_FIRST.md` | This process |
| `LIFEPUNCH_GAMEPLAY_LAWS.md` | Gameplay philosophy + drift checklist |
| `LIFEPUNCH_FEEL.md` | Product identity / Fantasy Check |
| `TERMINOLOGY.md` | Shared vocabulary |
| `OWNERSHIP_MATRIX.md` | Who decides what |
| `DECISIONS/README.md` | Decision register |
| `KNOWLEDGE/README.md` | Learned context (not law) |
| `RFC/README.md` | Under discussion |
| `PATTERN_LIBRARY.md` | Pattern index |
| `PUBLISH_REPO_LANE.md` | Core vs publish repo law |
| `GIT_CHECKPOINTS.md` | What to commit / push / pull — checkpoint habit |
| `BLOODWAVE_ALIAS.md` | Owner community name (Bloodwave; legacy Mr. Rager) |
| `CHATGPT_FOOD_PIPELINE.md` | CVL lanes + Architect → Integrator flow |
| `MCP_AGENT_ROUTING.md` | MCP/tool law after brief is accepted |

---

## ChatGPT Projects (one-time setup — Cursor already drafted)

**LIFEPUNCH™** custom instructions: `handoff/ARCHITECT_PROJECT_INSTRUCTIONS.txt`  
Full onboarding: `handoff/ARCHITECT_ONBOARDING_PASTE.txt` · Canon: `ARCHITECT.md`
Upload to Project: `handoff/BLANK_CURSOR_BRIEF.txt`

**CLV (GBR)** — infra only when pings/MCP break: `handoff/CHATGPT_PROJECT_CVL_INSTRUCTIONS.txt`
