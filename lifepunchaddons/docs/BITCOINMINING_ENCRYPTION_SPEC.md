# Bitcoin Miner hub — encryption upgrades (defense)

**Entity:** `bitcoin-miner` hub · **UI:** hashd upgrade section (new tab/section — same INSTALL row style)  
**Pairs with:** `hackerjob` server-rack offense + vengeance miner intrusion

---

## Tracks (5 skills × 3 points max — advanced money-job scaling)

| Track | Max tier | Effect per tier (proposed) |
|-------|----------|----------------------------|
| **Firewall** | 3 | +10% failed intrusion roll for attackers |
| **Wallet Cipher** | 3 | −5% max stealable BTC/cash per successful hack |
| **Intrusion Alert** | 3 | +15% chance owner/police notified on attempt |
| **Re-hack Cooldown** | 3 | +30s before same attacker can retry this hub |
| **Puzzle Hardening** | 3 | −4s attacker puzzle TTL (stacks vs hacker Puzzle Time) |

Tier 0 = stock (no encryption). Costs TBD — Cornerman distill → Red balance pass.

---

## Host resolution (Phase 2)

```text
attackerSuccessChance = base × (1 - firewallBonus) × hackerRewardTier
stealCap              = min(targetBalance, baseSteal × (1 - cipherBonus))
attackerPuzzleSeconds = basePuzzle + hackerPuzzleBonus - hardeningBonus
alertRoll             = intrusionAlertChance vs hacker Detection suppress
```

Wallet hack band (criminal): **$1,000–$2,500** base before upgrades.

---

## UI

Same as CPU/Cores panel:

```text
ENCRYPTION
  FIREWALL (L1/3)     [ INSTALL $X ]
  WALLET CIPHER (L1/3) ...
```

**Auth:** type `upgrade encryption` or `encrypt firewall` → click INSTALL.

---

## RGB Fans tie-in (optional)

Purchasing **RGB Fans** on a rack can require **Firewall L1** on hub — cosmetic reward for first encryption tier.

---

## Related

- `hackerjob/docs/HACKER_SERVER_RACK_SPEC.md` (offense mirror)
- `LIFEPUNCH_CYBER_ECOSYSTEM.md`
