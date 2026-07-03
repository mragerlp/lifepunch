# VENGEANCE — Projects folder path canon

**Updated:** 2026-07-03  
**Machine:** VENGEANCE (Red) only — Cornerman and Mac keep their own roots.

When docs or scripts disagree, **this file wins** for desk clone paths on VENGEANCE.

Full in-repo trees: **`LIFEPUNCH_REPO_LAYOUT.md`**.

---

## Clone layout (`C:\Users\jared\Projects\`)

| Lane | Path | Remote | Purpose |
|------|------|--------|---------|
| **LifePunch monorepo** | `C:\Users\jared\Projects\lifepunch` | `github.com/mragerlp/lifepunch` | Private LIFEPUNCH™ ship lane — commit here |
| **DXRP fork (nested)** | `{monorepo}\lifepunchdxrp` | `mragerlp/dxrp-public` + `upstream` → `dxura/dxrp` | Editor testing mount — **not** a sibling Projects folder |
| **Publish export** (optional) | `C:\Users\jared\Projects\lifepunch-published` | GitLab publish lane | Export output — not the edit root |

**Retired as Projects roots:** `lifepunchaddons`, `lifepunchdxrp` (sibling clone name).  
**Product addons** live at **`lifepunchaddons/`** inside the monorepo.

Bootstrap nested DXRP + Projects alignment:

```powershell
cd C:\Users\jared\Projects\lifepunch
powershell -File lifepunch\scripts\Setup-LifepunchProjectsLayout.ps1
```

---

## In-repo layout (monorepo root)

```text
lifepunch/           # ops — docs, scripts, server, platform
lifepunchaddons/     # product — lpbitcoin, lphacker, … (develop=test · main=publish-ready)
lifepunchdxrp/       # nested DXRP fork (ignored by monorepo git)
```

---

## Steam / runtime (not git roots)

| Checkout | Path | Notes |
|----------|------|-------|
| LifePunch editor mount | `D:\Steam\steamapps\common\sbox\dxrp` | Runtime — never commit from game tree |
| Vanilla upstream editor | `D:\Steam\steamapps\common\sbox\dxrp-vanilla` | Party / upstream proof |

---

## Other machines (unchanged)

| Machine | Monorepo root |
|---------|----------------|
| **Cornerman (Green)** | `C:\Projects\lifepunch` |
| **Architect (Mac)** | `~/Projects/lifepunch` |
| **lifepunchnet (Blue)** | `C:\lifepunch\lifepunch-rdp-server` (git root) |

---

## Archive

Redundant plain upstream clone: `C:\Users\jared\Projects\_archive\dxrp-dxura-upstream-*`  
Legacy sibling DXRP fork `C:\Users\jared\Projects\dxrp` → migrate into `{monorepo}\lifepunchdxrp`.

---

## Related docs

- `LIFEPUNCH_REPO_LAYOUT.md` — branch law for lifepunchaddons
- `MACHINE_CAST.md` — machine codenames
- `DXRP_CONTRIBUTOR_LANE.md` — two-repo law (monorepo vs dxrp fork)
- `CONFIG_SOURCE_OF_TRUTH.md` — which config file is law
