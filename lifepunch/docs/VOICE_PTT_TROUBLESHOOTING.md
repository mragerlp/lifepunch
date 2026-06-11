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

## Symptom: `RELEASED` then `(no audio — tap F7 to arm again)` (mic shows AT2020)

**Root cause:** `ptt_capture.record_ptt(armed=True)` only kept the last **300ms** of F8-hold audio in preroll and measured speech **after** release. Normal PTT (talk while holding, release when done) discarded almost everything.

**Fix:** `ptt_capture.py` — while armed and F8 held, append frames to `captured`; count speech across the full hold + tail.

**Deploy:** `Apply-CornermanPushToTalk.ps1` from VENGEANCE (or base64 `ptt_capture.py` to `cornerman-rag`). Restart **one** Talk to Vengeance window.

## Symptom: `UnicodeDecodeError` in `load_session_log` after successful TRANSCRIBING

**Root cause:** `outbox/session.log` contains a non-UTF-8 byte (often `0x97` from a Windows-1252 dash written by PowerShell `Add-Content` over SSH). `deliver()` crashes when painting the conversation log.

**Fix:** `patch_relay_ptt.py` replaces `load_session_log()` with UTF-8 / CP1252 fallback + `errors="replace"`. Re-run patch on Green; optionally rewrite `session.log` as UTF-8.

**Operator recovery:** Restart one Talk to Vengeance window after patch — transcript + clipboard still work; crash was post-STT UI only.

## Symptom: Voice Watch shows Windows SSH banner in SESSION LOG / pull crashes on Preview

**Root cause:** `Invoke-CornermanSshRead` returned raw `cmd /c type` output including Cornerman SSH login banner; multi-line SSH arrays broke `Substring` preview math in `pull-cornerman-voice.ps1`.

**Fix:** `Voice-Console.ps1` — `Normalize-CornermanSshFileContent`, `Get-CornermanSessionLogLines`, `Get-TextPreview`. Restart **LifePunch Voice Watch** window after pull.

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
