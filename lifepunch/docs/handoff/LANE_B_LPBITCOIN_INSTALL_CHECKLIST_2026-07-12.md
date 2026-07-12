# LANE B — lpbitcoin (lifepunchbitcoin) fresh gamemode INSTALL checklist

> **Class: INSTRUMENT** (editable until executed). Lane B runs **after Lane A's P7 passes.**
> Portal actions are Bloodwave's hands (Fable browser = read-only verifier) per §17.
> Drafted by Red 2026-07-12; sensors on the bundle below.

## Why this is an INSTALL, not a re-pin
`lpbitcoin` is **NOT installed in any gamemode** (`DXRP_PLATFORM_DOCTRINE.md §5`: "lpbitcoin is NOT yet installed in any gamemode"). So this is the **fresh-install rung of the lpbitcoin ladder pulled forward** — the full §4 pipeline, not a lifepunchulx-style revision bump.

## The bundle (REBUILT + re-sensored 2026-07-12 11:05, off develop `e31ea5a` = #70 merge)
```
Source:  prepare-publish.ps1 -Addon bitcoinmining   (manifest ident bitcoinmining -> lifepunchbitcoin)
Bundle:  lifepunchaddons\.dxrp-publish\upload\lifepunch\lpbitcoin\   (Assets\ + Code\)
Size:    221.4 MB  (Assets 220.9 + Code 0.6) — under 300 MB cap
Files:   241 staged | Assets 201 ship files, 68 compiled _c | Code 40
PORTAL PICK (upload level): the  lifepunch\lpbitcoin\  package root (holds Assets\ + Code\)
Terminal-set files PRESENT + FRESH (07-12 06:41): LpHashdPanel.razor/.scss, LpBitcoinTerminalPanel.razor/.scss
Config-extraction (#70) PRESENT + FRESH (07-12 11:05): LpBitcoinRackConfig.cs (the Code 39->40 delta),
  LpBitcoinComputeTrack.cs, LpBitcoinPortalEconomySync.cs, LpBitcoinRackEntity.cs.
  Positive ID read from the STAGED bytes: `public sealed class LpBitcoinRackConfig`,
  Tier1EffectMultiplier=2 .. Tier5EffectMultiplier=32, Tier1CostSats=25_000_000.
  => the T3 compute ladder ships in THIS bundle. Step 4 below is live because of it.
NOTE: prepare-publish exits 1 on validate-layout (the waived primaryReference/lpmonnowsprinterupgrade
  debt in Caveats). It stages the full bundle regardless; the nonzero exit is expected, not a failure.
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
4. **CONFIG (T3)** — **BLOCK-0 IS LIFTED for the COMPUTE ladder.** Config-extraction v1 shipped in **#70** under the ruled spec `LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md` (v1.2); LP now performs **one** T3 read — `GetConfig( new LpBitcoinRackConfig() )` at `LpBitcoinRackEntity.cs:288`. Portal Config Override JSON on a rack content entry **does** affect gameplay now, within these bounds:
   - **LIVE at T3 — the COMPUTE ladder, 11 keys** on `LpBitcoinRackConfig`: `MaxTier` (default 5), `Tier1–5EffectMultiplier` (×2/4/8/16/32), `Tier1–5CostSats` (0.25/0.75/2/6/16 BTC = 25M/75M/200M/600M/1600M sats). Activation is **edit → Save → SYNC → restart** (not live-tunable).
   - **SET IT ON ONE RACK ENTRY.** The ladder is **global-once** (spec **v1.2-B**): a single process-wide `rack_compute` registry entry behind a one-shot latch. The **first** rack to reconcile latches cost + effect; a later rack whose config **diverges is ignored and logged once** (`Log.Warning`). **The Advanced GPU Rack does NOT carry its own ladder** — do not tune it separately expecting a second curve. (Its 2× yield ratio is a separate rack-level multiplier, untouched by this.)
   - **NOT tunable at T3 — leave at defaults, deferred to v1.2-C's own PR + GO:** tick intervals, buffer caps, base hash rates, yields. These are still `const` in `LpBitcoinEconomy`.
   - **Live economy dials are Store, not T3:** `cashUsdPerBtc` / multiplier / redeem ride the atomic key `lifepunch:bitcoin:config:settings`, reloaded by `/lpbitcoinreloadconfig` (gated `ManageEconomy || EditServer`). Not a portal Config-tab surface.
   - **"Do not advertise configurability" survives, narrowed:** advertise the compute ladder (tier costs + tier effect multipliers). Do **not** yet advertise intervals, buffer caps, base hash rates, or yields.
   - **Confirmation this step feeds:** the **6th** live confirmation — T3 content-override delivery after Sync (Red drives on GO).
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
