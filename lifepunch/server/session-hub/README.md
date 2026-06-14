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
| `cvl-checkpoint` | Universal tri-stack probe (`Invoke-CvlUniversal.ps1`) |
| `cvl-git` | VENGEANCE git parity (red tier) |
| `cvl-relay` | Cornerman PTT state (green tier) |
| `cvl-services` | lifepunchnet :9000/:9101/:9102 (blue tier) |
| `cvl-watchdog` | lifepunchnet on-box watchdog snapshot |
| `cvl-security` | Alert from VENGEANCE lifepunchnet watch |
| `cvl-uptime` | UP/DOWN/DEGRADED state change |
| `cvl-note` | Bloodwave note attached to a checkpoint |

## CVL tiers (uniform — not cosmetic)

| `tier` | Node | Color |
|--------|------|-------|
| `universal` | tri-stack / rainbow | All three |
| `vengeance` | VENGEANCE desk | Red |
| `cornerman` | Cornerman LAN | Green |
| `lifepunchnet` | Hosted server | Blue |

Structured ingest accepts **any JSON fields** — they are stored verbatim in `voice-session.ndjson` for search and Odysseus later.

**Universal command (VENGEANCE):** `Invoke-CvlUniversal.ps1` — probes CVL, posts tier-tagged lines to `:9102`.

## Security (before high-value data)

1. **Firewall scope (lifepunchnet, elevated):** `Secure-LifepunchnetCvlPorts.ps1 -RemoteAddress <VENGEANCE-home-public-IP>`  
   Scopes `:9000` Whisper, `:9101` status, `:9102` hub to your IP only. Docker binds `0.0.0.0:9000` — firewall is mandatory.
2. **Bearer token:** `C:\lifepunch\status\status-token.txt` — copy to VENGEANCE `server-host-watch.local.json` only (gitignored).
3. **VENGEANCE gate:** `Test-CvlSecurity.ps1` must PASS before `Invoke-CvlUniversal -IngestToHub` (enforced by default).
4. **Transport:** HTTP + scoped IP + Bearer (v1). No secrets in hub lines. TLS/reverse-proxy is a future hardening layer.
5. **Cornerman:** LAN SSH only; no lifepunchnet tokens on that box.
6. **Anti-tumble:** Hub is append-only on lifepunchnet. Data flows **in** (Green outbox → VENGEANCE bridge → Blue hub). No node reads hub and re-posts. Ingest rejects secret fields and echo/tumble types.
7. **IP allowlist (app layer):** `C:\lifepunch\status\hub-ingest-allowlist.txt` — set by `Secure-LifepunchnetCvlPorts.ps1`; restart hub + status server tasks after update.

## Install

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts
.\Install-LifepunchnetSessionHub.ps1 -RemoteAddress <VENGEANCE-home-IP>
```

VENGEANCE bridge: `lifepunch/scripts/start-session-sync.ps1`

Full workflow: `lifepunch/server/LIFEPUNCHNET_RDP_ODYSSEUS.txt`
