# Cornerman — Bitcoin Hub / GPU upgrade architecture distill (P0 prep)

**Issued:** 2026-06-25 · **Lane:** Tier-3 distill prep · **Eyes:** covered (repo/docs only — no playtest)  
**Owner gate:** Bloodwave sends final ChatGPT workflow plan → Red approves → **then** implementation. This task is **prep only**.

---

## Mission

Distill owner + ChatGPT mining-farm architecture into **actionable canon** for a hub UI / economy overhaul **without destroying** the existing `LpHashdPanel` shell.

**Design rule (locked):**

> Every upgrade answers: *Does this make the **controller smarter**, or the **hardware stronger**?*

- **Hub** = mining controller (brain) — hub upgrades live here
- **Terminal** = keyboard + monitor — never mines; commands + farm status
- **GPU racks** = workers — hash; local BTC buffer before deposit to hub wallet

**Hard caps (unchanged):**

- 2× standard GPU Rack + 1× Advanced GPU Rack per hub
- 1 hub · 1 terminal · 3 racks per operator (portal)

---

## Owner canon (2026-06-25 — supersedes stale lines in older docs)

### Yield (base, before upgrades)

| Slot | Base yield multiplier | Notes |
|------|----------------------|--------|
| Standard GPU Rack | **1.0×** | Clock/speed vs block-reward split below |
| Advanced GPU Rack | **2.0×** | Stronger default hardware tier |

### Local buffer (undeposited BTC on rack before mining stops / deposit required)

| Slot | Default cap formula | Owner note |
|------|---------------------|------------|
| Standard GPU Rack | **max($10,000 USD, 1 BTC)** per rack | **1 BTC** per standard rack (not 2) |
| Advanced GPU Rack | **max($20,000 USD, 2 BTC)** | Higher tier buffer |

Upgrades can **raise rack buffer capacity** (not buy more racks).

### Upgrade semantics (target — not yet in code)

| Upgrade name (working) | Real-mining analog | Owner | Gameplay effect |
|------------------------|-------------------|--------|-----------------|
| **CPU Clock Path** | Controller dispatch / firmware | **HUB** | Hash **speed** (effective hashrate) |
| **CPU Core Count** | Share handling / scheduler threads | **HUB** | **Block reward / yield** multiplier |
| **GPU rack upgrades** | OC, cooling, PSU, VRAM | **Per rack (Servers tab)** | That rack's hashrate, thermals, buffer tiers |

**Cut from scope (owner):** enterprise motherboard, mining OS SKU, network controller, automation software, buy-more-GPU tiers, extra rack purchases beyond 2+1.

**Keep on hub later:** encryption / security module (hacker lane — see `BITCOINMINING_ENCRYPTION_SPEC.md`).

---

## Repo reality snapshot (for gap analysis)

Distill must compare **owner canon** vs **current code**:

| Topic | Current code / UI | Gap |
|-------|-------------------|-----|
| CPU upgrades | `CpuUpgradeLevel` / `CoreUpgradeLevel` on **`LpBitcoinRackEntity`**; bought in Hub **Servers → Upgrade** sub-view | Should move to **hub** (controller) |
| Advanced 2× yield | `AdvancedRack` flag exists; `YieldMultiplier` always `1f` | Need **2.0× base** for advanced |
| Rack capacity | Flat `RackBtcCapacity = 0.15f` BTC all racks | Need USD+BTC dual cap per tier |
| Servers tab | Status + per-rack CPU upgrade shop | Should be **GPU / hashing** only |
| Hub upgrades tab | Does not exist | **New tab** — controller upgrades |
| Terminal | CRT commands; STATUS sidebar block added | Expand as farm readout (pool, racks, selected worker) |
| Mining AFK | Racks tick on host when mining | Align copy with "hub keeps running" |
| Docs | `BITCOINMINING_HUB_ARCH.md` lists CPU on rack | Stale vs owner direction |

**Key files (read-only distill):**

- `lifepunch/addons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinEconomy.cs`
- `lifepunch/addons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinRackEntity.cs`
- `lifepunch/addons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinIdent.cs`
- `lifepunch/addons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor`
- `lifepunch/addons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinTerminalPanel.razor`
- `lifepunch/addons/docs/BITCOINMINING_HUB_ARCH.md`
- `lifepunch/addons/Code/Addons/lifepunch/bitcoinmining/docs/BITCOINMINING_TERMINAL_DOCTRINE.md`
- `lifepunch/addons/docs/BITCOINMINING_UX_SPEC.md`

---

## Deliverables (write to `C:\lifepunch\cornerman\outbox\`)

| # | Output file | Contents |
|---|-------------|----------|
| 1 | `BITCOINMINING_CONTROLLER_VS_HARDWARE.md` | One-pager: hub / terminal / rack roles + data flow diagram (text/mermaid) |
| 2 | `BITCOINMINING_UPGRADE_TAXONOMY.md` | Table: every upgrade → hub vs rack; rename map (CPU Clock Path → …, etc.) |
| 3 | `BITCOINMINING_ECONOMY_MIGRATION_NOTES.md` | Fields to move rack→hub; capacity formula; advanced 2×; payout math sketch |
| 4 | `BITCOINMINING_HUB_UI_TAB_PLAN.md` | **Preserve** existing tabs; propose **Hub Upgrades** tab + Servers relabel; no layout destroy |
| 5 | `BITCOINMINING_TERMINAL_COPY_PASS.md` | rig0 / help / STATUS lines aligned to real mining vocabulary |
| 6 | `BITCOINMINING_DOC_DRIFT_FIXLIST.md` | Files + lines to update when Red ships |
| 7 | `BITCOINMINING_CHATGPT_PROMPT_MERGE.md` | Empty shell — **fill when owner drops final ChatGPT plan**; diff vs deliverables 1–6 |

---

## Model + constraints

- **Warm:** `WarmDistill` only
- **Do not** write C#, Razor, or commit to git on Green
- **Do not** invent portal prices — flag TBD for Red
- **Do not** claim playtest or in-game verification
- Ping Red one line when batch done: `OK cornerman hub-upgrade-arch prep @<date>`

---

## References pushed with this task

See inbox copies of hub arch, terminal doctrine, UX spec, economy/rack C# excerpts in prep snapshot.
