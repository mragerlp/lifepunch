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

## 4. BLOCK-0 — LP reads config ZERO times today

**Flag before any config-extraction implementation:** LP code currently reads the addon config
surface **zero times** (Odysseus L2 finding). The extraction work (moving hardcoded tunables to
T3 keys the game reads) **re-scopes at the next regroup** before any implementation — do not
start wiring a config read on this skill's authority. This skill teaches the model and the
check-order; the build is gated.
