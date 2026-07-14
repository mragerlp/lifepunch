---
name: lifepunch-config
description: The DXRP three-tier config model for LIFEPUNCH — use before writing ANY code that hardcodes a tunable (hash rate, tick interval, buffer cap, tier cost, payout percent, cooldown, health, limit) or when asked "is X adjustable?". Answers check-order T1 (server engine) → T2 (gamemode) → T3 (addon defaults) before code. Enforces the secrets law (secrets live in server convars, NEVER T2/T3 gamemode config, which can sync to clients) and the LP addon config-shape law. This skill points at canon; it does not restate it.
---

# LIFEPUNCH config — externalize, don't hardcode

**This skill points at canon. Read the cited file before building.**

## 1. THE THREE TIERS — check-order before any hardcode

Canon: **`lifepunch/docs/DXRP_PLATFORM_DOCTRINE.md`** §21 (`:308-348`).

- **T1 — server engine config** (per server, Edit → Editor, one JSON doc; activates NEXT
  RESTART). Cooldowns, institutional economies, Sentinel, master switches. Most apparent
  "engine limitations" are T1 knobs.
- **T2 — gamemode config** (per gamemode: jobs/market/content entries + per-entry override
  JSON; activates Save + SYNC SERVERS).
- **T3 — addon shipped defaults** (the addon's Config tab JSON, inherited by every installing
  gamemode until overridden).

**"Is X tunable?" is answered by checking T1 → T2 → T3 BEFORE writing code**
(`DXRP_PLATFORM_DOCTRINE.md:337`). CHECK THE PORTAL before declaring a platform gap (§1).

## 2. THE LP ADDON CONFIG-SHAPE LAW

Every LP addon ships its tunables in config JSON (`DXRP_PLATFORM_DOCTRINE.md` §4, `:73-93`).
Reference schema: **Monnow's Printer Upgrades** (~48 keys — per-level costs, rates, intervals,
storage; `:76-87`). Configurability is a **selling point**. `lpbitcoin`'s config MUST take this
shape: hash rates, tick intervals, buffer caps, tier costs, payout percents. The captured
tunable set for extraction: **`lifepunch/docs/handoff/LPBITCOIN_TUNABLES_EXPORT.md`** (feeds
Odysseus **Packet H**, the config-extraction packet; re-grep before Packet H acts — line drift).

## 3. SECRETS LAW — convars only, never T2/T3

**Gamemode config CAN be synced to clients** (`DXRP_PLATFORM_DOCTRINE.md:88-93`, third-party
confirmed). Therefore: **secrets (API keys, tokens, webhook URLs) go in SERVER CONVARS, never
addon/gamemode config.** T2/T3 carry **gameplay numbers only** — no keys, no URLs-as-credentials,
nothing secret. Store values are portal-visible too (§13) — derived values, never keys.

## 4. BLOCK-0 — SUPERSEDED (config-extraction v1 shipped, #70)

**BLOCK-0 was "LP reads the addon config surface ZERO times" (Odysseus L2 finding). That is no
longer true.** Config-extraction v1 landed on `develop` in **#70** under the ruled spec
**`lifepunch/docs/handoff/LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md`** (v1.2). Read the
spec before touching this surface; the shipped state is:

- **ONE T3 read exists** — `GetConfig( new LpBitcoinRackConfig() )` at
  `lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinRackEntity.cs:287`, feeding
  `LpBitcoinComputeTrack.EnsureRegistered` (`LpBitcoinComputeTrack.cs:39`).
- **What T3 tunes today: the COMPUTE ladder only — 11 keys** on `LpBitcoinRackConfig`:
  `MaxTier`, `Tier1–5EffectMultiplier` (×2/4/8/16/32), `Tier1–5CostSats`
  (0.25/0.75/2/6/16 BTC). Portal Config Override JSON on a rack content entry;
  edit → Save → **Sync** → restart (not live).
- **The ladder is GLOBAL-ONCE, not per-entity** (spec **v1.2-B**). It is one process-wide
  registry entry (`rack_compute`) behind a one-shot latch: the **first** rack to reconcile
  latches cost + effect from its config; a later rack whose config diverges is **ignored and
  logged once** (`Log.Warning`). A separately-tuned `advancedgpurack` does **not** get its own
  ladder. Set the ladder on **one** rack entry.
- **STILL NOT T3-tunable — deferred to v1.2-C's own PR and its own GO:** tick intervals, buffer
  caps, base hash rates, yields. These remain `const` canon in `LpBitcoinEconomy`
  (`StartClockGhz`, `BaseSpeed`, `PayoutIntervalSeconds`, `BufferCapTicks`) — converting them to
  T3 overrides means mutable statics in the economy core, which is **propose-and-STOP class**.
- **Live economy dials are Store, not T3** — one atomic key `lifepunch:bitcoin:config:settings`
  (spec v1.1-a), reloaded by `/lpbitcoinreloadconfig`, gated on `ManageEconomy || EditServer`
  (spec **v1.2-A**; the permission already existed at `Permission.cs:148-149` — none was minted).

**So §2's Monnow-shaped ~48-key target is an OPEN DEBT, not a shipped fact** — 11 keys of it
exist, by ruling. Do not advertise buffer caps, intervals, hash rates, or yields as configurable.
Do not wire a new config read on this skill's authority: extending the T3 surface past the
compute ladder is still gated on a ruling.
