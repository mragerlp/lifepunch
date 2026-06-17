# LifePunch — model intake drop map (owner → repo)

> **June 2026 foundation reset:** Entity ↔ folder mappings below are **reference only** until you define the new map. Staging lane: `_modeldoc/` + `DXRP_MODELDOC_GREENFIELD_LANE.md`. Agent waits for your assignments.

**Purpose:** You name folders; drop FBX (+ textures); agent runs ModelDoc → **foundation sign-off** → promote → **Phase 1 collision** → existing entity code stays on prefab.

**Fab list incoming:** use `FAB_MODEL_MANIFEST_TEMPLATE.md` (Fab URL + intended role per row).

**Code intact law:** model swaps touch **Assets only** (`source/`, vmdl, vmat, prefab `ModelRenderer` + collider bake). **Never** replace `Code/Addons/...` entity logic, Razor UI, RPC, or `addons.json` slugs unless you approve a **new** entity.

**Colors do not matter** — only which folder maps to which shipped entity.

**Phase 1 gate (every prop):** white mesh wireframe = BoxCollider **Center X,Y,Z** + **Scale X,Y,Z** (red/green/blue gizmo box). Feet on floor in play. No walk-through.

---

## Where to drop files (OneDrive — preferred)

Canonical root (already used by intake scripts):

```text
%USERPROFILE%\OneDrive\Desktop\LIFEPUNCH*\addons\
```

Create **one folder per row** below. Each folder should contain:

- `source\<name>.fbx` (or `<name>.fbx` at folder root — agent normalizes)
- `textures\` if PBR maps are separate
- optional `.blend` (archived to `C:\lifepunch\reference-intake\`, not required in ship tree)

| Drop folder (under `addons\`) | Shipped entity | Repo model path | Prefab | Game code |
|-------------------------------|----------------|-----------------|--------|-----------|
| `lifepunchbitcoin\bitcointerminal\` | bitcoin-terminal | `bitcoinmining/models/.../bitcoin-terminal/` | `entities/bitcoin-terminal/bitcoin-terminal.prefab` | `LpBitcoinTerminalEntity` |
| `lifepunchbitcoin\bitcoinminer\` | bitcoin-miner (hub) | `bitcoinmining/models/.../bitcoin-miner/` | `entities/bitcoinminer/bitcoin-miner.prefab` | `LpBitcoinHubEntity` |
| `lifepunchhacker\hacker\hackerterminal\` | hacker-terminal | `hackerjob/models/.../hacker-terminal/` | `entities/hacker-terminal/hacker-terminal.prefab` | `HackerTerminalEntity` |
| `lifepunchhacker\hacker\advancedhackerterminal\` | advanced-hacker-terminal | `hackerjob/models/.../advanced-hacker-terminal/` | `entities/advanced-hacker-terminal/advanced-hacker-terminal.prefab` | `HackerTerminalEntity` (Advanced tier) |
| `lifepunchhacker\hacker\serverrack\` | server-rack | `hackerjob/models/.../server-rack/` | `entities/server-rack/server-rack.prefab` | `HackerServerRackEntity` |
| `lifepunchhacker\hacker\advancedserverrack\` | advanced-server-rack | `hackerjob/models/.../advanced-server-rack/` | `entities/advanced-server-rack/advanced-server-rack.prefab` | `HackerAdvancedServerRackEntity` |
| `lifepunchhacker\fbi\governmentserverrack\` | government-server-rack | `governmentdatacenter/models/.../government-server-rack/` | `entities/government-server-rack/` | *(gov rack — wire on intake)* |
| `lifepunchhacker\fbi\governmentterminal\` | police-terminal | `governmentdatacenter/models/.../police-terminal/` | `entities/police-terminal/police-terminal.prefab` | `PoliceTerminal` UI host |
| `lifepunchblackmarketdealer\blackmarkethub\` | black-market-hub | `blackmarketdealer/models/.../black-market-hub/` | `entities/blackmarkethub/` | *(BM hub — wire on intake)* |
| `lifepunchblackmarketdealer\blackmarketterminal\` | black-market terminal | *(TBD slug on intake)* | *(TBD)* | terminal pattern |

### Not swapping mesh (collision-only on current art)

| Entity | Drop folder | Work |
|--------|-------------|------|
| `gpu-rack` | `lifepunchbitcoin\gpurack\` | **Keep** existing FBX — Phase 1 collider + fan child GOs only |
| `advanced-gpu-rack` | same family | **Keep** stacked vmdl — clone gpu-rack collision pattern |

---

## Alternate drop (any path)

If you use Downloads or a zip, tell the agent the **full path** and **which entity row** each pack is for. OneDrive layout above is optional but fastest (intake scripts auto-resolve).

---

## Agent workflow per drop (do not skip steps)

1. **Intake** — copy FBX/textures into repo `models/.../source/` (run matching `Intake-*.ps1` or manual copy + archive to `reference-intake`).
2. **ModelDoc** — `import_scale` @ prefab `1,1,1`, `import_translation [0,0,0]`, align **Center / Center / Bottom**, compile vmdl + vmats.
3. **Prefab** — keep `Rigidbody`, `BoxCollider`, entity component, `lcd_screen` child; update `ModelRenderer.Model` only if path unchanged.
4. **Collider** — `OnAwake` → `LifePunchPropPhysics.SyncBoxColliderFromModel` (all axes = white wireframe).
5. **Verify** — bridge orbit + `lp_bitcoin_scale_audit` (bitcoin lane) or flatgrass spawn for other lanes.
6. **Pull** — `Pull-DxrpCompiledAssetsToRepo.ps1` for `_c` files.
7. **Phase 2** — fans / LEDs only after you sign off Phase 1.

### CRT terminal trio

Same layout family (bitcoin + hacker + advanced hacker): tune **`lcd_screen`** once, clone transform across the three prefabs.

---

## Intake scripts (repo)

| Entity | Script |
|--------|--------|
| bitcoin-terminal | `addons/scripts/Intake-BitcoinTerminalAssets.ps1` |
| bitcoin-miner hub | `addons/scripts/Intake-BitcoinMinerHub.ps1` |
| hacker-terminal | `addons/scripts/Intake-HackerTerminalModel.ps1` |
| advanced-hacker-terminal | `Intake-AdvancedHackerTerminal.ps1` *(parked — re-enable on drop)* |
| server-rack | `Intake-HackerServerRack.ps1` |
| advanced-server-rack | `Intake-AdvancedServerRack.ps1` |
| government-server-rack | `Intake-GovernmentServerRack.ps1` |
| government-terminal | `Intake-GovernmentTerminal.ps1` |
| black-market-hub | `Intake-BlackMarketHub.ps1` |

---

## When you send files

Message format (copy per pack):

```text
Entity: bitcoin-terminal
Drop path: C:\Users\...\OneDrive\Desktop\LIFEPUNCH\addons\lifepunchbitcoin\bitcointerminal
Main FBX: source/computer.fbx
Notes: (optional)
```

Agent will confirm mapping, intake, Phase 1, then ask you to reopen prefab tab and sign off white = colored box on all axes.
