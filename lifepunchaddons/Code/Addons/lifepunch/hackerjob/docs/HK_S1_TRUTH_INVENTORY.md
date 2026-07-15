# HK-S1 — Hacker Job brownfield truth inventory

**Issue:** #151 · **Verified:** 2026-07-15 against the assigned worktree at `1e6bd4da` before edits  
**Scope:** Existing `hackerjob` code and docs only. No runtime, visual, or portal-deployment claim is made.

## Executive truth

- This is a real Phase-1 brownfield addon: 21 C# files and two Razor components, not an empty lane.
- No source class is docs-only. Planned capabilities without a complete implementation are identified below as **Stubbed**.
- DXRP money movement remains absent. `HackerEconomySecurity` returns `AcceptedNoTransfer` for wallet and govdb success (`HackerEconomySecurity.cs:96-125`), and the only `ChargeHost` / `PayHost` references in this tree are comments or docs.
- HK-S1 closes two unsafe defaults: DXRP terminal access now denies until R3 supplies a T2 job identity (`HackerTerminalSession.cs:61-77`), and paid rack INSTALL requests cannot change a tier until HK-S4 supplies a successful host debit (`HackerServerRackEntity.cs:407-420`). `LIFEPUNCH_LOCAL` remains a no-economy editor smoke path.

## Class and component census

State means **Built** (implemented Phase-1 behavior), **Stubbed** (safe shell, preview, or incomplete contract), or **Docs-only** (no class). “Built + stubbed seam” is classified as Stubbed so incomplete behavior is not overstated.

| Class / component | State | Machine-verified role and boundary |
|---|---|---|
| `HackerJob` | Built | Package constants and bank-untouchable law (`HackerJob.cs:20-69`); package ident drifts from portal config. |
| `HackerTerminalTier` | Built | Standard/Advanced hardware enum (`HackerTerminalTier.cs:17-23`). |
| `HackerTerminalBrand` | Built | Tier-specific labels, prompts, cards, and About copy (`HackerTerminalBrand.cs:18-99`). |
| `HackerTerminalRange` | Built | Delegates shared menu open/close range checks (`HackerTerminalRange.cs:19-25`). |
| `HackerTerminalHost` | Built | Mounts/closes the dedicated screen panel and controls camera lock (`HackerTerminalHost.cs:24-105`). |
| `HackerTerminalSession` | Stubbed | Login/power checks are built (`HackerTerminalSession.cs:24-58`); DXRP job gate is deliberately fail-closed pending R3/T2 (`:61-77`). |
| `HackerTerminalEntity` | Stubbed | World USE, rack power, RPC submit, and failure-alert seams exist (`HackerTerminalEntity.cs:28-184`); economy behind submits remains disabled. |
| `HackerTerminal` (`.razor`) | Stubbed | Built `PanelComponent` shell (`HackerTerminal.razor:19-23`) with client puzzle UX; success copy explicitly says govdb/wallet economy is Phase 2 (`:672-678`). |
| `HackerPuzzleSession` / `PuzzleKind` | Stubbed | Timed client puzzle model is built (`HackerPuzzleSession.cs:22-91`); host-issued session identity is absent (`:17-20`). |
| `HackerScanService` / target records | Stubbed | Records and wallet/HASHD scans exist (`HackerScanService.cs:27-39`, `:73-138`); govdb scan is a TODO stub (`:43-52`). |
| `HackerEconomySecurity` / `HackAttemptResult` | Stubbed | Host puzzle validation is built (`HackerEconomySecurity.cs:25-70`); wallet/govdb paths accept without transfer (`:72-159`). |
| `HackerCounterplayService` | Stubbed | DXRP panic broadcast is built (`HackerCounterplayService.cs:24-44`); Wanted integration remains Phase 2 (`:42`). |
| `HackerHackTargetPolicy` / `HackerHackTarget` | Built | Tier-to-target policy only (`HackerHackTargetPolicy.cs:14-47`); it does not itself implement theft. |
| `HackerRackTier` | Built | Basic/Advanced rack enum (`HackerRackTier.cs:15-18`). |
| `HackerUpgradeCatalog` / `HackerUpgradeKind` | Stubbed | Tier caps, effects, prices, and labels exist (`HackerUpgradeCatalog.cs:19-126`), but values are hardcoded and Advanced Detection/Puzzle max at 5 (`:26-29`) while cost tables stop at tier 4 (`:95-104`). |
| `HackerServerRackAccessPin` | Built | PIN validation and host-only hash helper (`HackerServerRackAccessPin.cs:19-45`). |
| `HackerServerRackRegistry` | Built | Explicit rack/terminal linking and power lookup (`HackerServerRackRegistry.cs:22-126`). |
| `HackerServerRackEntity` | Stubbed | Power, PIN, link, and tier state exist (`HackerServerRackEntity.cs:28-50`); paid INSTALL is fail-closed until HK-S4 (`:397-420`). |
| `HackerAdvancedServerRackEntity` | Built | Sets the inherited rack to Advanced (`HackerAdvancedServerRackEntity.cs:23-32`). |
| `HackerServerRackMenuHost` | Built | Mount/close helper plus local wallet preview (`HackerServerRackMenuHost.cs:21-88`). Preview is not payment. |
| `HackerServerRackMenu` (`.razor`) | Stubbed | Built rack/PIN/upgrade UI shell (`HackerServerRackMenu.razor:18-22`); affordability and INSTALL are previews (`:646-687`), not a debit. |
| `HackerCommandHost` | Built | Local-only terminal login command and nearest-powered-terminal lookup (`HackerCommandHost.cs:43-195`). |
| `HackerDevSpawn` | Built | Dev/editor UI, prefab spawn, kit, and cleanup commands (`HackerDevSpawn.cs:24-148`, `:225-401`). Excluded from publish by its own declaration (`:21-24`). |

