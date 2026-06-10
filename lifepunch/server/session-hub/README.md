# lifepunchnet session hub

Append-only voice + chat log on the always-on box. Cornerman captures audio; VENGEANCE bridges
logs here; Odysseus / Block C agents read them.

## Paths (on lifepunchnet)

| Path | Purpose |
|------|---------|
| `C:\lifepunch\session-hub\voice-session.ndjson` | Main ingest log (one JSON object per line) |
| `C:\lifepunch\session-hub\imports\` | Manual chat/transcript drops from VENGEANCE |

## HTTP API (`:9102`, Bearer = `C:\lifepunch\status\status-token.txt`)

| Method | Path | Body / query |
|--------|------|----------------|
| GET | `/status` | Line count + hub path |
| GET | `/tail?lines=50` | Last N NDJSON lines (max 500) |
| POST | `/ingest` | JSON: `{ "source", "type", "text", "ts?" }` |

## NDJSON fields

```json
{"ts":"2026-06-10T12:00:00.0000000Z","source":"cornerman","type":"transcript","text":"..."}
```

| `type` | Meaning |
|--------|---------|
| `session` | Line from Cornerman `outbox\session.log` |
| `transcript` | Latest `outbox\to-vengeance.txt` |
| `stt-path` | Line from `outbox\stt-path.log` |
| `chat` | Manual or future Cursor import |
| `conversation` | Structured turn from `outbox/conversation.ndjson` (user_text, ai_text, agent, intent, project, stt) |

Structured ingest accepts **any JSON fields** — they are stored verbatim in `voice-session.ndjson` for search and Odysseus later.

## Install

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts
.\Install-LifepunchnetSessionHub.ps1 -RemoteAddress <VENGEANCE-home-IP>
```

VENGEANCE bridge: `lifepunch/scripts/start-session-sync.ps1`

Full workflow: `lifepunch/server/LIFEPUNCHNET_RDP_ODYSSEUS.txt`
