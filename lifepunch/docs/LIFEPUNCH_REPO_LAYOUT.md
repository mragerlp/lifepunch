# LIFEPUNCH™ — Monorepo layout (Red workspace)

**Status:** Active — July 2026  
**Read with:** `PATH_CANON_VENGEANCE.md` · `REPO_DOMAIN_MAP.md` · `BRANCH_MODEL.md`

---

## One mental model

**GitHub:** `github.com/mragerlp/lifepunch`  
**Red clone path:** `C:\Users\jared\Projects\lifepunch` (not `lifepunchaddons` at Projects root)

Three **top-level trees** inside the monorepo:

| Folder | Role |
|--------|------|
| **`lifepunch/`** | Ops — docs, scripts, server, platform, business, tooling |
| **`lifepunchaddons/`** | Product — s&box addon packages (`lpbitcoin`, `lphacker`, …) |
| **`lifepunchdxrp/`** | Nested **DXRP fork** clone for editor testing (separate git root; ignored by monorepo) |

**Retired:** `C:\Users\jared\Projects\lifepunchaddons` as a **workspace/repo root** — that name is only the **in-repo product folder** now.

---

## Branch law for `lifepunchaddons/`

Same folder paths on **`develop`** and **`main`** — branch selects **maturity**, not layout:

| Branch | `lifepunchaddons/` content |
|--------|------------------------------|
| **`develop`** | Editor testing — WIP assets, flatgrass proof, ModelDoc iteration |
| **`main`** | Publish-ready format — export/portal shape after owner GO |

Ship flow: work on **`develop`** → PR **`develop` → `main`** → sync **`main` → `develop`**.

---

## Package layout (inside `lifepunchaddons/`)

```text
lifepunchaddons/
├── config/                 # addons.json, portfolio.json (registry)
├── lpbitcoin/              # lifepunch.bitcoin package
├── lphacker/               # (future / quarantine promote)
├── lifepunchulx/           # adminmenu publish lane
└── …
```

Editor sync mounts packages from here into the nested DXRP tree under **`lifepunchdxrp/`** for playtest.

---

## Nested DXRP fork (`lifepunchdxrp/`)

- **Remote:** `mragerlp/dxrp-public` + `upstream` → `dxura/dxrp`
- **Purpose:** Latest pulled DXRP + LifePunch addon mount for **Red Host Play / flatgrass proof**
- **Not tracked** in the monorepo git index (nested `.git` — see root `.gitignore`)
- **Bootstrap:** `lifepunch\scripts\Setup-LifepunchProjectsLayout.ps1`

Legacy sibling clone `C:\Users\jared\Projects\dxrp` is migrated into this folder and retired.

---

## Related paths

| Machine | Monorepo root |
|---------|----------------|
| **Red (VENGEANCE)** | `C:\Users\jared\Projects\lifepunch` |
| **Green (Cornerman)** | `C:\Projects\lifepunch` |
| **Architect (Mac)** | `~/Projects/lifepunch` |

Steam runtime (not git): `D:\Steam\steamapps\common\sbox\dxrp`
