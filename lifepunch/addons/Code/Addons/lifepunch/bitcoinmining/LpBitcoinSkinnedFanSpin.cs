// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Keeps animated props on <c>bindPose</c> and spins fan bones with local delta rotation.
/// Avoids full-sequence playback (<c>fanAction</c>, <c>power_on</c>) which displaces hull bones.
/// </summary>
public static class LpBitcoinSkinnedFanSpin
{
	public const string BindSequence = "bindPose";

	public static SkinnedModelRenderer GetSkinned( ModelRenderer renderer )
	{
		if ( !renderer.IsValid() )
			return null;

		if ( renderer is SkinnedModelRenderer skinned )
			return skinned;

		return renderer.GameObject?.Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf );
	}

	public static void HoldBindPose( SkinnedModelRenderer skinned, ref bool bindApplied )
	{
		if ( !skinned.IsValid() )
			return;

		skinned.UseAnimGraph = false;

		if ( bindApplied )
			return;

		skinned.Sequence.Name = BindSequence;
		skinned.Sequence.Looping = false;
		skinned.PostAnimationUpdate();
		bindApplied = true;
	}

	public static void ForceBindPose( SkinnedModelRenderer skinned )
	{
		if ( !skinned.IsValid() )
			return;

		skinned.UseAnimGraph = false;
		skinned.Sequence.Name = BindSequence;
		skinned.Sequence.Looping = false;
		skinned.PostAnimationUpdate();
	}

	public static BoneCollection.Bone[] CacheFanBones( Model model )
	{
		if ( model is null || !model.IsValid || model.BoneCount == 0 )
			return Array.Empty<BoneCollection.Bone>();

		var bones = new List<BoneCollection.Bone>();

		if ( model.Bones.HasBone( "fan" ) )
			bones.Add( model.Bones.GetBone( "fan" ) );

		for ( var i = 0; i < 32; i++ )
		{
			TryAddBone( model, bones, $"FanBlades_{i:D3}" );
			TryAddBone( model, bones, $"FanBlades.{i:D3}" );
		}

		return bones.ToArray();
	}

	public static void SpinFanBones(
		SkinnedModelRenderer skinned,
		IReadOnlyList<BoneCollection.Bone> fanBones,
		float speedDegPerSec )
	{
		if ( !skinned.IsValid() || speedDegPerSec <= 0f || fanBones is null || fanBones.Count == 0 )
			return;

		var delta = Rotation.FromAxis( Vector3.Up, speedDegPerSec * Time.Delta );

		foreach ( var bone in fanBones )
		{
			if ( !skinned.TryGetBoneTransformLocal( in bone, out var transform ) )
				continue;

			transform.Rotation *= delta;
			skinned.SetBoneTransform( in bone, transform );
		}

		skinned.PostAnimationUpdate();
	}

	private static void TryAddBone( Model model, List<BoneCollection.Bone> bones, string name )
	{
		if ( !model.Bones.HasBone( name ) )
			return;

		bones.Add( model.Bones.GetBone( name ) );
	}
}
