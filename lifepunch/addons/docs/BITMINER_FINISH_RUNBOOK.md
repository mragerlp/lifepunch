# Bitcoin Mining — finish runbook (owner lanes)

**Goal:** Shippable LIFEPUNCH™ three-entity bitminer — terminal controls racks, hashd console, portal-ready addon.  
**Canon:** `reference/BITMINER_THREE_ENTITY_ARCH.md` · `reference/BITMINER_REMOTE_RACK_SPEC.md`

---

## Done (2026-06-11)

| Piece | Status |
|-------|--------|
| Three prefabs (terminal, miner, advanced) | In repo |
| Phase 1 hashd CLI + telemetry rail | Shipped |
| `BitminerTerminalProp` Scene fix (CS0120) | `2e81a2c` |
| `AdvancedRack` 2× yield on stacked prefab | Shipped |
| Green distill: remote rack UX, protection scaffolds | `670fdee` + `2e81a2c` |

---

## Lane split — who finishes what

### Red (VENGEANCE) — code + integration

| # | Task | Est. | Notes |
|---|------|------|-------|
| R1 | **Multi-rig registry** (`BitminerRigRegistry` + `racks` / `select` / `mining start all`) | Done this session | Spec: `BITMINER_REMOTE_RACK_SPEC.md` |
| R2 | **Phase 2 module UI** (Dashboard / Wallet / Upgrades / Log / About) | 2–4h Opus | `RED_BITMINER_PHASE2_BUILD.md` Step 1 |
| R3 | `addons.json` content row + portal description | 30m | After prefab paths confirmed |
| R4 | Protection gate grep | 30m | `BITMINER_PROTECTION_CHECKLIST.md` |
| R5 | Remove `BitminerDevSpawn` before publish | 5m | Playtest-only |

### Green (Cornerman) — docs only, no C# / ModelDoc

| # | Task | Deliverable |
|---|------|-------------|
| G1 | Fill `BITMINER_PROTECTION_CHECKLIST.md` grep rows | Outbox copy |
| G2 | Portal listing copy (title, description, 3 entity names) | `BITMINER_PORTAL_LISTING.md` |
| G3 | Player-facing “how it works” (3 placeables, hashd flow) | 1-page in `BITMINER_UX_SPEC.md` §player |

**Green does NOT:** `BitminerTerminalProp.cs`, ModelDoc, `git push`.

### Owner (editor — one session)

| # | Task | Blocks |
|---|------|--------|
| E1 | ModelDoc compile `bitcoin-terminal.vmdl` + 6 vmats → `_c` | CRT ERROR mesh |
| E2 | ModelDoc compile `gpu-rack-stacked.vmdl` | Advanced rack ERROR mesh |
| E3 | ModelDoc `power_on` / `power_off` on `gpu-rack.vmdl` | BITMINER-01 fan spinners |
| E4 | Tune `lcd_screen` transform on terminal prefab | LCD alignment |
| E5 | Sync `_c` from DXRP → monorepo before publish | Portal compile |

---

## Definition of done (portal ship)

1. All three entities placeable; terminal USE or `hashd` opens console.
2. Terminal can start/stop **multiple** racks in range (`racks` + `mining start all`).
3. CRT + stacked rack show real meshes (not ERROR) after E1–E2.
4. Phase 2 modules OR Phase 1 CLI passes playtest checklist.
5. Protection checklist green; dev spawn commands removed.
6. `prepare-publish.ps1 -Addon bitcoinmining` staging verified.

---

## Order of operations

```text
Red R1 (registry) → Red R2 (modules) → Owner E1–E2 (meshes) → playtest → R3–R5 → publish
         ↘ Green G1–G3 in parallel (docs)
```

Ping Green: `BITMINER_FINISH_RUNBOOK.md` on main — G1–G3 only.
