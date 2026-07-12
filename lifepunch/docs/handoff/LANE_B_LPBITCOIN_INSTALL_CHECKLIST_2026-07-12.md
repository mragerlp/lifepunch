# LANE B — lpbitcoin (lifepunchbitcoin) fresh gamemode INSTALL checklist

> **Class: INSTRUMENT** (editable until executed). Lane B runs **after Lane A's P7 passes.**
> Portal actions are Bloodwave's hands (Fable browser = read-only verifier) per §17.
> Drafted by Red 2026-07-12; sensors on the bundle below.

## Why this is an INSTALL, not a re-pin
`lpbitcoin` is **NOT installed in any gamemode** (`DXRP_PLATFORM_DOCTRINE.md §5`: "lpbitcoin is NOT yet installed in any gamemode"). So this is the **fresh-install rung of the lpbitcoin ladder pulled forward** — the full §4 pipeline, not a lifepunchulx-style revision bump.

## The bundle (built + sensored 2026-07-12)
```
Source:  prepare-publish.ps1 -Addon bitcoinmining   (manifest ident bitcoinmining -> lifepunchbitcoin)
Bundle:  lifepunchaddons\.dxrp-publish\upload\lifepunch\lpbitcoin\   (Assets\ + Code\)
Size:    221.4 MB  (Assets 220.9 + Code 0.5) — under 300 MB cap
Files:   240 staged | Assets 201 ship files, 68 compiled _c | Code 39
PORTAL PICK (upload level): the  lifepunch\lpbitcoin\  package root (holds Assets\ + Code\)
Terminal-set files PRESENT + FRESH (07-12 06:41): LpHashdPanel.razor/.scss, LpBitcoinTerminalPanel.razor/.scss
```

## Addon identifiers (`config/addons.json:276-337`)
- `dxrpAddonIdentifier`: **lifepunchbitcoin**
- `dxrpAddonId`: `019ec9a4-d867-7668-b452-904f97493c7e`
- `sboxIdentifier`: `lifepunch.bitcoin`

## §4 install steps (Bloodwave's portal hands)
1. **PUBLISH** the `lifepunchbitcoin` revision — upload the `lifepunch\lpbitcoin\` package root (draft -> publish). Record the NEW revision ID/timestamp.
2. **INSTALL** in the **LIFEPUNCH™ Dev** gamemode -> Addons tab (fresh install; pins the new revision). Confirm pinned == published.
3. **CONTENT entries** — 4 entities appear in the gamemode CONTENT tab, attributed to `lifepunchbitcoin`+revision. Per-entry: Name Override, grouping `Entities`, limit-per-player, health, behavior toggles (destroyOnDisconnect / destroyOnJobChange / allowOwnershipTransfer), CONFIG JSON:
   - **Bitcoin Hub** — `addons/lifepunch/lpbitcoin/bitcoinhub/assets/entities/bitcoinhub.prefab`
   - **HASHD Terminal** — `addons/lifepunch/lpbitcoin/hashdterminal/assets/entities/hashdterminal.prefab`
   - **GPU Rack** — `addons/lifepunch/lpbitcoin/gpurack/assets/entities/gpurack.prefab`
   - **Advanced GPU Rack** — `addons/lifepunch/lpbitcoin/gpurack/assets/entities/advancedgpurack.prefab`
4. **CONFIG (T3)** — **FLAG / BLOCK-0:** LP code reads the addon config surface **ZERO times** (Odysseus L2 finding; see `lifepunch-config` skill). Install with **defaults** — no live T3 keys yet. Portal-config tuning will **not** affect gameplay (hash rates, tick intervals, buffer caps, tier costs, payout percents) until the config-extraction work lands. Do not advertise configurability yet.
5. **MARKET bindings** — bind market items (Cost + per-job Whitelist/Blacklist) so players can purchase/spawn. **RULED (Bloodwave 2026-07-12) — portal-set cash Costs (placeholders, server-owner tunable):**
   - Bitcoin Hub — **$2500**
   - HASHD Terminal — **$1500**
   - GPU Rack — **$5000**
   - Advanced GPU Rack — **$10000**
   BTC-gated acquisition is the **future tablet rung**, NOT this market binding — cash costs only for now. Law 2 job-blacklist is the enforcement surface. **DESIGN-PENDING tag stays on the Advanced GPU Rack:** it must **out-earn 2× standard racks at playtest** — revisit its $10000 if the yield ratio breaks.
6. **SAVE** the gamemode.
7. **SYNC SERVERS** (gamemode action).
8. **RESTART** + **TEST on Dev first** (per protection doctrine).

## Caveats
- Fresh install (not a re-pin) — expect the CONTENT tab to be empty for lpbitcoin until step 2 completes.
- The **waived** `validate-layout` debt (lpbitcoin↔bitcoinmining `primaryReference` naming; `lpmonnowsprinterupgrade` paths) does not block this bundle — same regroup-migration bucket.
- Publish-notes precedent (`config/addons.json:288`): Rev 3+ historically compiled in the DXRP game tree first; this bundle used the **repo** source (68 compiled `_c` present, terminal-set razor is runtime-compiled so needs no `_c`).
