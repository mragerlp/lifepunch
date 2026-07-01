---
applyTo: "**"
description: "LifePunch DXRP addon foundation rules"
sourceRule: ".cursor/rules/dxrp-addon-foundation.mdc"
---

> **Synced from** `.cursor/rules/dxrp-addon-foundation.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch DXRP Foundation

- Treat this repo as the LifePunch DXRP server workspace.
- Keep all community work under the main `lifepunch/` folder.
- Keep addon package work in `lifepunch/addons/`.
- Keep gamemode work in `lifepunch/gamemode/`.
- Keep hosted server records and audits in `lifepunch/server/`.
- Keep DXRP portal tab documentation in `lifepunch/portal/`.
- Keep staff role and permission policy in `lifepunch/admin-panel/`.
- Keep trademark, brand-architecture, and proprietary-IP doctrine in `lifepunch/legal/` (canonical: `lifepunch/legal/TRADEMARK_AND_IP.md`). Trademark specimens live in `lifepunch/legal/specimens/`, mark drawings + logo filing in `lifepunch/legal/marks/`, and clearance evidence in `lifepunch/legal/clearance-evidence/`. Never commit sensitive identifiers (EIN, domicile street address) — they stay in OneDrive.
- Treat `lifepunch/addons/config/addons.json` as the source of truth for LifePunch addon packages.
- Treat `lifepunch/addons/config/packages.json` as the source of truth for **packageSlug** (public branch names) and target **sboxIdentifier** values. Each registered addon in `addons.json` should carry a matching `packageSlug`. Repo folder paths use legacy **ident** until path migration (`PACKAGE_NAMING_STANDARD.md`).
- Keep addon assets under `lifepunch/addons/Assets/addons/lifepunch/<ident>/`.
- Keep addon code under `lifepunch/addons/Code/Addons/lifepunch/<ident>/`.
- Do not use flat `upload-assets/` or `upload-code/` folders as canonical source.
- **Proprietary header on EVERY source file.** Every LifePunch-authored code file (`.cs`, `.razor`, `.razor.scss`, and any future source) MUST begin with the canonical proprietary header before any `using`/`namespace`/`@namespace`/style declaration. No exceptions, including dev-only/test helpers. Use `//` comments for `.cs`/`.scss` and a `@* ... *@` block for `.razor`. Fill the name slot from `addons.json` for that addon: `"<title>" (s&box ident: <sboxIdentifier-or-lifepunch.<ident>> · addon ident: <dxrpAddonIdentifier-or-<ident>>)`. Canonical text:

```
// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "<ADDON TITLE>" (s&box ident: <s&box ident> · addon ident: <addon ident>) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────
```
- Separate addon package data, content row data, and gamemode attachment data.
- Refer to `https://github.com/dxura/dxrp/tree/develop` when evaluating compatibility with the official DXRP gamemode.
- Refer especially to `https://github.com/dxura/dxrp/tree/develop/game` when shaping LifePunch's main repository and gamemode structure.
- If LifePunch infrastructure improvements do not conflict with DXRP's project direction, consider whether they can be proposed upstream to the official DXRP project.
- Validate with `scripts/validate-workspace.ps1` at the repo root and `lifepunch/addons/scripts/validate-layout.ps1` for addon work.
- **Entity / prop work:** machines not props — `lifepunch/addons/docs/LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` · ModelDoc P0 gate: `MODEL_FOUNDATION_PASS.md` · staging: `PACKAGE_STAGING_LAYOUT.md`.
- **Weapon work:** weapon platform not gun mesh — `lifepunch/addons/docs/LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` · intake: `WEAPON_INTAKE.md` · FP rig: `VIEWMODEL_RIG_PIPELINE.md`.
- Rebuild AK47 only through the reusable pipeline; do not make it a one-off exception.
