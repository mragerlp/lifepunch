# LIFEPUNCH Architect — current project state (volatile)

> **Regenerate** when phase, gates, or owner decisions change.  
> **Cursor boot paste:** `handoff/CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt`  
> **Architect boot paste:** `handoff/NEW_CHAT_BOOTSTRAP_PASTE.txt` + `ARCHITECT_ONBOARDING_PASTE.txt`  
> **Evergreen law** lives in repo docs — this file is **dated state only**.  
> **GitHub wins** over uploaded Project ZIP snapshots.

**Last updated:** 2026-07-02  
**Integration commit anchor:** see `git log -1` on `main` after pull  
**Cursor boot:** paste `handoff/CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt` alone — full grounding, no extra directions

---

## Active lane

| Field | Value |
|-------|-------|
| **Machine** | **VENGEANCE** (Integration Architect / Cursor Red) |
| **Package** | `lifepunchbitcoin` / repo ident `bitcoinmining` / s&box `lifepunch.bitcoin` |
| **Staging** | `lpbitcoin/{bitcoinhub,hashdterminal,gpurack}` |
| **Current phase** | **Phase A — Hub polish** |
| **Next executable slice** | **H4 + H5** — hub powered/off world feedback + audio baseline |
| **Implementation gate** | **PLAN DONE** — wait for Bloodwave **GO H4/H5 HUB STATE** |
| **Next legal phase** | Phase B HASHD Terminal — **only after H10 owner sign-off** |
| **After B** | Phase C GPU Racks (2 Standard + 1 Advanced) |

**Tracker:** `addons/docs/OWNER_PROGRESS_TRACKER.txt`  
**H1:** pipeline fixed — **owner sign-off pending** (do not reopen unless flatgrass scale fails)

---

## Implementation gates

| Gate | Status |
|------|--------|
| Phase A Hub mesh + proof (H1–H10) | **In progress** — **H4/H5 next**; H4/H5 before H10 |
| Hub admin UI unlinked (`LpHashdPanel`) | **Owner signed off** (2026-06-24) |
| Hub world power/audio flatgrass (H4/H5) | **Code landed — flatgrass proof partial; owner GO + sign-off pending** |
| Phase B Terminal (T1–T6) | **Locked until H10** |
| Hub/Rack upgrade ownership (RFC-0005) | **HOLD** — no code until Bloodwave GO |
| Economy / five-by-five implementation | **HOLD** — Architect questions open |
| Law 10 publish loop | **Blocked** until A + B + C + economy proof |

---

## Hub H4/H5 repo snapshot (2026-07-02)

| Layer | Current state |
|-------|----------------|
| **Power SoT** | `[Sync(FromHost)] IsPowered` on `LpBitcoinHubEntity`; spawn OFF |
| **UI toggle** | `LpHashdPanel` power switch → `SetPoweredHost()` |
| **World visuals** | `LpBitcoinHubVisuals` → `LpBitcoinPowerLeds` fence emissive (green ON / red OFF) |
| **Point light** | `hub_power_glow` PointLight (green, radius 140) when `EnablePowerGlow=true` — **owner keep/remove decision still open** |
| **Fan motion** | **Parked** — no `fan_spin_hub` on prefab (`TECH_DEBT` BITCOINMINING-05) |
| **Audio** | `UpdateHubFanSounds()` wired — startup / fan loop / fan down via `LpBitcoinIdent` paths; **`hub-*.vsnd_c` present in repo** |
| **Prefab** | `lpbitcoin/bitcoinhub/assets/entities/bitcoinhub.prefab` — hub entity + visuals wired |

**Red autopilot proof (2026-07-02):** flatgrass `game.scene` Host Play → `lp_bitcoin_spawn_hub` → `lp_bitcoin_hub_power_toggle` ON/OFF; material audit 5 slots OK; status LED emissive on slot 1 (`bitcoinhub-sm-fence-led.vmat`); log proof in `AUTOPILOT_BITCOIN_2026-07-02.md`. **Not owner-signed** — needs Bloodwave GO paste + ear check on fan audio + day/night hero for H10.

