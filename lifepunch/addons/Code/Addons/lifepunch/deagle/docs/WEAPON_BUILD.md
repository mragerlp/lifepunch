# Desert Eagle â€” Build Checklist

Copy AK golden-kit workflow. Class = **handgun** / **usp**.

- [ ] CS2 glTF â†’ Blender study â†’ own `w_deagle.fbx`
- [ ] `w_deagle.vmdl` + materials
- [ ] `w_deagle.prefab` cloned from `gameplay/equipment/weapons/usp/w_usp.prefab` (Equipment + Functions)
- [ ] `vm_deagle.prefab` OR placeholder `gameplay/equipment/weapons/usp/vm_usp.prefab` for FP
- [ ] Sounds under `sounds/` (own or licensed)
- [ ] Tune `Deagle.Stats` from class reference
- [ ] `addons.json` content row + portal Equipment + Gun Dealer shipment (Qty 5)
- [ ] `prepare-publish.ps1 -Addon deagle`

## Portal

Create DXRP addon package on portal â†’ set `dxrpAddonId` in `addons.json`.
