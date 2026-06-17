// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Hub display — chassis on <c>bindPose</c>; only the <c>fan</c> bone spins via local delta rotation.
/// Never plays <c>fanAction</c> (explodes hull bones).
/// </summary>
public sealed class LpBitcoinHubVisuals : Component
{
	private const float FanMaxSpeed = 900f;

	[Property] public LpBitcoinHubEntity Hub { get; set; }

	private SkinnedModelRenderer _skinned;
	private BoneCollection.Bone[] _fanBones = System.Array.Empty<BoneCollection.Bone>();
	private bool _bindPoseApplied;
	private bool _lastPowered;

	protected override void OnStart()
	{
		if ( !Hub.IsValid() )
			Hub = Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelf );

		_skinned = LpBitcoinSkinnedFanSpin.GetSkinned( Components.Get<ModelRenderer>( FindMode.EverythingInSelf ) );
		if ( !_skinned.IsValid() )
			return;

		_fanBones = LpBitcoinSkinnedFanSpin.CacheFanBones( _skinned.Model );
		LpBitcoinSkinnedFanSpin.ForceBindPose( _skinned );
		_bindPoseApplied = true;
		_lastPowered = Hub is { IsPowered: true };
	}

	protected override void OnUpdate()
	{
		if ( !_skinned.IsValid() || !Hub.IsValid() )
			return;

		if ( !Hub.IsPowered )
		{
			if ( _lastPowered )
			{
				LpBitcoinSkinnedFanSpin.ForceBindPose( _skinned );
				_bindPoseApplied = true;
			}

			_lastPowered = false;
			return;
		}

		_lastPowered = true;
		LpBitcoinSkinnedFanSpin.HoldBindPose( _skinned, ref _bindPoseApplied );
		LpBitcoinSkinnedFanSpin.SpinFanBones( _skinned, _fanBones, FanMaxSpeed );
	}
}
