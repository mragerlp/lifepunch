# Cornerman task — Hacker Job terminal (Phase 1 shell)

**Lane:** Cornerman (Green) → patch handoff → VENGEANCE integrates  
**Model routing:** Economy + wallet transfer = **Opus / Tier-1** on Red. Green ships **UI shell + puzzle framework stubs only**.  
**Issued:** 2026-06-11  
**Status:** Green handoff **complete** — `origin/main` `ba8de9c` (Ops Console on Red).  
**Owner directive:** Bitcoin Miner terminal looks good — Hacker Job needs the same depth (real terminal, puzzles, cool ops). Work from `HACKER_JOB_SPEC.md`; government database (cyan lifepunchnet) is a separate lane.

---

## Goal

Ship a **playable cornerman.exe / vengeance.exe Ops Console** for the Hacker Job (`HACKER_OPS_CONSOLE_SPEC.md`):

1. 960×640 session rail + LOG / SCAN / GOVDB / TARGET / HELP modules (green / red — not amber hashd, not cyan police)
2. `scan` → target table (stub in local; live in Phase 2)
3. `hack <steamid>` / `infil <nodeid>` → time-boxed coding puzzle
4. Success/fail messaging — **no wallet movement** until Opus signs off Phase 2

---

## Commands (mirror Bitcoin Miner pattern)

| Command | Action |
|---------|--------|
| `cornerman` | Open terminal on nearest entity (6m / 3m vertical) |
| `hack` | Alias of `cornerman` |
| `cornerman close` | Close UI |
| `lp_spawn_hacker_terminal` | Dev spawn prefab in front of viewer |

In-terminal: `help`, `scan`, `hack <id>`, `status`, `clear`, `about`

---

## Puzzle kinds (Phase 1 — client display only)

| Kind | Example |
|------|---------|
| `CompleteTheLine` | Fill in `drain(wallet);` |
| `TypeSequence` | Type `cornerman_bypass` under 30s |
| `PickFix` | Pick valid packet header `1` |

Phase 2: server generates token + validates submit; client never moves money.

---

## Files (ship tree)

```text
lifepunchaddons/Code/Addons/lifepunch/hackerjob/
  HackerJob.cs
  HackerTerminalEntity.cs
  HackerTerminalHost.cs
  HackerCommandHost.cs
  HackerTerminal.razor + .razor.scss
  HackerScanService.cs
  HackerPuzzleSession.cs
  HackerDevSpawn.cs
  docs/HACKER_TERMINAL_BUILD.md
```

---

## Red lane (after Green handoff)

1. Opus review dual-build + RPC surface
2. ModelDoc CRT mesh + `hacker-terminal.prefab`
3. Wire live player scan + economy (wallet-only rule)
4. Align skin with owner tabbed UI from `hackerterminal` intake folder when ready
5. Government Database — separate spec (`GOVERNMENT_DATABASE_SPEC.md`)

---

## Validation

```powershell
powershell -File lifepunchaddons/scripts/validate-layout.ps1
powershell -File lifepunchaddons/scripts/validate-headers.ps1
```

**Deliverable commits:**  
- `feat(hackerjob): cornerman.exe terminal shell with scan and puzzle stubs (Phase 1)`  
- `feat(hackerjob): ops console UI with session rail and module panes` (`ba8de9c` on `origin/main`)
