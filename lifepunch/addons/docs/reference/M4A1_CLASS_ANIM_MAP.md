# M4A1 class animation map (AK-47 FP target)

**Purpose:** Map DXRP **M4A1 class kit** animations (what we ship) to CS2 AK-47 **timing/choreography** study values (reference only).

**Golden rule:** `vm_ak47` rides `v_m4a1` animgraph — CS2 `weapon_rif_ak47` sequences inform tuning, not skeleton retarget.

---

## Class kit source

| Piece | Path |
|-------|------|
| World prefab | `gameplay/equipment/weapons/m4a1/w_m4a1.prefab` |
| Viewmodel prefab | `gameplay/equipment/weapons/m4a1/vm_m4a1.prefab` |
| Viewmodel vmdl | `models/weapons/sbox_assault_m4a1/v_m4a1.vmdl` |
| Animgraph | `v_m4a1.vanmgrph` (download cache) |

See `M4A1_REFERENCE.md` · `DXRP_CLASS_WEAPON_REFERENCES.md`.

---

## Anim event map

| Player action | M4 class anim / event | CS2 AK study target | LifePunch sound |
|---------------|----------------------|---------------------|-----------------|
| Draw / deploy | M4 deploy | TBD duration | `ak47_draw.sound` |
| Idle | M4 idle | — | — |
| Primary fire | M4 fire | bolt travel | `ak47_shot.sound` |
| Reload (tap) | M4 reload | mag out/in timing | `ak47_reload_clipout` + `clipin` |
| Reload (empty) | M4 empty reload | bolt hold-open | same + `ak47_cock` if needed |
| ADS in | M4 ADS | TBD | — |
| ADS out | M4 ADS out | TBD | — |

*Fill CS2 column from `CS2_AK47_STUDY.md` animation catalog.*

---

## Bones / attachments (M4 template)

| Bone / GO | AK mesh must align |
|-----------|-------------------|
| `camera` | Viewmodel origin — `AK47_FIX_CHECKLIST.md` |
| Muzzle | `ShootWeaponComponent` muzzle flash |
| Ejection port | brass eject direction |
| `weapon_root` children | bolt / mag if skinned on AK mesh |

Export `v_m4a1` FBX from ModelDoc to compare bone names vs `ak47_vm.fbx` bind.

---

## Related

- `CS2_AK47_STUDY.md`
- `AK47_FIX_CHECKLIST.md`
- `VIEWMODEL_RIG_PIPELINE.md`
