# Voice test checklist (Bloodwave / VENGEANCE)

PTT mode only — **not** wake phrase. Cornerman stack: `C:\Projects\cornerman-rag`.

## Cornerman (pre-flight — no redeploy unless verify fails)

- Relay windows closed; no relay processes running (clean before you start).
- Stack already verified: `ptt.py`, `relay_ui.py`, `relay.py` with PTT loop (`ptt.wait_tap` → F7 → Ready → F8 → `deliver()`).
- **Do not** re-run `Apply-CornermanPushToTalk.ps1` unless post-`git pull` verification fails.
- Bloodwave launches **`Talk to Vengeance.cmd`** on Cornerman desktop (relay window must stay **focused**).

| Step | Action |
|------|--------|
| Shortcut | `Talk to Vengeance.cmd` → `relay.ps1 -PushToTalk` |
| Arm | Tap **F7** → TTS **"Ready"** |
| Talk | Hold **F8** → speak → release |
| Output | `outbox\to-vengeance.txt` + Cornerman clipboard + TTS paste cue |

## VENGEANCE (one click — preferred)

Double-click **LifePunch — Start Day** (or `Start-LifePunchDay.ps1`):

- Gates on **lifepunchnet :9000** (TCP) — stops with *start lifepunchnet Whisper first* if red
- Starts voice watch + session sync + lifepunchnet watch (background windows)
- Remote-starts Cornerman PTT via `Start-CornermanVoiceRelay.ps1`
- Does **not** SSH to lifepunchnet or redeploy Cornerman unless verify fails

Install shortcut: `Install-LifePunchDayShortcut.ps1`  
Refresh RDP: `Install-LifePunchRemoteShortcuts.ps1`

## VENGEANCE (manual — same checks)

1. `git pull --rebase` on monorepo.
2. `Test-VoiceCommsReady.ps1` — all **OK** (especially **lifepunchnet Whisper :9000**).
3. **LifePunch Voice Comms** running (or at minimum `start-vengeance-voice-watch.ps1`).
4. Cornerman SSH works:
   ```powershell
   ssh cornerman "Get-Content C:\Projects\cornerman-rag\outbox\to-vengeance.txt -ErrorAction SilentlyContinue"
   ```

Watcher scripts (`watch-cornerman-voice.ps1`) poll `to-vengeance.txt` via SSH — correct for PTT. Ignore legacy wake-phrase docs; UI banners are F7/F8.

**STT dependency:** Current `relay.ps1` has **no local Lemonade/faster-whisper fallback**. If lifepunchnet `:9000` is down, transcribe fails.

## Success criteria (one round)

- [ ] Hear **"Ready"** after F7 tap.
- [ ] Green UI: **`RELEASED`** (F8 up) then **`TRANSCRIBING`** (not stuck on RECORDING).
- [ ] After F8 release, transcript in `to-vengeance.txt`.
- [ ] VENGEANCE watcher: hash change → clipboard → **Ctrl+V** in Cursor.
- [ ] `outbox\stt-path.log` shows `lifepunchnet | http://205.209.104.22:9000/...` (not local fallback).
- [ ] Exactly **one** Talk to Vengeance relay window on Green (no duplicate `relay.py`).

Troubleshooting: `VOICE_PTT_TROUBLESHOOTING.md`

## Known blocker

Earlier sessions: lifepunchnet `:9000` / `:9102` timeouts from VENGEANCE. Fix hosted Whisper + hub on lifepunchnet **before** cold-start E2E test.

## Related

- `CORNERMAN_PUSH_TO_TALK.md`
- `VOICE_PIPELINE_STATUS.md`
