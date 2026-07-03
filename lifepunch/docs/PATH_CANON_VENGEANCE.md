# VENGEANCE — Projects folder path canon

**Updated:** 2026-07-03  
**Machine:** VENGEANCE (Red) only — Cornerman and Mac keep their own roots.

When docs or scripts disagree, **this file wins** for desk clone paths on VENGEANCE.

---

## Clone layout (`C:\Users\jared\Projects\`)

| Lane | Path | Remote | Purpose |
|------|------|--------|---------|
| **LifePunch monorepo** (addons, ops, docs, scripts) | `C:\Users\jared\Projects\lifepunchdxrp` | `github.com/mragerlp/lifepunch` | Private LIFEPUNCH™ ship lane — commit here |
| **DXRP fork** (public upstream / Dimmer / party / bounty) | `C:\Users\jared\Projects\dxrp` | `origin` → `mragerlp/dxrp-public`, `upstream` → `dxura/dxrp` | Vanilla DXRP only — no LifePunch IP |
| **Publish export** (optional) | `C:\Users\jared\Projects\lifepunch-published` | GitLab publish lane | Export output — not the edit root |

**Do not** use a separate `dxrp-public` folder — the fork lives at **`dxrp`**.

**Do not** use `C:\Users\jared\Projects\lifepunch` — renamed to **`lifepunchdxrp`** (July 2026).

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
| **Cornerman** (Green B) | `C:\Projects\lifepunch` |
| **MacBook** (Green A) | `~/Projects/lifepunch` |
| **lifepunchnet** (Blue) | `C:\lifepunch\lifepunch-rdp-server` (git root) |

Cornerman patch-handoff and deploy keys still target **`C:\Projects\lifepunch`** on Green — not the VENGEANCE folder name.

---

## Archive

Redundant plain upstream clone (dxura-only, no fork branches) was moved to:

`C:\Users\jared\Projects\_archive\dxrp-dxura-upstream-*`

Use **`C:\Users\jared\Projects\dxrp`** (fork with `upstream` remote) for all DXRP git work.

---

## Related docs

- `MACHINE_CAST.md` — machine codenames
- `DXRP_CONTRIBUTOR_LANE.md` — two-repo law (monorepo vs dxrp fork)
- `CONFIG_SOURCE_OF_TRUTH.md` — which config file is law
