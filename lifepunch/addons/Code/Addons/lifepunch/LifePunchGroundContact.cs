// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// LifePunch shared ground-alignment for placeable props (mesh bottom → surface).
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons;

/// <summary>Aligns a prop's rendered mesh bottom to the ground trace under it.</summary>
public static class LifePunchGroundContact
{
	private const float TraceUp = 64f;
	private const float TraceDown = 256f;
	private const float Epsilon = 0.05f;

	/// <summary>Lifts <paramref name="go"/> so <see cref="ModelRenderer"/> bounds sit on the surface below.</summary>
	public static void AlignMeshBottom( GameObject go )
	{
		if ( !go.IsValid() )
			return;

		var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( !renderer.IsValid() )
			return;

		var meshBottom = renderer.Bounds.Mins;
		var scene = go.Scene ?? Game.ActiveScene;
		if ( scene is null )
		{
			LiftBy( go, -meshBottom.z );
			return;
		}

		var start = meshBottom + Vector3.Up * TraceUp;
		var end = meshBottom - Vector3.Up * TraceDown;
		var trace = scene.Trace.Ray( start, end ).Run();
		if ( !trace.Hit )
		{
			LiftBy( go, -meshBottom.z );
			return;
		}

		LiftBy( go, trace.HitPosition.z - meshBottom.z );
	}

	private static void LiftBy( GameObject go, float delta )
	{
		if ( MathF.Abs( delta ) <= Epsilon )
			return;

		go.WorldPosition += Vector3.Up * delta;
	}
}
