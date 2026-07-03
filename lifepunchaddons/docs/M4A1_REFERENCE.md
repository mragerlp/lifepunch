# M4A1 Reference (DXRP Public)

**Easiest workflow:** [`AK47_FIX_CHECKLIST.md`](AK47_FIX_CHECKLIST.md) (do that first; use this doc when you need links and tables).

Official vanilla M4A1 patterns from [mragerlp/dxrp-public `develop`](https://github.com/mragerlp/dxrp-public/tree/develop). Use this when tuning LifePunch AK-47 world model, viewmodel, and prefabs.

**Do not copy Facepunch assets into LifePunch packages.** Use M4A1 as a layout and behavior reference only.

---

## Files in dxrp-public (in Git)

| Piece | Path |
|--------|------|
| World prefab | [`game/Assets/gameplay/equipment/weapons/m4a1/w_m4a1.prefab`](https://github.com/mragerlp/dxrp-public/blob/develop/game/Assets/gameplay/equipment/weapons/m4a1/w_m4a1.prefab) |
| Viewmodel prefab | [`game/Assets/gameplay/equipment/weapons/m4a1/vm_m4a1.prefab`](https://github.com/mragerlp/dxrp-public/blob/develop/game/Assets/gameplay/equipment/weapons/m4a1/vm_m4a1.prefab) |
| Sounds | [`game/Assets/gameplay/equipment/weapons/m4a1/sounds/`](https://github.com/mragerlp/dxrp-public/tree/develop/game/Assets/gameplay/equipment/weapons/m4a1/sounds) |
| ViewModel runtime | [`game/Code/Equipment/ViewModel.cs`](https://github.com/mragerlp/dxrp-public/blob/develop/game/Code/Equipment/ViewModel.cs) |
| Equipment / viewmodel spawn | [`game/Code/Equipment/Equipment.cs`](https://github.com/mragerlp/dxrp-public/blob/develop/game/Code/Equipment/Equipment.cs) |
| Shipment world model load | [`game/Code/Utilities/Resource/GameModeEquipmentDtoExtensions.cs`](https://github.com/mragerlp/dxrp-public/blob/develop/game/Code/Utilities/Resource/GameModeEquipmentDtoExtensions.cs) (`GetWorldModel` → content `worldModelPath`) |

There is **no** `v_m4a1.vmdl`, `w_m4a1.vmdl`, or `m4a1.equip` source in dxrp-public. Those ship in the Facepunch S&box library.

---

## Model paths (S&box library — not in Git)

| Role | Mounted path |
|------|----------------|
| World | `models/weapons/sbox_assault_m4a1/w_m4a1.vmdl` |
| Viewmodel | `models/weapons/sbox_assault_m4a1/v_m4a1.vmdl` |
| First-person arms | `models/first_person/v_first_person_arms_human.vmdl` |

LifePunch AK-47 equivalents:

| Role | Mounted path |
|------|----------------|
| World | `addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/w_ak47.vmdl` |
| Viewmodel | `addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/v_ak47.vmdl` |
| Arms (optional) | `models/first_person/v_first_person_arms_human.vmdl` (same as M4A1) |

---

## Visual references (what to match)

| Reference | What it defines |
|-----------|----------------|
| M4A1 on gun-dealer **shipment** crate | World model height vs crate (`worldModelPath` / `w_*.vmdl` import translation). Official M4A1 may float slightly above the wood; match that relationship for AK. |
| M4A1 **first person** | Viewmodel layout: gun lower-right, hands visible, clear view past weapon (`v_*.vmdl` + `camera` bone + `vm_*.prefab`). |

---

## ViewModel runtime (`camera` bone)

From `ViewModel.cs`:

```csharp
var bone = ModelRenderer.SceneModel.GetBoneLocalTransform("camera");
camera.LocalPosition += bone.Position;
camera.LocalRotation *= bone.Rotation;
```

The viewmodel skeleton must include a bone named exactly **`camera`**. **Position and rotation** both matter. A default Blender bone (pointing up) causes the “stock filling the screen” bug.

Do **not** fix first person with `vm_*` root rotation hacks. M4A1 uses **`Rotation: 0,0,0,1`** on the prefab root.

---

## Prefab comparison: `vm_m4a1` vs `vm_ak47`

| Setting | M4A1 (official) | LifePunch AK target |
|---------|-----------------|---------------------|
| Root rotation | `0,0,0,1` | `0,0,0,1` |
| Tags | `player`, `viewmodel` | Same |
| Model on root | `v_m4a1.vmdl` | `v_ak47.vmdl` |
| **CreateBoneObjects** | `true` | `true` |
| **UseAnimGraph** | `true` | `false` until AK anims exist |
| **Arms** renderer + bone merge | Yes | Add when FP is stable |
| **Muzzle** / **EjectionPort** | On bone children (~small coords) | Reparent from world-model offsets |
| **`camera` child** | From Create Bone Objects | Requires correct bone in `v_ak47` |

---

## Prefab comparison: `w_m4a1` vs `w_ak47`

| Setting | M4A1 (observed) | LifePunch AK notes |
|---------|-----------------|-------------------|
| Root `Equipment` + `TagBinder` | Yes | Match |
| `Model` child position | `2.888, 1.646, -6.576` | AK `w_ak47` uses same first-pass offsets |
| `Model` child rotation | Small yaw on Z (`~0.116`) | AK aligned to same pattern |
| World model path | `models/weapons/sbox_assault_m4a1/w_m4a1.vmdl` | `addons/lifepunch/ak47/.../w_ak47.vmdl` |
| **Muzzle** (on Model child) | `~20, 0, 7` | AK should use similar scale, not `-459` |
| **EjectionPort** | `~1.77, -0.42, 7.67` | AK should use similar scale |

**Shipment display** uses content row **`worldModelPath`** directly (`GetWorldModel`), not the world prefab child transform. Tune **`w_ak47.vmdl`** `import_translation` (especially Z) for crate height.

---

## Content row fields (portal / `addons.json`)

M4A1 content lives in DXRP Base Content on the portal. AK-47 uses the same field shape:

| Field | AK-47 example |
|-------|----------------|
| `primaryReference` | `addons/lifepunch/ak47/equipment/w_ak47/w_ak47.prefab` |
| `secondaryReference` | `addons/lifepunch/ak47/equipment/vm_ak47/vm_ak47.prefab` |
| `worldModelPath` | `addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/w_ak47.vmdl` |
| `iconPath` | `/addons/lifepunch/ak47/ui/ak47_killfeed.png` (leading `/` for DXRP `<Icon>`) |

---

## Two separate fix tracks

```
Shipment height  →  w_ak47.vmdl (import_scale, import_translation Z)
First person     →  v_ak47.vmdl + camera bone (Blender) + vm_ak47.prefab (M4A1 layout)
```

Do not publish portal revisions for prefab rotation tweaks alone. Fix assets in S&box, local or dev test, then `prepare-publish.ps1 -Addon ak47`.

---

## Related LifePunch docs

| Doc | Purpose |
|-----|---------|
| [`AK47_SBOX_BEGINNER_GUIDE.md`](AK47_SBOX_BEGINNER_GUIDE.md) | Step-by-step S&box workflow |
| [`../Assets/addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/VIEWMODEL_BUILD.md`](../Assets/addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/VIEWMODEL_BUILD.md) | Viewmodel checklist |
| [`../Assets/addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/MODEL_BUILD.md`](../Assets/addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/MODEL_BUILD.md) | World model + shipment height |
| [`AK47_PORTAL_DEV_TEST.md`](AK47_PORTAL_DEV_TEST.md) | Publish and dev-server testing |

---

## Side-by-side in S&box

1. Open project: `lifepunchaddons/addons.sbproj`
2. Open official prefabs (from DXRP install or clone) next to:
   - `equipment/vm_ak47/vm_ak47.prefab`
   - `equipment/w_ak47/w_ak47.prefab`
3. Open ModelDoc:
   - `models/weapons/sbox_assault_m4a1/v_m4a1.vmdl` (library)
   - `addons/lifepunch/ak47/models/lifepunch/ak47/v_ak47/v_ak47.vmdl`
4. Compare skeleton **`camera`** bone and compiled preview orientation.
