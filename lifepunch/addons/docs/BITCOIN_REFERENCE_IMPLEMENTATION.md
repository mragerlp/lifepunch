# Bitcoin reference implementation — the cyber bible

**Status:** STUB — populate on Bitcoin Phases A–C owner sign-off (Law 8).  
**Until complete:** patterns live in code + `BITCOINMINING_POLISH_CHECKLIST.md`; this doc is the **clone source** for Hacker, Banker, Government, and all future lanes.

**Do not copy empty sections into new jobs.** Wait for owner sign-off, then fill every section with proof artifacts.

**Parent laws:** `CYBER_REFERENCE_LAWS.md` · `ACTIVE_WORKSTREAM.md`  
**Brand matrix:** `TERMINAL_BRAND_MATRIX.md`

---

## 1. Visual rules

| Rule | Value | Proof |
|------|-------|-------|
| Hub silhouette | Ophion `bitcoin-miner` | *(screenshot TBD)* |
| Hub scale vs citizen | Waist-to-chest relationship | *(flatgrass comparison TBD)* |
| Terminal CRT theme | `lp-ops-crt--gray` | *(screenshot TBD)* |
| Hub admin UI | `LpHashdPanel` amber `#f0a500` / `#12100c` | *(screenshot TBD)* |
| Rack read | Small vs large stacked | *(screenshot TBD)* |
| Day / night visibility | Powered vs off obvious | *(screenshots TBD)* |
| Brand mark | `ui/hashd/btc-mark.png` | *(screenshot TBD)* |

**30-foot test result:** *(pass/fail + notes TBD)*

---

## 2. Dimensions & collider

| Asset | Import scale | Translation | BoxCollider | Notes |
|-------|--------------|-------------|-------------|-------|
| `bitcoin-miner.vmdl` | 0.77 | Z 16.324 | 30×15.5×20 | See `MODEL_BUILD.md` |
| `bitcoin-terminal.vmdl` | *(TBD)* | *(TBD)* | *(TBD)* | Phase B |
| `gpu-rack.vmdl` | *(TBD)* | *(TBD)* | *(TBD)* | Phase C |
| `gpu-rack-stacked.vmdl` | *(TBD)* | *(TBD)* | *(TBD)* | Phase C |

---

## 3. Interaction rules

| Surface | USE target | Player loop | Authority |
|---------|------------|-------------|-----------|
| Hub | `bitcoin-miner` body | Clickable admin — power, link, upgrades | `LpBitcoinHubEntity` |
| Terminal | `bitcoin-terminal` | Typed `rig0>` commands | Hub must be powered |
| Rack | `gpu-rack` / large | Terminal commands only — no hub mine/stop | Linked to hub in radius |

**State machine (Law 6):** document final OFF / BOOTING / ONLINE / WORKING / WARNING / ERROR / UPGRADING mapping per entity here on sign-off.

---

## 4. Pattern library (clone these)

| Pattern | Canonical file / class | Reuse by |
|---------|------------------------|----------|
| CRT terminal shell | `LpOpsCrtTerminal.scss` | All `lp-ops-crt--*` themes |
| Bitcoin CRT panel | `LpBitcoinTerminalPanel.razor` | Gray civilian rig |
| Hub dashboard | `LpHashdPanel.razor` | Future server-rack / vault hubs |
| UI chrome | `LpUiChrome.scss`, `LpUiScale.scss` | All LifePunch panels |
| Boot sequence | Terminal boot splash + lines | Per-lane boot copy |
| Dev spawn / proof | `LpBitcoinDevSpawn.cs` | Playtest ConCmd pattern |

---

## 5. Upgrade & progression rules

*(Populate after hub + rack economy signed off)*

- Hub power gate
- Rack link (`LinkedHubId`; terminal `LinkRange` 512u)
- **Per-rack BTC** (`LpBitcoinRackEntity.BitcoinAmount`) — sell via terminal

---

## 6. UX & naming standards

| Item | Bitcoin canon | Matrix row |
|------|---------------|------------|
| Program | `hashd` | TERMINAL_BRAND_MATRIX § hashd |
| Prompt | `rig0>` | Gray CRT |
| Accent | `#f0a500` amber | Civilian miner |
| Product title | LIFEPUNCH™ Bitcoin Miner for DXRP | `LpBitcoinIdent` |
| Error tone | Short, actionable — hub off, not linked | Consistent across lanes |

---

## 7. Proof archive (sign-off package)

| Artifact | Path / filename | Phase |
|----------|-----------------|-------|
| Day screenshot | *(TBD)* | A |
| Night screenshot | *(TBD)* | A |
| USE state | *(TBD)* | A |
| Citizen comparison | *(TBD)* | A |
| 30s gameplay clip | *(TBD)* | A–C |
| Full kit hero | *(TBD)* | C |

---

## 8. Sign-off log

| Date | Phase | Owner | Notes |
|------|-------|-------|-------|
| — | A | — | Stub created 2026-06-15 |
| — | B | — | |
| — | C | — | |
| — | **Reference quality** | — | Unlocks Tier 1 cyber lanes |

**Last updated:** 2026-06-15
