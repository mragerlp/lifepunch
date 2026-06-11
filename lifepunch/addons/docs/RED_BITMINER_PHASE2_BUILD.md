# Red — Bitminer Phase 2 build runbook (VENGEANCE)

**Prerequisite:** Phase 1 HASHD shipped · protection fixes on `origin/main` (`cbeb481`+)  
**Canon:** `BITMINER_PHASE2_WIREFRAME.md` · `BITMINER_PHASE2_TOKENS.scss` · `BITMINER_UX_SPEC.md`

---

## Step 0 — Sync

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
git pull --rebase origin main
powershell -File lifepunch\addons\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
```

---

## Step 1 — Phase 2 module UI (~2–4h, Opus)

Refactor `BitminerTerminal.razor` / `.scss`:

1. Add `_activeModule` enum: `Dashboard | Wallet | Upgrades | Log | About`
2. Keep left **telemetry rail**; add **MODULES** nav (see wireframe)
3. Replace `_showUpgradeMenu` full-screen overlay → **Upgrades** module
4. Wire buttons to existing RPCs (no `BitminerEntity.cs` changes for menu-only pass):
   - `SetMiningState` · `RequestSellBitcoin` · `RequestUpgrade(Cpu|Cores)`
5. StaffMenu-style confirm modals for SELL ALL + INSTALL
6. Copy amber tokens from `BITMINER_PHASE2_TOKENS.scss` into `.razor.scss`
7. `menu` command → `SwitchModule(Dashboard)`

**Pass:** `hashd` → Dashboard shows cards; Wallet sells with confirm; Upgrades installs CPU; Log + `rig0>` still work; About = LIFEPUNCH™ only.

---

## Step 2 — Dual rack (after Step 1 or parallel ModelDoc)

**Spec:** `docs/reference/BITMINER_DUAL_RACK_SPEC.md`

1. ModelDoc `gpu-rack-stacked.vmdl` from `gpu-rack-stacked-anim.fbx`
2. Prefab child `gpu_rack_large` (offset TBD in editor)
3. Opus: `RackExpansionLevel`, `RackYield`, `BitminerUpgradeType.Rack`, `$250k` upgrade
4. Third row in **Upgrades** module + `upgrade rack` CLI

---

## Step 3 — Parallel blockers

| Blocker | Doc |
|---------|-----|
| CRT checkerboard | `cornerman/outbox/BITMINER_VMAT_AUDIT.md` |
| Small rack `power_on/off` | `TECH_DEBT` BITMINER-01 |
| Sounds | `sounds/bitcoin-miner/` |

---

## Step 4 — Playtest

```text
lp_spawn_bitminer
hashd
mining start
upgrade
bitcoin sell
about
```

See `bitcoinmining/docs/BITMINER_PLAYTEST.md`.

---

## Protection gate

Re-run `briefs/BITMINER_PROTECTION_CHECKLIST.md` grep before publish.
