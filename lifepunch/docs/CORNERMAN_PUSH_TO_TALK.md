# Cornerman push-to-talk (PTT)

## Why

Wake-phrase mode always listens and runs STT to detect `"send message"`. That wastes lifepunchnet Whisper calls and adds idle log noise.

**Arm-then-PTT** keeps Cornerman silent until you start a round. You control timing on both sides:

- **F7 tap** — you arm Cornerman for one round
- **F8 hold** — you talk (only after Cornerman says Ready)
- **Clipboard** — Cornerman arms you back with the transcript; paste in Cursor when you want

## Modes

| Shortcut on Cornerman | Mode |
|----------------------|------|
| `Talk to Vengeance.cmd` | **Default:** tap **F7** → Ready → hold **F8** → release → clipboard |
| `Talk to Vengeance (PTT).cmd` | Same as default |
| `Talk to Vengeance (Wake).cmd` | Legacy wake phrase (not recommended) |

## Deploy from VENGEANCE

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
powershell -ExecutionPolicy Bypass -File .\lifepunch\scripts\cornerman-relay\Apply-CornermanPushToTalk.ps1
```

Copies `ptt.py`, `ptt_capture.py`, `relay_ui.py`, `commands.py`, and patches `cornerman-rag\relay.py` in place.

## Key bindings

| Key | Env var | Default | Action |
|-----|---------|---------|--------|
| Arm | `CORNERMAN_ARM_KEY` | **F7** | Tap once to start a round |
| Talk | `CORNERMAN_PTT_KEY` | **F8** | Hold after Ready to record |

Allowed values: `space`, `f8`, `f9`, `f10`, `scrolllock`, `pause`.

Keys use `GetAsyncKeyState` — relay console window must be focused. Global hotkeys (foot pedal while alt-tabbed) are a future upgrade.

## Pipeline

```
Tap F7 → Cornerman says Ready → hold F8 → lifepunchnet Whisper :9000
  → Cornerman clipboard + outbox → VENGEANCE watch → Ctrl+V in Cursor
  → session hub :9102 (via VENGEANCE session sync)
```

VENGEANCE runs **LifePunch Voice Comms** (preflight + paste watch + session sync + watchdog).

## Rollback

Use `Talk to Vengeance (Wake).cmd` only if needed. To remove PTT entirely, delete `ptt.py` / `ptt_capture.py` and strip `run_ptt_loop` / `--ptt` from `relay.py`.
