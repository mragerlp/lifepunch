# ChatGPT → Cursor food pipeline

**Why ChatGPT exists in CVL:** Bloodwave uses ChatGPT Plus as a **simpler ideation lane** —
hacker job, Bitcoin miner, banker, player fantasy, UX flows. ChatGPT knows **some** DXRP;
Cursor + repo know **everything** shipped, wired, and trademark-bound.

**Problem:** If what ChatGPT says and what Cursor knows are not labeled, you confuse both lanes.  
**Fix:** One paste shape from ChatGPT → Cursor. Cursor treats it as **brief**, not law.

---

## The five lanes (who eats what)

| Lane | Tool | You use it for |
|------|------|----------------|
| **Ideation** | ChatGPT LIFEPUNCH™ | Concepts, player stories, UI ideas, "make it real" drafts |
| **Infra** | ChatGPT CLV | Pings, boot order, MCP triage (Run 1 paste) |
| **Integrate** | Cursor VENGEANCE | Repo truth, MCP execution, commits |
| **Prep** | Cornerman LM | Bulk distill, cheap drafts → outbox |
| **Hard ship** | Cursor Opus | Economy, multi-file C#, legal |

ChatGPT does **not** know: your `mcp.json`, compile errors, spawn scale, `OFF_CURSOR` state, portal law.  
Cursor does **not** need: ChatGPT's generic DXRP essay — it needs **structured briefs**.

---

## Run 1 result (infra advisory) — verdict

ChatGPT **passed** the roots test on naming:

- ACK correct: `sbox` / `sbox-editor` / `cornerman-lm`, tiers right
- No Chromr, no Claude Bridge as model, no LM on Red
- Q6 agrees: `local-llm-mcp-server` node → `:1234`
- ROOTS CHECK / RED·GREEN ACTION match our canon

**Minor drift (ignore or merge carefully):**

| ChatGPT said | Repo already has |
|--------------|------------------|
| New files: `CVL_NODES.md`, `MCP_TOPOLOGY.md`, etc. | `MACHINE_CAST.md`, `SBOX_EDITOR_MCP.md`, `MCP_AGENT_ROUTING.md` |
| Latency 150–250ms | We said &lt;300ms OK — close enough |
| Q1 "T1" for spawn checks | We say Tier-2 — stakes-based, not fatal |

**Use ChatGPT infra answers** as advisory; **repo docs** stay law.

---

## Your real workflow (concept lane)

```text
You (typed or Cursor mic in chat)
    → ChatGPT LIFEPUNCH™ ("banker job: player does X at hub Y")
    → ChatGPT expands (UX, loops, DXRP-flavored copy)
    → YOU paste BRIEF into Cursor (template below)
    → Cursor grounds in repo + MCP + ships or says what's missing
```

**Voice lane (current):** Cursor **mic plugin** in chat — not lifepunchnet Whisper / desk PTT unless owner re-enables.

**Do not** paste raw ChatGPT walls into Cursor without the template — that's the confusion.

---

## What to ask ChatGPT (concept chats)

Use **LIFEPUNCH™ Project** with custom instructions from  
`handoff/CHATGPT_PROJECT_LIFEPUNCH_INSTRUCTIONS.txt`

**Good prompts:**

- "Banker job for DXRP: player loop, props, failure states — no code, brief for my integrator"
- "Bitcoin miner hub: what should powered-on look like to a player? Terminal beats, not C#"
- "Hacker job: three press interactions that feel illegal but are fair — LIFEPUNCH™ tone"

**Bad prompts (use Cursor or CLV Project instead):**

- "Fix my vmat compile" (needs sbox-editor)
- "Why is SMB red" (needs CLV Project + scripts)
- "Commit this patch" (Cursor only)

---

## Paste INTO ChatGPT (concept starter)

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
| `handoff/CHATGPT_STEP1_PASTE.txt` | Product ideation → CURSOR BRIEF |
| `handoff/CHATGPT_VISUAL_PASS_PASTE.txt` | Visual/asset pass brief |
| `handoff/CHATGPT_SBOX_EDIT_SESSION_PASTE.txt` | Pre-editor checklist |
| `handoff/CHATGPT_ADDON_SHIP_CHECKLIST_PASTE.txt` | Portal ship advisory |
| `handoff/BLANK_CURSOR_BRIEF.txt` | Upload to ChatGPT Project knowledge |
| `handoff/CHATGPT_RUN1_PASTE.txt` | Infra Run 1 (already answered — keep in Project) |
| `addons/docs/briefs/BRIEF_INDEX.md` | Brief status index |
| `SBOX_EDIT_STANDARDS.md` | Editor hardware/software bar |
| `MCP_AGENT_ROUTING.md` | Cursor law for MCP/tools |
| `CHATGPT_OPENAI_INTEGRATION.md` | Two Projects setup |
