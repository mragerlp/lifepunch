# LifePunch Addons

Fresh DXRP-shaped workspace for LifePunch addon assets, code, manifests, and publish staging.

This folder intentionally mirrors the layout DXRP mounts into a game project:

```text
Assets/addons/<org>/<ident>/
Code/Addons/<org>/<ident>/
```

LifePunch addon work belongs under:

```text
Assets/addons/lifepunch/
Code/Addons/lifepunch/
```

The `official` / `Official` folders are reference lanes for DXRP or official gamemode structure only. Do not place LifePunch addon work there.

Open this folder in S&box through:

```text
addons.sbproj
```

This project file is the local S&box editor entry point for the LifePunch addon workspace. It does not replace the manifest-driven DXRP package structure.

Start with the foundation docs:

- `docs/DXRP_LAYOUT.md` explains the DXRP mount layout.
- `docs/ADDON_PIPELINE.md` explains addon archetypes and the manifest-first workflow.
- `docs/WEAPON_INTAKE.md` explains the repeatable source intake process for weapons.
- `docs/REUSABLE_ADDON_FRAMEWORK.md` explains what should carry forward from AK47 to future LifePunch addons.
- `docs/OFFICIAL_ADDON_REFERENCE.md` tracks official/public DXRP addon page examples.
- `docs/PUBLISHING.md` explains generated publish staging.
- `config/addons.json` is the source of truth for LifePunch addon packages.

Validate the addon lane with:

```powershell
.\scripts\validate-layout.ps1
```

Generate publish staging only when needed:

```powershell
.\scripts\prepare-publish.ps1 -Addon ak47
```
