# Hacker Job — Security architecture

**Status:** Phase 1 seams in place · Phase 2 economy = **Opus / Tier-1**  
**Canon spec:** `addons/docs/HACKER_JOB_SPEC.md` §2–3

---

## Threat model

| Asset | Risk | Mitigation |
|-------|------|------------|
| Player wallet cash | Client-forged hack success / inflated steal amount | Host-only validation + transfer in `HackerEconomySecurity` |
| Bank balance | Hacker drains protected savings | Hard rule `HackerJob.BankUntouchable` — wallet field only |
| Scan roster | Client invents targets or balances | Phase 2: `[Rpc.Host]` scan; client display only |
| Puzzle answers | Client skips puzzle or replays | Host re-validates via `ValidatePuzzleOnHost`; Phase 2 host-issued session id (HACKER-02) |
| Terminal access | Non-hackers / remote players open UI | `GameUtils.HasPermission` today; job + distance gate Phase 2 |
| Govdb infil | Advanced tier abused without map nodes | Host enumerates real `GovernmentTaxMinerEntity` instances Phase 2 |

---

## Phase 1 (current)

| Path | Behavior |
|------|----------|
| Open terminal | `[Rpc.Host]` `OpenTerminalHost` — permission check, broadcast to caller only |
| Puzzle submit | `[Rpc.Host]` `SubmitWalletHackHost` / `SubmitGovdbInfilHost` → `HackerEconomySecurity` |
| Money moved | **Never** — `FundsMoved` always false |
| Client UX | `TrySubmit` for responsive UI; host logs validation separately |

**Files:**

- `HackerEconomySecurity.cs` — single swap point for Phase 2 economy
- `HackerTerminalEntity.cs` — RPC entry points
- `HackerPuzzleSession.cs` — client display only

---

## Phase 2 prep (skeleton only — no transfer)

Economy method stubs and checklist live in `HACKER_PHASE2_ECONOMY_PREP.md`.  
`HackerEconomySecurity.cs` header comments mark the swap point — **do not** call `ChargeHost`/`PayHost` until owner post-legal sign-off.

Rack menu INSTALL buttons preview affordability client-side; host debit lands in `ProcessRackUpgradeChargeHost` (Phase 2).

---

## Phase 2 checklist (Opus — before publish)

- [ ] Job gate: only Hacker job can complete wallet hack RPC
- [ ] Distance / LOS from hacker to linked `HackerTerminalEntity`
- [ ] Host issues puzzle session id on `hack` / `infil` start (closes HACKER-02)
- [ ] Host builds scan list; client cannot add targets not returned by server
- [ ] Transfer: `min(requested, target.WalletBalance)`; debit wallet, credit hacker via DXRP APIs
- [ ] Per-hacker + per-target cooldowns; daily steal cap
- [ ] Audit log entry per attempt (success/fail) — `AUDIT_LOG_REFERENCE.md`
- [ ] Optional counterplay: target/police notification hook
- [ ] Rpc result broadcast to caller — UI success/fail from host only (closes HACKER-01)

---

## IP / source identity

Player-facing About copy: `HackerTerminalBrand.AboutLines` — **LIFEPUNCH™** publisher only.  
`cornerman.exe` / `vengeance.exe` are in-world fiction, not claims about real systems.

See `addons/docs/briefs/HACKER_JOB_PROTECTION_CHECKLIST.md`.
