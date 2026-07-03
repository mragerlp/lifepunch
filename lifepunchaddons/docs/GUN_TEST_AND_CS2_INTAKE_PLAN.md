# Gun testing + CS2 intake brainstorm

**Status:** Planning capture (2026-06-11). Owner + Red action list.  
**Canon:** `FAST_WEAPON_TEST.md` · `CS2_WEAPON_HARVEST.md` · `RED_WEAPON_MASS_PRODUCTION_PLAN.md`

---

## Part A — Start testing guns (today)

### Prerequisites (one-time)

1. Red applied Green patches (`b4e551f+`) and `git push`
2. `Sync-LifePunchAddonsToDxrp.ps1 -Addon ak47` (add others as they ship)
3. DXRP editor → Play as host

### Test ladder (do in order — each step is a gate)

| Gate | Command | Pass | Time |
|------|---------|------|------|
| **G0** Compile | Open project, no C# errors | Green console | 2 min |
| **G1** AK kit | `lp_give_ak` | Arms + AK 1P, no M4 mesh, fire/reload | 5 min |
| **G2** Class pistols | `lp_give_deagle` | USP VM, semi fire, 7-round feel | 3 min |
| **G3** Class SMG | `lp_give_mp9` | MP5 VM, auto spray | 3 min |
| **G4** Class sniper | `lp_give_ssg08` | M700 scope, bolt semi | 3 min |
| **G5** Class shotgun | `lp_give_xm1014` | 8-pellet spread | 3 min |
| **G6** Generic | `lp_give_weapon ssg08` | Same as dedicated cmd | 1 min |

**G1–G5** can run **before any CS2 export** — class placeholders prove hold type, fire mode, and `*Weapon.cs` stats targets.

### After CS2 mesh ships (per weapon)

| Gate | What | Pass |
|------|------|------|
| **G7** 3P mesh | LifePunch `w_<ident>.vmdl` on cloned prefab | Correct gun visible in hand, muzzle flash at barrel |
| **G8** Stats | Mirror `WEAPON_PREFAB_TUNE.md` onto prefab | RPM/mag/damage match spec sheet |
| **G9** Sounds | Wire paths from `<Pascal>.cs` | Fire/reload audible |
| **G10** Portal | Equipment row + `prepare-publish.ps1` | Dedicated server mounts `_c` |

### Suggested Red session (90 min)

```
00:00  Sync addon, G0
00:05  G1 AK — log any hold/muzzle issues
00:15  G2 deagle — then start CS2 export for deagle (parallel)
00:25  G3–G5 remaining class smokes
00:40  Blender study deagle glTF → w_deagle.fbx
01:00  ModelDoc w_deagle.vmdl → clone USP prefab → re-test lp_give_deagle (G7)
01:30  Tune stats G8, note sheet in WEAPON_BUILD.md
```

### Bots + guns

Bots (`lifepunch_spawn_testbot`) are **not required** for gun give tests. Use them later for:

- Damage / kill feedback on a standing target
- Wallet-adjacent RP (separate from gun pipeline)

---

## Part B — Gather more CS2 weapon models

### Current state

| ident | Intake on disk | glTF exported |
|-------|----------------|---------------|
| deagle | `reference-intake/cs2-weapons/deagle/MANIFEST.txt` | **Red** — needs S2V on VENGEANCE |
| mp9 | MANIFEST stub | Red |
| ssg08 | MANIFEST stub | Red |
| xm1014 | MANIFEST stub | Red |
| ak47 | optional proportion check | `weapon_rif_ak47` |

Cornerman: `Intake-Cs2WeaponReference.ps1 -ManifestOnly`  
Red: full export with CS2 installed + Source 2 Viewer.

### Batch weapon harvest (Red, one sitting)

```powershell
cd lifepunchaddons\scripts
$cli = 'C:\Tools\Source2Viewer-CLI.exe'   # adjust path
powershell -File .\Intake-Cs2WeaponReference.ps1 -Ident deagle,mp9,ssg08,xm1014 -CliPath $cli -ExportGltf
```

