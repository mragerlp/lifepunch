# Cornerman push-to-talk (PTT)

## Why

Wake-phrase mode (`"send message"`) **always listens** and runs STT on every utterance to detect the phrase. That wastes lifepunchnet Whisper calls and can false-trigger on room noise.

**Push-to-talk** records only while you hold a key — one STT call per intentional message.

## Modes

| Shortcut on Cornerman | Mode |
|----------------------|------|
| `Talk to Vengeance.cmd` | Wake phrase (`send message` → speak) |
| `Talk to Vengeance (PTT).cmd` | Hold **F8** → speak → release |

## Deploy from VENGEANCE

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
powershell -ExecutionPolicy Bypass -File .\lifepunch\scripts\cornerman-relay\Apply-CornermanPushToTalk.ps1
```

Requires `ssh cornerman` + SCP. Patches `cornerman-rag` in place; adds `ptt.py` + `ptt_capture.py`.

## Key binding

Default: **F8** (`CORNERMAN_PTT_KEY`).

On Cornerman:

```powershell
setx CORNERMAN_PTT_KEY space
```

Allowed: `space`, `f8`, `f9`, `f10`, `scrolllock`, `pause`.

PTT uses `GetAsyncKeyState` — works while the **Talk to Vengeance** console window is focused. Global hotkeys (foot pedal while alt-tabbed) are a future upgrade.

## Pipeline (unchanged)

```
Hold F8 → record → lifepunchnet Whisper :9000 → outbox → VENGEANCE paste + session hub
```

VENGEANCE still runs **LifePunch Voice Comms** for paste + `:9102` archive.

## Rollback

Delete `ptt.py`, `ptt_capture.py`, remove `run_ptt_loop` / `--ptt` from `relay.py`, use wake-phrase shortcut only.
