# Materials: gpu_rack (Bitcoin Mining)

**Status:** Waiting for final `.vmat` + textures.

## Drop files here (repo path)

```
bitcoin-mining/Assets/materials/gpu_rack/
  gpu_rack.vmat
  gpu_rack_color.png
  gpu_rack_normal.png    (optional)
  gpu_rack_rough.png     (optional)
  gpu_rack_metal.png     (optional)
```

## After adding files

```powershell
cd C:\Users\jared\Projects\lifepunch-dxrp-addons
.\scripts\sync-to-lifepunchaddons.ps1
```

Editor path: `Assets/bitcoinmining/materials/gpu_rack/`

In ModelDoc open `Assets/bitcoinmining/models/gpu_rack/gpu_rack.vmdl` and remap the mesh material to `bitcoinmining/materials/gpu_rack/gpu_rack.vmat`.

Do **not** use **Create Material** on the color PNG if you already have a hand-authored `.vmat` (same rule as AK-47).
