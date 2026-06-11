# Hacker Job — Protection & security checklist

**Status:** 🟡 Living doc — **Green audits** · **Red/Opus ships** fixes  
**Scope:** Trademark/source identity + economy security for `hackerjob` (flagship asset)  
**Security detail:** `hackerjob/docs/SECURITY.md`

---

## 1. In-product source identity (trademark)

```powershell
rg -i "spl mute|evo|BitOS|credits" lifepunch/addons/Code/Addons/lifepunch/hackerjob
rg -i "spl mute|evo" lifepunch/addons/Assets/addons/lifepunch/hackerjob
```

| Check | Pass criteria | Status | Notes |
|-------|---------------|--------|-------|
| About command | `HackerTerminalBrand.AboutLines` — LIFEPUNCH™ + lifepunch.co | ☐ | Red shipped 2026-06 |
| Title bar | `LIFEPUNCH cornerman.exe` / `vengeance.exe` | ☐ | |
| In-world LCD | `LIFEPUNCH` prefix on standby text | ☐ | `HackerTerminalEntity` |
| Fiction disclaimer | cornerman/vengeance = in-world only | ☐ | About + brand doc |
| No third-party credits in UI | Study refs in docs/`reference/` only | ☐ | |
| Portal / `addons.json` | "Published by LIFEPUNCH" lead naming | ☐ | |
| Use `™` not `®` | Pending USPTO registration | ☐ | |

---

## 2. Proprietary headers & package metadata

```powershell
cd lifepunch/addons/scripts
.\validate-headers.ps1
```

| Check | Pass criteria | Status |
|-------|---------------|--------|
| All `.cs` / `.razor` / `.scss` in `hackerjob/` | Canonical proprietary block | ☐ |
| `addons.json` ownership wording | No resale/redistribution | ☐ |
| `sboxIdentifier` | `lifepunch.hackerjob` | ☐ |

---

## 3. Economy security (anti-exploit)

| Check | Pass criteria | Status | Owner |
|-------|---------------|--------|-------|
| Hack submit uses `[Rpc.Host]` | `SubmitWalletHackHost` / `SubmitGovdbInfilHost` | ☐ | Red |
| Host re-validates puzzle | `HackerEconomySecurity.ValidatePuzzleOnHost` | ☐ | Red |
| Phase 1: no funds moved | `FundsMoved == false` always | ☐ | Red |
| Bank never touched | `HackerJob.BankUntouchable` + Phase 2 code review | ☐ | Opus |
| Self-hack denied | `hacker.SteamId == target` rejected | ☐ | Red |
| Scan host-authoritative | Phase 2 `[Rpc.Host]` scan | ☐ | Opus |
| Host-issued puzzle session | Closes HACKER-02 | ☐ | Opus |
| UI success from host RPC only | Closes HACKER-01 | ☐ | Opus |
| Job + distance gate on open + hack | Phase 2 | ☐ | Opus |
| Cooldowns + steal caps | Phase 2 | ☐ | Opus |
| Audit log per transfer | Phase 2 | ☐ | Opus |

---

## 4. Brand separation (clone resistance)

| Terminal | Must stay distinct |
|----------|-------------------|
| Hacker green `#00FF7F` | ≠ HASHD amber bitminer |
| Hacker red `#E4002B` | ≠ VENGEANCE machine fiction only in advanced tier |
| Ops console layout | Shared *shape* with police cyan — different program/commands |

See `TERMINAL_BRAND_MATRIX.md` · `HACKER_OPS_CONSOLE_SPEC.md`.

---

## 5. Publish tree hygiene

| Check | Pass criteria | Status |
|-------|---------------|--------|
| No `reference/` assets in ship tree | Self-authored CRT + sounds | ☐ |
| No Facepunch cloud model paths | Self-contained prefabs | ☐ |
| Compiled `_c` in publish staging | Dedicated server parity | ☐ |

---

## 6. Pre-publish gate (Red + Opus)

Run in order:

1. `validate-headers.ps1`
2. `validate-layout.ps1` (when assets land)
3. Complete §3 economy rows (Phase 2)
4. `prepare-publish.ps1 -Addon hackerjob`
5. Portal listing shows **Published by LIFEPUNCH**

---

## 7. Cornerman outbox

`C:\lifepunch\cornerman\outbox\HACKER_JOB_PROTECTION_AUDIT.md` — grep evidence + open items for Red.

**Parallel:** `BITMINER_PROTECTION_CHECKLIST.md` (amber HASHD — separate addon).
