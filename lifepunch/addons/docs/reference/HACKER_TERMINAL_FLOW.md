# Hacker Job terminal flow (scaffold)

**Status:** Cornerman fills from `HACKER_JOB_SPEC.md`  
**Ship target:** `lifepunch.hackerjob` · `cornerman.exe` fiction

---

## State machine

| State | Enter | Exit |
|-------|-------|------|
| IDLE | Player USE terminal | Boot starts |
| BOOTING | | `cornerman.exe` loaded |
| CORNERMAN_LOADED | | `scan` success |
| SCAN_LIST | | Target selected |
| TARGET_LOCKED | | Puzzle starts |
| PUZZLE_ACTIVE | | Timer expires or submit |
| SUCCESS | Server validates | Cooldown |
| FAIL | Wrong answer / timeout | Cooldown |
| COOLDOWN | | IDLE |

---

## Per-screen notes

### BOOTING

TBD — boot lines, skippable?, duration

### CORNERMAN_LOADED

TBD — prompt `cornerman@rig:~$`, available commands

### SCAN_LIST

TBD — table columns, click targets

### PUZZLE_ACTIVE

TBD — timer UI, input mode

---

## cornerman.exe commands

| Command | States allowed | Server RPC |
|---------|----------------|------------|
| TBD | | |

---

## Economy (proposed)

| Knob | Value |
|------|-------|
| Wallet-only | yes |
| Steal cap | TBD |
| Cooldown | TBD |

---

## Bitminer reuse

| Shared | Hacker-only |
|--------|-------------|
| Scroll terminal SCSS | scan + puzzle flow |
| Boot aesthetic | wallet drain RPC |
| `cornerman@rig` voice | job gate |

---

## Open answers (from HACKER_JOB_SPEC §5)

1. Scan scope: TBD  
2. Puzzle format MVP: TBD  
3. Steal amount formula: TBD  
4. Counterplay / notify target: TBD  
5. Terminal placement: TBD  
