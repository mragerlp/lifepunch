# XM1014 â€” Build Checklist

Copy AK golden-kit workflow. Class = **shotgun** / **spaghelli**.

- [ ] CS2 glTF â†’ Blender study â†’ own `w_xm1014.fbx`
- [ ] `w_xm1014.vmdl` + materials
- [ ] `w_xm1014.prefab` cloned from `gameplay/equipment/weapons/spaghelli/w_spaghelli.prefab` (Equipment + Functions)
- [ ] `vm_xm1014.prefab` OR placeholder `gameplay/equipment/weapons/spaghelli/vm_spaghelli.prefab` for FP
- [ ] Sounds under `sounds/` (own or licensed)
- [x] Tune `Xm1014.Stats` from class reference (`DXRP_CLASS_WEAPON_REFERENCES.md`)
- [ ] `addons.json` content row + portal Equipment + Gun Dealer shipment (Qty 5)
- [ ] `prepare-publish.ps1 -Addon xm1014`

## Portal

Create DXRP addon package on portal â†’ set `dxrpAddonId` in `addons.json`.
