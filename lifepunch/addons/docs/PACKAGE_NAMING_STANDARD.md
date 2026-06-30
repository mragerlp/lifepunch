# LIFEPUNCH™ — package naming standard

**June 2026** — Bloodwave law for **public branches** and all addon packages on LIFEPUNCH™ servers.

Canonical manifest: `config/packages.json`

---

## The standard

Every shippable addon uses **one concatenated package slug**:

```text
lifepunch{product}     (all lowercase — e.g. lifepunchbitcoin, lifepunchulx)
```

| Layer | Rule | Example |
|-------|------|---------|
| **packageSlug** | Public name, Git branch, ChatGPT briefs, publish folder target | `lifepunchbitcoin` |
| **packageFolder** | **Parent path on disk** — always `lp{product}` under `lifepunch/addons/` | `lpbitcoin`, `lphacker`, `lpbanker`, `lifepunchulx` |
| **s&box identifier** | `lifepunch.` + slug without `lifepunch` prefix | `lifepunch.bitcoin` |
| **LIFEPUNCH™ display** | Lead mark on titles; DXRP nominative only; ™ not ® | LIFEPUNCH™ Bitcoin Miner for DXRP |
| **repoIdent** | **Legacy** monorepo code folder until Phase 4 migration — do not add new files | `bitcoinmining`, `hackerjob`, `adminmenu` |
| **Proprietary** | Headers + `addons.json` ownership on **every** package — server-only now, sellable later | always on |

**Package parent path (locked 2026-06-30):** all addon work lives under `lifepunch/addons/{packageFolder}/` with `Code/`, `Assets/`, `docs/`, and eventually `{product}.sbproj`. Detail: `PACKAGE_STAGING_LAYOUT.md`.

**SWAT:** package slug `lifepunchswat` (lowercase on disk). Player-facing may say SWAT.

---

## Registered packages (public branch set)

| packageSlug | s&box | repoIdent (today) | Status |
|-------------|-------|-------------------|--------|
| `lifepunchulx` | `lifepunch.lifepunchulx` | adminmenu | publish-ready |
| `lifepunchbitcoin` | `lifepunch.bitcoin` | bitcoinmining | active dev |
| `lifepunchhacker` | `lifepunch.hacker` | hackerjob | quarantine |
| `lifepunchbanker` | `lifepunch.banker` | bankerjob | quarantine WIP |
| `lifepunchswat` | `lifepunch.swat` | — | reserved |
| `lifepunchak47` | `lifepunch.ak47` | ak47 | quarantine |
| `lifepunchdrugprocessing` | `lifepunch.drugprocessing` | advanceddrugprocessing | quarantine |
| `lifepunchdrugdrops` | `lifepunch.drugdrops` | additionaldroplocations | quarantine |
| `lifepunchdeserteagle` | `lifepunch.deserteagle` | deagle | quarantine |
| `lifepunchdoublebarreledshotgun` | `lifepunch.doublebarreledshotgun` | doublebarrelshotgun | quarantine |

Weapons/mp9/ssg08/xm1014 and others **not** in this public set until owner adds rows to `packages.json`.

---

## Posture (owner law)

- **In-house, in-house** — original assets and code; no third-party ship trees.
- **LifePunch servers first** — built for our DXRP servers; not optimizing third-party resale **now**.
- **Unique to us** — others can make their own; we keep proprietary layer intact.
- **Public branch** — each `packageSlug` is what we branch/export on LIFEPUNCH™ when promoted.
- **IP intact** — headers, no-redistribution, TOS — even while not selling.

---

## Migration (repo paths)

**Law locked 2026-06-30:** target parent = `lifepunch/addons/{packageFolder}/`. Legacy **`repoIdent`** paths (`Code/.../bitcoinmining/`, `hackerjob/`, …) are transitional until Phase 4 `git mv` slices.

| When promoted | Action |
|---------------|--------|
| Portal/public | Export under `packageSlug`; `sboxIdentifier` from manifest |
| Phase 4a–4b | Consolidate code/assets under `lifepunch/addons/lp*/`; retire `repoIdent` folder |
| Phase 6 | Extract per-package `.sbproj` — see `RESTRUCTURE_TARGET_LAYOUT.md` |

Do **not** add new files under legacy `repoIdent` folders when `packageFolder` exists in `package-staging.json`.

---

## ChatGPT / Cursor

Use **packageSlug** in briefs:

```text
Product: lifepunchbitcoin — Ophion visual pass
Addon ident (s&box): lifepunch.bitcoin
```

---

## Related

- `config/packages.json` — machine manifest
- `config/portfolio.json` — active vs quarantine vs publish
- `PACKAGE_STAGING_LAYOUT.md` — packageFolder parent path law
- `legal/TRADEMARK_AND_IP.md` — mark doctrine
