# Voice pipeline status (VENGEANCE ↔ Cornerman ↔ lifepunchnet)

> Updated when lifepunchnet confirms services live. Agents: read after `git pull --rebase`.

## lifepunchnet services (auto-boot target)

| Port | Service | Boot |
|------|---------|------|
| 9000 | Whisper STT (`small.en`) | `LifePunch-Whisper-Deploy` AtLogon → `deploy-whisper.ps1` |
| 9101 | Watchdog status API | `LifePunch-ServerHost-StatusServer` AtStartup |
| 9102 | Session hub `/ingest` | `LifePunch-SessionHub` AtStartup |

**One-shot installer (lifepunchnet, elevated):** `lifepunch/server/scripts/Install-LifePunchNetBoot.ps1`

Docker Desktop **Start when you sign in** (Administrator) is still manual once. VENGEANCE does not start Docker remotely in v1.

Token: `C:\lifepunch\status\status-token.txt` on lifepunchnet = `server-host-watch.local.json` on VENGEANCE.

See `lifepunch/docs/LIFEPUNCH_PARTY_HANDOFF.md`.

## VENGEANCE — Start Day (one desktop action)

**LifePunch — Start Day** → `Start-LifePunchDay.ps1`

- Gate: `Test-NetConnection` lifepunchnet **:9000** (no Docker/SSH to lifepunchnet from desk in v1)
- Starts: voice watch, session sync, lifepunchnet watchdog watch
- Remote-starts Cornerman PTT: `Start-CornermanVoiceRelay.ps1` over SSH
- Install: `Install-LifePunchDayShortcut.ps1`

## VENGEANCE wiring (owner runs before Cornerman voice work)

### 1. Cornerman STT → lifepunchnet Whisper

On Cornerman (machine env):

```
CORNERMAN_REMOTE_WHISPER_URL=http://205.209.104.22:9000/v1/audio/transcriptions
CORNERMAN_REMOTE_WHISPER_MODEL=small.en
```

Verify from VENGEANCE: `ssh cornerman` then echo those vars, or run `Test-VoiceCommsReady.ps1`.

Cornerman desktop: **Talk to Vengeance** (push-to-talk only in normal use).

| Mode | Shortcut | Trigger |
|------|----------|---------|
| **PTT** (default) | `Talk to Vengeance.cmd` | Tap **F7** (arm) → Cornerman says ready → hold **F8** → release → clipboard |
| Wake phrase (legacy) | `Talk to Vengeance (Wake).cmd` | Say `send message` → speak (not recommended) |

Deploy PTT from VENGEANCE: `lifepunch/scripts/cornerman-relay/Apply-CornermanPushToTalk.ps1`

Console layout is shared: `lifepunch/scripts/Voice-Console.ps1` (VENGEANCE) mirrors `cornerman-rag/relay_ui.py` (Cornerman).
See `CORNERMAN_PUSH_TO_TALK.md` and **`CORNERMAN_VOICE_NETWORK.md`** (full stack: STT, commands, TTS, lifepunchnet memory).

### 2. Session hub ingest (logs)

**Canonical path today:** VENGEANCE bridge — not direct Cornerman POST.

```
Cornerman outbox (SSH) → start-session-sync.ps1 → POST http://205.209.104.22:9102/ingest
```

Bearer = same token as `:9101`. Started by **LifePunch Voice Comms** shortcut.

**Direct Cornerman → `/ingest`:** not implemented in `relay.py` yet. If added later, traffic
egresses via your **home public IP** (same as VENGEANCE), not `192.168.1.227` — firewall already
allows `71.250.46.224` for ingest.

### 3. Paste into Cursor

`start-vengeance-voice-watch.ps1` (included in Voice Comms shortcut) → Ctrl+V when Cornerman cues.

## E2E test (VENGEANCE)

1. `Test-VoiceCommsReady.ps1` — all OK
2. Double-click **LifePunch Voice Comms**
3. Cornerman: tap F7 → wait for Ready → hold F8 → release
4. VENGEANCE: Ctrl+V in Cursor
5. Check hub: `Invoke-RestMethod` on `:9102/tail?lines=10` with Bearer token

## Not started (per lifepunchnet handoff)

- Odysseus on lifepunchnet
- Session-hub STT filters / advanced hub
- Production DXRP deploys
- Addon/website work on lifepunchnet

## Monorepo cleanup (when convenient)

Push watchdog install fixes (em-dash + scheduled-task `RepetitionDuration`), re-export
`lifepunch-rdp-server` lane so lifepunchnet `git pull` replaces clipboard installs.
