// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Drives hub/rack vmdl ON/OFF sequences via <see cref="SceneModel.DirectPlayback"/>.
/// Hub Steam Machine export: <c>fanAction</c> (powered), <c>front_panelAction</c> (optional), <c>bindPose</c> (off).
/// GPU racks: <c>power_on</c> / <c>GPU_Farm_Final</c> (small), <c>Mining_Rig_Stacked</c> (advanced).
/// </summary>
public static class LpBitcoinPowerAnim
{
	public const string PowerOn = "power_on";
	public const string PowerOff = "power_off";

	private static readonly string[] HubPowerOnCandidates =
	{
		PowerOn,
		"fanAction",
		"fan_action",
		"front_panelAction",
		"front_panel_action",
	};

	private static readonly string[] HubPowerOffCandidates =
	{
		PowerOff,
		"bindPose",
		"bindpose",
	};

	private static readonly string[] RackPowerOnCandidates =
	{
		PowerOn,
		"GPU_Farm_Final",
		"gpu_farm_final",
		"Mining_Rig_Stacked",
		"mining_rig_stacked",
	};

	private static readonly string[] RackPowerOffCandidates =
	{
		PowerOff,
		"bindPose",
		"bindpose",
	};

	public static bool ApplyHubPower( ModelRenderer renderer, bool powered, out string playedSequence )
		=> ApplyPower( renderer, powered, HubPowerOnCandidates, HubPowerOffCandidates, out playedSequence );

	public static bool ApplyRackPower( ModelRenderer renderer, bool mining, out string playedSequence )
		=> ApplyPower( renderer, mining, RackPowerOnCandidates, RackPowerOffCandidates, out playedSequence );

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

		var sequences = GetAvailableSequences( renderer, sceneModel );
		if ( sequences.Count == 0 )
			return false;

		var resolved = ResolveSequence( sequences, powered ? onCandidates : offCandidates, powered );
		if ( string.IsNullOrEmpty( resolved ) )
			return false;

		if ( powered && IsBindOrIdleSequence( resolved ) )
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

	private static bool IsBindOrIdleSequence( string sequence )
	{
		if ( string.IsNullOrWhiteSpace( sequence ) )
			return true;

		var normalized = NormalizeSequenceName( sequence );
		return normalized.Contains( "bind", StringComparison.OrdinalIgnoreCase )
		       || string.Equals( normalized, "idle", StringComparison.OrdinalIgnoreCase );
	}

	internal static IReadOnlyList<string> GetAvailableSequences( ModelRenderer renderer, SceneModel sceneModel )
	{
		var playbackSequences = sceneModel?.DirectPlayback?.Sequences;
		if ( playbackSequences is { Count: > 0 } )
			return playbackSequences;

		var model = renderer?.Model;
		if ( model is null || !model.IsValid )
			return Array.Empty<string>();

		if ( model.AnimationNames is { Count: > 0 } )
			return model.AnimationNames;

		if ( model.AnimationCount > 0 )
		{
			return Enumerable.Range( 0, model.AnimationCount )
				.Select( model.GetAnimationName )
				.Where( name => !string.IsNullOrWhiteSpace( name ) )
				.ToArray();
		}

		return Array.Empty<string>();
	}

	private static bool TryGetSceneModel( ModelRenderer renderer, out SceneModel sceneModel )
	{
		sceneModel = null;

		if ( !renderer.IsValid() )
			return false;

		sceneModel = renderer.SceneObject as SceneModel;
		return sceneModel is not null && sceneModel.IsValid();
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

		if ( !powered && available.Count > 0 )
			return available[^1];

		return null;
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
