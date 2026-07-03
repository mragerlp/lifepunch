# Government database terminal (lifepunchnet — Phase 4 scaffold)

**Skin:** lifepunchnet · **Accent:** `#00D4FF` · **Prompt:** `lifepunch@lifepunch.net:~$`  
**Program:** `lifepunch-ops.exe` · **Addon:** `governmentdatacenter` (not built)  
**Status:** Prep only — ship after Hacker Ops Console pattern is stable  
**Canon:** `branding/lifepunch-ops/outfits/lifepunchnet/TIER-SPEC.md`

---

## Boot fiction

```text
(c) Lifepunch Government Systems. All rights reserved.
L I F E P U N C H . N E T
lifepunch@lifepunch.net:~$ ls
citizens  records  surveillance  infrastructure
```

---

## Ops Console modules (mirror hacker rail shape)

| Module | Fiction purpose | Sample commands |
|--------|-----------------|-----------------|
| **LOG** | Audit scrollback | `clear`, `about` |
| **CITIZENS** | Player / citizen lookup | `lookup <steamid>`, `warrant <id>` |
| **RECORDS** | Licenses, fines, warrants | `records list`, `records open <case>` |
| **SURVEILLANCE** | Cameras / alerts | `cams list`, `cams feed <id>` |
| **INFRA** | Server / map status | `status map`, `status power` |
| **HELP** | Staff command ref | `help` |

---

## Command scaffold (read-only / staff-gated)

### `citizens`

| Command | Output fiction | Gate |
|---------|----------------|------|
| `lookup <steamid>` | Name, job, license flags | Police / Mayor / Admin |
| `flag <steamid> <reason>` | Adds watch flag | Admin |

### `records`

| Command | Output fiction | Gate |
|---------|----------------|------|
| `records list` | Open case ids | Police+ |
| `records open <case>` | Fine / warrant detail | Police+ |
| `warrant issue <steamid>` | Warrant stub line | Judge role TBD |

### `surveillance`

| Command | Output fiction | Gate |
|---------|----------------|------|
| `cams list` | Camera ids + zones | Police+ |
| `cams feed <id>` | ASCII “feed active” | Police+ |
| `alert raise <zone>` | Dispatch ping hook | Police+ |

### `infrastructure`

| Command | Output fiction | Gate |
|---------|----------------|------|
| `status map` | Player count, entity load | Staff |
| `status treasury` | City balance read-only | Mayor / Admin |
| `counter hack` | Log recent hacker RPC ids | Ties to Hacker Job audit |

---

## ASCII wireframe — CITIZENS module

```text
┌─ LIFEPUNCH OPS — lifepunchnet ─────────────────────────────────────┐
│ [LOG] [CITIZENS*] [RECORDS] [SURVEILLANCE] [INFRA] [HELP]            │
├────────────────────────────────────────────────────────────────────┤
│ CITIZENS — ID LOOKUP                                               │
│  SteamID          Name              Job           Flags            │
│  7656119…         Jared Zerillo     Police        —                │
│  7656119…         Test Bot          Citizen       WATCH            │
│                                                                    │
│  > lookup 7656119…                                                 │
├────────────────────────────────────────────────────────────────────┤
│ lifepunch@lifepunch.net:~$ _                                       │
└────────────────────────────────────────────────────────────────────┘
```

---

## ASCII wireframe — RECORDS module

```text
┌─ LIFEPUNCH OPS — lifepunchnet ─────────────────────────────────────┐
│ [LOG] [CITIZENS] [RECORDS*] [SURVEILLANCE] [INFRA] [HELP]          │
├────────────────────────────────────────────────────────────────────┤
│ RECORDS — CASE FILE RC-1042                                        │
│  Subject:   7656119… (Test Bot)                                    │
│  Type:      Traffic fine                                           │
│  Status:    OPEN                                                   │
│  Amount:    $250                                                   │
│                                                                    │
│  commands: records list | records open <id> | warrant issue <id> │
├────────────────────────────────────────────────────────────────────┤
│ lifepunch@lifepunch.net:~$ _                                       │
└────────────────────────────────────────────────────────────────────┘
```

---

## Relation to Hacker Job

| Hacker (green/red) | Government (cyan) |
|------------------|-------------------|
| `cornerman.exe` / `vengeance.exe` — criminal fiction | `lifepunch-ops.exe` — official database |
| wallet steal puzzle | read-only / staff queries |
| job: Hacker | job: Police / Mayor / Admin (TBD) |
| `govdb` infiltration (advanced hacker) | `counter hack` + treasury **read** |

Advanced hacker About line: *“Govdb breaches countered by Police terminals (lifepunchnet cyan).”*

---

## Dev smoke (future)

```text
lp_lifepunch_ops_ui    # cyan ops console — NOT built yet
```

See `GOVERNMENT_DATABASE_SPEC.md` for full Phase 4 lane.
