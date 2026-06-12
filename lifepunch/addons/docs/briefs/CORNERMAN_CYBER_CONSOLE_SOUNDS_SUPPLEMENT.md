# Cornerman supplement — cyber console + fan sounds (P1d add-on)

**Read with:** `CORNERMAN_BITCOINMINING_SOUNDS_TASK.md` (primary P1d)  
**Owner asks (inbox):**

- `OWNER_ASK_LOUD_CLICK_TYPING.txt`
- `OWNER_ASK_UNIVERSAL_CONSOLE_KEYBOARD.txt`
- `OWNER_ASK_GPU_FAN_LIFECYCLE.txt`
- `OWNER_ASK_HACKERJOB_SOUNDS.txt`

---

## 1. Universal console keyboard (all jobs)

One **loud click typing** asset for every LifePunch terminal UI:

- bitcoinmining `HashdTerminal` + PIN numpad
- hackerjob `HackerTerminal` (cornerman + vengeance)
- future gov/police consoles

Proposed canonical path: `addons/lifepunch/shared/sounds/lifepunch-console-keyboard.sound`

Shortlist **one winner + two alternates** with license notes.

---

## 2. GPU fan lifecycle (bitcoinmining)

Owner fantasy:

```text
ON → ramp up → passive loop → OFF → ramp down → silence
```

**Code fact:** `GpuRackEntity` + `BitcoinMinerHubEntity` already ramp **loop volume over ~8s** — prioritize a **seamless fan/hum loop**; spin-up/down one-shots are optional layers.

| Slot | Role |
|------|------|
| `server-hum` | Rack mining loop (primary) |
| `hub-fan-loop` | Hub powered loop (can share same vsnd as server-hum at different volume) |
| `hub-startup` | Optional spin-up one-shot |
| `hub-fan-down` | Optional spin-down one-shot |

Cross-reference `GpuRackEntity` `HumRampSeconds` / `FanRampSeconds` = 8f.

---

## 3. Hacker Job sound matrix

See `OWNER_ASK_HACKERJOB_SOUNDS.txt`. Keyboard = universal. Additional CRT boot, access granted/denied, rack fan family, scan pulse — shortlist for Phase 3 assets (`HACKER_JOB_SPEC.md` §6).

No C# wiring required in this distill — intake spec only.

---

## 4. Output

Extend existing P1d outbox files OR add:

| File | Add |
|------|-----|
| `BITCOINMINING_SOUND_SHORTLIST.md` | § Universal keyboard · § GPU fan lifecycle · § Hacker Job |
| `BITCOINMINING_SOUND_SLOT_SPEC.md` | Fan ramp notes + shared keyboard policy |
| `HACKERJOB_SOUND_SHORTLIST.md` | (optional standalone) |

Ping Red: `OK cornerman cyber sounds supplement — universal keyboard + fan lifecycle + hacker matrix`
