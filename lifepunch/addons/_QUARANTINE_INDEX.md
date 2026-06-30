# Addon quarantine index

**Status:** Restructure Phase 2a — visibility only (no folder moves).  
**Updated:** 2026-06-30

Agents: read this **before** editing anything under `Code/Addons/lifepunch/` or `Assets/addons/lifepunch/`.

---

## Law (short)

| Status | Compile | Edit | Ship |
|--------|---------|------|------|
| **Active** | Yes | Yes (within ACTIVE_WORKSTREAM) | When owner + portfolio says ready |
| **Staging** | Yes (partial tree) | Yes (active lane only) | Not until promotion complete |
| **Quarantined** | **No** (`addons.csproj` Remove) | **No** without owner promotion | **Never** from quarantine |
| **`_dev`** | Dev helpers only | Owner-only | Never |

Full law: `docs/QUARANTINE_REGISTER.md` · manifest: `config/portfolio.json`

---

## Active (build + ship path)

| repoIdent | packageSlug (public) | s&box ident | Code path | Asset staging |
|-----------|----------------------|-------------|-----------|---------------|
| `adminmenu` | `lifepunchulx` | `lifepunch.lifepunchulx` | `Code/Addons/lifepunch/adminmenu/` | `Assets/addons/lifepunch/adminmenu/` |
| `bitcoinmining` | `lifepunchbitcoin` | `lifepunch.bitcoin` | `Code/Addons/lifepunch/bitcoinmining/` | `Assets/addons/lifepunch/bitcoinmining/` + legacy |

**Staging (active lane, not a separate portfolio ident):**

| Tree | Role |
|------|------|
| `Code/Addons/lifepunch/lpbitcoin/` | Per-entity hub code (`bitcoinhub/`, …) |
| `Assets/addons/lifepunch/lpbitcoin/` | Entity slugs: `bitcoinhub`, `hashdterminal`, `gpurack` |

See `docs/PACKAGE_STAGING_LAYOUT.md` · `docs/DXRP_ADDON_PUBLISH_DOCTRINE.md`.

---

## Quarantined (frozen — context only)

Listed in `config/portfolio.json` → `quarantinedAddons`. C# excluded via `Code/addons.csproj` `<Compile Remove="...">`.

| repoIdent | Reason (summary) | Code | Assets (may exist) |
|-----------|------------------|------|---------------------|
| `ak47` | Viewmodel baseline; `lane/ak47` branch | `ak47/` | `Assets/.../ak47/`, `lpweapons/` |
| `hackerjob` | Resume as separate lane after Bitcoin | `hackerjob/` | `hackerjob/`, `lphacker/` |
| `bankerjob` | WIP; promote from brief | `bankerjob/` | `lpbanker/` |
| `governmentdatacenter` | After Bitcoin economy | `governmentdatacenter/` | `governmentdatacenter/`, `lpgovernment/` |
| `advanceddrugprocessing` | Economy not signed off | `advanceddrugprocessing/` | `lpchemist/` |
| `additionaldroplocations` | Map coords unset | `additionaldroplocations/` | various |
| `deagle` | Weapon draft queue | `deagle/` | weapon assets |
| `mp9` | Weapon draft queue | `mp9/` | weapon assets |
| `ssg08` | Weapon draft queue | `ssg08/` | weapon assets |
| `xm1014` | Weapon draft queue | `xm1014/` | weapon assets |
| `doublebarrelshotgun` | Foundation-only assets | `doublebarrelshotgun/` | assets only |
| `uraniumspecialist` | Intake pause | `uraniumspecialist/` | assets |
| `visiblepocket` | HUD policy paused | `visiblepocket/` | minimal |

**Also quarantined / parallel lanes (not in portfolio list):**

| Item | Notes |
|------|-------|
| Git branch `lane/ak47` | AK paths only — never merge without owner sign-off |
| `Assets/addons/lifepunch/*` job stubs | Many `lp*` folders (casino, police, blackmarket, …) — **no active Code** until promotion |

Do **not** copy quarantined prefabs, SCSS, or C# into `adminmenu` or `bitcoinmining`.

---

## Dev-only

| Path | Purpose |
|------|---------|
| `Code/Addons/lifepunch/_dev/` | Local dev helpers — not ship |

---

## Promotion checklist (owner)

To move an ident from quarantined → active:

1. Owner + Architect brief GO
2. Update `config/portfolio.json` (`activeAddons`, remove from `quarantinedAddons`)
3. Remove matching `<Compile Remove="...">` from `Code/addons.csproj`
4. Update `ACTIVE_WORKSTREAM.md` gate
5. Flatgrass proof before publish export

---

## Related

- `docs/QUARANTINE_REGISTER.md`
- `config/portfolio.json`
- `lifepunch/docs/RESTRUCTURE_ROADMAP.md` — Phase 2b optional physical `_quarantined/` move
- `reference/` (repo root) — third-party study; **not** our quarantine WIP
