# SSG 08 â€” Build Checklist

Copy AK golden-kit workflow. Class = **sniper** / **m700**.

- [ ] CS2 glTF â†’ Blender study â†’ own `w_ssg08.fbx`
- [ ] `w_ssg08.vmdl` + materials
- [ ] `w_ssg08.prefab` cloned from `gameplay/equipment/weapons/m700/w_m700.prefab` (Equipment + Functions)
- [ ] `vm_ssg08.prefab` OR placeholder `gameplay/equipment/weapons/m700/vm_m700.prefab` for FP
- [ ] Sounds under `sounds/` (own or licensed)
- [ ] Tune `Ssg08.Stats` from class reference
- [ ] `addons.json` content row + portal Equipment + Gun Dealer shipment (Qty 5)
- [ ] `prepare-publish.ps1 -Addon ssg08`

## Portal

Create DXRP addon package on portal â†’ set `dxrpAddonId` in `addons.json`.
