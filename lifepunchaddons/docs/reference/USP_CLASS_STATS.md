# USP class stats reference (Deagle DXRP class)

**Source:** `DXRP_CLASS_WEAPON_REFERENCES.md` (dxrp-public `develop` `w_usp.prefab`)  
**LifePunch ident:** `deagle` · **Class:** `handgun` · **CS2 study mesh:** `weapon_pist_deagle`  
**Ship stats:** `Deagle.cs` → `DeagleWeaponStats` (Red/Opus validate in editor)

---

## Comparison table

| Field | USP (DXRP class) | Deagle proposed | Rationale |
|-------|------------------|-----------------|-----------|
| HoldType | `Pistol` | `Pistol` | Same class kit |
| MaxAmmo / MaxReserve | 13 / 52 | 7 / 35 | Deagle smaller mag, fewer reserves |
| BaseDamage | 25 | **55** | Heavy pistol identity |
| FireRate (RPM) | 600 (~0.2s semi) | **267** (~0.225s) | Slower, heavier shots |
| ReloadTime / EmptyReload | 1.5s / 2.0s | **2.0s** (single) | Longer mag + slide |
| Recoil vertical / horizontal | 2 / ±1.4 | **4.5 / ±1.8** | `RecoilPitch` / `RecoilYaw` in `Deagle.cs` |
| Spread | TBD — editor | **2.5°** | Slightly wider than USP tap |
| Range | TBD — editor | **75m** | Short pistol engagement |
| Automatic | false | false | Semi only |
| Model child position | `3.20348, 0.622, -3.676` | Clone USP until `w_deagle` | Swap model child only |
| Muzzle (Model child) | `4.32, 0, 4.76` | Re-tune after Deagle mesh | CS2 deagle longer barrel |
| Library VM placeholder | `vm_usp.vmdl` | `vm_deagle` when rigged | FP via USP class until own rig |
| Library W placeholder | `w_usp.vmdl` | `w_deagle.vmdl` | LifePunch mesh |

---

## Sound mapping (LifePunch-owned)

| Event | Path |
|-------|------|
| Fire | `deagle_shot.sound` |
| Fire distant | `deagle_shot_distant.sound` |
| Reload | `deagle_reload.sound` |
| Cock / empty | `deagle_cock.sound` |
| Draw | `deagle_draw.sound` |

CS2 `weapon_pist_deagle` WAVs → `reference-intake/cs2-weapons/deagle/sounds/` only.

---

## CS2 animation study (expected — Red S2V verify)

| Sequence | ~Duration | USP class reuse |
|----------|-----------|-----------------|
| deploy | ~0.8s | USP draw |
| idle | loop | USP idle |
| fire | ~0.1s | USP fire |
| reload | ~2.2s | USP reload |
| reload_empty | ~2.8s | USP empty |
| inspect | ~4s | optional |

See `deagle/docs/SOURCE_INTAKE.md` · `MANIFEST.txt` at `reference-intake/cs2-weapons/deagle/`.

---

## Red verify checklist

- [ ] Spawn `w_usp` + `Deagle.cs` stats on test bot — feel recoil/damage
- [ ] ModelDoc `w_deagle` with physics hull
- [ ] Clone `w_usp.prefab` → swap model + sounds only
- [ ] Opus sign-off before portal row goes live
