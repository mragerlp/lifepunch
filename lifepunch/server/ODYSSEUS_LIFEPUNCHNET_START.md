# Odysseus on lifepunchnet — start here

> After voice network commit. Cornerman captures + logs; **lifepunchnet** remembers and reasons.

## Prerequisites (should be live)

- [x] Whisper `:9000`
- [x] Session hub `:9102` + `voice-session.ndjson`
- [x] VENGEANCE `start-session-sync.ps1` archiving `conversation.ndjson`
- [ ] GitLab re-export (lane catches up from GitHub) — optional for Odysseus itself

## Install (RDP into lifepunchnet)

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts
git pull --rebase
powershell -ExecutionPolicy Bypass -File .\Install-Odysseus-Lifepunchnet.ps1
```

Or manual: `LIFEPUNCHNET_RDP_ODYSSEUS.txt` Step 4.

## Model backend (required)

Odysseus needs an OpenAI-compatible endpoint:

1. Install [Ollama for Windows](https://ollama.com/download) on lifepunchnet
2. `ollama pull qwen2.5-coder:7b` (or your chosen coding model)
3. In Odysseus Settings → `http://localhost:11434/v1`

## Feed Cornerman / voice memory into Odysseus

| Source | Path / API |
|--------|------------|
| Session hub (all voice + conversation turns) | `C:\lifepunch\session-hub\voice-session.ndjson` |
| Manual imports | `C:\lifepunch\session-hub\imports\` |
| Live tail from VENGEANCE | `GET http://205.209.104.22:9102/tail?lines=50` + Bearer token |

**RAG in Odysseus:** index `lifepunch-foundation` mirror only — no `secure/`, no tokens.

**v1 workflow:** paste `/tail` JSON into an Odysseus chat, or drop NDJSON into imports and reference in chat.

## Cornerman advantage loop

```
Cornerman PTT → lifepunchnet Whisper → conversation.ndjson
  → session-sync → lifepunchnet hub
  → Odysseus reads hub → long-context review, summarize, plan
  → Bloodwave executes on VENGEANCE / Cursor
```

## CVL hub log (security + same-page — build this first)

VENGEANCE universal command posts tier-tagged NDJSON to `:9102`:

```powershell
powershell -File lifepunch\scripts\Invoke-CvlUniversal.ps1 -IngestToHub
```

| tier | node | logs |
|------|------|------|
| `universal` | tri-stack | `cvl-checkpoint` |
| `vengeance` | red | `cvl-git` |
| `cornerman` | green | voice + `cvl-relay` |
| `lifepunchnet` | blue | `cvl-watchdog`, `cvl-security` |

Odysseus conductor reads `voice-session.ndjson` or `GET /tail?lines=50` — one static host, real audit trail.

## Hard rules

- `AUTH_ENABLED=true`, loopback/LAN only — **no** public `:7000`
- No real LifePunch email/API creds in Odysseus
- Agent has **no** write-git credentials
- AGPL — unmodified internal use only; flag owner before fork-and-serve

## Update session ingest (if hub stores only `text` today)

If structured `conversation` fields are missing in hub lines, restart session hub from latest `ServerHost-SessionIngest.ps1` (after `git pull` on lane or copy from monorepo).
