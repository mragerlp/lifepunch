# LifePunch Addon Pipeline

This folder is the foundation for LifePunch addons on the DXRP.net network. The goal is to keep every addon package consistent before any single asset, prefab, or code file becomes complicated.

## Source Of Truth

This addon lane mirrors the DXRP game project layout:

```text
Assets/addons/lifepunch/<ident>/
Code/Addons/lifepunch/<ident>/
```

The central manifest at `config/addons.json` describes every LifePunch addon package. Scripts and validation should read that manifest instead of hard-coding addon names in multiple places.

Public DXRP addon pages are the reference for the finished publish shape. Track observed examples in `docs/OFFICIAL_ADDON_REFERENCE.md`, including the addon detail page, content tab, server usage metadata, and Code Explorer layout.

## Addon Package Vs Content Row

An addon package is the published DXRP package, such as `lifepunch.ak47` or `lifepunch.hackerjob`.

A content row is something the gamemode can reference from that package. One package may contain one content row, like AK47, or many rows, like a job/entity pack.

Keep these concerns separate:

- Addon package: identity, revision, assets/code folders, publish staging.
- Content row: `type`, prefab references, world model path, grouping, icon, config.
- Gamemode attachment: addon revision pinning, equipment rows, and market rows. Keep this in `../gamemode`.
- Server sync and hosted server change records belong in `../server`.

## Archetypes

### `weapon`

Use for guns and equipment that DXRP treats as equipment content.

- Content `type`: `1`.
- Required content fields: `primaryReference`, `secondaryReference`, `worldModelPath`, `grouping`.
- Typical grouping values: `Primary`, `Secondary`, `Utility`, `Melee`.
- Asset shape:

```text
Assets/addons/lifepunch/<ident>/
  equipment/w_<slug>/w_<slug>.prefab
  equipment/vm_<slug>/vm_<slug>.prefab
  models/lifepunch/<ident>/w_<slug>/w_<slug>.vmdl
```

AK47 will be rebuilt as the first `weapon` once the foundation validates.

### `simple-entity`

Use for spawnable world entities that do not need custom code yet.

- Content `type`: `0`.
- Required content fields: `primaryReference`.
- No `secondaryReference`.
- Prefabs should use DXRP entity components such as `Dxura.RP.Game.BaseEntity`.
- Asset shape:

```text
Assets/addons/lifepunch/<ident>/
  entities/<slug>/<slug>.prefab
  models/lifepunch/<ident>/<slug>/<slug>.vmdl
```

Hacker job props and other simple-entity props start here unless they need custom behavior.

### `interactive-entity`

Use for spawnable entities with custom behavior, services, interactions, or config.

- Content `type`: `0`.
- Required content fields: `primaryReference`.
- May use `baseConfig` and `configOverride`.
- Requires code under `Code/Addons/lifepunch/<ident>/`.
- Asset shape follows `simple-entity`, with code added beside it.

### `code-only`

Use for utilities that do not mount assets.

- No asset content rows unless the addon later changes archetype.
- Requires code under `Code/Addons/lifepunch/<ident>/`.
- Publish as a Code revision only.

## Reference Rules

All content references use forward slashes and never include the leading `Assets/`.

Correct:

```text
addons/lifepunch/ak47/equipment/w_ak47/w_ak47.prefab
addons/lifepunch/<ident>/entities/<entity>/<entity>.prefab
```

Incorrect:

```text
Assets/addons/lifepunch/ak47/equipment/w_ak47/w_ak47.prefab
addons\lifepunch\ak47\equipment\w_ak47\w_ak47.prefab
```

## Build Order

1. Keep `config/addons.json` accurate.
2. Run `scripts/validate-layout.ps1`.
3. Generate publish staging only when needed.
4. Compare the expected publish shape against official DXRP addon pages.
5. Rebuild AK47 as the first `weapon`.
6. Reuse the same manifest and validation pattern for entities and future tools.
