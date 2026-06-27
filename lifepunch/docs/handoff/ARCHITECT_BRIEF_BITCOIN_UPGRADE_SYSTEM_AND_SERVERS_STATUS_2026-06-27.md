# LIFEPUNCH — Bitcoin lane: steer the new Upgrade + Status system

**Date:** 2026-06-27  
**For:** Design Architect (ChatGPT / Opus) — advisory only. Red (Cursor) implements.  
**Owner:** Bloodwave  
**Status:** Ready for Architect steer → owner review → phased implementation.

You are Architect (design brain, "does this make the game better?"). I'm the Cursor implementer on VENGEANCE. This is the LIFEPUNCH Bitcoin lane (s&box / DXRP gamemode). I need you to steer the architecture of a reworked **upgrade system** and a **Servers status page** before I write the real C#. Give me a recommended design + the decisions called out at the bottom. Don't write code — shape the system.

## The entities (already real, networked via [Sync(FromHost)])
- **Bitcoin HUB** (`LpBitcoinHubEntity`): `IsPowered`, owner wallet, `GetLinkedRacks()`, `HasLinkedTerminal()`, `GetRackPendingBtc()`. The hub hosts the "BITCOIN OPS" menu (`LpHashdPanel`).
- **HASHD Terminal** (`hashdterminal`): links to the hub; today it's where you run `link gpurack-1` etc. and where mining start/stop happens (the "CRT"). See `LpBitcoinTerminalPanel`.
- **GPU Racks** (`LpBitcoinRackEntity`): slots `gpurack-1`, `gpurack-2`, `advancedgpurack` at `rig0`. Real fields:
  - `IsMining`, `ClockGhz`, `CoreCount`, `CpuUpgradeLevel`, `CoreUpgradeLevel`
  - `MiningRatePerMinute`, `BitcoinAmount`, `YieldMultiplier`
  - Upgrades today purchased per-rack with real in-game cash (2 paths: CPU clock / Core count).

## What's REAL today (the only working economy)
Per-rack upgrades with real in-game cash, 2 paths only:
- **CPU clock path** → raises `ClockGhz` (`LpBitcoinEconomy.CpuUpgradeCosts[level]`).
- **Core count path** → raises `CoreCount` (`CoreUpgradeCosts[level]`).
Both feed `MiningRatePerMinute`. Reached by selecting a rack from Servers (Racks tab) → per-rack upgrade screen.
HUB and Terminal have **no** functional upgrades yet (only preview shell work in progress).

## What was built in the immediate prior session (UI shell, NO economy wired)
A "Universal Upgrades" tab (under OpsTab.Upgrades) intended to become the single purchase surface:
- Surface chips: **HUB / TERMINAL / GPU RACK** (plus rack selector for GPU racks).
- Each surface lists **path buttons** (icon + name + current tier label) → opens a **path detail** showing that path's **full 5 tiers laid out in one horizontal line** (icon + Tier Roman + label + price/state).
- States: owned (amber fill, pointer-events:none), available (hoverable), locked (greyed).
- It's a **preview shell only** (internal `_previewTier` dictionary + helpers like `TierState`, `PreviewBuyTier`, `TierAt` guard). No real cash, no RPCs, no stat mutations.
- Proposed taxonomy (5 paths × 5 tiers each), purely as placeholder content for the shell:
  - HUB "Controller tracks": Job Scheduler, Share Pipeline, Pool Client, Farm Firmware, Trust Policy (+ Sound Pack cosmetic).
  - TERMINAL "Defense & capabilities": Endpoint Firewall, Command Auth, Intrusion Detection, Audit Retention, Monitoring Suite (+ skin cosmetic).
  - GPU RACK "Hardware": Compute Profile, Cooling System, Power Delivery, Efficiency Tuning, Payout Buffer (+ Fan RGB cosmetic).
