# lifepunchbitcoin — start here (Ophion P0)

**Package:** `lifepunchbitcoin` · **s&box:** `lifepunch.bitcoin` · **repo folder:** `bitcoinmining` (until NAME-01 migration)

Read first: `PACKAGE_NAMING_STANDARD.md` · `briefs/BITCOIN_OPHION_CURSOR_BRIEF.md` · quarantine law in `portfolio.json`.

---

## What “from scratch” means

We are **not** deleting the repo tree. We are restarting **ship work** under the canonical package identity:

1. **Identity** — product = `lifepunchbitcoin`, mount = `lifepunch.bitcoin`, paths = `bitcoinmining/` for now.
2. **Scope** — Ophion **hub visual pass** on flatgrass only (P0 in brief). No new meshes, no portal publish, no quarantine addons.
3. **Architecture** — keep hub + GPU racks + HASHD terminal; rebuild **player-readable power/mining states** and hub aesthetics.

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
lp_spawn_bitcoin_miner_hub_only
```

5. MCP: orbit screenshots of hub scale, glass/interior, citizen height.
6. Optional full kit: `lp_spawn_bitcoin_miner_hub` (hub + racks).

---

## P0 deliverables (sign-off gate)

| # | Done when |
|---|-----------|
| 1 | Hub vmdl/vmat compile clean; no P0 log spam |
| 2 | Hub on flatgrass — screenshot proof (MCP) |
| 3 | Rack LED/emissive baseline readable |
| 4 | Powered hub + mining loop playtest |
| 5 | HASHD copy = amber ops (not hacker green) |
| 6 | Owner visual sign-off → then publish lane export |

**Not P0:** Hardware Shop, generators, multi-room tiers, portal listing.

---

## Sync commands (repo ↔ DXRP)

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
| Large rack | `entities/largegpurack/large-gpu-rack.prefab` | `models/.../gpu-rack/gpu-rack-stacked.vmdl` |
| Terminal | hub USE path → `HashdTerminal` | `bitcoin-terminal` mesh shared |

Code root: `Code/Addons/lifepunch/bitcoinmining/`
