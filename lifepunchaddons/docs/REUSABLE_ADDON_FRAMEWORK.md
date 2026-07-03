# Reusable Addon Framework

This document captures the reusable LifePunch addon workflow proven while building AK47.

AK47 is the first working weapon target, but the framework must carry forward to future weapons, tools, entities, and more complex addon packages.

## Reusable Rules

- Keep clean addon source under `lifepunchaddons/Assets/addons/lifepunch/<ident>/` and `lifepunchaddons/Code/Addons/lifepunch/<ident>/`.
- Keep raw downloads, Blender work, screenshots, alternates, and experiments in the local reference mirror first.
- Promote only cleaned, named, ready files into the main repo.
- Track every package in `config/addons.json`.
- Separate addon package data, content row data, gamemode attachment data, and server sync records.
- Use public DXRP addon pages as structural references only.
- Keep all code and package identity LifePunch-owned.

## Weapon Pattern

Future LifePunch weapons should follow the same intake and source shape:

```text
Assets/addons/lifepunch/<ident>/
  equipment/w_<slug>/w_<slug>.prefab
  equipment/vm_<slug>/vm_<slug>.prefab
  models/lifepunch/<ident>/w_<slug>/
    source/<slug>.fbx
    textures/
    materials/
    w_<slug>.vmdl
  sounds/

Code/Addons/lifepunch/<ident>/
```

Weapon content rows use:

- `type`: `1`
- `primaryReference`: world prefab
- `secondaryReference`: viewmodel prefab
- `worldModelPath`: mounted model path
- `iconPath`: optional mounted UI image path for kill-feed/display icons; use a leading `/` when the path is passed into DXRP `<Icon>` UI components
- `grouping`: `Primary`, `Secondary`, `Utility`, or `Melee`

## AK47-Specific Choices

These choices should not automatically leak into every future weapon:

- AK47 grouping is `Secondary`.
- AK47 uses `w_ak47` and `vm_ak47`.
- AK47 first-pass viewmodel prefab currently uses the same `w_ak47.vmdl` as the world prefab.
- AK47 damage, recoil, spread, reload, ammo, and sound names are weapon-specific tuning.
- AK47 model attribution is specific to the Sketchfab source by `wburton` / `@wburton95`.

## Public Reference Boundary

Public examples such as Simple Weapon Base are reference material only.

Do not copy:

- Namespaces.
- Package identifiers.
- Group/category labels.
- Server/community names.
- Branding such as `SWB`, `SWE`, or `BeCreativeRP`.

Translate useful architecture into LifePunch-owned code only after confirming it is needed for DXRP.

## Runtime Implementation Direction

For AK47, the next runtime pass should stay narrow:

- LifePunch-owned namespace.
- Weapon identity and metadata.
- Prefab references.
- Ammo/clip settings.
- Fire rate and primary attack.
- Reload timing.
- Sound hooks.

Only split into larger partial/component architecture when real complexity requires it.
