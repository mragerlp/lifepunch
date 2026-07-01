# Cornerman LM Studio — three models + Claude Bridge

**Policy:** **Use Claude Bridge whenever you can** — local LM Studio costs $0 against Cursor's $400
API pool and keeps long agent sessions off cloud frontier. Default prep: warm Tier-3 on Cornerman,
run `Start-ClaudeBridge.ps1` on VENGEANCE, then `claude --model …` (or persistent
`claudeCode.environmentVariables`). Escalate to Cursor Opus only when Bridge + Auto are insufficient.

Tier-3 on **Cornerman** (`192.168.1.229:1234`). VENGEANCE reaches the endpoint over LAN; no tunnel unless the server is bound to loopback only.

## The three models

| Role | Catalog key | When |
|------|-------------|------|
| **Distill** | `qwen/qwen3.6-35b-a3b` | Default — doc prep, voice, briefs, Claude Bridge daily driver |
| **Coder** | `qwen2.5-coder-32b-instruct` | PowerShell validators, script lanes (`validate-headers.ps1`, etc.) |
| **Embed** | `text-embedding-nomic-embed-text-v1.5` | RAG index build / retrieval (small, pinned at low GPU) |

**Default — all three hot:** `-Profile three` (or `-WarmModel all`) loads embed + distill + coder with
split GPU offload (`0.05` / `0.45` / `0.45` in `Start-CornermanLmStudio.ps1`). If OOM, fall back to
`-WarmModel distill` or `-WarmModel coder` (two LLMs + embed only).

| Model | Claude Bridge command | Use |
|-------|----------------------|-----|
| Distill | `claude --model "qwen/qwen3.6-35b-a3b"` | Briefs, summarize, voice prep |
| Coder | `claude --model "qwen2.5-coder-32b-instruct"` | PowerShell, validators, scripts |
| Embed | `/v1/embeddings` (not Claude) | RAG index — `text-embedding-nomic-embed-text-v1.5` |

## LM Studio server settings (set once in GUI)

**Developer → Server:**

| Setting | Value | Why |
|---------|-------|-----|
| JIT Loading | **ON** | Coder loads on first `claude --model qwen2.5-coder-32b-instruct` without manual swap |
| Auto-Evict | **OFF** | Pinned distill/embed are not kicked when JIT loads coder |
| Max loaded models | **3** | Matches routing table |
| JIT TTL | 3600s (or taste) | Specialists unload after idle |

Bind server to **LAN IP** (`192.168.1.229`), not `0.0.0.0` public. Firewall: port `1234` scoped to Private/LAN only (`LOCAL_AI_WORKSTATION.md` §6).

## Start Tier-3 (Cornerman)

```powershell
# Daily (recommended)
powershell -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1 -Profile three -WarmModel distill

# Coder-only session
powershell -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1 -Profile three -WarmModel coder

# From VENGEANCE after script sync
powershell -ExecutionPolicy Bypass -File lifepunch\scripts\Sync-CornermanRebootScripts.ps1
ssh cornerman "powershell -File C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1 -Profile three -WarmModel distill"
```

Headless boot uses the same script via `Invoke-CornermanFullPerformance.ps1` / `Invoke-CornermanHeadlessBoot.ps1`.

## Claude Bridge (VENGEANCE → Cornerman)

LM Studio **0.4.1+** ships an Anthropic-compatible `/v1/messages` endpoint ([LM Studio blog](https://lmstudio.ai/blog/claudecode)). Any Anthropic client only needs a base URL change.

### One-shot terminal session

```powershell
cd C:\Users\jared\Projects\LIFEPUNCH
powershell -ExecutionPolicy Bypass -File lifepunch\scripts\Start-ClaudeBridge.ps1
claude --model "qwen/qwen3.6-35b-a3b"
```

Coder work:

```powershell
powershell -ExecutionPolicy Bypass -File lifepunch\scripts\Start-ClaudeBridge.ps1 -Model qwen2.5-coder-32b-instruct
claude --model qwen2.5-coder-32b-instruct
```

### Persistent env (PowerShell profile on VENGEANCE)

```powershell
$env:ANTHROPIC_BASE_URL = 'http://192.168.1.229:1234'
$env:ANTHROPIC_AUTH_TOKEN = 'lmstudio'
```

### VS Code / Cursor (Claude Code extension)

```json
"claudeCode.environmentVariables": [
  { "name": "ANTHROPIC_BASE_URL", "value": "http://192.168.1.229:1234" },
  { "name": "ANTHROPIC_AUTH_TOKEN", "value": "lmstudio" }
]
```

Use **≥25k context** in LM Studio load settings for agentic Claude Code sessions.

### MCP alternative (secondary)

[claude-lmstudio-bridge](https://github.com/infinitimeless/claude-lmstudio-bridge) exposes local models as **tools** inside Claude Desktop. LifePunch primary path remains **native `/v1/messages`** + `Start-ClaudeBridge.ps1` — use whenever Cornerman is live.

## Red dispatch shortcuts

```powershell
# Warm distill + embed + voice relay
powershell -File lifepunch\scripts\Send-CornermanWorkflow.ps1 -Action FullPerformance

# Warm coder (from VENGEANCE)
ssh cornerman "powershell -File C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1 -Profile three -WarmModel coder"

# Claude Bridge probe
powershell -File lifepunch\scripts\Start-ClaudeBridge.ps1
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `probe failed` on :1234 | LM Studio not running; run `Start-CornermanLmStudio.ps1` on Cornerman |
| Model not in `/v1/models` | JIT will load on first request, or run with `-WarmModel` |
| OOM on load | Drop to one role model; use `-Profile legacy` or smaller quant |
| Claude Code empty/errors | Confirm LM Studio ≥ 0.4.1; raise context length; try distill before coder 32B |
| Embed load fails | Search `nomic-embed` in LM Studio; update `$EmbedModel` in script |

## What this is not

- **Not** a replacement for s&box editor compile / play-test on VENGEANCE.
- **Not** lifepunchnet Whisper STT (`:9000`) — voice STT unchanged.
- **Not** a ship asset — LAN-only inference; no secrets on Cornerman.
