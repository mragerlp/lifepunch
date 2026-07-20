# BLACKBOX STUDY — for the CVL armor (2026-07-19)

Read live via eye.js from docs.blackbox.ai. Owner has PRO (Agent API unlocked). Key held/fenced (sk- format, .env storage). This is armor intel, not yet wired.

## VERDICT
Blackbox = a COST-ARBITRAGE INFERENCE + AGENT GATEWAY. Not just a body or an inference layer — it makes the ENTIRE body-stable cheaper through one keyed interface, runtime-swappable. Three roles: (1) inference gateway (cheap models), (2) agent/task runtime (opencode-replacer body), (3) wrappable as governed MCP Tool.

## AUTH
- Bearer token, `Authorization: Bearer sk-...`. Store in .env (matches CVL secret doctrine — never commit).
- Agent API = PRO feature (owner HAS Pro). Inference endpoint api.blackbox.ai; Agent endpoint agent.blackbox.ai; Enterprise enterprise.blackbox.ai.
- Errors: 401 (bad key), 403 (plan lacks feature). Rotate via dashboard.

## AGENT API — TASK LIFECYCLE (maps to CVL ephemeral-agent canon)
POST /api/v1/tasks -> {taskId, runId, status:queued} -> running -> [completed|failed|cancelled|interrupted]
- Fire-and-hand-off NATIVE: POST returns runId immediately, agent runs async. = CVL "fire -> do -> dissolve".
- Resumable: POST /tasks/:id/continue (follow-up prompt) = "pick up on cadence".
- Runtime-AGNOSTIC: Codex task & Claude task share states + events. = the socket model, in their API.
- Evidence NATIVE: /tasks/:id/logs/stream (SSE), /status, /agent/stream, files-diff. = evidence-before-acceptance clause, satisfied by API.
- Cancel: PATCH /tasks/:id.

## CREATE TASK — body-swap via one field
- type: "claude" (Claude Agent SDK) | "standard" (chat completion SSE).
- model: selects runtime (Anthropic->Claude SDK, Codex ids->Codex SDK).
- agent override: "claude" | "codex" | "grok" = explicit body swap, one param.
- apiKey + baseUrl: BRING-YOUR-OWN router (OpenAI-compatible) — not locked to Blackbox models.
- GitHub: POST /git/config with ghp_ token -> agent works on repos, returns diffs. (WRITE-classified -> Bloodwave gate on push/merge per governance doctrine.)

## PRICING — the cheap-frontier thesis, CONFIRMED (per 1M tokens, one gateway, 47 models)
FRONTIER (deep reasoning):
- nvidia/nemotron-3-ultra: $0.37 in / $1.08 out, 1M ctx   <-- ~13x cheaper in / ~23x out vs Opus
- anthropic/claude-opus-4.8: $5.00 / $25.00, 1M
- anthropic/claude-sonnet-4.6: $3.00 / $15.00, 1M
- openai/gpt-5.5-pro: $30 / $180 (avoid unless needed)
- x-ai/grok-4.3: $1.25 / $2.50, 1M
- deepseek-v4-pro: $0.44 / $0.87, 1M
CHEAP/BULK + FREE:
- grok-code-fast-1:FREE, minimax-free:FREE
- nemotron-3-nano: $0.05/$0.20 ; llama-3.1-8b: $0.02/$0.05 ; gemma-4-26b: $0.13/$0.40
- gpt-5.4-nano: $0.20/$1.25 ; grok-4.1-fast: $0.20/$0.50, 2M ctx

## ARMOR IMPLICATION
Body-routing by cost/physics (per CVL canon) gets a concrete cheap tier: frontier reasoning at nemotron-ultra $0.37/1M instead of $5-30; free bodies for bulk. This is a real operational edge that compounds per-token. Blackbox wraps as an MCP Tool ("dispatch task -> stream logs -> get diff") that satisfies the tool contract almost by design (named owner=key, write-classified for GitHub ops=gated, evidence=logs+diffs native). opencode stays an option; Blackbox = trial body + cost gateway.

## STILL TO READ (next pass): Provider Routing, Zero Data Retention (IP-fence claim), Service Tiers, Tool & Function Calling detail, Agent Runtimes selection rule, Dedicated API.

FROM: Fable (Jarvis), 2026-07-19. Owner has Pro; key held/fenced.
