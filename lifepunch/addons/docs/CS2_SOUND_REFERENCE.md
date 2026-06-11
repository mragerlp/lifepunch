# CS2 weapon sounds — reference harvest (ship LifePunch WAVs)

AK-47 LifePunch sounds **work in-game** — keep that pattern. CS2 provides **timing, loudness, and layering** reference only.

**Never** copy CS2 `.wav` / `.vsnd` into `lifepunch/addons/Assets/` publish tree.

---

## Where CS2 hides weapon audio

| Location | What to find |
|----------|--------------|
| `sounds/weapons/` | Per-weapon folders (`ak47`, `deagle`, `m4a1`, …) |
| `soundevents/` | `weapon.*.vsndevts` — event names tied to animations |
| S2V search | Filter VPK by weapon ident + `fire`, `reload`, `deploy`, `distant` |

Export reference WAV to:

```text
C:/lifepunch/reference-intake/cs2-weapons/<ident>/sounds/
```

---

## LifePunch ship set (mirror per weapon)

Copy structure from `ak47/sounds/`:

| Slot | AK example | Wire on prefab |
|------|------------|----------------|
| Fire | `ak47_shot.sound` + `ak47_shot.wav` | `ShootWeaponComponent.ShootSound` |
| Fire distant | `ak47_shot_distant.sound` | distant variant |
| Reload out | `ak47_reload_clipout.sound` | `ReloadWeaponComponent` timed sounds |
| Reload in | `ak47_reload_clipin.sound` | timed sounds |
| Cock / pump | `ak47_cock.sound` | empty reload tail |
| Draw | `ak47_draw.sound` | `Equipment.DeploySound` |

Author **new** WAVs; use CS2 only to judge length (~ms) and punch.

---

## CS2 search terms by queue weapon

| ident | CS2 mesh | S2V sound search hints |
|-------|----------|------------------------|
| `ak47` | `weapon_rif_ak47` | `ak47`, `rif_ak47` |
| `deagle` | `weapon_pist_deagle` | `deagle`, `pist_deagle` |
| `mp9` | `weapon_smg_mp9` | `mp9`, `smg_mp9` |
| `ssg08` | `weapon_snip_ssg08` | `ssg08`, `scout`, `ssg` |
| `xm1014` | `weapon_shot_xm1014` | `xm1014`, `m1014`, `shot_xm` |
| `doublebarrelshotgun` | `weapon_shot_sawedoff` | `sawedoff`, `mag7` |
| `awp` | `weapon_snip_awp` | `awp`, `snip_awp` |
| `glock18` | `weapon_pist_glock18` | `glock`, `pist_glock` |
| `m4a4` | `weapon_rif_m4a1` | `m4a1`, `rif_m4` |
| `p250` | `weapon_pist_p250` | `p250`, `pist_p250` |

Record heard event names in each weapon's `MANIFEST.txt` under `## Sounds`.

---

## Intake

`Intake-Cs2WeaponReference.ps1` MANIFEST stubs include sound folder paths.  
Red exports WAV in S2V GUI; Green/Cornerman logs event names in MANIFEST.

---

Canon: `ak47/docs/SOURCE_INTAKE.md` (owned sound intake) · `CS2_WORLD_MODEL_PIPELINE.md`
