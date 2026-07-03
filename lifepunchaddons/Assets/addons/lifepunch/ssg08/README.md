# SSG 08 Assets

Mass-production scaffold â€” clone of AK kit pattern. Class: **sniper** (DXRP reference: **m700**).

## CS2 reference (study only â€” do not ship)

Source 2 Viewer: `weapons/models/ssg08/` â†’ `weapon_snip_ssg08`

Export glTF to: `C:/lifepunch/reference-intake/cs2-weapons/ssg08/` (reference-only).

## Target mounted paths

```text
addons/lifepunch/ssg08/equipment/w_ssg08/w_ssg08.prefab
addons/lifepunch/ssg08/equipment/vm_ssg08/vm_ssg08.prefab
addons/lifepunch/ssg08/models/lifepunch/ssg08/w_ssg08/w_ssg08.vmdl
```

## Next editor steps

1. Import own FBX â†’ `models/lifepunch/ssg08/w_ssg08/source/`
2. Build `w_ssg08.vmdl` + materials (see MODEL_BUILD.md)
3. Clone `gameplay/equipment/weapons/m700/w_m700.prefab` / `gameplay/equipment/weapons/m700/vm_m700.prefab` prefab wiring in editor â†’ save as w_/vm_ prefabs here
4. Tune 3rd-person grip vs class reference
5. Ship VM as **clean class placeholder** until FP rig bind (`gameplay/equipment/weapons/m700/vm_m700.prefab`)

See `Code/Addons/lifepunch/ssg08/docs/WEAPON_BUILD.md`.
