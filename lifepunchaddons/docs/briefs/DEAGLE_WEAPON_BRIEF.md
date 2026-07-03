# Desert Eagle — Active Weapon Brief (Queue #2)

**Issued:** 2026-06-11 · **Lane:** Red builds on VENGEANCE · **Green:** Tier-3 distill/RAG only  
**Canon:** `config/weapon-production.json` · `WEAPON_MASS_PRODUCTION.md` · `WEAPON_CLASS_SPEC.md`

---

## Identity

| Field | Value |
|-------|--------|
| ident | `deagle` |
| title | Desert Eagle |
| s&box | `lifepunch.deagle` |
| DXRP class | **Handgun** → clone **`usp`** kit |
| CS2 reference (study only) | `weapon_pist_deagle` |
| status | `foundation-scaffold` |
| portal | `dxrpAddonId` **empty** — create package before publish |

---

## What exists (scaffold)

- Asset tree: `Assets/addons/lifepunch/deagle/` (`equipment/`, `models/`, `sounds/`, `ui/`)
- Code: `Deagle.cs`, `DeagleWeapon.cs` — stats **zeroed**, paths wired
- Placeholders: `w_deagle` / `vm_deagle` prefab folders (`.gitkeep` only)
- `addons.json` row present; **no content row** yet

---

## Build order (copy AK golden path)

1. **CS2 intake** — glTF `weapon_pist_deagle` → `C:/lifepunch/reference-intake/cs2-weapons/deagle/` (never commit).
2. **Own FBX** — Blender study → `models/.../w_deagle/source/w_deagle.fbx`.
3. **World model** — `w_deagle.vmdl` + `deagle_body.vmat` per `w_deagle/MODEL_BUILD.md`.
4. **3rd-person prefab** — Clone `gameplay/equipment/weapons/usp/w_usp.prefab` → save as `equipment/w_deagle/w_deagle.prefab`; set `Equipment.HoldType = Pistol`, tune `Model` child offset.
5. **1st-person (baseline)** — Use class placeholder `gameplay/equipment/weapons/usp/vm_usp.prefab` on `ViewModelPrefab` until FP rig batch (same AK doctrine).
6. **Stats** — Fill `Deagle.Stats` in `Deagle.cs` from USP class reference, then tune Deagle feel (see below).
7. **Sounds** — Own or licensed under `sounds/source/`.
8. **Manifest** — Portal Equipment row + `addons.json` content; set `dxrpAddonId`.
9. **Publish (VENGEANCE + Opus)** — after Red review: `prepare-publish.ps1 -Addon deagle` → portal → Gun Dealer qty 5. Cornerman cannot push.

---

## Stats target (first pass — tune in editor after USP clone)

Desert Eagle = hard-hitting semi-auto pistol. Start from **USP** DXRP values, then bias:

| Stat | Direction |
|------|-----------|
| Damage | **High** (primary identity) |
| MagazineSize | **Low** (7–8 class) |
| RoundsPerMinute | Moderate semi-auto |
| Automatic | **false** |
| RecoilPitch | **Higher** than USP |
| SpreadDegrees | Slightly wider |
| ReloadSeconds | Similar or slightly longer |

Do not ship zeroed stats.

---

## Path constants (already in `Deagle.cs`)

```text
WorldPrefabPath     → addons/lifepunch/deagle/equipment/w_deagle/w_deagle.prefab
ViewModelPrefabPath → addons/lifepunch/deagle/equipment/vm_deagle/vm_deagle.prefab
WorldModelPath      → addons/lifepunch/deagle/models/lifepunch/deagle/w_deagle/w_deagle.vmdl
Class placeholders  → gameplay/equipment/weapons/usp/w_usp.prefab + vm_usp.prefab
```

---

## Red vs Green

| Who | Job |
|-----|-----|
| **VENGEANCE (Red)** | s&box editor, ModelDoc, prefab clone, stats, publish |
| **Cornerman (Green)** | Distill this brief + `WEAPON_CLASS_SPEC.md` §Handgun for Cursor paste; no editor |

---

## Done when

- [ ] `w_deagle.vmdl` compiles green in ModelDoc
- [ ] `w_deagle.prefab` holds and fires in DXRP sandbox (3rd person correct)
- [ ] Viewmodel uses USP placeholder or own `vm_deagle` if rig ready
- [ ] `Deagle.Stats` non-zero; Functions wired on prefab
- [ ] `prepare-publish.ps1 -Addon deagle` staging clean
- [ ] Portal package + `dxrpAddonId` set

---

## Next action on Red

Open DXRP editor on VENGEANCE → confirm AK still golden → start **deagle** at step 1 (CS2 intake or FBX if intake already on disk).
