# Uranium Specialist — asset inventory

**Source pack:** `Pack_SciFi_B_001_V1.0.zip` (LowPoly SciFi Pack B)  
**Intake script:** `addons/scripts/Intake-UraniumSpecialistScifiPack.ps1`  
**Archive:** `C:\lifepunch\reference-intake\uraniumspecialist\pack-scifi-b-001`

## Props (ModelDoc TODO — raw intake complete)

| Slug | Pack FBX | Role | vmdl | prefab |
|------|----------|------|------|--------|
| `uranium-reactor` | `SM_Reactor` | Job centerpiece | TODO | TODO |
| `uranium-energy-cell` | `SM_Energy_Cell` | Fuel / enriched crate | TODO | TODO |
| `uranium-cell` | `SM_Cell` | Small cell | TODO | TODO |
| `uranium-control-panel` | `SM_Control_Pannel` | Control station | TODO | TODO |
| `uranium-power-cabinet` | `SM_Power_Cabinet` | Cabinet | TODO | TODO |
| `uranium-power-junction` | `SM_Power_Junction` | Junction | TODO | TODO |
| `uranium-fuse-box` | `SM_Fuse_Box` | Fuse box | TODO | TODO |
| `uranium-battery` | `SM_Batterie` | Battery | TODO | TODO |
| `uranium-capacitor` | `SM_Capacitor` | Capacitor | TODO | TODO |
| `uranium-circuit-card` | `SM_Card` | Circuit card | TODO | TODO |
| `uranium-switch` | `SM_Switch` | Switch | TODO | TODO |
| `uranium-cooling-fan` | `SM_Ventilateur` | Cooling fan | TODO | TODO |

Each slug: `models/lifepunch/uraniumspecialist/<slug>/source/<slug>.{fbx,obj,mtl}`

## Build order (suggested)

1. **Reactor** — scale reference for the whole job line  
2. **Control panel** — interaction / terminal anchor (if job uses placeable UI)  
3. **Energy cell + cell** — processing props  
4. Remaining set dressing (cabinet, junction, fan, etc.)

## Code (repo)

| File | Role |
|------|------|
| `UraniumSpecialistJob.cs` | Package identity constants (scaffold) |

Spec: `addons/docs/URANIUM_SPECIALIST_SPEC.md`
