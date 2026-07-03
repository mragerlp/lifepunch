# MP9 — Build Checklist

Queue **#3** · Class **smg** · Clone **MP5** · Editor test: **`lp_give_mp9`**

## Code (Green — done)

| Item | Location |
|------|----------|
| Stats + paths | `Mp9.cs` |
| Equipment helper | `Mp9Weapon.cs` |
| Class placeholders | `w_mp5.prefab` / `vm_mp5.prefab` |
| Prefab tune sheet | `addons/docs/WEAPON_PREFAB_TUNE.md` |

## Stats (mirror to prefab)

| Field | Value |
|-------|-------|
| Damage | 11 |
| RPM | 857 (auto) |
| Mag / reserve | 30 / 90 |
| Reload | 1.4s |
| Range | 65m |
| Spread | 2.2° |
| Recoil | 3.0 pitch / 2.0 yaw |

## Red lane

- [ ] CS2 `weapon_smg_mp9` → Blender study → own `w_mp9.fbx`
- [ ] `w_mp9.vmdl` + materials under `models/lifepunch/mp9/`
- [ ] `w_mp9.prefab` cloned from `gameplay/equipment/weapons/mp5/w_mp5.prefab`
- [ ] `ViewModelPrefab` → class `vm_mp5.prefab` until FP rig batch
- [ ] Tune prefab from stats table; verify hold rotation vs MP5 class
- [ ] Sounds under `sounds/`
- [ ] Killfeed icon `ui/mp9_killfeed.png`
- [ ] `prepare-publish.ps1 -Addon mp9`

**Pass criteria:** high-RPM SMG spray; 30-round mag; auto fire; MP9 mesh 3P; class MP5 arms 1P until custom VM.

## Portal

Create DXRP addon package → set `dxrpAddonId` in `addons.json` → Equipment row + Gun Dealer shipment (Qty 5).