**Owner decisions open for H4/H5:** world LED green/red vs HASHD amber; point light yes/no; H4+H5 tracker checkboxes vs split sign-off.

**Owner GO paste (Integration Architect — locks routing):**

```text
GO H4/H5 HUB STATE — World LED: [green/red | HASHD amber]. Point light on ON: [yes | no].
Route: [GROK REQUIRED | AUTO OK | OPUS REQUIRED]. H4+H5 one commit.
```

**Default without GO:** plan-only · no hub code · agent uses FIRST REPLY block in Cursor bootstrap paste.

---

## Owner decisions (settled)

- No LIFEPUNCH NPC systems (G9, DECISION-0003)
- Hub = ops policy + ledger · `LpHashdPanel` = admin shell + Universal Upgrades home (HUB · TERMINAL · GPU RACK) per **DECISION-0010**
- Terminal never mines (DECISION-0005); owns defense/capability profile
- Three-surface upgrade law: Hub controller / Terminal defense / Rack hardware
- Rack cap: **2 Standard + 1 Advanced** (DECISION-0004)
- Fantasy Check mandatory after flatgrass proof (DECISION-0008)
- Slugs: `bitcoinhub`, `hashdterminal`, `gpurack` — retired `advancedgpurack` folder slug
- Visual identity: HASHD amber for **UI**; world status LED color = **open for H4**
- Model routing: Opus (Tier-1) · Grok Build 1 (Tier-2A) · Auto/Composer (Tier-2B) · Cornerman (Tier-3 prep only)

---

## Parallel lanes (not bitcoin gate)

| Lane | Status |
|------|--------|
| **lifepunchulx r10** | Set Job picker + `StaffMenuBridgeService` compaction — **committed**; portal v1.0.3 / r10 when owner uploads |
| **lpmonnowsprinterupgrade Rev 9** | Path canon: `addons/lifepunch/monnowprinterlp/monnowprinter.prefab`; staging ready; **portal pin + gamemode PrimaryReference update pending**; never `secondaryReference` → `.prefab_c` |

---

## Cross-repo fallback + commit hygiene

- **New chat fallback order:** `handoff/CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt` → `handoff/ARCHITECT_CURRENT_STATE.md` → `addons/docs/ACTIVE_WORKSTREAM.md` → `addons/docs/BITCOIN_SHIP_ROADMAP.md`.
- **Strict lane split:** LP Bitcoin implementation stays in `mragerlp/lifepunch`; DXRP issue/PR work stays in `dxura/dxrp`.
- **Commit hygiene applies to both lanes:** author-only identity (`mragerlp <mragerlp@gmail.com>`), no AI attribution trailers.
- **Checkpoint before lane switch:** commit + push + issue/PR status note before moving between LP and DXRP sessions.

---

## Unresolved Architect questions (do not implement silently)

- v1.0 vs v1.1: full 5×5×5 tree required for first portal ship?
- Tier costs, curves, balance multipliers, buffer recalc
- Save migration: legacy CPU/Core → Compute Profile
- Rack USE → shared CRT vs second Terminal owner
- RFC-0005 upgrade ownership migration timing

---

## Proof status

| Slice | Status |
|-------|--------|
| Hub admin UI unlinked | Owner signed off |
| Hub world H4/H5 flatgrass | **Partial** — MCP proof 2026-07-02; owner GO + audio/visual sign-off pending |
| H10 hub hero | **Open** |
| Terminal Phase B | **Locked** |
| Law 10 exit | **Blocked** |

---

## Session boot (VENGEANCE)

```powershell
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -FullCapacity -PreflightFix -BitcoinOnly -SyncAddon lpbitcoin,adminmenu
powershell -File lifepunch\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
```

Probe: `get_bridge_status` before visual claims. Owner: `lp_authorize` after Host Play.

---

## Continuity kit refresh

**Law:** `handoff/ARCHITECT_CONTINUITY_KIT_LAW.md`

Full kit rebuild warranted by this update (CURRENT_STATE + onboarding + Monnow Rev 9 path canon).

---

*Integration Architect maintains on VENGEANCE after approved doc commits.*
