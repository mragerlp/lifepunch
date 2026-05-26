# AK47 Portal And Development Test

Date: 2026-05-26

This is an internal LifePunch operator note. Keep it outside `Assets/addons/lifepunch/ak47` and `Code/Addons/lifepunch/ak47` so it is not copied into DXRP publish staging.

## Local Preflight

Validated from the LifePunch workspace root:

```powershell
.\scripts\validate-workspace.ps1
```

Validated and regenerated publish staging from `lifepunch/addons`:

```powershell
.\scripts\validate-layout.ps1
.\scripts\prepare-publish.ps1 -Addon ak47
```

Built addon code from `lifepunch/addons/Code`:

```powershell
dotnet build .\addons.csproj
```

Result: validation and build passed with 0 warnings and 0 errors.

## Publish Inputs

Use generated upload root:

```text
lifepunch/addons/.dxrp-publish/upload
```

Use generated package export:

```text
lifepunch/addons/.dxrp-publish/package-ak47.json
```

Portal content row values from the package export:

```json
{
  "slug": "ak47",
  "label": "AK-47",
  "type": 1,
  "primaryReference": "equipment/w_ak47/w_ak47.prefab",
  "secondaryReference": "equipment/vm_ak47/vm_ak47.prefab",
  "worldModelPath": "addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/w_ak47.vmdl",
  "grouping": "Secondary"
}
```

## Initial Portal State Observed

AK47 addon:

- DXRP addon ID: `019e44aa-1d30-76fe-87f9-8a9f904bff9f`
- Visibility: `Private`
- Current revisions: `19` before the clean publish pass.
- Current content row type: `Equipment`
- Initial portal content JSON had empty `primaryReference`, `secondaryReference`, `grouping`, and `worldModelPath` fields.

LifePunch gamemode:

- DXRP gamemode ID: `019e36c0-a67f-701c-90f2-460e0b0f1487`
- AK47 installed revision: `Rev 18`
- AK47 latest revision: `Rev 19`
- Portal reports `Update Available`.

Servers:

- `LifePunch Official | DEVELOPMENT SERVER` is online with 0 players at preflight time.
- `LifePunch Official | 70p` must not be synced for this AK47 test.

## Publish And Pin Result

- AK47 `Rev 21` was published successfully from sanitized staging.
- Sanitized staging excluded `docs`, `.md` files, and internal build metadata.
- The sanitized upload was scanned for personal paths and reference/addon terms before publishing.
- AK47 `Rev 21` was pinned and saved on the LifePunch gamemode.
- AK47 was added to the LifePunch gamemode Market tab because the in-game Market section is populated from gamemode market rows.
- Ignore the Base Content update shown in the portal because it is not live yet.
- `LifePunch Official | DEVELOPMENT SERVER` uses the `LifePunch` gamemode and is the runtime test target.
- `LifePunch Official | 70p` must remain on the vanilla gamemode.

## Runtime Test Observation

- AK47 and AK47 Shipment appeared in the in-game Market on the development server.
- Purchasing/spawning showed a large orange `ERROR` model around the AK47 shipment.
- Likely cause: `w_ak47.vmdl` references `addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/source/ak47.fbx`, but the first sanitized upload excluded the `source` folder.
- Remediation: publish a new revision from regenerated staging that includes `source/ak47.fbx` after sanitizing embedded local path metadata in the generated upload copy.
- Expected fixed upload counts: code `2` files, assets `56` files.
- Follow-up publish result: `Rev 23` includes the sanitized AK47 model source and has the intended changelog.
- `Rev 22` was an extra intermediate no-changelog revision and should not be treated as the active test target.
- `Rev 23` still showed orange `ERROR` models in-game after the sanitized source was included.
- `Rev 24` still showed orange `ERROR` models in-game.
- Portal Rev 24 asset ZIP inspection confirmed DXRP stores uploaded asset packages relative to the selected `ak47` folder root: `equipment/`, `models/`, and `sounds/`.
- `Rev 25` updated the local package-root asset references, but the live portal content JSON still showed `primaryReference` and `secondaryReference` as `addons/lifepunch/ak47/equipment/...`.
- Current likely cause: the runtime is still loading the world/viewmodel prefabs from content-row paths that do not exist in the published asset ZIP.
- Remediation: publish a follow-up revision after changing the live portal content JSON to package-root `primaryReference` and `secondaryReference` values.
- Follow-up publish result: `Rev 26` has package-root content row references in the live portal JSON:
  - `primaryReference`: `equipment/w_ak47/w_ak47.prefab`
  - `secondaryReference`: `equipment/vm_ak47/vm_ak47.prefab`
  - `worldModelPath`: `models/lifepunch/ak47/w_ak47/w_ak47.vmdl`
- Follow-up gamemode result: `Rev 26` is pinned on the LifePunch gamemode for `lifepunchdevelopment`.
- `Rev 26` still showed a large orange `ERROR` model around the AK47 shipment.
- Next likely cause: DXRP loads shipment and dropped-equipment previews through `GameModeEquipmentDto.GetWorldModel()`, which passes `worldModelPath` directly to `Model.Load`. Unlike `primaryReference` and `secondaryReference`, `worldModelPath` likely needs the full addon-mounted path.
- Next publish target: keep prefab references package-root, but set `worldModelPath` to `addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/w_ak47.vmdl`.
- AK47 content grouping is `Secondary`.
- AK47 market row is a shipment-style equipment row:
  - `grouping`: `#entity.category.shipment`
  - `cost`: `5000`
  - `limit`: `5`
  - `quantity`: `5`

## Current Development Test Gate

1. Confirm the development server loads the saved LifePunch gamemode state without affecting server 1.
2. Confirm AK47 appears in the in-game Market section on the development server.
3. Runtime test AK47 purchase/grant, equip, world model, viewmodel, fire, reload, ammo, muzzle/ejection effects, and sounds.
4. Record runtime errors before considering any wider rollout.

Do not sync `lifepunchmainserver`; it must remain on the vanilla gamemode.
