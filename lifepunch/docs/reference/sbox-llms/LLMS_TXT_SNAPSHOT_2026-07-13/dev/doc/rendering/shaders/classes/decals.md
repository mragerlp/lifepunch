# Decals

**Decals** is a class that handles whole process of rendering decals on scene. Usually you may need to use this class if you are building a custom shading model and you want it to support decal rendering. You don't have to use this function if your shader passes all data into a standard shading model, it already handles decals.

## ::From

```cpp
Decals::From( float3 WorldPosition, in out Material material )

```

* `WorldPosition` is the world-space pixel position
* `Material` is the material that you built in the main shader. Decals iterate over the existing material, they are applied on top of it. `in out` means that it will automatically write new changes to the material variable that you pass into this function.
* * Make sure that your `ScreenPosition` in the material struct is not empty!

This is everything that you need to know about decals if you want to add them in your shader code. If you are curious about the internal stuff, you're welcome to continue reading. 

## Decals Culling

### Counting Available Decals 

All decals are culled using the **clustered culling**. To check how many decals are avaiable in the current cluster, you do this:

```cpp
ClusterRange range = Cluster::Query( ClusterItemType_Decal, ScreenPosition );
```

ClusterRange is a struct that holds a **Count** property, it will contain the number of decals present in cluster. Zero means that current cluster has no decals available. Do whatever you want with this. This range will be required to load the actual decal ID from cluster. 

### Reading from Cluster

Decals are stored in a structured buffer, but you need an ID to load correct decals from it. This ID is stored within the cluster data, this is how you fetch it: 

```cpp
// Iterate through all decals in cluster, load and resolve them
for ( uint j = 0; j < range.Count; j++ )
{
	Decal decal = DecalBuffer[ Cluster::LoadItem( range, j ) ];
    // Do whatever...
}
```

## Decal Data Structure

All decals are stored in a global structured buffer called **DecalsBuffer**. Each decal instance stores following data:

```cpp
struct Decal
{
	float3  WorldPosition;      // Decal position in world
	float4  Quat;               // Decal rotation 
	float3  Scale;              // Decal scale
	uint2   PackedTextureID;    // Packed bindless texture IDs, attenuation, exponent
	uint    SortOrder;          // unused
	uint    ExclusionBitMask;   // unused
	uint    ColorTint;          // Decal tint
	int     ExtraDataOffset;    // Byte address offset for extra data struct
};

```

### PackedTextureID

**PackedTextureID** is a packed uint2 vector that stores bindless IDs for standard decal textures and additional values, such as *decal attenuation* and *color tint exponent*. 

Standard decal textures are: **color**, **normal** and **RMA** (packed roughness/metalness/AO). Red channel is roughness, green channel is metalness, and blue is ambient occlusion. For RMA, it is expected that artist must manually pack these textures together using that specific order. Additional texture slots such as heightmap/emission are stored in the extra data buffer.

Here is an example how to unpack this data:

```cpp
// Unpacking bindless texture IDs 
uint nColorId = decal.PackedTextureID.x & 0xFFFF;
uint nNormalId = ( decal.PackedTextureID.x >> 16 ) & 0xFFFF;
uint nRmaId = decal.PackedTextureID.y & 0xFFFF;

// Unpacking decal attenuation and exponent
uint nDecalAttenuation = ( decal.PackedTextureID.y >> 24 ) & 0xFF;
float flAttenuation = (float)nDecalAttenuation / 255.0f; // Attenuation must be a float
uint nColorExponent = ( decal.PackedTextureID.y >> 16 ) & 0xFF;
```

### Color Tint

Color tint property in this struct is also packed. To get the actual color value, Decal class file has a helper function `UnpackColor( uint packedColor )`. Use it to get the actual `float4` color tint value. 

Here's an example how to unpack the tint color, get the signed value, and then apply color tint exponent: 

```cpp
// Unpack the tint color and get a signed vector
float4 vColorTint = UnpackColor( decal.ColorTint );
float3 vSignedRGB = vColorTint.rgb * 255.0 - 128.0;

// Apply exponent to the color tint
vColorTint.rgb = vSignedRGB * exp2( float( exp ) - 128.0 - 7.0 );
```

### Helper Struct Functions

There are two helper functions included with the main buffer:

* `GetCenter()` returns `-WorldPosition`
* `GetRadius()` returns the radius of this decal in world units

None of these functions are used in the actual decal resolving code.

## Extra Decal Data 

To avoid cluttering the main struct with every single feature, there is a dedicated byte address buffer called **DecalsExtraDataBuffer** which stores all extra data for optional features. An integer property **ExtraDataOffset** from main buffer tells you where exactly the data for current decal is stored. 

At the current moment, extra data struct looks like this:

| Byte Offset | Type | Property |
|-------------|------|----------|
| 0  | float4 | Sheet Data | 
| 16 | uint   | Sequence Index | 
| 20 | float  | Color Mix Amount | 
| 24 | uint   | Feature flags (unused?) | 
| 28 | uint   | Heightmap bindless ID | 
| 32 | float  | Parallax strength | 
| 36 | uint   | SamplerState bindless ID | 
| 40 | uint   | Emission bindless ID | 
| 44 | float  | Emission strength |

Not every decal has its own extra data allocated in this buffer. By default, no extra data is allocated at all if decal does not match at least one of these conditions:

* Heightmap texture is added
* Emission texture is added
* Color map texture has a sheet sequence
* Color mix value is less than `1.0f`
* Using non-default sampler (texture filter mode)

Here's an example how to load some of this data:

```cpp
// Safety check, avoid reading extra data directly since some decals
// may not have any extra data allocated at all!
if ( decal.ExtraDataOffset >= 0 )
{
    float4 vSheetData = asfloat( DecalsExtraDataBuffer.Load4( decal.ExtraDataOffset ) );
    uint nSheetSequence = DecalsExtraDataBuffer.Load( decal.ExtraDataOffset + 16 );
    float flColorMix = asfloat( DecalsExtraDataBuffer.Load( decal.ExtraDataOffset + 20 ) );
    uint nHeightBindlessID = DecalsExtraDataBuffer.Load( decal.ExtraDataOffset + 28 );
    uint nSamplerBindlessID = DecalsExtraDataBuffer.Load( decal.ExtraDataOffset + 36 );
    uint nEmissionBindlessID = DecalsExtraDataBuffer.Load( decal.ExtraDataOffset + 40 );
}

```

## Helper Functions

### Transform Point

`float3 TransformPoint( Decal decal, float3 position )`
* Applies world transforms of this decal. `position` is a world-space pixel position, passed from your main shader/material.

### Decal Attenuation

Calculates the attenuation masking of this decal based on decal orientation and surface normals. It gives a nice and cheap effect of projection.

`float DecalAttenuation( float3 SurfaceNormal, float3 DecalOrientation, float AttenuationFactor )`

* `SurfaceNormal` is expected to be world-space normals, for example normals from Material struct
* `DecalOrientation` is the direction of this decal
* `AttenuationFactor` is the amount of attenuation within 0-1 range. This is the value that you unpack from uint2 `PackedTextureID` property

![](https://cdn.sbox.game/doc/rendering/shaders/classes/images/decal_attenuation.png)

### Quaternion To Matrix

Converts **float4** quaternion vector value to **float3x3** matrix. 

`float3x3 QuaternionToMatrix( float4 q )`

