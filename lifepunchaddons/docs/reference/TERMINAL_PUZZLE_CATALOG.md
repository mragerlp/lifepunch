# Terminal puzzle catalog

**Purpose:** Server-validated mini-games for Hacker Job wallet drain and govdb infiltration.  
**Rule:** Client displays fiction; host holds puzzle kind + answer + expiry (Phase 2 issues session tokens — `TECH_DEBT` HACKER-02).

**Implementation:** `HackerPuzzleSession.cs` · Submit RPC: `HackerTerminalEntity` → `HackerEconomySecurity` (Phase 2 host).

---

## MVP set (shipped Phase 1)

| id | kind | difficulty | time | tier |
|----|------|------------|------|------|
| `wallet-complete-line` | `CompleteTheLine` | 2 | 45s | standard |
| `wallet-type-sequence` | `TypeSequence` | 1 | 30s | standard |
| `wallet-pick-header` | `PickFix` | 2 | 35s | standard |
| `govdb-breach-token` | `GovDbBypass` | 3 | 40s | advanced |

Standard terminals randomize among the first three (`Random.Shared.Int(0,2)`). Advanced `infil` always uses `GovDbBypass`.

---

## Normalization rules (all puzzles)

```text
input = clientText?.Trim()
match = string.Equals(input, serverAnswer, OrdinalIgnoreCase)
reject if elapsed >= timeLimitSeconds
```

No collapse-spaces rule in Phase 1 — exact trim + case-insensitive equality.

---

## `wallet-complete-line`

- **Kind:** `CompleteTheLine`
- **Prompt:**
  ```text
  Complete the bypass line:
    if (wallet.balance > 0) { __________ }
  ```
- **Input:** TextEntry at command prompt
- **Solution (server):** `drain(wallet);`
- **Success line:** `BYPASS OK — host validated (Phase 1 stub; no funds moved).`
- **Fail line:** `DENIED — {N}s remaining.` or `ERROR: too slow — connection dropped.`
- **Validation (host pseudocode):**
  ```csharp
  bool ok = kind == CompleteTheLine
      && elapsed <= timeLimit
      && string.Equals(answer.Trim(), "drain(wallet);", OrdinalIgnoreCase);
  // Phase 2: compare to server-issued token, not static string
  ```

---

## `wallet-type-sequence`

- **Kind:** `TypeSequence`
- **Prompt:** `Type the exploit token within 30s:`
- **Input:** TextEntry
- **Solution:** `cornerman_bypass`
- **Success / fail:** same as above
- **Validation:**
  ```csharp
  bool ok = kind == TypeSequence
      && elapsed <= 30f
      && string.Equals(answer.Trim(), "cornerman_bypass", OrdinalIgnoreCase);
  ```

---

## `wallet-pick-header`

- **Kind:** `PickFix`
- **Prompt:**
  ```text
  Pick the valid packet header (type the number):
    1) CORNERMAN/1.0 OK
    2) DXRP/HACK FREE
    3) WALLET/OPEN ALL
  ```
- **Input:** TextEntry — user types `1`
- **Solution:** `1`
- **Notes:** Option 2 uses DXRP nominatively as **decoy fiction**, not affiliation claim.
- **Validation:**
  ```csharp
  bool ok = kind == PickFix
      && elapsed <= 35f
      && string.Equals(answer.Trim(), "1", OrdinalIgnoreCase);
  ```

---

## `govdb-breach-token`

- **Kind:** `GovDbBypass`
- **Prompt:** `Bypass treasury firewall — type the intrusion token:`
- **Input:** TextEntry
- **Solution:** `govdb_breach`
- **Tier:** Advanced terminal only (`infil` flow)
- **Success line:** `BYPASS OK — host validated (Phase 1 stub; no records exfiltrated).`
- **Validation:**
  ```csharp
  bool ok = kind == GovDbBypass
      && terminal.Tier == Advanced
      && elapsed <= 40f
      && string.Equals(answer.Trim(), "govdb_breach", OrdinalIgnoreCase);
  ```

---

## Phase 2 additions (proposed)

| id | type | notes |
|----|------|-------|
| `pipe-grep-log` | command | `grep WALLET access.log \| head -1` — normalize collapse spaces |
| `hex-decode` | decode | short hex → ASCII token |
| `syntax-fix-2` | syntax | fix `if (!auth) bypass();` missing brace |

Cornerman catalogs only until Opus signs host token generation.

---

## Worked validation flow (wallet hack)

```text
1. Client: scan → hack <steamid> → puzzle displayed
2. Client: user submits → RequestSubmitWalletHack(steamId, kind, answer, elapsed, limit)
3. Host:   GameUtils.HasPermission(caller, terminal)
4. Host:   job gate (Phase 2)
5. Host:   distance / LOS (Phase 2)
6. Host:   HackerEconomySecurity.ValidatePuzzleOnHost(...)
7. Host:   if ok → debit wallet / credit hacker (Phase 2) else audit fail
8. Client: TrySubmit for immediate UX; host is authoritative for money
```