GUI alternative: S2V → `pak01_dir.vpk` → `weapons/models/<weapon>/` → export glTF to  
`C:\lifepunch\reference-intake\cs2-weapons\<ident>\viewmodel\`

**Per weapon, capture in MANIFEST.txt:**

- Main `.vmdl_c` filename (not mag-only)
- Animation names seen in S2V dropdown (reload, fire, idle)
- Texture size notes

### Optional queue expansion (future Gun Dealer rows)

| ident | CS2 mesh | Class clone | Notes |
|-------|----------|-------------|-------|
| `glock` | `weapon_pist_glock18` | USP or new | Sidearm variety |
| `m4a4` | `weapon_rif_m4a1` | m4a1 | AR alt skin |
| `awp` | `weapon_snip_awp` | m700 line | Heavier sniper |
| `knife` | `weapon_knife_*` | melee class | Low priority |

Add rows to `weapon-production.json` only after #2–#5 ship.

---

## Part C — CS2 player models for jobs

### Two-source rule (same as weapons)

| Source | Use | Ship |
|--------|-----|------|
| **CS2** `characters/models/` | Silhouette, vest/helmet proportions, texture palette study | **Never** |
| **s&box citizen** + DXRP clothing | Rig, animations, multiplayer | **Ship** custom materials/meshes attached to citizen |

CS2 agents **do not** replace the citizen skeleton in DXRP. Study → model **own** gear in Blender → mount as clothing/props on citizen.

### CS2 VPK paths (S2V)

| Asset | VPK path | Job use |
|-------|----------|---------|
| CT agents | `characters/models/ctm_*` | SWAT, Police |
| T agents | `characters/models/tm_*` | Criminal / Hacker street look study |
| SWAT | `ctm_swat` variants | SWAT job (`SWAT_JOB_SPEC.md`) |
| SAS / GIGN etc. | named agent folders | Elite police skins |

Export glTF → `C:\lifepunch\reference-intake\cs2-characters\<role>\` (new root, never commit).

### Proposed job study queue

| Job | CS2 study target | LifePunch endgame | Terminal brand |
|-----|------------------|-------------------|----------------|
| **Hacker** | Casual T agent + CRT prop (separate) | Own street outfit + hacker terminals | Cornerman green |
| **Police** | `ctm_fbi` / default CT | lifepunchnet uniform + police terminal | Cyan |
| **SWAT** | `ctm_swat` + shield study | Tactical rig on citizen | Cyan + heavy kit |
| **Cybersecurity Officer** | CT tech / FBI variant | Owner-built | TBD |
| **Mayor / Gov** | Suit agent variants | lifepunchnet ops | Cyan |

### Character intake (scaffolded)

- **Queue:** `config/gear-production.json` (swat, police, hacker, mayor, cybersecurity + riot_shield prop)
- **Script:** `scripts/Intake-Cs2CharacterReference.ps1`
- **Docs:** `CS2_CHARACTER_HARVEST.md`

```powershell
# Cornerman
powershell -File Intake-Cs2CharacterReference.ps1 -ManifestOnly

# Red
powershell -File Intake-Cs2CharacterReference.ps1 -Ident swat,police -CliPath <S2V-CLI> -ExportGltf
```

### Player model workflow (endgame)

```
CS2 agent glTF → Blender measure → own vest/helmet FBX → ModelDoc → 
DXRP Clothing / BodyGroup or prop attach on citizen → job loadout in portal
```

Opus review before any job loadout touches economy or permissions.

---

## Part D — Who does what

| Task | Green (Cornerman) | Red (VENGEANCE) |
|------|-------------------|-----------------|
| Gun test runbook | ✅ this doc + FAST_WEAPON_TEST | Run G0–G10 |
| CS2 weapon MANIFEST stubs | ✅ done #2–#5 | Export glTF |
| CS2 character MANIFEST | Scaffold script + role table | Export agents |
| `w_deagle.vmdl` | — | Blender + ModelDoc |
| SWAT / Police gear | Spec only | Models + citizen attach |
| Portal publish | — | After G8 per weapon |

---

## Part E — Immediate next actions

1. **Red:** `git am` Green patches → sync ak47 → **G1 `lp_give_ak`**
2. **Red:** G2–G5 class smokes (10 min total)
3. **Red:** S2V export **deagle** glTF first (unblocks #2)
4. **Green:** ✅ `gear-production.json` + `Intake-Cs2CharacterReference.ps1` — Red runs S2V export
5. **Owner:** confirm datacenter / SWAT art priority vs gun queue #2