- Header: "Universal Upgrades" centered with breathing room; intro text updated.
- SCSS mirrors LIFEPUNCH ULX action grid patterns for tiles (no dashed borders, solid + rgba for cosmetics/caps).
- NRE hardened (`TierAt` safe accessor so hotload nulls on `track.Tiers` can't crash render tree).
- `BuildHash()` includes `_openPath` and `_previewTierRev` for deterministic re-renders.
- Dev ConCmd: `lp_bitcoin_preview_upgrades_home` (bypasses PIN, opens the home directly).

**Important:** This shell **must not** be treated as the finished economy. It exists to validate layout, tab flow, and the 5-tier line presentation.

## What the OWNER wants ("true proper functioning")
1. **Upgrades tab = the ONLY place you buy upgrades.** Servers never sells anything.
2. **Servers tab = pure live STATUS dashboard**, one card per entity:
   **Bitcoin HUB, HASHD Terminal, GPU Rack 1, GPU Rack 2, Advanced GPU Rack.**
   - Keep the existing "how to link" guidance per rack (it's good UX).
   - Show link/connection confirmations like racks have now, plus:
     - HUB powered on? Terminal linked? Each rack linked? (revealed one-by-one as they connect).
     - When a rack is **linked**: show whether it has started mining. If mining, show its **rack balance, hash rate, etc., derived from its real upgrades**, and a **per-upgrade tier readout (e.g. 1/5 or 3/5)** reflecting that rack's TRUE upgrade levels (not the preview shell).
     - If an entity becomes **unlinked**, the page tells you clearly.
3. **Power/link cascade (core rule):** the HUB is the root. If the **HUB is powered off, all linked entities (Terminal + every rack) unlink** and the player must link everything again from scratch. Linking order is: HUB power → Terminal link → racks link at rig0.
4. **When unlinked / hub off:** mining stops, status reflects "not linked" or "hub offline", balances remain but active contribution stops.
5. **No buying on Servers.** The per-rack CPU/Core buy UI that exists today will be migrated or replaced by the universal Upgrades flow (or kept only as a thin "view stats" entry until the taxonomy lands). Architect to advise on migration path without spaghetti.

## The open design problem (where I need your steer)
The shell taxonomy (5×5 per surface) is pretty, but I don't want pretty-but-fake. I need a real, non-spaghetti system. Please recommend an architecture and answer these:

1. **Economy model:** Should the 5-path×5-tier taxonomy BECOME the real economy (replacing or evolving the current 2-path CPU/Core rack model — e.g. Compute Profile ≈ clock, Cooling/Power/Efficiency ≈ multipliers, Payout Buffer ≈ yield), or should I keep CPU/Core as the core rack stats and treat the extra paths as additive modifiers / side-grades? What's cleanest, most fun, and doesn't explode tuning complexity?

2. **Stat mapping (real effects):** Define how each tier should translate to actual stats for:
   - GPU Racks: hashrate, stability, power draw, payout buffer, efficiency.
   - HUB (controller): job dispatch, share handling, yield policy, security/encryption (PvP defense vs hacker lane), automation QoL.
   - Terminal: defense (breach resistance, detection, response), command capability (session length, auth strength, monitoring), without ever letting Terminal mine.
   What should HUB and Terminal upgrades actually DO so they're not cosmetic or dead-ends? Give concrete, reference-quality mappings.

3. **State + persistence + authority:**
   - Where should upgrade levels live? (Per-entity `[Sync(FromHost)]` fields like the rack already has for Cpu/Core? A single upgrade profile component on the hub? Separate records?)
   - How do they persist across sessions/relinks?
   - Should upgrades survive an unlink/relink, or reset (or "degrade") on hub power-off like the links do?
   - Host-authoritative purchase RPCs: what does the buy flow look like (client requests, host validates cash + prerequisites + applies)?

4. **Link/power state machine (detailed):**
   - Confirm the cascade (HUB off → unlink all → relink required).
   - Should Terminal-unlink also stop rack mining?
   - Should racks keep their local `BitcoinAmount` through a relink?
   - What's the right UX for "you were unlinked / hub powered down" without it feeling punishing or losing player progress?
   - How does the UI (both Upgrades and Servers status) react to power/link changes in real time (sync, events, polling)?

5. **Cosmetics:** Keep cosmetic tracks (purely visual, no stat effect) in the taxonomy for v1, or cut them for v1 and treat as a later donor/visual lane?

6. **Surface scope for v1 (phasing):**
   - Given Bitcoin is the reference lane that caps all future cyber lanes (Hacker HUB/Terminal will likely preserve the same three-surface structure), what's the smallest shippable slice that proves the system end-to-end?
   - Likely candidate: Real GPU-rack hardware upgrades (5 paths or the evolved CPU/Core+additive) wired through the universal Upgrades home → Servers status dashboard reflects true per-rack tier readouts + mining stats + link/power states → power-off cascade unlinks everything.
   - HUB controller upgrades and Terminal defense upgrades as a defined-but-later phase, with clear stubs so the UI contract is stable.
   - Provide a phased plan (v1 slice, v1.1, post-Law10) with owner-gate points.

## Constraints (so your steer fits reality)
- s&box networked entities; host-authoritative `[Sync(FromHost)]`. No client-side mutation of sync fields. Menu is a Razor PanelComponent (`LpHashdPanel`); all purchase / link / power changes must round-trip through host methods. `BuildHash()` must capture every flag that changes markup.
- Upgrades tab = only purchase surface; Servers = read-only status. Do not reintroduce buying on Servers.
- Owner gates every phase: Plan (Architect) → owner sign-off → implement one slice → flatgrass proof (not editor screenshots) → review → next. Give me phased, owner-gateable slices.
- Preserve existing hub chrome / tab model. The current `OpsTab` (Overview, Wallet, Transfers, Racks/Servers, Upgrades, Logs, Settings) and the "← Servers" back button pattern are established.
- Quality bar: Machine not prop; flatgrass is truth; reference first (Law 1); no spaghetti (clean module with one obvious swap point from the current `_previewTier` shell to real state).
- Future reuse: Hacker job will have its own "Server Rack HUB" and "Hacker Terminal". The three-surface upgrade taxonomy + universal home + status dashboard pattern should be reusable with different names/stats. Design for copy-paste / inheritance of the contract, not the Bitcoin numbers.

## Deliver
- Recommended architecture (data model + stat mapping + state machine + purchase flow).
- Crisp answers to questions 1–6.
- Smallest v1 slice you'd ship first, with explicit owner-gate criteria and what "flatgrass proof" looks like for that slice.
- Any immediate contradictions or gaps you see in the current shell vs the desired "true proper functioning".

---

## For the implementer (Red / Cursor) — notes after Architect replies
- Cross-check every recommendation against:
  - s&box Razor/SCSS rules (no dashed, gradients, display:none/block, etc.; class root on root; `BuildHash` must include new flags).
  - Host sync model (no direct writes from panel).
  - One swap point (preview → real).
  - Surface roles (Upgrades buys, Servers reads).
  - Existing rack fields and `LpBitcoinEconomy` methods.
- When implementing the v1 slice: keep a clean baseline in `TECH_DEBT.md` if any temporary fork is needed.
- After each slice: full proof package (day/night/USE/citizen scale/clip) + owner H-sign-off before next.
- Reference this brief + `DECISION-0010` + `BITCOIN_UPGRADE_TAXONOMY.md` in future job handoffs.

**GitHub monorepo is source of truth.** This brief is the handoff artifact for continuity (Architect, Cornerman, future Red slices, Hacker lane prep).
