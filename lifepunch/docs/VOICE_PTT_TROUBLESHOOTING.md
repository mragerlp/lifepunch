# Voice PTT — troubleshooting (June 2026)

Canonical fixes from the F7/F8 E2E debug round. Pair with `VOICE_TEST_CHECKLIST.md` and `CORNERMAN_PUSH_TO_TALK.md`.

## Symptom: Green frozen on `RECORDING  F8 held - release to send`

**Root cause:** `ptt_capture.record_ptt()` waited forever for F8 release. While the key read as still down, the capture loop had **no timeout** — UI never advanced.

**Contributing factor:** Multiple `relay.py --ptt` processes (repeated Start Day / Talk to Vengeance starts). Competing relays confuse PTT key polling.

**Fix (repo + deploy):**

- `ptt.is_released()` — debounced release (consecutive up samples).
- `ptt_capture.py` — max hold timeout (`CORNERMAN_PTT_MAX_HOLD_SEC`, default 90s), `q.get(timeout=1.0)`.
- UI events: **`RELEASED`** (F8 up) → **`TRANSCRIBING`** (lifepunchnet Whisper).
- `Start-CornermanVoiceRelay.ps1` — stop all stale `relay.py` before starting one window.

**Operator recovery:** Close every old Talk to Vengeance window (Ctrl+C). Start one relay. Focus that window. F7 → Ready → F8 hold → release. Expect `RELEASED` then `TRANSCRIBING` before clipboard.

## Symptom: Red `sync error: Stream was not readable`

**Root cause:** Session sync posts to hub `:9102` via `Invoke-RestMethod`. Empty ingest bodies can throw that error in PowerShell 5.

**Fix:** `Cvl-Hub.ps1` uses `Invoke-WebRequest -UseBasicParsing` for hub POST. Restart **LifePunch Session Sync** window after pull so the fix loads.

**Not a yellow-leg blocker** — Voice Watch paste works independently of session sync.

## Symptom: `Unknown key='f7'` on relay start

**Root cause:** Default arm key F7 missing from `ptt.py` VK map.

**Fix:** F6–F12 in `ptt.py`; deploy via `Apply-CornermanPushToTalk.ps1`.

## Symptom: Red pull script preview crash

**Fix:** `pull-cornerman-voice.ps1` guards empty preview after clipboard copy.

## Deploy path (Green runtime)

Monorepo source: `lifepunch/scripts/cornerman-relay/`. Runtime on Green: `C:\Projects\cornerman-rag\`.

```powershell
# On VENGEANCE after git pull
powershell -File lifepunch\scripts\cornerman-relay\Apply-CornermanPushToTalk.ps1
```

That copies `ptt.py`, `ptt_capture.py`, `relay_ui.py`, runs `patch_relay_ptt.py` on `relay.py`, deploys Whisper preflight.

## One relay rule

**Exactly one** focused Talk to Vengeance console on Green during voice work. Duplicates → stuck PTT or ghost key state.

## Blue legs (confirm from Red)

| Port | Service |
|------|---------|
| `:9000` | Whisper STT (cyan leg) |
| `:9101` | ServerHost status / watchdog |
| `:9102` | Session hub (append-only) |

`Test-VoiceCommsReady.ps1` on VENGEANCE probes all three. Green `Test-LifepunchnetWhisperPreflight.ps1` probes cyan only.

## Related

- `SYNC_ROUND_VOICE_PTT_20260610.txt` — lane copy-paste for this round
- `CVL_RGB_DOCTRINE.md` — yellow / cyan / magenta path names
