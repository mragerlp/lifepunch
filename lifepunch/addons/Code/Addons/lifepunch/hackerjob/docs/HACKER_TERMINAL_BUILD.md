# Hacker Terminal — Build Checklist

**Red runbook (VENGEANCE):** `addons/docs/RED_HACKER_JOB_BUILD.md`

Two tiers per `TERMINAL_BRAND_MATRIX.md`. **Ops Console** layout (960×640, session rail + LOG/SCAN/GOVDB/TARGET/HELP modules) — distinct from amber HASHD rig and cyan lifepunchnet police shell. See `addons/docs/HACKER_OPS_CONSOLE_SPEC.md`.

## Tiers

| Tier | Program | Dev UI | Commands |
|------|---------|--------|----------|
| Standard | `cornerman.exe` | `lp_cornerman_ui` | `scan`, `hack` |
| Advanced | `vengeance.exe` | `lp_vengeance_ui` | + `govdb`, `infil` |

## Phase 1 — Done on Green

| File | Status |
|------|--------|
| `HackerTerminalTier.cs` / `HackerTerminalBrand.cs` | Done |
| `HackerTerminal.razor` + `.scss` | Polished — scanlines, tier colors, TTL countdown |
| `HackerScanService.cs` | Wallet + govdb stubs |
| `HackerPuzzleSession.cs` | Wallet + govdb bypass puzzles |
| `HackerDevSpawn.cs` | `lp_cornerman_ui`, `lp_vengeance_ui` |
| `HackerEconomySecurity.cs` | Host validation seam — Phase 1 no transfer |
| `docs/SECURITY.md` | Threat model + Phase 2 Opus checklist |

## Editor smoke test (use bots)

Spawn targets first — **`HACKER_JOB_PLAYTEST.md`**:

```text
lifepunch_spawn_testbot Greg
lp_cornerman_ui
scan
hack <steamid from scan output>
```

**Advanced (red):**

```text
lp_vengeance_ui
govdb
infil govdb-tax-01
govdb_breach
```

## Phase 2 — Red / Opus

- [ ] CRT models: `hacker-terminal` + `advanced-hacker-terminal` (`Seed-HackerTerminalCrt.ps1` + ModelDoc)
- [ ] Entity prefabs: `ENTITY_PREFAB_BUILD.md` · `lp_spawn_hacker_terminal` · `lp_spawn_advanced_hacker_terminal`
- [ ] Job gate, live scan, server-validated puzzles, wallet transfer
- [ ] Protection audit green — `briefs/HACKER_JOB_PROTECTION_CHECKLIST.md`
- [ ] Phase 2 Opus sign-off — `docs/SECURITY.md` checklist complete before publish
- [ ] Govdb breach hooks into `governmentdatacenter` tax miners
- [ ] Police counterplay via `police-terminal` (lifepunchnet cyan)

## Related

- `addons/docs/GOVERNMENT_DATABASE_SPEC.md`
- `governmentdatacenter/docs/GOVERNMENT_TAX_MINER_BUILD.md`
