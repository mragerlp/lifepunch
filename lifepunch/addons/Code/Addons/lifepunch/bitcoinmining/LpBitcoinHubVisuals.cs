// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Hub display — keeps chassis on bindPose and spins only the <c>fan</c> bone (DXRP printer pattern).
/// Avoids broken <c>fanAction</c> vmdl playback that separates hull parts.
/// </summary>
public sealed class LpBitcoinHubVisuals : Component
{
	private const string FanBoneName = "fan";
	private const string BindSequence = "bindPose";
	private const float FanMaxSpeed = 900f;

	[Property] public LpBitcoinHubEntity Hub { get; set; }

	private SkinnedModelRenderer _skinned;
	private BoneCollection.Bone _fanBone;
	private bool _hasFanBone;
	private float _fanAngleDeg;
	private bool _lastPowered;

	protected override void OnStart()
	{
		if ( !Hub.IsValid() )
			Hub = Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelf );

		_skinned = Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf );
		CacheFanBone();
		HoldBindPose();
		_lastPowered = Hub is { IsPowered: true };
	}

	protected override void OnUpdate()
	{
		if ( !_skinned.IsValid() || !Hub.IsValid() )
			return;

		if ( !Hub.IsPowered )
		{
			if ( _lastPowered || _fanAngleDeg != 0f )
			{
				_fanAngleDeg = 0f;
				HoldBindPose();
			}

			_lastPowered = false;
			return;
		}

		_lastPowered = true;
		HoldBindPose();

		if ( !_hasFanBone )
			return;

		_fanAngleDeg += FanMaxSpeed * Time.Delta;
		SpinFanBone();
	}

	private void CacheFanBone()
	{
		_hasFanBone = false;
		_fanBone = default;

		var model = _skinned?.Model;
		if ( model is null || !model.IsValid || model.BoneCount == 0 )
			return;

		if ( !model.Bones.HasBone( FanBoneName ) )
			return;

		_fanBone = model.Bones.GetBone( FanBoneName );
		_hasFanBone = true;
	}

	private void HoldBindPose()
	{
		if ( !_skinned.IsValid() )
			return;

		_skinned.UseAnimGraph = false;
		_skinned.Sequence.Name = BindSequence;
		_skinned.Sequence.Looping = false;
	}

	private void SpinFanBone()
	{
		if ( !_skinned.IsValid() || !_hasFanBone )
			return;

		var bind = _fanBone.LocalTransform;
		var spin = Rotation.FromAxis( Vector3.Forward, _fanAngleDeg );
		var transform = new Transform( bind.Position, bind.Rotation * spin, bind.Scale );
		_skinned.SetBoneTransform( in _fanBone, transform );
		_skinned.PostAnimationUpdate();
	}
}
