# Architect → Integrator food pipeline

> **Architect** = ChatGPT on VENGEANCE (Red) — CVL **design brain**.  
> **Integrator** = Cursor on the same machine — **ship brain**.  
> Legacy file name `CHATGPT_*` kept for paths; new prose should say **Architect**.

**Why Architect exists in CVL:** Bloodwave uses ChatGPT Plus as the **design lane** —
systems architecture, gameplay loops, economy, UX, progression, portfolio planning.
Architect asks **"Does this make the game better?"** Integrator asks **"Does this compile and match repo law?"**

**Problem:** If Architect output and Integrator repo truth are not labeled, both lanes confuse each other.  
**Fix:** One paste shape Architect → Integrator. Integrator treats output as **brief**, not law.

Canon: `lifepunch/docs/ARCHITECT.md`

---

## The CVL lanes (who eats what)

| Lane | Tool | Core question | You use it for |
|------|------|---------------|----------------|
| **Architect** | ChatGPT LIFEPUNCH™ on Red | Does this make the game better? | Architecture, loops, economy, UX, briefs |
| **Infra** | ChatGPT CLV Project | Are nodes/MCP healthy? | Pings, boot order (Run 1 paste) |
| **Integrator** | Cursor on Red | Does this ship? | Repo truth, MCP execution, commits |
| **Distiller** | Cornerman LM on Green | Can this be prepped cheaper? | Bulk distill → outbox |
| **Hard ship** | Cursor Opus on Red | Is this correct at scale? | Economy, multi-file C#, legal |

Architect does **not** know: your `mcp.json`, compile errors, spawn scale, `OFF_CURSOR` state, portal law.  
Integrator does **not** need: Architect's generic DXRP essay — it needs **structured CURSOR BRIEFs**.

---

## Run 1 result (infra advisory) — verdict

Architect (infra CLV project) **passed** the roots test on naming:

- ACK correct: `sbox` / `sbox-editor` / `cornerman-lm`, tiers right
- No Chromr, no Claude Bridge as model, no LM on Red
- Q6 agrees: `local-llm-mcp-server` node → `:1234`
- ROOTS CHECK / RED·GREEN ACTION match our canon

**Minor drift (ignore or merge carefully):**

| Architect said | Repo already has |
|----------------|------------------|
| New files: `CVL_NODES.md`, `MCP_TOPOLOGY.md`, etc. | `MACHINE_CAST.md`, `SBOX_EDITOR_MCP.md`, `MCP_AGENT_ROUTING.md` |
| Latency 150–250ms | We said &lt;300ms OK — close enough |
| Q1 "T1" for spawn checks | We say Tier-2 — stakes-based, not fatal |

**Use infra answers** as advisory; **repo docs** stay law.

---

## Your real workflow (concept lane)

```text
You (typed or Cursor mic on Red)
    → Architect Step 1 ("banker job: player does X at hub Y")
    → Architect expands (UX, loops, DXRP-flavored copy) → CURSOR BRIEF
    → YOU paste BRIEF into Cursor Integrator
    → Integrator grounds in repo + MCP + ships one slice
    → Playtest (flatgrass + sbox MCP)
    → Fantasy Check ("Does this still feel like LIFEPUNCH™?")
    → Architect Review (major slices — full drift checklist)
    → Owner sign-off → commit consent
```

**Voice lane (current):** Cursor **mic plugin** in chat — not lifepunchnet Whisper / desk PTT unless owner re-enables.

**Do not** paste raw Architect walls into Integrator without the template — that's the confusion.

---

## What to ask Architect (concept chats)

Use **LIFEPUNCH™ Project** with custom instructions from  
`handoff/ARCHITECT_PROJECT_INSTRUCTIONS.txt` (or full `ARCHITECT_ONBOARDING_PASTE.txt`)

**Good prompts:**

- "Banker job for DXRP: player loop, props, failure states — no code, brief for Integrator"
- "Bitcoin miner hub: what should powered-on look like to a player? Terminal beats, not C#"
- "Hacker job: three press interactions that feel illegal but are fair — LIFEPUNCH™ tone"
- "Does moving CPU upgrades to the hub make the mining fantasy more believable?"

**Bad prompts (use Integrator or CLV Project instead):**

- "Fix my vmat compile" (needs sbox-editor)
- "Why is SMB red" (needs CLV Project + scripts)
- "Commit this patch" (Integrator only)

---

## Paste INTO Architect (concept starter)

```text
LIFEPUNCH™ concept brief request
Product: [Bitcoin miner / Banker / Hacker / …]
Audience: DXRP roleplay players on LIFEPUNCH™ servers
Output: CURSOR BRIEF only — use the 8-field template in CHATGPT_CONCEPT_BRIEF_TEMPLATE.txt
Do NOT write C# or file paths unless marking them "suggested — integrator verifies"
DXRP: nominative only. Lead LIFEPUNCH™ as source. No ®.
```

---

## Files

| File | Role |
|------|------|
| `ARCHITECT.md` | Canon — responsibilities, boundaries, CVL map |
| `handoff/ARCHITECT_ONBOARDING_PASTE.txt` | ChatGPT Project custom instructions |
| `handoff/ARCHITECT_PROJECT_INSTRUCTIONS.txt` | Short project instructions |
| `handoff/CHATGPT_STEP1_PASTE.txt` | Product ideation → CURSOR BRIEF |
| `handoff/CHATGPT_FULL_ONBOARDING_PASTE.txt` | Full knowledge upload bundle |
| `handoff/CHATGPT_VISUAL_PASS_PASTE.txt` | Visual/asset pass brief |
| `handoff/CHATGPT_SBOX_EDIT_SESSION_PASTE.txt` | Pre-editor checklist |
| `handoff/CHATGPT_ADDON_SHIP_CHECKLIST_PASTE.txt` | Portal ship advisory |
| `handoff/BLANK_CURSOR_BRIEF.txt` | Upload to ChatGPT Project knowledge |
| `handoff/CHATGPT_RUN1_PASTE.txt` | Infra Run 1 (CLV project — not Architect) |
| `addons/docs/briefs/BRIEF_INDEX.md` | Brief status index |
| `SBOX_EDIT_STANDARDS.md` | Editor hardware/software bar |
| `MCP_AGENT_ROUTING.md` | Integrator law for MCP/tools |
| `CHATGPT_OPENAI_INTEGRATION.md` | Two Projects setup |
