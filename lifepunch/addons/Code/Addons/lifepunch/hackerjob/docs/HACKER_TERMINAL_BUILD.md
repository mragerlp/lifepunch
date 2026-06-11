# Hacker Terminal — Build Checklist

Queue priority after weapon smoke test. Shares **Cornerman green-on-black terminal skin** with Bitcoin Miner (`BITMINER_UX_SPEC.md`) but different program flow: `cornerman.exe` → scan → puzzle → wallet hack.

## Phase 1 — Terminal shell (Green, this commit)

| File | Status |
|------|--------|
| `HackerJob.cs` | Done — paths, commands, constants |
| `HackerTerminalEntity.cs` | Done — interact + RPC open |
| `HackerTerminalHost.cs` | Done — dual-build mount |
| `HackerCommandHost.cs` | Done — `cornerman` / `hack` |
| `HackerTerminal.razor` + `.scss` | Done — boot, scan, hack, puzzles |
| `HackerScanService.cs` | Stub targets (local); live list Phase 2 |
| `HackerPuzzleSession.cs` | 3 puzzle kinds, time-boxed |
| `HackerDevSpawn.cs` | `lp_spawn_hacker_terminal` |

**No economy transfer in Phase 1** — puzzle success prints stub only.

## Phase 2 — Economy + validation (Red / Opus)

- [ ] Job gate: only Hacker job can run `hack`
- [ ] Server scan: live players, exclude self/staff/down
- [ ] Server-validated puzzle tokens (client never asserts success)
- [ ] Wallet debit/credit via DXRP `PayHost` / `ChargeHost` — **wallet only**
- [ ] Cooldowns, caps, audit log hook
- [ ] Counterplay (alert police / target notify) — TBD

## Phase 3 — Assets (Red)

- [ ] CRT model `hacker-terminal.vmdl` (owner sources retro screen mesh)
- [ ] `hacker-terminal.prefab` with `TextRenderer` + interaction
- [ ] Sounds under `sounds/hacker-terminal/`
- [ ] WorldPanel on monitor face (optional — Phase 1 uses screen overlay CLI)

## Editor smoke test

**Fast path (no prefab yet):**

```text
lp_cornerman_ui
scan
hack 76561198000000001
<type puzzle answer>
```

**Full path (after Red ships `hacker-terminal.prefab`):**

```text
lp_spawn_hacker_terminal
cornerman
scan
hack 76561198000000001
```

Pass: boot sequence, scan list, puzzle timer, bypass message (no money moved).

## Later — Government Database

See `addons/docs/GOVERNMENT_DATABASE_SPEC.md` (concept stub; after Hacker Job economy sign-off).
