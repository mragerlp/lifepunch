# BITMINER — IP & attribution protection checklist

**Lane:** Cornerman audit (docs) · **Red** fixes ship-tree findings  
**Scope:** `lifepunch/addons/Code/Addons/lifepunch/bitcoinmining/` + `Assets/.../bitcoinmining/`  
**Last run:** 2026-06-11 (Green G1 — post `dfd2f18` multi-rig registry)

---

## G1 — Grep audit (ship tree `.cs` / `.razor` / `.scss`)

```powershell
rg -i "spl mute|BitOS|root@bitminer|cornerman@rig|#44aaff" lifepunch/addons/Code/Addons/lifepunch/bitcoinmining --glob "*.{cs,razor,scss}"
rg -i "Evo|evo-bitminer" lifepunch/addons/Code/Addons/lifepunch/bitcoinmining --glob "*.{cs,razor,scss}"
```

| Check | Result | Path / notes |
|-------|--------|----------------|
| No `Spl Mute` / Spl credits | **PASS** | Zero hits in ship `.cs` / `.razor` / `.scss` |
| No `BitOS` / `root@bitminer` | **PASS** | Zero hits |
| No `cornerman@rig` (bitminer prompt) | **PASS** | Uses `rig0>` — `BitminerTerminal.razor.scss` |
| No Evo blue `#44aaff` in UI | **PASS** | Accent `#f0a500` — `BitminerTerminal.razor.scss` |
| Evo in player UI | **PASS** | No player-facing Evo strings |
| Evo in code comments only | **N/A** | `Bitminer.cs:14` XML study ref; `BitminerEntity.cs:316` TECH_DEBT comment — OK |
| `about` command LIFEPUNCH™ | **PASS** | `BitminerTerminal.razor` L613–618 |
| Boot line LIFEPUNCH | **PASS** | `>> hashd init — LIFEPUNCH mining daemon` L179 |
| Title bar HASHD (not BitOS) | **PASS** | `HASHD RIG CONTROL` L25 |
| LCD amber `#f0a500` | **PASS** | `BitminerEntity.cs` L142–143, L262–263 |
| `addons.json` leads LIFEPUNCH | **PASS** | `description` contains `LIFEPUNCH hashd` — `config/addons.json` |
| Portal listing draft | **PASS** | `reference/BITMINER_PORTAL_LISTING.md` — Red pastes on publish |
| `™` not `®` | **PASS** | `LIFEPUNCH™` in About only; pending registration |

`reference/` and `docs/` may cite Evo as study-only — **OK** outside publish tree.

---

## Ship-tree findings (historical)

| Path | Finding | Severity | Status |
|------|---------|----------|--------|
| `BitminerTerminal.razor` `about` | ~~`spl mute`~~ | HIGH | ✅ LIFEPUNCH™ only |
| `BitminerEntity.cs` `TextRender.Color` | ~~`#00FF7F`~~ | MED | ✅ `#f0a500` |
| `BitminerEntity.cs` comment | `Deprecate Evo child-fan` | LOW | OK — internal |
| `Bitminer.cs` XML | `reference/evo-bitminer` | LOW | OK — not player-facing |

---

## About tab / `about` command — required copy

Player-facing only (`BitminerTerminal.razor`):

```text
HASHD RIG CONTROL — LIFEPUNCH™ Bitcoin Miner
Published by LIFEPUNCH — lifepunch.co
Proprietary software. All rights reserved.
Use on your server only. No redistribution or resale.
```

**Forbidden in About:** Spl Mute, Null, Evo, BitOS, third-party menu credits.

---

## Visual brand alignment

| Token | Correct (bitminer) | Wrong (drift) |
|-------|-------------------|---------------|
| UI accent | `#f0a500` amber | `#00FF7F` green |
| Prompt | `rig0>` | `cornerman@rig:~$` |
| Program | `hashd` / `mine.exe` | `BitOS`, `cornerman.exe` |
| Layout family | HASHD rig control (+ Phase 2 modules) | Hacker ops console green |

Canonical: `TERMINAL_BRAND_MATRIX.md` · `BITMINER_UX_SPEC.md` · `BITMINER_PHASE2_TOKENS.scss`

---

## validate-headers.ps1 (bitcoinmining)

| File | Header |
|------|--------|
| `Bitminer.cs` | ✓ |
| `BitminerEntity.cs` | ✓ |
| `BitminerRigRegistry.cs` | ✓ |
| `BitminerTerminalProp.cs` | ✓ |
| `BitminerTerminal.razor` | ✓ (razor block) |
| `BitminerTerminal.razor.scss` | ✓ |
| `BitminerTerminalHost.cs` | ✓ |
| `BitminerCommandHost.cs` | ✓ |
| `BitminerDevSpawn.cs` | ✓ (remove before publish — R5) |

---

## Pre-publish gate (Red)

- [x] Re-run grep on `bitcoinmining` ship tree (2026-06-11 G1)
- [x] `about` / About module — LIFEPUNCH™ only
- [x] LCD `TextRender` color amber `#f0a500`
- [x] Portal listing copy drafted — `BITMINER_PORTAL_LISTING.md`
- [ ] Portal live listing shows **Published by LIFEPUNCH**
- [ ] No Evo meshes/sounds `_c` in publish staging
- [ ] `BitminerDevSpawn` stripped or gated for publish (R5)
- [ ] `prepare-publish.ps1 -Addon bitcoinmining` clean

---

## Related

- `BITMINER_PORTAL_LISTING.md` · `BITMINER_FINISH_RUNBOOK.md`
- `BITMINER_PHASE2_WIREFRAME.md` · `TECH_DEBT.md` BITMINER-01
