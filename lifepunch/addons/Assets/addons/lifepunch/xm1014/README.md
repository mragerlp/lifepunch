# XM1014 Assets

Mass-production scaffold â€” clone of AK kit pattern. Class: **shotgun** (DXRP reference: **spaghelli**).

## CS2 reference (study only â€” do not ship)

Source 2 Viewer: `weapons/models/xm1014/` â†’ `weapon_shot_xm1014`

Export glTF to: `C:/lifepunch/reference-intake/cs2-weapons/xm1014/` (reference-only).

## Target mounted paths

```text
addons/lifepunch/xm1014/equipment/w_xm1014/w_xm1014.prefab
addons/lifepunch/xm1014/equipment/vm_xm1014/vm_xm1014.prefab
addons/lifepunch/xm1014/models/lifepunch/xm1014/w_xm1014/w_xm1014.vmdl
```

## Next editor steps

1. Import own FBX â†’ `models/lifepunch/xm1014/w_xm1014/source/`
2. Build `w_xm1014.vmdl` + materials (see MODEL_BUILD.md)
3. Clone `gameplay/equipment/weapons/spaghelli/w_spaghelli.prefab` / `gameplay/equipment/weapons/spaghelli/vm_spaghelli.prefab` prefab wiring in editor â†’ save as w_/vm_ prefabs here
4. Tune 3rd-person grip vs class reference
5. Ship VM as **clean class placeholder** until FP rig bind (`gameplay/equipment/weapons/spaghelli/vm_spaghelli.prefab`)

See `Code/Addons/lifepunch/xm1014/docs/WEAPON_BUILD.md`.
