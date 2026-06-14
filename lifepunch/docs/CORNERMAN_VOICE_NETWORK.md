# Cornerman voice network (local AI + lifepunchnet archive)

> Mic → STT → router → agents → TTS, with **lifepunchnet** as the durable external log.

## Machine roles

| Machine | Role in voice network |
|---------|----------------------|
| **Cornerman** | Mic, PTT, local LLM (LM Studio), local TTS, RAG, structured `conversation.ndjson` |
| **lifepunchnet** | Hosted Whisper STT (`:9000`), session hub archive (`:9102`), future Odysseus |
| **VENGEANCE** | Cursor paste, session sync bridge, integration |

## Pipeline (two modes)

### C — VENGEANCE desk PTT (no Cornerman)

```
AT2020 USB+ on VENGEANCE → F7/F8 → lifepunchnet Whisper :9000 → clipboard → Cursor
```

See `VENGEANCE_PTT.md`. Virtuoso headset = listen output only.

### A — Talk to Vengeance (brainstorm → Cursor)

```
AT2020 → tap F7 (arm) → Ready → hold F8 → lifepunchnet Whisper :9000 → relay outbox
  → Cornerman clipboard (arm back) → VENGEANCE paste → lifepunchnet :9102 (session sync)
```

No local LLM on this path — Cornerman stays thin.

### B — Talk to Cornerman (local AI teammate)

```
Mic → faster-whisper (local) OR lifepunchnet Whisper → command parser
  → LM Studio / Ollama :1234 → Piper/SAPI TTS → speakers
  → conversation.ndjson (local) → lifepunchnet :9102 (via session sync)
```

## Speech-to-text tiers

| Tier | Where | When |
|------|-------|------|
| **Primary (relay)** | lifepunchnet Whisper `small.en` `:9000` | Talk to Vengeance PTT — GPU on hosted box |
| **Local fallback** | faster-whisper on Cornerman | lifepunchnet unreachable |
| **Local default (talk.py)** | faster-whisper on Cornerman | Talk to Cornerman loop |
| **Future** | lifepunchnet larger model / whisper.cpp | Owner upgrade on lifepunchnet only |

Configured on Cornerman:

```
CORNERMAN_REMOTE_WHISPER_URL=http://205.209.104.22:9000/v1/audio/transcriptions
CORNERMAN_REMOTE_WHISPER_MODEL=small.en
```

## Natural spoken commands

Prefix **`Cornerman,`** (optional on Vengeance relay; default on talk.py).

| Phrase | Intent | Agent / route |
|--------|--------|----------------|
| summarize this | `summarize` | cornerman (RAG + LLM) |
| open the DXRP project | `open_project` | router → project `dxrp` |
| send this to the finance AI | `route_agent` | finance (future lane) |
| remember this for the LifePunch site | `remember` | shottaWEB / website context |
| explain this like I'm new | `explain_eli5` | cornerman |

Parser: `cornerman-rag/commands.py` — logs `intent` + `agent` on every turn; full routing is incremental.

## Text-to-speech

| Tier | Engine | Latency | Notes |
|------|--------|---------|-------|
| **Baseline** | Windows SAPI (`pyttsx3`) | Low | Ships today in `tts.py` |
| **Upgrade** | Piper (local `.onnx`) | Low | Set `CORNERMAN_TTS=piper` + `PIPER_EXE` / `PIPER_VOICE` |

Requirements: low latency, clear pronunciation, offline — Piper is the documented swap point.

## Conversation memory (local + lifepunchnet)

### Local (Cornerman)

`C:\Projects\cornerman-rag\outbox\conversation.ndjson` — one JSON object per line:

```json
{
  "ts": "2026-06-10T12:00:00Z",
  "channel": "vengeance-relay",
  "user_text": "Cornerman, summarize the watchdog setup",
  "ai_text": null,
  "agent": "cornerman",
  "intent": "summarize",
  "project": "dxrp",
  "stt": "lifepunchnet",
  "tags": ["voice", "lifepunch"]
}
```

### External (lifepunchnet)

Same records POSTed to `http://205.209.104.22:9102/ingest` (Bearer = status token) by VENGEANCE `start-session-sync.ps1`.

Read back: `GET /tail?lines=50` on lifepunchnet or RDP + Odysseus later.

## Daily startup (Bloodwave)

**VENGEANCE:** `LifePunch Voice Comms` shortcut (preflight + paste + sync + watch)

**Cornerman:**

| Task | Shortcut |
|------|----------|
| Voice → Cursor | `Talk to Vengeance.cmd` (F7 arm → F8 talk) |
| Local AI chat | `Talk to Cornerman.cmd` |
| LM Studio | Must be running on `:1234` for talk.py |

## Deploy voice-network modules to Cornerman

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
powershell -ExecutionPolicy Bypass -File .\lifepunch\scripts\cornerman-relay\Apply-CornermanVoiceNetwork.ps1
```

Requires prior PTT deploy (`Apply-CornermanPushToTalk.ps1`).

## Not started

- Finance / multi-agent routing
- lifepunchnet-hosted TTS
- Session-hub STT filters
- Odysseus auto-ingest of `conversation.ndjson`

## Related

- `CORNERMAN_PUSH_TO_TALK.md`
- `VOICE_PIPELINE_STATUS.md`
- `lifepunch/server/session-hub/README.md`
- `LOCAL_AI_WORKSTATION.md` § voice
