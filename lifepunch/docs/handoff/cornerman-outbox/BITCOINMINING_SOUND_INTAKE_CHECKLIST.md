# Bitcoin mining — sound intake checklist (Red / VENGEANCE)

**After owner picks sources** from `BITCOINMINING_SOUND_SHORTLIST.md` · **Cornerman does not run this lane**

---

## 0 — Owner drop folder

Create / fill:

```text
%USERPROFILE%\Downloads\bitcoinminer-sounds\
```

Required filenames (stem — `.wav`, `.mp3`, or `.ogg`):

| P0 wired | Optional P2 |
|----------|-------------|
| `hub-startup` | `metal-hit` |
| `hub-fan-loop` | `smoke` |
| `hub-fan-down` | `explode` |
| `server-hum` | |
| `keyboard` | |
| `glitch` | |
| `error` | |

**Keyboard:** trim to loud single-hit sources; multiple variants OK (name `keyboard.wav`, `keyboard-2.wav` — intake copies by basename).

**CC0 fast-path:** run `Prepare-BitcoinMinerSoundsDrop.ps1` to auto-build the seven P0 WAVs from shortlist picks (then replace keyboard with RECORD when ready).

---

## 1 — Intake script

From repo addons root:

```powershell
cd C:\Users\jared\Projects\lifepunch
powershell -File lifepunchaddons\scripts\Intake-BitcoinMinerSounds.ps1
```

- Archives to `C:\lifepunch\reference-intake\bitcoinmining\sounds\` (local, not published)
- Copies into `lifepunchaddons/Assets/addons/lifepunch/bitcoinmining/sounds/bitcoinminer/`

Dry run:

```powershell
powershell -File lifepunchaddons\scripts\Intake-BitcoinMinerSounds.ps1 -WhatIf
```

---

## 2 — Compile `.vsnd` in s&box

1. `Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining`
2. `Start-SboxDxrpEditor.ps1`
3. Editor compiles new audio under addon assets → `_c` / `.vsnd` as per workspace pipeline
4. Dedicated server needs compiled assets — no hot-compile on DS

---

## 3 — Author `.sound` per slot

Mirror working pattern: `addons/Assets/addons/lifepunch/ak47/sounds/ak47_shot.sound`

Per P0 slot create:

```text
sounds/bitcoinminer/hub-startup.sound
sounds/bitcoinminer/hub-fan-loop.sound
sounds/bitcoinminer/hub-fan-down.sound
sounds/bitcoinminer/server-hum.sound
sounds/bitcoinminer/keyboard.sound
sounds/bitcoinminer/glitch.sound
sounds/bitcoinminer/error.sound
```

Each `.sound` JSON:

- `Sounds`: array pointing at matching `.vsnd` path under `addons/lifepunch/bitcoinmining/sounds/bitcoinminer/`
- `DistanceAttenuation`: **true** for world sounds (hub + rack); **keyboard** may use UI-friendly falloff — match `ak47_shot` as baseline, tune `Decibels` / `Distance`
- `SelectionMode`: `Random` if multiple variants
- **Loops:** set loop-appropriate flags on `hub-fan-loop` and `server-hum` sources in ModelDoc / sound metadata

Suggested starting `Decibels` (tune in playtest):

| Slot | Decibels hint |
|------|----------------|
| hub-startup | 72 |
| keyboard | 70 |
| error | 68 |
| glitch | 66 |
| hub-fan-down | 64 |
| server-hum | 58 (loop bed) |
| hub-fan-loop | 56 (loop bed) |

---

## 4 — Path parity verify

Constants in `BitcoinMiningAddon.cs` must match `.sound` paths exactly:

```text
addons/lifepunch/bitcoinmining/sounds/bitcoinminer/hub-startup.sound
addons/lifepunch/bitcoinmining/sounds/bitcoinminer/hub-fan-loop.sound
addons/lifepunch/bitcoinmining/sounds/bitcoinminer/hub-fan-down.sound
addons/lifepunch/bitcoinmining/sounds/bitcoinminer/server-hum.sound
addons/lifepunch/bitcoinmining/sounds/bitcoinminer/keyboard.sound
addons/lifepunch/bitcoinmining/sounds/bitcoinminer/glitch.sound
addons/lifepunch/bitcoinmining/sounds/bitcoinminer/error.sound
```

```powershell
rg "bitcoinminer/" lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/BitcoinMiningAddon.cs
Get-ChildItem lifepunchaddons/Assets/addons/lifepunch/bitcoinmining/sounds/bitcoinminer -File
```

---

## 5 — Smoke test (playtest)

```text
lp_spawn_bitcoin_miner_hub
lp_hub_power 1          → hub-startup + hub-fan-loop
lp_hashd_pin_preview setup → keyboard on PIN/UI keys
mining start (rack)     → server-hum ramps ~8s
lp_hub_power 0          → hub-fan-down
(damage path)           → glitch + error on rack
```

**Listen for:**

- Keyboard audible in RP at normal talk distance (owner ask)
- Loop seams inaudible on hub fan + server hum
- No double-trigger pops on hub power toggle

---

## 6 — Prefab / entity hooks

| Entity | Hook |
|--------|------|
| `BitcoinMinerHubEntity.cs` | `HubStartupSoundPath`, `HubFanLoopSoundPath`, `HubFanDownSoundPath` — already wired |
| `GpuRackEntity.cs` | `HumSoundPath`; prefab `ErrorBeepSound` / `GlitchSound` — align with constants or SoundEvent refs |
| `HashdTerminal.razor` | `KeyboardSoundPath` on UI interactions |

Re-enable hub sound props if nulled during prior playtest (per `BITCOINMINING_PLAYTEST.md`).

---

## 7 — Ship gate

```powershell
powershell -File lifepunchaddons/scripts/validate-layout.ps1
powershell -File scripts/validate-workspace.ps1
```

Update `BITCOINMINING_PROTECTION_CHECKLIST.md` G1 row "audio binaries" after intake.

**Do not commit** reference-intake archives or third-party pack rips.
