# Black Market hub — Fab Vault Safe world model

**Entity slug (planned):** `black-market-hub` · **Folder:** `entities/blackmarkethub/`  
**Source:** Fab [Vault Safe + Gold & Silver](https://www.fab.com/listings/66cf0cb2-65cf-4d95-a4dd-211020007d4a)  
**Addon ident:** `blackmarketdealer` — **not in `addons.json` yet** (Phase H prep lane)

## Intake

```powershell
powershell -File lifepunch/addons/scripts/Intake-BlackMarketHub.ps1
```

Drop: `OneDrive\Desktop\LIFEPUNCH™\addons\blackmarkethub`

Archive: `C:\lifepunch\reference-intake\blackmarketdealer\black-market-hub`

## Ship tree

```text
models/lifepunch/blackmarketdealer/black-market-hub/
  source/black-market-hub.fbx     ← Safe_Vault_FBX.fbx
  source/textures/safe-vault/     ← 2K Safe_Vault PBR
  source/textures/bullion/        ← 2K Bullion PBR
  materials/black-market-vault.vmat
  materials/black-market-bullion.vmat
  black-market-hub.vmdl
```

## ModelDoc (initial)

| Field | Value |
|-------|-------|
| Mesh | `source/black-market-hub.fbx` |
| Import scale | `1.0` — tune vs citizen on flatgrass |
| Align Z | Bottom |
| Slots | `Safe_Vault`, `Bullion` |

**Door:** No baked clips — rotate `Safe_Vault_Door` in Blender or code on hub power/open. Author also ships closed / ajar / open mesh variants in `Safe_Vault_TRIO.fbx` if needed.

## Gameplay (planned)

Hub = dealer admin + optional BTC payments (`lp-ops-crt--blackmarket` terminal is separate CRT entity).
