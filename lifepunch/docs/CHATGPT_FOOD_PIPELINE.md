# Design Architect → Integration Architect food pipeline

> **Design Architect** = ChatGPT LIFEPUNCH™ on VENGEANCE (Red) — CVL **product/gameplay/UX/economy architecture**.  
> **Integration Architect** = Cursor on the same machine — **repo law, implementation, MCP, compile, proof**.  
> Legacy file name `CHATGPT_*` kept for paths; new prose should use **formal CVL Architect role names**.

**Why Design Architect exists in CVL:** Bloodwave uses ChatGPT Plus as the **design lane** —
systems architecture, gameplay loops, economy, UX, progression, portfolio planning.
Design Architect asks **"Does this make the game better?"** Integration Architect asks **"Does this match repo law and ship criteria?"**

**Problem:** If Design Architect output and Integration Architect repo truth are not labeled, both lanes confuse each other.  
**Fix:** One paste shape Design Architect → Integration Architect. Integration Architect treats output as **brief**, not law.

Canon: `lifepunch/docs/ARCHITECT.md`

---

## The CVL Architect family (who eats what)

| Role | Tool | Core question | You use it for |
|------|------|---------------|----------------|
| **Design Architect** | ChatGPT LIFEPUNCH™ on Red | Does this make the game better? | Architecture, loops, economy, UX, briefs |
| **Infrastructure Architect** | ChatGPT CLV Project | Are nodes/MCP healthy? | Pings, boot order (Run 1 paste) — advisory only |
| **Integration Architect** | Cursor on Red | Does this ship? | Repo truth, MCP execution, commits |
| **Distillation Architect** | Cornerman LM on Green | Can this be prepped cheaper? | Bulk distill → outbox |
| **Operations Architect** | RDP agent on lifepunchnet | Does hosted ops match Bloodwave intent? | Hosted ops under owner authority |

**Opus** is not a separate role — Integration Architect uses **Tier-1 Opus** for economy, permissions, multi-file C#, and cross-system debugging.

Design Architect does **not** know: your `mcp.json`, compile errors, spawn scale, `OFF_CURSOR` state, portal law.  
Integration Architect does **not** need: Design Architect's generic DXRP essay — it needs **structured CURSOR BRIEFs**.

---

## Run 1 result (Infrastructure Architect advisory) — verdict

Infrastructure Architect (CLV project) **passed** the roots test on naming:

- ACK correct: `sbox` / `sbox-editor` / `cornerman-lm`, tiers right
- No Chromr, no Claude Bridge as model, no LM on Red
- Q6 agrees: `local-llm-mcp-server` node → `:1234`
- ROOTS CHECK / RED·GREEN ACTION match our canon

**Minor drift (ignore or merge carefully):**

| Infrastructure Architect said | Repo already has |
|-------------------------------|------------------|
| New files: `CVL_NODES.md`, `MCP_TOPOLOGY.md`, etc. | `MACHINE_CAST.md`, `SBOX_EDITOR_MCP.md`, `MCP_AGENT_ROUTING.md` |
| Latency 150–250ms | We said <300ms OK — close enough |
| Q1 "T1" for spawn checks | We say Tier-2 — stakes-based, not fatal |

**Use infra answers** as advisory; **repo docs** stay law.

---

## Your real workflow (concept lane)

```text
You (typed or Cursor mic on Red)
    → Design Architect Step 1 ("banker job: player does X at hub Y")
    → Design Architect expands (UX, loops, DXRP-flavored copy) → CURSOR BRIEF
    → YOU paste BRIEF into Integration Architect (Cursor)
    → Integration Architect grounds in repo + MCP + ships one slice
    → Playtest (flatgrass + sbox MCP)
    → Fantasy Check ("Does this still feel like LIFEPUNCH™?")
    → Design Architect Review (major slices — full drift checklist)
    → Owner sign-off → commit consent
```

**Voice lane (current):** Cursor **mic plugin** in chat — not lifepunchnet Whisper / desk PTT unless owner re-enables.

**Do not** paste raw Design Architect walls into Integration Architect without the template — that's the confusion.

---

## What to ask Design Architect (concept chats)

Use **LIFEPUNCH™ Project** with custom instructions from  
`handoff/ARCHITECT_PROJECT_INSTRUCTIONS.txt` (or full `ARCHITECT_ONBOARDING_PASTE.txt`)

**Good prompts:**

- "Banker job for DXRP: player loop, machines, failure states — no code, brief for Integration Architect"
- "Bitcoin miner hub: what should powered-on look like to a player? Terminal beats, not C#"
- "Hacker job: three press interactions that feel illegal but are fair — LIFEPUNCH™ tone"
- "Does moving CPU upgrades to the hub make the mining fantasy more believable?"

**Bad prompts (use Integration Architect or Infrastructure Architect instead):**

- "Fix my vmat compile" (needs sbox-editor)
- "Why is SMB red" (needs CLV Project + scripts)
- "Commit this patch" (Integration Architect only)

---

## Paste INTO Design Architect (concept starter)

```text
LIFEPUNCH™ concept brief request
Product: [Bitcoin miner / Banker / Hacker / …]
Audience: DXRP roleplay players on LIFEPUNCH™ servers
Output: CURSOR BRIEF only — use CHATGPT_STEP1_PASTE.txt / CURSOR BRIEF shape
Do NOT write C# or file paths unless marking them "suggested — Integration Architect verifies"
DXRP: nominative only. Lead LIFEPUNCH™ as source. Never ® — use ™ while pending.
```

---

## Files

| File | Role |
|------|------|
| `ARCHITECT.md` | Canon — responsibilities, boundaries, CVL map |
| `handoff/ARCHITECT_ONBOARDING_PASTE.txt` | ChatGPT Project custom instructions |
| `handoff/ARCHITECT_PROJECT_INSTRUCTIONS.txt` | Short project instructions |
| `handoff/CHATGPT_STEP1_PASTE.txt` | Product ideation → CURSOR BRIEF |
| `handoff/CHATGPT_FULL_ONBOARDING_PASTE.txt` | **SUPERSEDED** — use compact package + bootstrap paste |
| `handoff/CHATGPT_VISUAL_PASS_PASTE.txt` | Visual/asset pass brief |
| `handoff/CHATGPT_SBOX_EDIT_SESSION_PASTE.txt` | Pre-editor checklist |
| `handoff/CHATGPT_ADDON_SHIP_CHECKLIST_PASTE.txt` | Portal ship advisory |
| `handoff/BLANK_CURSOR_BRIEF.txt` | CURSOR BRIEF skeleton |
| `handoff/CHATGPT_RUN1_PASTE.txt` | Infra Run 1 (CLV project — Infrastructure Architect) |
| `addons/docs/briefs/BRIEF_INDEX.md` | Brief status index |
| `SBOX_EDIT_STANDARDS.md` | Editor hardware/software bar |
| `MCP_AGENT_ROUTING.md` | Integration Architect law for MCP/tools |
| `CHATGPT_OPENAI_INTEGRATION.md` | Two Projects setup |
