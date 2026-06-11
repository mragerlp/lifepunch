# Bitcoin Miner — sounds (owner-only)

**Ship policy:** LifePunch-owned or owner-licensed audio **only**. No third-party addon sound packs, no copied WAVs from other bitminers.

The ship tree has **no audio binaries** until you drop files via `Intake-BitcoinMinerSounds.ps1`.

## Semantic slots (not copies of anyone else's files)

| Slot | Path constant | Role |
|------|---------------|------|
| `hub-startup` | `HubStartupSoundPath` | Hub power on |
| `hub-fan-loop` | `HubFanLoopSoundPath` | Hub fan loop |
| `hub-fan-down` | `HubFanDownSoundPath` | Hub power off |
| `server-hum` | `HumSoundPath` | Rack mining hum |
| `keyboard` | `KeyboardSoundPath` | HASHD UI typing |
| `glitch` | `GlitchSoundPath` | Damage glitch |
| `error` | `ErrorSoundPath` | Error beep |

Drop originals in `%USERPROFILE%\Downloads\bitcoinminer-sounds\` then run intake. Archive lands under `C:\lifepunch\reference-intake\bitcoinmining\sounds\` (local, not published).
