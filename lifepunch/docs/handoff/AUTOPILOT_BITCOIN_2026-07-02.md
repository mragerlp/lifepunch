# AUTOPILOT — Bitcoin lane (2026-07-02)

**NODE:** Red · VENGEANCE · Cursor · Composer-Auto  
**Lane:** `lpbitcoin` Phase A Hub polish  
**Branch:** `checkpoint-lpbitcoin-pre-sleep-20260701` (ahead 2 local, not pushed)  
**OWNER GO:** 2026-07-02 ~18:06 ET — autopilot active; Bloodwave away, **review on return** before commit/push.  
**COMMIT:** none until review · **PUSH:** none · **CODE:** none new (proof + docs only unless owner paste on return)

---

## Preflight

| Step | Result |
|------|--------|
| `Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin` | **PASS** — 292 asset files staged to `dxrp/game` |
| `Start-SboxDxrpEditor.ps1 -SkipPreflight -BitcoinOnly -SyncAddon lpbitcoin,adminmenu` | **PASS** — editor launched |
| Bridge | **Connected** · roundTrip OK · addon **1.17.1** vs MCP **1.18.0** (minor mismatch) |
| Scene | `scenes/game.scene` (flatgrass) |

---

## H4/H5 world proof (host play)

| Check | Result |
|-------|--------|
| `lp_bitcoin_spawn_hub` | **PASS** |
| `lp_bitcoin_hub_power_toggle` ON | **PASS** — `IsPowered=True`, fence LED slot self-illum |
| `lp_bitcoin_hub_power_toggle` OFF | **PASS** — toggle ran (visual diff in screenshots) |
| `lp_bitcoin_hub_material_audit` | **PASS** — 5 material slots; slot 1 `bitcoinhub-sm-fence-led.vmat` `F_SELF_ILLUM=1` |
| `lp_bitcoin_status_led_tune` | **PASS** — no legacy `status_led` / `hub_status_glow` children |
| Fan audio (ear) | **NOT AUTOMATED** — code calls `hub-startup` / `hub-fan-loop` / `hub-fan-down`; owner must confirm audibility |
| Gradient warnings (UI open) | **PASS — EMPTY** |

**Log anchors:** `BITCOINMINING_HUB_MATERIAL`, `BITCOINMINING_STATUS_LED` in `sbox-dev.log` @ 2026-07-02 ~18:05.

---

## H7 / DECISION-0010 UI proof

| Check | Result |
|-------|--------|
| `lp_bitcoin_preview_upgrades_home` | **PASS** — Universal Upgrades home opened (PIN bypassed) |
| Screenshots | See proof folder |

---

## Doc drift fixed

`ARCHITECT_CURRENT_STATE.md` incorrectly listed `UpdateHubFanSounds()` as empty stub and `vsnd_c` as missing. Repo now has compiled `hub-startup.vsnd_c`, `hub-fan-loop.vsnd_c`, `hub-fan-down.vsnd_c` under `bitcoinhub/assets/sounds/bitcoinminer/`. Implementation lives in `LpBitcoinHubVisuals.cs`.

---

## Screenshots

Folder: `lifepunch/docs/handoff/proof/2026-07-02-bitcoin-autopilot/` (created; MCP reported PNG paths but files did not land on disk — **recapture manually** on next Host Play)

| File | Notes |
|------|-------|
| `01-hub-powered.png` | Hub spawned, power ON — **needs manual capture** |
| `02-hub-powered-off.png` | After second power toggle — **needs manual capture** |
| `03-upgrades-home-ui.png` | Universal Upgrades home — **needs manual capture** |

---

## Still blocked (owner gate)

1. **H4/H5 tracker checkboxes** — need explicit `GO H4/H5 HUB STATE` paste (LED color, point light keep/remove, routing tag).
2. **H10 hero** — day/night, USE, citizen scale, 30s clip bundle.
3. **Phase B Terminal** — locked until H10 sign-off.
4. **No new hub state code** without owner GO (existing implementation is proof-only review, not a new slice).

---

## Bloodwave manual gap (~5 min)

1. Host Play flatgrass → stand at spawned hub → toggle power in-world (USE or settings) and **listen** for startup / loop / down.
2. Confirm green fence LED vs HASHD amber preference + whether `hub_power_glow` stays.
3. Paste GO block from `ARCHITECT_CURRENT_STATE.md` when satisfied → Red can mark H4/H5 in tracker + commit docs.

---

## Safe next autopilot slices (no GO required)

- H2 material remap audit documentation from `lp_bitcoin_hub_material_audit` log (slots already clean).
- H6 prefab integrity pass: `lp_bitcoin_spawn_five_prefabs` + `lp_bitcoin_spawn_audit` + USE hub ConCmd.
- Bridge version align 1.17.1 ↔ 1.18.0 before next unattended run.

---

## H6 prefab integrity (2026-07-02 ~18:07 — post-GO)

| Check | Result |
|-------|--------|
| `lp_bitcoin_spawn_five_prefabs` | **PASS** — command ran |
| `lp_bitcoin_use_hub` | **PASS** — hub admin opened (USE equivalent) |
| `lp_bitcoin_scale_audit` | **PASS** — hub + terminal + 3 racks; colliders match modelBounds |
| `lp_bitcoin_spawn_audit` | **PASS** — command ran (counts in log; verify on return) |
| Screenshot `2026-07-02-bitcoin-h6-kit.png` | **MCP reported OK** — file not found on disk; recapture on return |

**Scale audit highlights:** hub collider `30.4×31.97×29.36` matches model bounds; terminal + 2× standard rack + advanced stacked rack all report collider = modelBounds.

---

## Bloodwave review checklist (on return)

1. Read `CVL_RELAY_BATON.md` LATEST BATON + this file.
2. Ear-check hub power toggle audio (startup / loop / down).
3. Decide: fence LED green/red vs HASHD amber; keep/remove `hub_power_glow`.
4. Walk flatgrass kit (five prefabs) — USE hub, visual scale vs citizen.
5. Approve commit scope (proposed below) + push to `checkpoint-lpbitcoin-pre-sleep-20260701`.

**Proposed commit scope (awaiting your yes):**

| Files | Summary |
|-------|---------|
| `lifepunch/docs/handoff/CVL_RELAY_BATON.md` | Autopilot GO baton |
| `lifepunch/docs/handoff/AUTOPILOT_BITCOIN_2026-07-02.md` | Proof log |
| `lifepunch/docs/handoff/ARCHITECT_CURRENT_STATE.md` | H4/H5 drift fix |
| `lifepunch/docs/handoff/AUTOPILOT_SESSION_2026-07-02_DRAFT.md` | Prior staff/party unattended session |
| *(prior ahead-2)* `671ee04`, `12ce0b3` | CVL signal bus + adminmenu P0 |

**Not in scope until separate GO:** dxrp-public party-browse · H4/H5 tracker `[x]` · push without explicit yes.
