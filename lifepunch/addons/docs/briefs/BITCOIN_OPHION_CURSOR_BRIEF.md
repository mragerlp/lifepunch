# Ophion hub — CURSOR BRIEF (ChatGPT LIFEPUNCH™ · June 14, 2026)

**Status:** Official product foundation for `lifepunchbitcoin` (repo ident `bitcoinmining`, s&box `lifepunch.bitcoin`).  
**Visual pass (P0 law):** `BITCOIN_OPHION_VISUAL_PASS_BRIEF.md` — Bloodwave verdicts locked.  
**Quarantine:** All other addons frozen per `QUARANTINE_REGISTER.md`.

---

## Brief (from ChatGPT)

**Product:** Bitcoin miner hub — player UX and visual pass (Ophion)  
**Priority:** P1  
**Listing:** LIFEPUNCH™ Bitcoin Miner Hub — Ophion Operations Center  
**Tagline:** "Scale from a single screaming ASIC to an industrial crypto operation."

### Player fantasy

Small-time crypto operator: one noisy machine → warehouse-scale empire. Upgrades show through power, heat, noise, profit. Hub as trophy room of infrastructure — physical growth, not abstract menus.

### Loop (target)

1. Acquire starter rig  
2. Install into hub rack slots  
3. Monitor power, cooling, uptime, wallet  
4. Upgrade infrastructure for larger loads  
5. Reinvest into expansion / efficiency / premium hardware  

### Visual direction

Industrial warehouse · black racks · blue-white LEDs · cable management progression · clean vs overloaded readable · room transformation over time.

### Out of scope (law)

Real crypto, real wallets, blockchain, tax sim, real profitability math, GPU assembly minigame, P2P crypto trading.

---

## Open questions — answered (repo canon)

| # | Question | Answer for P0 build |
|---|----------|---------------------|
| 1 | Simulated vs abstract economy? | **Simulated DXRP values** — fictional BTC balance, `PayHost`/`ChargeHost`, 90s tick (see `BITCOINMINING_UX_SPEC.md`). |
| 2 | residential → warehouse → industrial? | **Phased.** P0 = **one Ophion hub** looks right on flatgrass + racks slot in. Room/warehouse tiers = later content, not P0 gate. |
| 3 | Random vs maintenance failures? | **P0: none required.** Optional maintenance events post visual ship. |
| 4 | Utility / city inspectors? | **Out of P0.** Roleplay hook in brief — future job interaction. |
| 5 | Cooperative ownership? | **P0: single-owner hub wallet** on hub entity (current arch). Co-op = later. |

---

## Visual hierarchy (Bloodwave law)

The **room tells the story before USE**:

`Hub silhouette → rack wall → amber HASHD (on USE) → cable clutter → LEDs/fans`

Not: UI panel → terminal screen → menus.

## P0 build order (Cursor law)

| Step | MCP | Deliverable |
|------|-----|-------------|
| 1 | `sbox-editor` | Hub + rack vmdl/vmat compile clean; remap audit; `complex.shader` baseline |
| 2 | `sbox` | `lp_map_flatgrass` + **`lp_spawn_bitcoin_miner_hub`** — **hero full-kit** screenshot |
| 3 | `sbox` | `lp_spawn_bitcoin_miner_hub_only` — scale-vs-citizen doc screenshot only |
| 4 | `sbox` | Power on/off + mining — state unmistakable (emissive + audio; anim Phase 2) |
| 5 | `sbox` | USE hub — HASHD amber (secondary proof; no color-family contamination) |
| 6 | owner | Visual sign-off — review **five P0 failure gates** in visual pass brief |

**P0 verdicts:** full kit = hero · hub-only = scale doc · no RGB shader experiment · no dollhouse scale regression.

**Not P0:** full Hardware Shop UI, Generator Unit props, Mining Container, multi-room progression, hub fan/LED vmdl anim.

---

## Map to existing repo

| Brief entity | Repo today |
|--------------|------------|
| Ophion Miner / hub | `bitcoin-miner.prefab` + `bitcoin-miner.vmdl` |
| Rack Frame / GPU racks | `gpu-rack`, `large-gpu-rack` |
| Crypto Wallet Terminal | `HashdTerminal` on hub (USE hub path) |
| Starter ASIC / Titan | Future rack modules — not P0 |
| PDU, cooling duct, generator | Brief flavor — **not** new meshes P0 |

Keep **hub + rack + hashd** architecture; rebuild **visuals and player-readable states** per brief.

---

## ChatGPT entities to defer

Do not model P0: Battery Backup, Fiber Modem, Maintenance Toolkit, Profit Ledger, Mining Container, Industrial Exhaust — log in `TECH_DEBT.md` when requested.
