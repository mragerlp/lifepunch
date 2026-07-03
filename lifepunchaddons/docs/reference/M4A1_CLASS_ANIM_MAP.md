# M4A1 class animation map (AK-47 FP target)

**Purpose:** Map DXRP **M4A1 class kit** animations (what we ship) to CS2 AK-47 **timing/choreography** study values (reference only).

**Golden rule:** `vm_ak47` rides `v_m4a1` animgraph — CS2 `weapon_rif_ak47` sequences inform tuning, not skeleton retarget.

**Status:** Green fill (2026-06-11) — CS2 durations are **study estimates** until Red S2V verify.

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
| Draw / deploy | M4 deploy | **~1.0s** (`deploy`) | `ak47_draw.sound` |
| Idle | M4 idle | loop (`idle`) | — |
| Primary fire | M4 fire | **~0.08s** bolt (`fire`) | `ak47_shot.sound` |
| Fire distant | — | layering reference | `ak47_shot_distant.sound` |
| Reload (tap) | M4 reload | **~2.45s** mag swap (`reload`) | `ak47_reload_clipout` + `clipin` |
| Reload (empty) | M4 empty reload | **~3.10s** bolt hold (`reload_empty`) | + `ak47_cock.sound` |
| ADS in | M4 ADS / zoom | **~0.2s** (`zoom_in`) | — |
| ADS out | M4 ADS out | **~0.2s** (`zoom_out`) | — |
| Inspect | — (optional) | **~3.5s** — skip ship | — |

**Tuning note:** If AK reload feels sluggish on M4 graph, shorten **ReloadWeaponComponent** timed sound offsets before forking animgraph.

---

## Bones / attachments (M4 template)

| Bone / GO | AK mesh must align |
|-----------|-------------------|
| `camera` | Viewmodel origin — `AK47_FIX_CHECKLIST.md` |
| Muzzle child | `ShootWeaponComponent` flash — match CS2 muzzle line |
| EjectionPort child | Brass eject direction (right-side AK port) |
| `weapon_root` / bolt | Skin AK bolt on mesh; anim from M4 graph |
| Mag bone (if any) | Mag detach timing vs CS2 `reload` mid-point |

Export `v_m4a1` FBX from ModelDoc → compare bone names vs `v_ak47/source/ak47_vm.fbx` bind.

---

## Prefab wiring (LifePunch target)

| Setting | M4 official | `vm_ak47` target |
|---------|-------------|------------------|
| Root rotation | `0,0,0,1` | `0,0,0,1` |
| `UseAnimGraph` | `true` | `false` until AK rig — **use class `vm_m4a1` placeholder** |
| `CreateBoneObjects` | `true` | `true` when FP rig lands |
| Model child | `v_m4a1.vmdl` | `v_ak47.vmdl` (skin) or placeholder |

---

## Related

- `CS2_AK47_STUDY.md` · `AK47_FIX_CHECKLIST.md` · `VIEWMODEL_RIG_PIPELINE.md`
