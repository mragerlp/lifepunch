# Hacker Job terminal flow

**Status:** Green distill (2026-06-11) — matches shipped Ops Console (`HackerTerminal.razor`)  
**Ship:** `lifepunch.hackerjob` · Programs: `cornerman.exe` / `vengeance.exe`  
**Spec:** `HACKER_OPS_CONSOLE_SPEC.md` · `HACKER_JOB_SPEC.md`

---

## UI platform

| Field | Standard (green) | Advanced (red) |
|-------|------------------|----------------|
| Layout | 960×640 Ops Console — session rail + module panes + command line | Same |
| Accent | `#00FF7F` | `#E4002B` |
| Title bar | `LIFEPUNCH cornerman.exe v0.1 — cornerman@terminal` | `LIFEPUNCH vengeance.exe v0.1 — vengeance@terminal` |
| Prompt | `cornerman@terminal:~$` | `vengeance@terminal:~$` |
| Modules | LOG · SCAN · TARGET · HELP | + GOVDB |

**Not** amber `hashd` (bitcoinmining) · **Not** cyan `lifepunch-ops.exe` (governmentdatacenter).

---

## State machine

| State | Enter | Exit |
|-------|-------|------|
| **CLOSED** | — | Player USE terminal / `cornerman` / `hack` command |
| **BOOTING** | `HackerTerminal.Open` → `Boot()` | Boot lines written to LOG |
| **READY** | Boot complete | `scan` or `govdb` (advanced) |
| **SCAN_LIST** | `scan` success | Row select or `hack <steamid>` |
| **GOVDB_LIST** | `govdb` success (advanced only) | Row select or `infil <nodeid>` |
| **TARGET_LOCKED** | `hack` / `infil` starts puzzle | Submit or TTL expiry |
| **PUZZLE_ACTIVE** | Puzzle prompt + timer | Correct answer, wrong answer, or timeout |
| **SUCCESS** | `TrySubmit` true | Clear puzzle → LOG module |
| **FAIL** | Wrong answer (retry) or `IsExpired` | Clear puzzle → LOG module |
| **COOLDOWN** | — | Phase 2 (Opus) — not wired Phase 1 |

Phase 1: success/fail messaging only — **no wallet or treasury movement**.

---

## Per-module notes

### LOG (default after boot)

- Scrollback of commands + system lines.
- Boot sequence (~8 lines): LIFEPUNCH banner → program load → module list → `Type help or use the rail.`
- `clear` wipes scrollback only.

### SCAN

- Columns: SteamID · display name · wallet cash (server list).
- Click row → sets `_selectedTargetId`.
- **START HACK** button → `hack <steamid>`.

### GOVDB (advanced only)

- Columns: node id · label · security tier (`CLASSIFIED` / `RESTRICTED` / `ELEVATED`).
- **START INFIL** → `infil <nodeid>` → `GovDbBypass` puzzle.

### TARGET

- Shows active puzzle prompt + TTL countdown in status.
- All input routes to `HandlePuzzleInput` while `_puzzle != null`.
- Submit fires host RPC (`RequestSubmitWalletHack` / `RequestSubmitGovdbInfil`) — Phase 2 validates on host.

### HELP

- Static command reference (no economy knobs).

---

## Commands (`rig0>` equivalent: bottom TextEntry)

| Command | Tier | Module | Server RPC |
|---------|------|--------|------------|
| `help` | both | HELP | — |
| `scan` | both | SCAN | `HackerScanService.RequestScan` |
| `hack <steamid>` | both | TARGET | puzzle + `SubmitWalletHackHost` |
| `govdb` | advanced | GOVDB | `HackerScanService.RequestGovDbScan` |
| `infil <nodeid>` | advanced | TARGET | puzzle + `SubmitGovdbInfilHost` |
| `info` | both | LOG | — |
| `status` | both | LOG | — |
| `clear` | both | LOG | — |
| `about` | both | LOG | `HackerTerminalBrand.AboutLines` |

**World commands** (`HackerCommandHost`): `cornerman`, `hack` (open UI), `cornerman close`, `lp_spawn_hacker_terminal`, `lp_cornerman_ui`, `lp_vengeance_ui`.

---

## Economy (proposed — Phase 2 Opus)

| Knob | Value / rule |
|------|----------------|
| Wallet-only | `HackerJob.BankUntouchable = true` |
| Steal cap | TBD — flat vs % of wallet (`HACKER_JOB_SPEC` §5) |
| Cooldown | TBD — per-hacker + per-target |
| Job gate | Hacker job only — stub in entity host RPC |
| Puzzle validation | Host re-validates kind + answer + elapsed ≤ limit |
| Audit | Every transfer logged — `AUDIT_LOG_REFERENCE.md` |

---

## Shared vs separate terminal families

| Shared pattern | Hacker-only |
|----------------|-------------|
| Ops Console rail + modules + command line | SCAN / GOVDB / wallet puzzles |
| LIFEPUNCH proprietary About | `cornerman.exe` / `vengeance.exe` fiction |
| Keyboard `.sound` on typing | Green/red SCSS tokens |
| Host RPC submit shape | Govdb infiltration tier |

---

## Open answers (`HACKER_JOB_SPEC` §5)

1. **Scan scope:** server-wide live roster Phase 1; range/job filters Phase 2.  
2. **Puzzle MVP:** four kinds in `TERMINAL_PUZZLE_CATALOG.md`.  
3. **Steal formula:** Opus + owner sign-off.  
4. **Counterplay:** police lifepunchnet cyan terminals (advanced About line).  
5. **Placement:** map entities + dev spawn commands; count TBD.
