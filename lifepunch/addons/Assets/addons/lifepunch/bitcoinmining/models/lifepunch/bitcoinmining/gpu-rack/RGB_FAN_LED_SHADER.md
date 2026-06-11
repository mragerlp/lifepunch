# GPU rack — RGB fan LED shader (editor fix)

## Root cause (2026-06-11)

First draft used `GatherMaterial` / `FinalizePixelMaterial` — those are **not** in the s&box shader API, so the compiler never produced `lifepunch_rgb_fan_led.shader_c` and `gpu-rack-gpu.vmat` failed with `Error opening shader`.

## Compile order (do this in editor)

1. **Shader** — Asset Browser → `addons/lifepunch/bitcoinmining/shaders/lifepunch_rgb_fan_led.shader` → open → **Save**  
   Confirm `lifepunch_rgb_fan_led.shader_c` appears (no red errors in compile output).

2. **Material** — open `gpu-rack/materials/gpu-rack-gpu.vmat` → **Save**  
   Confirm `gpu-rack-gpu.vmat_c` rebuilds (references RGB shader, not `complex.shader`).

3. **Model** — ModelDoc `gpu-rack.vmdl` → **Compile** if GPU slot is pink.

4. **Repo** — `Pull-DxrpCompiledAssetsToRepo.ps1 -Addon bitcoinmining`

## C# hook

`BitminerEntity.UpdateRgbFanLeds()` sets `g_flLedActive` on the renderer scene object (0–1 with fan ramp).

## Rack slot

`gpu-rack-rack.vmat` still uses `complex.shader` until `Rack_Emission.png` exists (BITMINER-01).
