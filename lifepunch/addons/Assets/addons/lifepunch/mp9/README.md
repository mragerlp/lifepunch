# MP9 Assets

Mass-production scaffold â€” clone of AK kit pattern. Class: **smg** (DXRP reference: **mp5**).

## CS2 reference (study only â€” do not ship)

Source 2 Viewer: `weapons/models/mp9/` â†’ `weapon_smg_mp9`

Export glTF to: `C:/lifepunch/reference-intake/cs2-weapons/mp9/` (reference-only).

## Target mounted paths

```text
addons/lifepunch/mp9/equipment/w_mp9/w_mp9.prefab
addons/lifepunch/mp9/equipment/vm_mp9/vm_mp9.prefab
addons/lifepunch/mp9/models/lifepunch/mp9/w_mp9/w_mp9.vmdl
```

## Next editor steps

1. Import own FBX â†’ `models/lifepunch/mp9/w_mp9/source/`
2. Build `w_mp9.vmdl` + materials (see MODEL_BUILD.md)
3. Clone `gameplay/equipment/weapons/mp5/w_mp5.prefab` / `gameplay/equipment/weapons/mp5/vm_mp5.prefab` prefab wiring in editor â†’ save as w_/vm_ prefabs here
4. Tune 3rd-person grip vs class reference
5. Ship VM as **clean class placeholder** until FP rig bind (`gameplay/equipment/weapons/mp5/vm_mp5.prefab`)

See `Code/Addons/lifepunch/mp9/docs/WEAPON_BUILD.md`.
