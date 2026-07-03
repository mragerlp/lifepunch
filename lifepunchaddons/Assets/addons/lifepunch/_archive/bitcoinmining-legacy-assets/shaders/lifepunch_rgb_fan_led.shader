// LifePunch — RGB fan LED ring shader (bitcoinmining / gpu-rack)
// Complex PBR via Material.CommonInputs + HSV cycle on self-illum mask.
// Editor: open this file → Save (compiles .shader_c) → then Save gpu-rack-gpu.vmat.

HEADER
{
	Description = "LifePunch RGB fan LED (PBR + animated emission)";
}

FEATURES
{
	#include "common/features.hlsl"
}

MODES
{
	Forward();
	Depth();
}

COMMON
{
	#include "common/shared.hlsl"
}

struct VertexInput
{
	#include "common/vertexinput.hlsl"
};

struct PixelInput
{
	#include "common/pixelinput.hlsl"
};

VS
{
	#include "common/vertex.hlsl"

	PixelInput MainVs( VertexInput i )
	{
		PixelInput o = ProcessVertex( i );
		return FinalizeVertex( o );
	}
}

PS
{
	#include "common/pixel.hlsl"
	#include "common/utils/Material.CommonInputs.hlsl"

	CreateInputTexture2D( TextureSelfIllumMask, Linear, 8, "", "_selfillummask", "Material,10/92", Default3( 0.0, 0.0, 0.0 ) );
	Texture2D g_tSelfIllumMask < Channel( RGB, Box( TextureSelfIllumMask ), Linear ); OutputFormat( BC7 ); SrgbRead( false ); >;

	float g_flRgbCycleSpeed < Default( 0.20 ); Range( 0, 2 ); UiGroup( "LifePunch RGB,10/" ); >;
	float g_flRgbIntensity < Default( 3.0 ); Range( 0, 12 ); UiGroup( "LifePunch RGB,10/" ); >;
	float g_flRgbPhaseSpread < Default( 0.40 ); Range( 0, 3 ); UiGroup( "LifePunch RGB,10/" ); >;
	float g_flLedActive < Default( 0.0 ); Range( 0, 1 ); UiGroup( "LifePunch RGB,10/" ); >;
	float g_flIdleGlow < Default( 0.06 ); Range( 0, 1 ); UiGroup( "LifePunch RGB,10/" ); >;

	float3 HsvToRgb( float h, float s, float v )
	{
		float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
		float3 p = abs( frac( h.xxx + K.xyz ) * 6.0 - K.www );
		return v * lerp( K.xxx, saturate( p - K.xxx ), s );
	}

	float4 MainPs( PixelInput i ) : SV_Target0
	{
		Material m = Material::From( i );

		float3 illumMask = g_tSelfIllumMask.Sample( TextureFiltering, i.vTextureCoords.xy ).rgb;
		float emissionMask = max( max( illumMask.r, illumMask.g ), illumMask.b );

		if ( emissionMask > 0.001 )
		{
			float phase = dot( i.vPositionWithOffsetWs.xyz, float3( 0.173, 0.317, 0.587 ) ) * g_flRgbPhaseSpread;
			float hue = frac( g_flTime * g_flRgbCycleSpeed + phase );
			float3 rgb = HsvToRgb( hue, 1.0, 1.0 );
			float blend = lerp( g_flIdleGlow, 1.0, g_flLedActive );
			m.Emission = rgb * emissionMask * g_flRgbIntensity * blend * g_flSelfIllumScale;
		}

		return ShadingModelStandard::Shade( m );
	}
}
