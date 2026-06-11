# Desert Eagle Assets

Mass-production scaffold â€” clone of AK kit pattern. Class: **handgun** (DXRP reference: **usp**).

## CS2 reference (study only â€” do not ship)

Source 2 Viewer: `weapons/models/deagle/` â†’ `weapon_pist_deagle`

Export glTF to: `C:/lifepunch/reference-intake/cs2-weapons/deagle/` (reference-only).

## Target mounted paths

```text
addons/lifepunch/deagle/equipment/w_deagle/w_deagle.prefab
addons/lifepunch/deagle/equipment/vm_deagle/vm_deagle.prefab
addons/lifepunch/deagle/models/lifepunch/deagle/w_deagle/w_deagle.vmdl
```

## Next editor steps

1. Import own FBX â†’ `models/lifepunch/deagle/w_deagle/source/`
2. Build `w_deagle.vmdl` + materials (see MODEL_BUILD.md)
3. Clone `gameplay/equipment/weapons/usp/w_usp.prefab` / `gameplay/equipment/weapons/usp/vm_usp.prefab` prefab wiring in editor â†’ save as w_/vm_ prefabs here
4. Tune 3rd-person grip vs class reference
5. Ship VM as **clean class placeholder** until FP rig bind (`gameplay/equipment/weapons/usp/vm_usp.prefab`)

See `Code/Addons/lifepunch/deagle/docs/WEAPON_BUILD.md`.
