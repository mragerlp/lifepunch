# VENGEANCE desk PTT

**Status:** **Deferred (June 2026).** Default voice lane = **Cursor mic plugin** in chat.

Whisper STT on lifepunchnet and this desk PTT stack remain in repo for later re-enable.
See `SBOX_EDIT_STANDARDS.md` for current editing bar.

---

**June 2026** — Voice to Cursor **without Cornerman** or RDP (when enabled).

## Hardware (VENGEANCE)

| Role | Device | Match string |
|------|--------|--------------|
| **Input (record)** | Audio-Technica **AT2020 USB+** | `AT2020` |
| **Output (listen)** | **CORSAIR VIRTUOSO MAX** wireless | `VIRTUOSO` |

Windows may label devices slightly differently. Override:

```powershell
$env:VENGEANCE_PTT_INPUT_MATCH = 'AT2020'
$env:VENGEANCE_PTT_OUTPUT_MATCH = 'VIRTUOSO'
```

List devices:

```powershell
powershell -File lifepunch\scripts\vengeance-ptt\Start-VengeancePtt.ps1 -ListDevices
```

## Flow

```text
AT2020 USB+ (VENGEANCE) -> F7 arm -> F8 hold -> lifepunchnet Whisper :9000 -> clipboard -> Ctrl+V in Cursor
```

STT runs on **lifepunchnet** (same as before). Cornerman is **not** in the path.

## One-time install

```powershell
cd C:\Users\jared\Projects\lifepunch
powershell -ExecutionPolicy Bypass -File lifepunch\scripts\vengeance-ptt\Install-VengeancePtt.ps1
```

## Daily use

Double-click **`Talk-On-Vengeance.cmd`** or:

```powershell
powershell -File lifepunch\scripts\vengeance-ptt\Start-VengeancePtt.ps1
```

1. Focus the PTT window  
2. **F7** tap → Ready  
3. **F8** hold → speak → release  
4. **Ctrl+V** in Cursor  

## Preflight

Fails fast if lifepunchnet `:9000` is down (same cyan leg as Cornerman relay).

```powershell
powershell -File lifepunch\scripts\Test-VoiceCommsReady.ps1
```

Emergency skip: `Start-VengeancePtt.ps1 -SkipPreflight`

## vs Cornerman relay

| | VENGEANCE PTT | Cornerman Talk to Vengeance |
|--|---------------|----------------------------|
| Cornerman load | **None** | relay.py + SSH |
| RDP | **No** | No (SSH start) but mic on Green |
| Mic | AT2020 on desk | AT2020 on Cornerman |
| Whisper | lifepunchnet | lifepunchnet |

## Files

| Path | Role |
|------|------|
| `scripts/vengeance-ptt/vengeance_ptt.py` | Main loop |
| `scripts/vengeance-ptt/outbox/to-cursor.txt` | Last transcript |
| `scripts/vengeance-ptt/Talk-On-Vengeance.cmd` | Desktop shortcut target |

See `VOICE_DAY_ARCHITECTURE.md` path C.
