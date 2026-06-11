# BITMINER — IP & attribution protection checklist

**Lane:** Cornerman audit (docs) · **Red** fixes ship-tree findings  
**Scope:** `lifepunch/addons/Code/Addons/lifepunch/bitcoinmining/` + `Assets/.../bitcoinmining/`  
**Last run:** 2026-06-10

---

## Grep patterns (ship tree)

Search each release candidate:

```text
Evo | evo-bitminer | BitminerFan
BitOS | root@bitminer
Spl Mute | spl mute
#44aaff          (Evo blue terminal)
cornerman@rig    (deprecated bitminer prompt — use rig0>)
```

`reference/` and `docs/briefs/` may mention Evo **as study-only** — that is OK. **Player-visible** and **published** paths must not.

---

## Ship-tree findings (2026-06-10)

| Path | Finding | Severity | Red action |
|------|---------|----------|------------|
| `BitminerTerminal.razor` `about` | `Initial UI study — spl mute` | **HIGH** | Remove line; About module = LIFEPUNCH™ only per wireframe |
| `BitminerEntity.cs` `TextRender.Color` | `#00FF7F` (hacker green) | **MED** | Change to `#f0a500` amber for in-world LCD |
| `BitminerEntity.cs` comment | `Deprecate Evo child-fan` | LOW | OK — internal TECH_DEBT pointer |
| `Bitminer.cs` XML | `reference/evo-bitminer` study note | LOW | OK — not player-facing |
| `docs/RUNTIME_PATTERN.md` | Evo pattern mention | LOW | OK — dev doc |
| `gpu-rack/material-map.json` | Evo fan note in `notes` | LOW | OK — build metadata |
| `gpu-rack/MODEL_BUILD.md` | Evo scale comparison | LOW | OK — ModelDoc runbook |

**No `BitOS` or `root@bitminer` strings** in ship `.cs` / `.razor` / `.scss`.

---

## About tab / `about` command — required copy

Player-facing only:

```text
HASHD RIG CONTROL — LIFEPUNCH™ Bitcoin Miner
Published by LIFEPUNCH — lifepunch.co
Proprietary software. All rights reserved.
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
| `BitminerTerminal.razor` | ✓ (razor block) |
| `BitminerTerminal.razor.scss` | ✓ |
| `BitminerTerminalHost.cs` | ✓ |
| `BitminerCommandHost.cs` | ✓ |
| `BitminerDevSpawn.cs` | ✓ |

Repo-wide failure (unrelated): `docs/briefs/TERMINAL_PLATFORM_TOKENS.scss` — reference file; optional header add or exclude from validator.

---

## Pre-publish gate (Red)

- [ ] Re-run grep on `bitcoinmining` ship tree after fixes
- [ ] `about` / About module — LIFEPUNCH™ only
- [ ] LCD `TextRenderer` color amber
- [ ] Portal listing: Published by LIFEPUNCH
- [ ] No Evo meshes/sounds `_c` in publish staging
- [ ] `prepare-publish.ps1 -Addon bitcoinmining` clean

---

## Related

- `BITMINER_PHASE2_WIREFRAME.md` — About module spec
- `TECH_DEBT.md` BITMINER-01 — Evo fan deprecation
- Trademark rule: LIFEPUNCH™ on goods; no third-party source confusion