There are **zero docs-only class declarations** in the hackerjob source tree. The missing docs-only/content surface is the Advanced Hacker Terminal portal row: `addons.json` contains rack, advanced rack, and standard terminal rows only (`config/addons.json:110-144`), matching TECH_DEBT HACKER-03 (`docs/TECH_DEBT.md:37-40`).

## Complete TODO / Phase-2 marker ledger

The following is every literal `TODO` or `Phase 2` marker under `Code/Addons/lifepunch/hackerjob/` after the HK-S1 closures:

| File | Lines | Marker truth |
|---|---:|---|
| `HackerTerminalEntity.cs` | 23 | Entity is a Phase-1 shell; economy/puzzle completion remains Phase 2. |
| `HackerPuzzleSession.cs` | 20 | Host-issued puzzle session id remains Phase 2 / HACKER-02. |
| `HackerScanService.cs` | 25, 51 | Host-owned scan roster and real govdb enumeration remain Phase 2; line 51 is the only remaining literal source `TODO`. |
| `HackerCounterplayService.cs` | 42 | Wanted status remains Phase 2; DXRP panic is already built. |
| `HackerEconomySecurity.cs` | 22, 27-28, 88, 96, 98, 124-125 | Job/proximity/cooldown/audit, money transfer, and govdb payout remain disabled Phase-2 seams. |
| `HackerTerminal.razor` | 673, 678 | UI reports govdb and wallet economy as Phase 2. |
| `docs/TERMINAL_SESSION_DOCTRINE.md` | 37, 58 | Host job/session/proximity validation is deferred. |
| `docs/SECURITY.md` | 3, 14-17, 32, 38-47 | Threat table and swap-point declarations defer host scan/session/job/govdb/debit work. |
| `docs/HACKER_TERMINAL_BUILD.md` | 24, 50, 56 | Phase-2 security checklist/sign-off gate. |
| `docs/HACKER_SERVER_RACK_SPEC.md` | 39, 51, 81-83 | Wanted, payout multipliers, and wallet charge are Phase 2. |
| `docs/HACKER_PHASE2_ECONOMY_PREP.md` | 1, 18-29, 36 | Full no-transfer checklist, including rack debit, cooldowns, audit, and caller-only result. |

Other explicit stub labels that do not contain the words “TODO” or “Phase 2” remain at `docs/HACKER_JOB_PLAYTEST.md:40-76`, `HackerScanService.cs:37-52`, `HackerCounterplayService.cs:46-47`, and `HackerEconomySecurity.cs:97-157`.

## Doc-versus-code drift

1. `CYBER_JOBS_POLISH_CHECKLIST.md:20,34` says Hacker is blocked and both rack/terminal are “Not started,” while its own rows describe existing classes (`:119-160`) and the census above confirms Phase-1 code. Treat the checklist completion boxes as **unproven play/sign-off status**, not source absence.
2. The same checklist permits advanced Hacker “bank” targets (`CYBER_JOBS_POLISH_CHECKLIST.md:70-77`), but hard Rail 3 says player attacks touch wallet only and bank is never at risk (`CYBER_ECONOMY_RAILS.md:51-61`). The rail wins.
3. `HACKER_JOB_SPEC.md:3-4,94-98` accurately says Phase-1 shell/puzzles exist and money is not implemented.

## R3 proposal — T2 job row plus gate

**PROPOSAL ONLY; Bloodwave rules R3. Current behavior stays fail-closed.**

The current T2 snapshot has `jobs[]` (`lifepunch/docs/server-setup/config/GAMEMODE_CONFIG_T2_2026-07-12.json:1923`) but no Hacker name or tag anywhere in that file. Proposed dependency:

1. Add a dedicated Hacker row with a stable Bloodwave-selected UUID, localized Hacker name/description, criminal job group, and a `"hacker"` job tag. Selectability, vote, salary, max-count, clothes, and equipment remain explicit owner balance decisions.
2. After that row exists, define its UUID once in hackerjob config and resolve the DXRP job object by stable id. The implementation shape is:

```csharp
var hackerJob = GameModeJobs.All.FirstOrDefault( job => job.Id == HackerT2JobId );
return hackerJob is not null && Player.Local.Job == hackerJob;
```

The exact `GameModeJob` id member/type must be verified against the live DXRP API before implementation. Do not fall back to display-name matching. Advanced terminal authorization is a separate tier/role ruling and must not be inferred from the base Hacker row.

## R2 recommendation — package ident drift

**PROPOSAL ONLY; Bloodwave rules R2.**

- Code declares `lifepunch.hackerjob` (`HackerJob.cs:22`, including source headers/footer).
- Portal/package sources declare `lifepunch.hacker` (`config/addons.json:98-106`; `config/packages.json:31-35`).
- Recommend **`lifepunch.hacker` as the canonical s&box identifier** because it is already the portal-facing package identity. Keep `hackerjob` as the legacy `repoIdent`/folder name. If R2 accepts, perform a separately reviewed mechanical migration of the code constant, source proprietary headers, and UI footer; do not mix that broad rename into HK-S1.

## HK-S1 fail-close behavior

- **Job gate:** local editor smoke remains available; non-local DXRP users are denied with `hacker job unavailable — T2 job row not configured` until R3 lands (`HackerTerminalSession.cs:61-77`).
- **Rack INSTALL:** local editor smoke may advance tiers without money; non-local paid INSTALL never advances because HK-S1 has no successful-payment evidence and is forbidden to add wallet mutation. HK-S4 may replace the deny only with an atomic host debit followed by tier advancement (`HackerServerRackEntity.cs:407-420`).
- No lpbitcoin, Player Hub, Razor, SCSS, model, sound, or wallet-mutation file was changed.
