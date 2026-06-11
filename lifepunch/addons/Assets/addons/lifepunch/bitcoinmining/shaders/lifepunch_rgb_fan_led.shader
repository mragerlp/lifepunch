
// LifePunch ΓÇö RGB fan LED ring shader (bitcoinmining / gpu-rack)
// Extends standard complex PBR (GatherMaterial) with time-based HSV cycling on self-illum mask.
// Edit in VS Code with Slang extension (workspace flavor: vfx). Compiles on save in s&box editor.

HEADER
{
	CompileTargets = ( IS_SM_50 && ( PC || VULKAN ) );
	Description = "LifePunch RGB fan LED (complex PBR + animated emission)";
}

FEATURES
{
	#include "common/features.hlsl"
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

	PixelInput MainVs( INSTANCED_SHADER_PARAMS( VertexInput i ) )
	{
		PixelInput o = ProcessVertex( i );
		return FinalizeVertex( o );
	}
}

PS
{
	#include "common/pixel.hlsl"

	float g_flRgbCycleSpeed < Default( 0.20 ); Range( 0, 2 ); UiGroup( "LifePunch RGB,10/" ); >;
	FloatAttribute( g_flRgbCycleSpeed, g_flRgbCycleSpeed );

	float g_flRgbIntensity < Default( 3.0 ); Range( 0, 12 ); UiGroup( "LifePunch RGB,10/" ); >;
	FloatAttribute( g_flRgbIntensity, g_flRgbIntensity );

	float g_flRgbPhaseSpread < Default( 0.40 ); Range( 0, 3 ); UiGroup( "LifePunch RGB,10/" ); >;
	FloatAttribute( g_flRgbPhaseSpread, g_flRgbPhaseSpread );

	float g_flLedActive < Default( 0.0 ); Range( 0, 1 ); UiGroup( "LifePunch RGB,10/" ); >;
	FloatAttribute( g_flLedActive, g_flLedActive );

	float g_flIdleGlow < Default( 0.06 ); Range( 0, 1 ); UiGroup( "LifePunch RGB,10/" ); >;
	FloatAttribute( g_flIdleGlow, g_flIdleGlow );

	float3 HsvToRgb( float h, float s, float v )
	{
		float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
		float3 p = abs( frac( h.xxx + K.xyz ) * 6.0 - K.www );
		return v * lerp( K.xxx, saturate( p - K.xxx ), s );
	}

	PixelOutput MainPs( PixelInput i )
	{
		Material m = GatherMaterial( i );

		float emissionMask = max( max( m.Emission.r, m.Emission.g ), m.Emission.b );
		if ( emissionMask > 0.001 )
		{
			float phase = dot( m.WorldPosition, float3( 0.173, 0.317, 0.587 ) ) * g_flRgbPhaseSpread;
			float hue = frac( g_flTime * g_flRgbCycleSpeed + phase );
			float3 rgb = HsvToRgb( hue, 1.0, 1.0 );
			float blend = lerp( g_flIdleGlow, 1.0, g_flLedActive );
			m.Emission = rgb * emissionMask * g_flRgbIntensity * blend;
		}

		return FinalizePixelMaterial( i, m );
	}
}
