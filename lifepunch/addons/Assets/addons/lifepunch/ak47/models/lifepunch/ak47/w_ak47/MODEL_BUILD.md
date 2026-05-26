# AK47 Model Build

This folder is the model build area for the LifePunch AK47 world model.

## Active Source

Cleaned FBX:

```text
source/ak47.fbx
```

The cleaned FBX is the only active model source in the LifePunch repo. Raw/original exports stay in the local reference mirror.

## Texture Inputs

```text
textures/ak47_BaseColor.tga.png
textures/ak47_Normal.tga.png
textures/ak47_Metalness.tga.png
textures/ak47_Roughness.tga.png
```

## Target Outputs

Model resource:

```text
w_ak47.vmdl
```

Material resource:

```text
materials/ak47_body.vmat
```

## Current Status

- `w_ak47.vmdl` has been created by S&box.
- The model references `source/ak47.fbx`.
- `materials/ak47_body.vmat` has been created from the PBR texture set.
- `w_ak47.vmdl` is assigned to `materials/ak47_body.vmat`.
- `equipment/w_ak47/w_ak47.prefab` has been created with `Sandbox.SkinnedModelRenderer`.
- `equipment/w_ak47/w_ak47.prefab` now has first-pass DXRP `Equipment`, `TagBinder`, `Muzzle`, `EjectionPort`, `Functions`, ammo, shoot, reload, and recoil component wiring.
- `equipment/w_ak47/w_ak47.prefab` was reopened in S&box after wiring and saved with adjusted `Muzzle` and `EjectionPort` positions.
- `equipment/vm_ak47/vm_ak47.prefab` has been created with `Sandbox.SkinnedModelRenderer` using the same model as a first pass.
- `equipment/vm_ak47/vm_ak47.prefab` now has first-pass DXRP `ViewModel`, `Muzzle`, and `EjectionPort` wiring.
- Material references should stay mounted/relative, not absolute local filesystem paths.

## Build Notes

- Create the S&box model resource from `source/ak47.fbx`.
- Create the material from the imported PBR texture channels.
- Keep the world model mounted path stable: `models/lifepunch/ak47/w_ak47/w_ak47.vmdl`.
- Do not add raw Blender exports, loose bullet variants, or old model names here.
- Do not mark this model ready until S&box opens/compiles the resource cleanly.

## Next Manual S&box Step

1. Reopen `equipment/vm_ak47/vm_ak47.prefab` in S&box and confirm the `ViewModel` component loads cleanly.
2. Save the viewmodel prefab from the editor after confirming the patched references.
3. Do not publish until the world prefab and viewmodel prefab both load cleanly in a DXRP test context.
