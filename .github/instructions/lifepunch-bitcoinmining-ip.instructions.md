---
applyTo: "**"
description: "LIFEPUNCH Bitcoin Miner IP — original work, no third-party credits"
sourceRule: ".cursor/rules/lifepunch-bitcoinmining-ip.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-bitcoinmining-ip.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LIFEPUNCH Bitcoin Miner — IP (agents)

Canonical: `lifepunch/addons/docs/BITCOINMINING_IP_DOCTRINE.md`

## Non-negotiable

- **LIFEPUNCH™ Bitcoin Miner for DXRP** is original LIFEPUNCH content. Bitcoin-mining RP is a **genre** (GMod-era and earlier) — no third-party author gets miner credits.
- **No third-party credits** in miner ship code, UI, portal copy, or About tabs.
- **ULX / Ulysses** respect applies to **`lifepunch.ulx` only** — not the miner addon.
- **Never** commit third-party bitcoin mining study archives (gitignored under `reference/`).
- Built from **original LifePunch work** + public RP genre — not copy-paste; no creator credits except **ULX/Ulysses on `lifepunch.ulx` only**.

## Architecture (differentiation)

- HASHD UI runs on the **Bitcoin Miner hub** — GPU racks are hardware + LCD telemetry, **not** a terminal on the rig.
- Payout cadence: **`BitcoinMiningAddon.MiningPayoutIntervalSeconds` (90s)** — do not revert to 60s without owner ask.
- Sounds: **owner intake only** — ship tree has no WAVs until `Intake-BitcoinMinerSounds.ps1`; never copy third-party packs.

## Vocabulary (agents)

Canon only: `bitcoinmining`, `hashd`, GPU racks, Bitcoin Miner hub. Never re-introduce legacy third-party miner/admin names in greps, docs, rules, or comments.

## Before publish

Positive identity greps + checklist in `BITCOINMINING_IP_DOCTRINE.md` §6.
