// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using Sandbox;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Drives gpu-rack / hub vmdl ON/OFF sequences via <see cref="SceneModel.DirectPlayback"/>.
/// Falls back to legacy child-fan spin when the compiled model has no sequences yet (remove when BITMINER-01 closes).
/// </summary>
public static class BitminerPowerAnim
{
	public const string PowerOn = "power_on";
	public const string PowerOff = "power_off";

	private static readonly string[] RackPowerOnCandidates =
	{
		PowerOn,
		"Mining_Rig_Stacked",
		"mining_rig_stacked",
	};

	private static readonly string[] RackPowerOffCandidates =
	{
		PowerOff,
		"bindPose",
		"bindpose",
	};

	private static readonly string[] HubPowerOnCandidates =
	{
		PowerOn,
		"power_on",
	};

	private static readonly string[] HubPowerOffCandidates =
	{
		PowerOff,
		"power_off",
		"bindPose",
		"bindpose",
	};

	public static bool ApplyRackPower( ModelRenderer renderer, bool powered, out string playedSequence )
		=> ApplyPower( renderer, powered, RackPowerOnCandidates, RackPowerOffCandidates, out playedSequence );

	public static bool ApplyHubPower( ModelRenderer renderer, bool powered, out string playedSequence )
		=> ApplyPower( renderer, powered, HubPowerOnCandidates, HubPowerOffCandidates, out playedSequence );

	public static bool ApplyPower(
		ModelRenderer renderer,
		bool powered,
		IReadOnlyList<string> onCandidates,
		IReadOnlyList<string> offCandidates,
		out string playedSequence )
	{
		playedSequence = null;

		if ( !TryGetSceneModel( renderer, out var sceneModel ) )
			return false;

		sceneModel.UseAnimGraph = false;

		var sequences = sceneModel.DirectPlayback?.Sequences;
		if ( sequences is null || sequences.Count == 0 )
			return false;

		var resolved = ResolveSequence( sequences, powered ? onCandidates : offCandidates, powered );
		if ( string.IsNullOrEmpty( resolved ) )
			return false;

		try
		{
			sceneModel.DirectPlayback.Play( resolved );
			playedSequence = resolved;
			return true;
		}
		catch
		{
			return false;
		}
	}

	private static bool TryGetSceneModel( ModelRenderer renderer, out SceneModel sceneModel )
	{
		sceneModel = null;

		if ( !renderer.IsValid() )
			return false;

		sceneModel = renderer.SceneObject;
		return sceneModel.IsValid();
	}

	private static string ResolveSequence(
		IReadOnlyList<string> available,
		IReadOnlyList<string> candidates,
		bool powered )
	{
		foreach ( var candidate in candidates )
		{
			var hit = FindSequence( available, candidate );
			if ( !string.IsNullOrEmpty( hit ) )
				return hit;
		}

		if ( !powered )
		{
			foreach ( var seq in available )
			{
				if ( seq.Contains( "bind", StringComparison.OrdinalIgnoreCase ) )
					return seq;
			}
		}

		return powered ? available[0] : available[^1];
	}

	private static string FindSequence( IReadOnlyList<string> available, string candidate )
	{
		if ( string.IsNullOrWhiteSpace( candidate ) )
			return null;

		foreach ( var seq in available )
		{
			if ( string.Equals( seq, candidate, StringComparison.OrdinalIgnoreCase ) )
				return seq;

			if ( string.Equals( NormalizeSequenceName( seq ), candidate, StringComparison.OrdinalIgnoreCase ) )
				return seq;
		}

		return null;
	}

	private static string NormalizeSequenceName( string sequence )
	{
		if ( string.IsNullOrWhiteSpace( sequence ) )
			return sequence;

		return sequence.TrimStart( '@' );
	}
}
