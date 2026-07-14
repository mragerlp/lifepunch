# Fog

This class applies atmospheric effects to a fragment.

Only useful if you're doing your own [Shading Model](/dev/doc/rendering/shaders/shading-model), otherwise this is already all implied when you use `ShadingModelStandard`.

# API

## Apply All 

```cpp
Fog::Apply( float3 WorldPosition, float2 ScreenPosition, float3 Color );
```

This will apply *all* types of atmospheric effects onto current pixel (`float3 Color`) if they are available on scene:
* Gradient fog
* Cubemap fog
* Volumetric fog 

If you only need specific fog effects, see the functions below. 

## Gradient Fog

```cpp
ApplyGradientFog( inout float3 Color, float3 WolrdPosition, float3 PositionToCamera );
```

For both **gradient** and **cubemap** fog, you need to calculate `PositionToCamera`. This can be done by simply subtracting world-space camera position from pixel world position:

```cpp
float3 PositionToCamera = worldPos.xyz - g_vCameraPositionWs;
```

## Cubemap Fog

```cpp
ApplyCubemapFog( float3 Color, float3 WolrdPosition, float3 PositionToCamera );
```

## Volumetric Fog

```cpp
ApplyVolumetricFog( float3 Color, float3 WorldPosition, float2 ScreenPosition );
```