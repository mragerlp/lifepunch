# Additional Drop Locations — Runtime pattern

Adds **extra weed brick sell zones** on LifePunch servers by spawning the core DXRP gamemode prefab after map fitting.

## How DXRP drug drops work (gamemode core)

| Piece | Path |
|-------|------|
| Logic | `Dxura.RP.Game.DrugDrop` |
| Prefab | `prefabs/world/drug_drop.prefab` |
| Sell tag | `weed_brick` |
| Payout | `DrugDropMinPrice`–`DrugDropMaxPrice` (gamemode config) |

Default map fitting already places three `drug_drop` instances (e.g. `rp_downtown_scuffed_fitting.prefab`). This addon adds **more** without editing map fitting prefabs.

## Addon architecture

| File | Role |
|------|------|
| `AdditionalDropLocations.cs` | Package constants + `DropSite` list (enable + world transform per site) |
| `AdditionalDropLocationsService.cs` | `[AddonService]` host; `IGameEvents.OnMapFitted` → clone + `NetworkSpawn` drug drops |
| `config/drop-sites.json` | Machine-readable mirror of site config (sync manually until codegen) |

### Dual build

- **`#if !LIFEPUNCH_LOCAL`** — full DXRP service (economy-touching).
- **Local editor** — constants file only; service omitted (same pattern as `WaypointSyncService`).

## Cosmetic props (phase 2)

Blender study source (never commit):

```text
C:/lifepunch/reference-intake/additional-drug-drops/subway/
C:/lifepunch/reference-intake/additional-drug-drops/truck/
```

Intake script: `addons/scripts/Intake-AdditionalDropLocations.ps1`

Ship path (future): `Assets/addons/lifepunch/additionaldroplocations/models/...` spawned beside each drug drop trigger.

## Ship gates

- **Opus review** before enabling any `DropSite.Enabled = true` on production.
- Set real `Position` / `Rotation` per target map on VENGEANCE (editor or fitting pass).
- Portal package + `dxrpAddonId` in `addons.json` before publish.
