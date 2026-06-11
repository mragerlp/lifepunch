# Hacker Job — Phase 2 economy prep (no transfer yet)

**Status:** Skeleton comments only · **blocked on owner post-legal sign-off**  
**Implementation tier:** Opus / Tier-1 before publish  
**Canon:** `HackerJob.BankUntouchable` — wallet cash only

---

## Single swap point

`HackerEconomySecurity.cs` — all money-moving and host-authoritative scan/puzzle session logic lands here.

Phase 1 paths call `ValidatePuzzleOnHost` and return `AcceptedNoTransfer` always.

---

## Checklist (enable only after sign-off)

- [ ] `IsHackerJobHost( Player hacker )` — DXRP job gate
- [ ] `ValidateTerminalProximityHost( terminal, hacker )` — distance + LOS to linked rack
- [ ] `IssuePuzzleSessionHost` — host-issued id on `hack` / `infil` start
- [ ] `BuildScanTargetsHost` — players + map `GovernmentTaxMinerEntity` (requires `governmentdatacenter` compile)
- [ ] `ProcessWalletTransferHost` — `min(requested, target.WalletBalance)`; never bank
- [ ] `ProcessRackUpgradeChargeHost` — rack menu INSTALL debits installer wallet
- [ ] Per-hacker + per-target cooldowns; daily steal cap
- [ ] Audit log per attempt — `AUDIT_LOG_REFERENCE.md`
- [ ] Rpc result to caller only — UI success/fail from host (closes HACKER-01)

---

## Rack upgrade economy (advanced tier)

Advanced rack (`HackerRackTier.Advanced`) uses higher max tiers from `HackerUpgradeCatalog`.  
Phase 2 may apply **3-point install cost** per advanced skill step — constants TBD in catalog when economy ships.

---

## Related

- `docs/SECURITY.md` — threat model
- `HackerServerRackMenu.razor` — INSTALL buttons (affordability check is client preview today)
- `governmentdatacenter` intake — `Intake-GovernmentTerminal.ps1` unblocks real govdb scan targets
