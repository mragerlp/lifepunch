# ChatGPT / OpenAI — CVL infrastructure integration

**Status:** June 2026 · **Plan:** ChatGPT Plus/Pro · **Owner:** Bloodwave (VENGEANCE)

You run **two ChatGPT Projects** alongside **Cursor** (integrate lane) and **Cornerman LM** (Tier-3).
This doc defines what each Project owns so OpenAI **maximizes** the stack without fighting it.

---

## The four brains (do not collapse)

| Brain | Where | Job |
|-------|-------|-----|
| **Cursor Opus** | VENGEANCE | Hard ~20% — ship C#, architecture, economy, legal synthesis |
| **Cursor Auto/Composer** | VENGEANCE (+ Green mirror) | Routine ~80% — edits, MCP execution, validators |
| **Cornerman LM (Tier-3)** | Green `:1234` | Bulk distill, embed, cheap prep — **not** commits |
| **ChatGPT Projects** | Plus/Pro (any desk) | Advisory, research drafts, CVL ops planning, second opinion |

**ChatGPT does not replace Cursor integrate or Green inference.** It is the **fifth lane** for
thinking *about* the system and drafting *into* outbox — Red merges to GitHub.

---

## Two Projects — split by concern

| ChatGPT Project | Scope | Upload / attach from repo |
|-----------------|-------|---------------------------|
| **LIFEPUNCH™** | Product + studio — addons, DXRP, MCP routing, trademark, portal | `MCP_AGENT_ROUTING.md`, `SBOX_EDITOR_MCP.md`, `TRADEMARK_AND_IP.md` (public parts), addon specs |
| **CLV (GBR) Network** | Infrastructure — R/G/B nodes, pings, voice, hub, connectivity | `CVL_RGB_DOCTRINE.md`, `MACHINE_CAST.md`, `OPS_CLARITY_CHECKPOINT.md`, handoff topology paste |

**Rule:** Product questions → **LIFEPUNCH™** chat.  
**Rule:** "Why is Green tunnel red?" → **CLV** chat.

---

## Setup checklist (one-time per Project)

### LIFEPUNCH™ Project

1. **Custom instructions** — paste `handoff/CHATGPT_PROJECT_LIFEPUNCH_INSTRUCTIONS.txt`
2. **Project files** (upload or paste summaries):
   - `lifepunch/docs/MCP_AGENT_ROUTING.md`
   - `lifepunch/docs/SBOX_EDITOR_MCP.md`
   - `lifepunch/docs/handoff/to-chatgpt-mcp-topology-handoff.txt`
3. **Default model:** GPT-4o or latest reasoning model for architecture questions; instant OK for quick routing lookups
4. **Never store:** EIN, hub Bearer tokens, SMB passwords, street address

### CLV (GBR) Network Project

1. **Custom instructions** — paste `handoff/CHATGPT_PROJECT_CVL_INSTRUCTIONS.txt`
2. **Project files:**
   - `lifepunch/docs/CVL_RGB_DOCTRINE.md`
   - `lifepunch/docs/MACHINE_CAST.md`
   - `lifepunch/docs/MCP_AGENT_ROUTING.md` (Q2 boot order + Q7 monitoring only)
3. **Use for:** ping diagrams, failure triage, voice/hub workflow, white/black checkpoint language

---

## Daily workflow (maximize infra)

```text
Morning (Red)
  Test-PreLaunchCheckup.ps1 -Fix
  Start-SboxDxrpEditor.ps1 -PreflightFix
  Cursor = integrate lane

Product spike (LIFEPUNCH™ Project)
  "Given MCP_AGENT_ROUTING — Bitcoin hub visual pass next 5 steps?"
  → paste answer into Cursor on Red (or Green outbox if distill-sized)

Infra spike (CLV Project)
  "R→G ping failed — SMB OK, tunnel dead — triage order?"
  → run scripts on Red; do not let ChatGPT invent new ports

Ship
  Only Cursor on Red commits to GitHub
  ChatGPT output = draft until Red merges
```

---

## Paste INTO ChatGPT (concept starter)

See `handoff/CHATGPT_CONCEPT_BRIEF_TEMPLATE.txt` — ChatGPT fills the template; you paste the result into Cursor.

```text
LIFEPUNCH™ concept brief request
Product: [Bitcoin miner / Banker / Hacker / …]
Output: Fill CHATGPT_CONCEPT_BRIEF_TEMPLATE.txt exactly — all sections.
Do NOT write shippable C# — mark file paths "suggested — integrator verifies"
LIFEPUNCH™ lead · DXRP nominative · ™ not ®
```

---

## Paste templates (infra — Run 1 done)

See `handoff/CHATGPT_RUN1_PASTE.txt` for infra Q1–Q8. Answer merged in `MCP_AGENT_ROUTING.md`.

---

## Conflict resolution (law)

If ChatGPT contradicts repo docs, **repo wins**:

1. `MCP_AGENT_ROUTING.md` + `SBOX_EDITOR_MCP.md` (product MCP)
2. `CVL_RGB_DOCTRINE.md` + `MACHINE_CAST.md` (network)
3. `.cursor/rules` (agents on VENGEANCE)

Paste conflicts back into the **same** Project with: "§2 naming corrections in topology handoff wins — revise your answer."

---

## OpenAI API (future)

Plus/Pro Projects are **chat advisory** today. If you add **OpenAI API** keys later:

- **Do not** duplicate Green Tier-3 on Red
- API calls belong in **lifepunchnet** hub scripts or Cornerman batch — not Cursor MCP replace
- Track in `TECH_DEBT.md` before spending API $ on what Green LM already does free

---

## Handoff files

| File | Use |
|------|-----|
| `handoff/CHATGPT_PROJECT_LIFEPUNCH_INSTRUCTIONS.txt` | LIFEPUNCH™ custom instructions |
| `handoff/CHATGPT_PROJECT_CVL_INSTRUCTIONS.txt` | CLV (GBR) custom instructions |
| `handoff/to-chatgpt-mcp-topology-handoff.txt` | Full topology paste (either Project) |
| `handoff/CHATGPT_MEETING_SYNTHESIS_2026-06.md` | Meeting notes + Round 2 |
