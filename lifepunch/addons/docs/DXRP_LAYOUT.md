# DXRP Layout Contract

This folder is the clean source of truth for LifePunch DXRP addon packages. It mirrors a DXRP game project instead of storing each addon in its own package-shaped folder.

## Canonical Folders

```text
Assets/
  addons/
    official/      # DXRP / official asset reference lane
    lifepunch/     # LifePunch addon assets
Code/
  Addons/
    Official/      # DXRP / official code reference lane
    lifepunch/     # LifePunch addon code
```

LifePunch addon identities use the package formula `lifepunch.<ident>`. The folder name under both LifePunch lanes must match `<ident>`.

Examples:

```text
Assets/addons/lifepunch/ak47/
Code/Addons/lifepunch/ak47/
```

## Gamemode References

Gamemode content rows reference mounted asset paths with forward slashes. They do not include the leading `Assets/` folder.

Weapon example:

```text
addons/lifepunch/ak47/equipment/w_ak47/w_ak47.prefab
addons/lifepunch/ak47/equipment/vm_ak47/vm_ak47.prefab
addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/w_ak47.vmdl
```

Entity example:

```text
addons/lifepunch/<ident>/entities/<entity>/<entity>.prefab
```

## Publish Rule

Do not rebuild the old flat publish folders as the canonical format:

```text
upload-assets/
upload-code/
```

If a publish script needs staging later, it must preserve the DXRP project roots:

```text
upload/
  Assets/addons/lifepunch/<ident>/
  Code/Addons/lifepunch/<ident>/
```

## Manifest And Pipeline

The pipeline foundation lives in `docs/ADDON_PIPELINE.md`. Addon packages are declared in `config/addons.json` before content rows, prefabs, code, or publish output are added.

Keep addon package data separate from gamemode attachment data:

- Package data controls `lifepunch.<ident>`, asset/code folders, and publish staging.
- Content rows control primary/secondary prefab references, world model paths, grouping, icons, and config.
- Gamemode data controls revision pinning, equipment rows, and market rows. Keep that data in `../gamemode`.
- Server data controls hosted server records and sync/change audits. Keep that data in `../server`.

## Current Build Order

1. Keep this skeleton valid.
2. Keep `config/addons.json` valid.
3. Generate publish staging from the DXRP roots only.
4. Rebuild `ak47` only after the reusable addon pipeline validates.
5. Repeat for the remaining LifePunch addons.
