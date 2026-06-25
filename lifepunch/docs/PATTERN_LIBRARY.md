# LIFEPUNCH™ — Pattern library (index)

> **Why does this exist?** Prevent one-off systems — every addon reuses solved patterns first.  
> **Status:** Living index — add patterns when signed off, not when brainstormed.  
> **Active** in this index means **approved design pattern** — not automatically flatgrass-proven, published, or shipped. Implementation proof is tracked separately.  
> **Law:** Reuse before invent (`LIFEPUNCH_GAMEPLAY_LAWS.md` G8).  
> **Terms:** `TERMINOLOGY.md` · **Cyber stack:** `addons/docs/LIFEPUNCH_CYBER_SYSTEM_PATTERN.md`

Every new addon **searches this index first**.

---

## Core patterns

| Pattern | Doc | Status | Used by |
|---------|-----|--------|---------|
| **Gameplay laws** | `lifepunch/docs/LIFEPUNCH_GAMEPLAY_LAWS.md` | **active** | All lanes |
| **Cyber system stack** | `addons/docs/LIFEPUNCH_CYBER_SYSTEM_PATTERN.md` | **active** | All cyber lanes |
| **Digital machine** | `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` | **active** | All entities |
| **Weapon platform** | `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` | **active** | lpweapons (parallel) |

---

## UI / interaction patterns

| Pattern | Canonical surface | Status | Clone target |
|---------|-------------------|--------|--------------|
| **Hub admin dashboard** | `LpHashdPanel` (amber ops) | **active** (bitcoin) | Banker vault, gov terminal |
| **CRT terminal** | `LpBitcoinTerminalPanel` + `lp-ops-crt--gray` | **active** (bitcoin) | Hacker green, gov cyan |
| **Hub pattern** | Hub USE → PIN → powered admin | **active** (bitcoin) | All controller entities |
| **Terminal pattern** | Linked CRT → rig0 commands | **active** (bitcoin) | All operator interfaces |
| **Worker pattern** | Placeable rack → link → mine → deposit | **active** (bitcoin) | Farm/scaling units |
| **Upgrade pattern** | Universal Upgrades home in LpHashdPanel (HUB · TERMINAL · GPU RACK sub-tabs per DECISION-0010) | **draft → active after owner review** | All cyber lanes (Bitcoin reference) |
| **Scroll region** | `LifePunchScrollRegionPanel` + `lp-ui-scroll-region` | **active** | Hub logs, CRT log |
| **Menu chrome** | `LpUiChrome.scss` · `LpUiMenuLayout.scss` | **active** | All Razor ops panels |

---

## Security & access patterns

| Pattern | Canonical surface | Status | Clone target |
|---------|-------------------|--------|--------------|
| **PIN** | Hub PIN gate before admin | **active** (bitcoin) | Secured vaults, gov terminals |
| **Authentication** | Session + owner gates | **active** | Admin menu, hub access |
| **Security / encryption** | Hub upgrade tracks (target) | **draft** | Hacker vs miner PvP |

---

## Economy patterns

| Pattern | Doc / surface | Status | Notes |
|---------|---------------|--------|-------|
| **Wallet** | Hub Wallet tab · deposited BTC | **active** (bitcoin) | Authoritative on hub |
| **Hub wallet cashout** | `BITCOINMINING_UX_SPEC.md` | **active** | BTC → DXRP bank |
| **Rack buffer → deposit** | `BITCOIN_DATA_FLOW.md` | **active design / partial implementation** | Local cap then deposit |
| **Portal BTC redeem** | `LpBitcoinIdent` portal item | **active** | Class 9 ship path |
| **Banking** | — | **future** | Quarantined `bankerjob` |
| **ATM** | — | **future** | Player-operated, not NPC |
| **Store** | DXRP shop (reference) | **external** | Do not fork without brief |
| **Inventory** | DXRP pocket | **external** | Reference only |

---

## Roleplay & world patterns (future)

| Pattern | Status | Gate |
|---------|--------|------|
| **Business** | **future** | Bitcoin Law 10 exit |
| **Manufacturing** | **future** | Backlog |
| **Crime** | **future** | PvP / player-driven |
| **Vehicle** | **future** | Not bitcoin gate |

### Prohibited patterns (LIFEPUNCH™)

| Pattern | Status | Rule |
|---------|--------|------|
| **NPC systems** | **prohibited** | Law G9 · DECISION-0003 — no LIFEPUNCH NPC dependency; third-party DXRP NPCs remain out of scope |

---

## Bitcoin-specific (reference implementation)

| Pattern | Doc | Design status | Implementation proof |
|---------|-----|---------------|----------------------|
| Player design | `BITCOIN_PLAYER_DESIGN.md` | **active** | unproven |
| Controller roles | `BITCOIN_CONTROLLER_PATTERN.md` | **active design / partial legacy implementation** | partial (legacy CPU on rack) |
| Upgrade ownership | `BITCOIN_UPGRADE_TAXONOMY.md` | **active ownership design / final five-by-five pending** | unproven |
| Data flow | `BITCOIN_DATA_FLOW.md` | **active** | partial |
| Encryption / PvP | `BITCOINMINING_ENCRYPTION_SPEC.md` | **spec** | not started |
| Ship roadmap | `BITCOIN_SHIP_ROADMAP.md` | **active** | in progress |
| Signed-off bible | `BITCOIN_REFERENCE_IMPLEMENTATION.md` | **stub** | populate on Law 10 exit |

---

## Adding a pattern

1. Architect proposes in CURSOR BRIEF or pattern doc PR.
2. Owner approves.
3. Add **one row** here with `draft` → `active` when flatgrass-proven.
4. Cross-link from `CYBER_REFERENCE_LAWS.md` Law 3 if player-visible.

---

## Future lanes (park until unlock)

| Pattern | Target doc | Gate |
|---------|------------|------|
| Banking | `BANKING_PATTERN.md` | Bitcoin Law 10 exit |
| Hacking | `HACKING_PATTERN.md` | Bitcoin Law 10 exit |
| Business / manufacturing | `BUSINESS_PATTERN.md` | Backlog |

Do not create empty pattern files until lane unlocks — track intent here only.

---

*v1.1 — 2026-06-25 — Architect Phase 2*
