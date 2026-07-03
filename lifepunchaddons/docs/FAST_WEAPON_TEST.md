# Fast weapon test (editor, no portal Equipment row)

Use these **dev-only** console commands while the LifePunch addon is mounted in the DXRP editor project.
They clone prefabs directly — excluded from publish (`_dev/WeaponDevGive.cs`).

**Red first:** `Sync-LifePunchAddonsToDxrp.ps1 -Addon ak47` after every repo pull.

---

## AK-47 — 3P bot smoke (see broken hold fast)

```text
lifepunch_clear_testbots
lp_smoke_ak_bot
```

Or step by step:

```text
lifepunch_spawn_testbot Greg
lp_give_ak_bot Greg
```

Orbit **Greg** in free camera — third-person rifle hold should match M4 class.  
**Note:** `lifepunch_spawn_testbot` disables `Controller` by default; `lp_give_ak_bot` re-enables it for hold IK.

### AK — first person + drop (local player)

```text
lp_give_ak
```

Alias: `lp_give_ak_class` · `lp_give_weapon ak47`

| Piece | Path |
|-------|------|
| World prefab | `addons/lifepunch/ak47/equipment/w_ak47/w_ak47.prefab` |
| World mesh (runtime) | class `w_m4a1.vmdl` until CS2 rebuild |
| Viewmodel (forced) | `gameplay/equipment/weapons/m4a1/vm_m4a1.prefab` |
| Sounds | LifePunch `ak47/sounds/*` on prefab |

**Pass:** M4 arms 1P; M4 in hand 3P on Greg; drop rests on floor; AK fire/reload sounds.

**Fail cues:**

| Symptom | Likely cause |
|---------|----------------|
| Frankenstein FP mesh | Stale `vm_ak47` with bonemerged `v_ak47` — pull repo + sync |
| Gun floats / wrong angle on bot | Bot controller was off — use `lp_give_ak_bot` not manual equip |
| Falls through floor | Old `w_ak47.vmdl` without physics — sync repo baseline |
| `lp_give_ak` does nothing | Stale code — rebuild; should equip via class baseline |

---

## #2–5 Queue weapons (class placeholder until LifePunch prefabs ship)

```text
lp_give_deagle
lp_give_mp9
lp_give_ssg08
lp_give_xm1014
```

Canon: `RED_WEAPON_MASS_PRODUCTION_PLAN.md` · `weapon-production.json`
