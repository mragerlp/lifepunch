# Bitcoin — player design (fantasy, journey, constraints)

> **Status:** Active  
> **Why does this exist?** Every feature slice should serve the same player fantasy and progression curve — not just compile.  
> **How:** See `BITCOIN_CONTROLLER_PATTERN.md`, `BITCOIN_DATA_FLOW.md`, `BITCOIN_UPGRADE_TAXONOMY.md`.  
> **Feel:** `lifepunch/docs/LIFEPUNCH_FEEL.md`

---

## Player fantasy

> **Who does the player become?**

**Operator of a professional cryptocurrency mining operation.**

They own a powered hub, command a HASHD terminal like real ops software, link GPU racks, manage deposits and cashout, and grow from a single rack to a capped industrial farm — while other players (hackers, criminals, competitors) threaten or envy their infrastructure.

---

## Design constraints

### Never becomes

- Idle clicker (tap-to-mine with no machine literacy)
- Spreadsheet simulator (unlimited racks, opaque columns)
- Factory spam (props without machine states)
- NPC-dependent progression (no quest-giver miner)

### Always remains

- **Premium** — capped farm, polished surfaces
- **Industrial** — machines with OFF/ONLINE/WORKING states
- **Roleplay-first** — wallet, crime, economy hooks
- **High interaction** — USE, PIN, terminal commands, hub tabs
- **Low micromanagement** — mining continues when UI closes; deposit/cashout are deliberate beats

---

## Complexity budget

Where depth is **allowed** (stars = budget). Do not spend rack budget on hub problems.

| Surface | Budget | Allowed complexity |
|---------|--------|-------------------|
| **Hub** | ★★★★★ | Wallet, upgrades, servers, logs, PIN, power, alerts |
| **HASHD Terminal** | ★★★ | Commands, boot, STATUS sidebar, farm readout |
| **GPU Rack** | ★★ | Link state, mining indicator, per-rack hardware upgrades |
| **Advanced GPU Rack** | ★★ | Same as rack — higher tier defaults, not new UI paradigm |

**Rule:** New mechanics must fit the budget of the entity that **owns** them (Law G0).

---

## Player journey (target pacing)

Rough hour targets — tune in playtest; order matters more than exact numbers.

| Phase | Player milestone |
|-------|------------------|
| **Hour 1** | Learn hub — power, PIN, overview, what "mining" means |
| **Hour 5** | First GPU rack linked; terminal `mining start`; first deposit |
| **Hour 20** | Second standard rack; hub controller upgrade tier 1 |
| **Hour 50** | Advanced rack slot; encryption awareness (PvP prep) |
| **Hour 100** | Optimized industrial farm at cap — roleplay status object |

Every new feature should answer: **which hour does this serve?** If none → backlog.

---

## Rejected ideas (do not re-litigate without owner)

**Canon list:** `lifepunch/docs/KNOWLEDGE/bitcoin/rejected-ideas.md` (cite DECISION-#### when applicable)

---

## Fantasy Check (bitcoin)

After flatgrass proof, before owner sign-off:

> Does this still feel like operating a **professional mining farm** — not a minigame menu?

See `LIFEPUNCH_FEEL.md` for global feel bar.

---

*v1.0 — 2026-06-25 — Architect Phase 2*
