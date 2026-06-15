# lifepunchbitcoin — start here (Ophion P0)

**Package:** `lifepunchbitcoin` · **s&box:** `lifepunch.bitcoin` · **repo folder:** `bitcoinmining` (until NAME-01 migration)

Read first: `briefs/BITCOIN_OPHION_VISUAL_PASS_BRIEF.md` · `PACKAGE_NAMING_STANDARD.md` · quarantine law in `portfolio.json`.

---

## What “from scratch” means

**Greenfield v2 is live.** v1 C#/UI archived to `reference-intake/bitcoinmining-v1-code/`. v1 **assets** remain on disk as reference — v2 dev spawn uses **placeholder boxes** until new prefabs.

Read: `BITCOIN_GREENFIELD_REBUILD.md`

---

## Session kickoff (VENGEANCE)

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
git pull --rebase

# Sync lifepunch.bitcoin into DXRP + open editor
powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -PreflightFix -SyncAddon bitcoinmining
```

**Play law** (`BITCOINMINING_PLAYTEST.md` §0):

1. Close prefab tabs.
2. Open **`scenes/game.scene`** (tab title **Game**, not `Prefab: …`).
3. **Play** — wait for map fit + player join (2–5 min cold).
4. Console:

```text
lp_map_flatgrass
lp_bitcoin_spawn_kit
```

5. MCP: orbit screenshot — **full kit** (hub + 3 small + 1 large rack) = P0 hero composition.
6. Scale doc only: `lp_spawn_bitcoin_miner_hub_only` + citizen height check.

**Visual law:** room story before USE — hub silhouette → rack wall → clutter → LEDs. See visual pass brief § hierarchy.

**Polish tracker (check off as we go):** `Code/Addons/lifepunch/bitcoinmining/docs/BITCOINMINING_POLISH_CHECKLIST.md`

**Other cyber lanes (hacker, banker, black market, drug chemist, …):** `addons/docs/CYBER_JOBS_POLISH_CHECKLIST.md` · full portfolio order: `addons/docs/JOB_PORTFOLIO_ROADMAP.md`

---

## P0 deliverables (sign-off gate)

| # | Done when |
|---|-----------|
| 1 | Hub vmdl/vmat compile clean; no P0 log spam |
| 2 | **Full kit** on flatgrass — hero screenshot (MCP); hub-only = scale doc |
| 3 | Rack LED/emissive baseline readable |
| 4 | Powered hub + mining loop playtest |
| 5 | HASHD copy = amber ops (not hacker green) |
| 6 | Owner visual sign-off → then publish lane export |

**Not P0:** Hardware Shop, generators, multi-room tiers, portal listing.

---

# DXRP editor (lane scripts)

Bitcoin greenfield does **not** mount in the default DXRP editor until you run a lane script.

| Lane | Script | Mounts |
|------|--------|--------|
| ULX only | `Set-DxrpLifepunchUlxOnly.ps1` | `lifepunchulx` |
| **Bitcoin only** | `Set-DxrpLifepunchBitcoinOnly.ps1` | `bitcoinmining` + `_dev` (`lp_map_flatgrass`) |

See `DXRP_ULX_ONLY_LANE.md` · bitcoin lane: run Bitcoin script above, then restart editor.

## Sync commands (repo to DXRP when promoted)

```powershell
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
powershell -File lifepunch\scripts\Pull-DxrpCompiledAssetsToRepo.ps1 -Addon bitcoinmining
```

---

## Key paths (repo ident until migration)

| Entity | Prefab | Model |
|--------|--------|-------|
| Ophion hub | `entities/bitcoinminer/bitcoin-miner.prefab` | `models/.../bitcoin-miner/bitcoin-miner.vmdl` |
| GPU rack | `entities/gpurack/gpu-rack.prefab` | `models/.../gpu-rack/gpu-rack.vmdl` |
| Advanced rack | `entities/advancedgpurack/advanced-gpu-rack.prefab` | `models/.../gpu-rack/gpu-rack-stacked.vmdl` |
| Terminal | hub USE path → `HashdTerminal` | `bitcoin-terminal` mesh shared |

Code root: `Code/Addons/lifepunch/bitcoinmining/`
