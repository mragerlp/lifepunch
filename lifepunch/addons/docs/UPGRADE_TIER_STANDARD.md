# LIFEPUNCH upgrade tier standard (ecosystem)

Applies across hacker, bitcoin, and government addons unless a job brief overrides.

---

## Basic hardware

| Property | Value |
|----------|-------|
| Skill slots | **3** |
| Points per skill | **1** (pick one branch per slot or linear — TBD per entity) |
| Terminal upgrades | **None** — ON/OFF only |
| Server / hub upgrades | ON/OFF + 3 basic skills |

**Examples:** standard hacker server rack, standard terminal power gate.

---

## Advanced hardware

| Property | Value |
|----------|-------|
| Skill slots | **4–5** |
| Points per skill | **3** |
| Terminal | Intrusion / ops UI — upgrades live on **advanced server** |

**Examples:** hacker Detection/Puzzle/Reward/Cooldown (5×3 on rack).

---

## Money-farming jobs (bitcoin-miner)

| Property | Value |
|----------|-------|
| More tiers | CPU (7), Cores (3), encryption (3×5 tracks), RGB, etc. |
| Impact per tier | Lower than action jobs — scalability over spike power |

---

## Action jobs (hacker / gov)

| Property | Value |
|----------|-------|
| Fewer tiers | 3×1 or 5×3 |
| Impact per tier | **Higher** — each point should be felt in RP |

---

## Auth pattern (all spend/power actions)

1. Type command at prompt (`upgrade cpu`, `power on`, `encrypt firewall`)
2. Click **INSTALL** / **START** / **POWER ON** to confirm
3. Host charges wallet / applies tier

Prevents misclick steals and supports RP "authentication."

---

## Implementation

Data-driven catalogs (pattern: `HackerUpgradeCatalog.cs`, future `BitcoinMinerEncryptionCatalog.cs`).
