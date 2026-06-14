# ChatGPT CVL meeting — synthesis (2026-06)

**Plan:** ChatGPT Plus on desk · **Integrate lane:** Cursor on VENGEANCE  
**Handoff paste:** `to-chatgpt-mcp-topology-handoff.txt`

## Browser read status

Cursor Glass browser was logged in (Jared Plus) but the MCP meeting thread was **not visible**
in the automated read — only ChatGPT home + an unrelated "Welcome to ChatGPT" DXRP chat.
Synthesis below is **Red-canonical** (merged into `lifepunch/docs/MCP_AGENT_ROUTING.md`).

If ChatGPT gave different answers in your live session, paste Q1+Q2+Q7 back into Cursor
and we will diff against this file.

## What ChatGPT should agree with (after handoff)

- Topology diagram in thread 2 is **correct** (SMB + tunnel + LAN LM).
- **chomnr** is editor MCP — not Chromr, not web research.
- **Claude Bridge** is `sbox` tool — not a reasoning tier.
- **Tier-3 = Cornerman LM** — not Claude Bridge; Tier-1 = Opus on Cursor.
- **No LM Studio on VENGEANCE.**

## What to push back if ChatGPT drifts

| Drift | Correction |
|-------|------------|
| "ClaudeBridge for architecture" | Opus in Cursor |
| "Move chomnr to Green" | Editor stays on Red |
| "LM on Red for autocomplete" | cornerman-lm client only |
| Generic Postgres/Supabase MCP stack | Out of scope |
| Tier 1 = LM, Tier 3 = Bridge | LifePunch tiers inverted vs that |

## ChatGPT Plus/Pro — how we use it

| Use | Don't use |
|-----|-----------|
| Advisory routing refinement | Git commits |
| Project custom instructions (topology §0–§3) | Replacing Cursor agents |
| Draft research markdown for Green outbox | Production C# without Red |
| Second opinion on DXRP modular questions | s&box editor control |

**Workflow:** Paste handoff → get Q1–Q8 → Red merges good parts into repo docs → Green never commits.

## Repo updates from this meeting

- **NEW** `lifepunch/docs/MCP_AGENT_ROUTING.md` — Q1–Q8 canon
- **UPDATED** `SBOX_EDITOR_MCP.md` — points to routing doc
- **UPDATED** off-Cursor handoffs — superseded by dual-stack requirement

## Round 2 paste (optional — same ChatGPT chat)

```text
Round 2 — LifePunch CVL meeting
Red (Cursor) merged your answers into MCP_AGENT_ROUTING.md.

1. List anything you still disagree with in that doc.
2. One paragraph: optimal ChatGPT Project instructions for Plus plan.
3. Red flags for using ChatGPT Pro reasoning vs Cursor Opus for the same task.
```
