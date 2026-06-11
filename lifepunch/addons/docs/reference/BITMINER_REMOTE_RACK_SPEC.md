# Bitminer — remote rack control (hashd console)

**Status:** Green distill (2026-06-11) · **Red:** `BitminerRigRegistry` + multi-rig RPC  
**Canon arch:** `BITMINER_THREE_ENTITY_ARCH.md`  
**Economy:** `BITMINER_DUAL_RACK_SPEC.md` (yield multiplier still valid)

---

## Entity table

| Slug | Player name | Mesh | Component | Yield role |
|------|-------------|------|-----------|------------|
| `bitcoin-terminal` | Bitcoin Terminal | `bitcoin-terminal.vmdl` | `BitminerTerminalProp` | **Hub** — hashd UI, upgrades, rig registry |
| `bitcoin-miner` | Bitcoin Miner | `gpu-rack.vmdl` | `BitminerEntity` (`AdvancedRack=false`) | Small rack — base `×1.0` |
| `advanced-bitcoin-miner` | Advanced Bitcoin Miner | `gpu-rack-stacked.vmdl` | `BitminerEntity` (`AdvancedRack=true`) | Large rack — `×2.0` yield on that rig |

Racks are **separate placeables**. Terminal does not parent CRT onto a rack prefab.

---

## Placement & linking rules

| Rule | Phase 1 (shipped) | Target (owner canon) |
|------|-------------------|----------------------|
| Terminal ↔ rack distance | ≤ **4 m** horizontal, ≤ **2 m** vertical (`BitminerTerminalProp`) | Same for **registration** |
| `hashd` open range | ≤ **8 m** to a rig (`BitminerCommandHost`) | Terminal registers all rigs in radius |
| Multiple racks | One auto-linked nearest rig | **N racks** per terminal registry |
| Multiple terminals | TBD — Red playtest | Prefer **one terminal per room**; racks shared if in range of one hub |
| Pocket / carry | Racks stop mining when pocket-tagged | Unchanged |

**Registration proposal:** On terminal `OnStart` + every `Press`, scan `Scene` for `BitminerEntity` within link box; add to synced `RegisteredRigIds` if not present. Rigs leaving range drop off registry after grace period — **TBD — Red playtest**.

---

## Data flow

```text
Player → USE CRT or hashd
       → BitminerTerminalProp / BitminerCommandHost
       → BitminerTerminal.razor (hashd overlay)
       → [Phase 1] single LinkedRig BitminerEntity
       → [Target] BitminerRigRegistry.SelectedRig → BitminerEntity RPCs
```

| Action | Phase 1 | Target |
|--------|---------|--------|
| `mining start` | `SetMiningState(true)` on linked rig | Selected rig, or **all** registered |
| `mining stop` | `SetMiningState(false)` on linked rig | Selected rig, or **all** |
| `upgrade cpu` | `RequestUpgrade` on linked rig | **Selected rig** (see model below) |
| Balance display | Linked rig `[Sync] BitcoinAmount` | **Pooled** sum in rail + per-rig in `racks` list |
| LCD amber text | `BindScreen` on linked rig | Terminal shows **aggregate** or selected rig — **TBD** |

### Upgrade model (proposal)

**Per-rig upgrades** — CPU/Cores live on each `BitminerEntity`. Terminal is a **remote control panel**, not a second economy. Purchasing CPU on rig-1 does not buff rig-0. Justification: matches world fiction (each rack has its own motherboard); avoids one terminal buffing a farm for free.

**Exception:** Future “terminal host CPU” buff is a separate upgrade track — **not Phase 2** unless owner requests.

---

## hashd telemetry rail (multi-rack)

When registry count ≥ 1:

```text
RACKS   2 linked (1× SMALL · 1× ADVANCED)
ACTIVE  rig-0 SMALL · MINING
        rig-1 ADVANCED · IDLE
SELECT  rig-0
```

Single rack (Phase 1 feel):

```text
RACKS   1 linked (1× SMALL)
ACTIVE  rig-0 SMALL · MINING
```

---

## CLI commands (spec — Red wires Phase 2)

| Command | Behavior |
|---------|----------|
| `racks` | List registered rigs: `id`, type (SMALL/ADVANCED), `IsMining`, balance snippet |
| `select <id>` | Set active rig for `status`, `upgrade`, `mining start` without id |
| `mining start` | Start **selected** rig |
| `mining start all` | Start every registered rig |
| `mining start <id>` | Start one rig by id |
| `mining stop` | Stop selected |
| `mining stop all` | Stop all registered |
| `mining stop <id>` | Stop one |

Rail **START** / **STOP** buttons: default to selected rig; long-press or modifier for all — **TBD — UX on Red**.

---

## Advanced miner prefab wireframe

```text
advanced-bitcoin-miner (root, scale ~1.11)
├── ModelRenderer          → gpu-rack-stacked.vmdl
├── fan_placeholder*       → spin until stacked power_on anim ships (BITMINER-01)
└── BitminerEntity
      AdvancedRack = true
      (no bitcoin-terminal child)
```

### ModelDoc (Red)

1. Import `gpu-rack-stacked-anim.fbx` → `gpu-rack-stacked.vmdl` (if not compiled).
2. Remap five slots → `gpu-rack-*.vmat` per `BITMINER_DUAL_RACK_SPEC.md`.
3. Sequences `power_on` / `power_off`.
4. Physics hull on floor-aligned origin (`align_origin_z_type = Bottom`).
5. Prefab at `entities/advanced-bitcoin-miner/advanced-bitcoin-miner.prefab`.

---

## RPC surface (target — Opus review)

| RPC | Host validates |
|-----|----------------|
| `RegisterRigsInRange()` | Terminal position, max count |
| `SetMiningState(rigId, bool)` | Rig in registry, job/ownership TBD |
| `RequestUpgrade(rigId, type)` | Rig in registry, `ChargeHost` |
| `SelectRig(rigId)` | Caller owns terminal session |

Phase 1 seams: `BitminerTerminalProp.FindNearestRig(Scene, pos)` — evolve to registry scan same helper.

---

## Related

- `BITMINER_THREE_ENTITY_ARCH.md` · `BITMINER_UX_SPEC.md` §3f
- `RED_BITMINER_PHASE2_BUILD.md`
