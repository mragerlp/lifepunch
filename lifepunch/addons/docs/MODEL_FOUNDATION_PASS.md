# Model foundation pass — before prefab or play

**Gate:** No entity prefab wiring, no `OnAwake` collider sync, no flatgrass spawn, no economy playtest until **every row** for that asset is checked.

**Doctrine:** `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — machines, not props. This doc is **P0 only**.

**Editor lane (preferred):** ModelDoc Studio — no DXRP gamemode:

```powershell
powershell -File lifepunch\scripts\Start-SboxModelDocStudio.ps1
```

**Staging paths:** `Assets/addons/lifepunch/lp{package}/{entity}/assets/` · law: `PACKAGE_STAGING_LAYOUT.md`

Legacy DXRP greenfield lane (ULX + lp*): `Set-DxrpLifepunchModelDocLane.ps1` — use only when DXRP context is required.

---

## Per-model checklist

| # | Check | Pass when |
|---|--------|-----------|
| 1 | **Source in `assets/source/`** | FBX/OBJ/blend clean; textures present or solid-color plan documented |
| 2 | **ModelDoc opens** | No missing mesh / material errors on import node |
| 3 | **`import_scale`** | Prefab will use `1,1,1`; mesh height sane vs citizen (~64–72 units) |
| 4 | **`import_translation`** | `[0,0,0]` unless documented offset fix |
| 5 | **Align** | **Center / Center / Bottom** — feet on ground when previewed on flat plane |
| 6 | **Orientation** | Front faces +Z (or documented convention); CRT/terminal not sideways |
| 7 | **Materials** | vmats compile; no hot-pink; emissive plan noted for P1 lights |
| 8 | **Animation** | Rigged body spin / explode → **reject for body**; fans = child-GO or separate take (P2) |
| 9 | **Compile `_c`** | Asset browser shows compiled vmdl; no ERROR mesh in preview |
| 10 | **Owner sign-off** | Screenshot or ModelDoc orbit — you say “this mesh is correct” |

**Only after row 10:** map folder → entity slug → copy vmdl into shipped `models/...` → prefab hierarchy per digital machine standard → P1+ (attachments, lights, states).

---

## Phase 1 collision (after promote to prefab)

Separate pass — still before full gameplay:

- **Baseline:** white wireframe = `BoxCollider` **Center + Scale on X, Y, Z** (honest hack — track swap to convex hulls in `TECH_DEBT.md`)
- `LifePunchPropPhysics.SyncBoxColliderFromModel` on entity `OnAwake`
- Feet on floor; no walk-through

**Endgame:** multiple convex hulls authored in ModelDoc — see `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` §2.

---

## Phase 2+ (defer)

- Attachments (`fan_*`, `screen`, `led_*`)
- Fan child GO spin or `fan_spin_*` sequences
- Point lights + state-driven emissive
- Dynamic UI on screen child plane
- Audio, sparks, smoke (P4)

---

## Agent law this phase

1. **Wait** for owner folder → entity mapping — do not assume Fab title → slug.
2. **ModelDoc first** — ModelDoc Studio or `sbox-editor` MCP; not play mode for mesh proof.
3. **Do not** run `Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining` until owner promotes from `lp*` staging.
4. **Do not** commit entity rewrites or prefab GUID surgery during foundation pass unless owner asks.
5. **Think machine stack** — mesh is step 1 of 9 in `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`.
