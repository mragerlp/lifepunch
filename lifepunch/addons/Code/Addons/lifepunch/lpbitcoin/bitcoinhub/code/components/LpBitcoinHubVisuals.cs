// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Hub world visuals — fence emissive status LED (green ON / red OFF) on the vmdl mesh only.
/// Phase 0: fan mesh is part of <c>bitcoinhub.vmdl</c> (no child GO spin). Phase 2: optional fan child.
/// </summary>
public sealed class LpBitcoinHubVisuals : Component
{
	private const float FanMaxSpeed = 900f;
	private const float FanRampSeconds = 6f;

	/// <summary>Blender fanAction spins around world +Y; matches grill after ModelDoc Y=90 import.</summary>
	private static readonly Vector3 FanSpinAxis = Vector3.Up;

	/// <summary>Counter-clockwise when viewed from the front grill (matches fanAction).</summary>
	private const float FanSpinSign = -1f;

	[Property] public LpBitcoinHubEntity Hub { get; set; }

	/// <summary>Phase 2 only — fan is baked into body vmdl for Phase 0.</summary>
	[Property] public bool AutoAlignFanToGrille { get; set; } = false;

	/// <summary>Fine-tune after auto-align (prefab editor values stack on top).</summary>
	[Property] public Vector3 FanManualOffset { get; set; }

	private GameObject _fanChild;
	private Rotation _fanBaseLocalRotation = Rotation.Identity;
	private float _fanSpeed;
	private float _fanAngle;
	private bool _lastPowered;
	private bool _fanAlignPending = true;
	private TimeSince _sinceStart;
	private int _materialRefreshPasses;

	private ModelRenderer _bodyRenderer;

	protected override void OnStart()
	{
		if ( !Hub.IsValid() )
			Hub = Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelf );

		_bodyRenderer = GameObject.Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
		                 ?? GameObject.Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;

		RemoveLegacyStatusLightChildren();
		CacheFanChild();

		_lastPowered = Hub is { IsPowered: true };
		_sinceStart = 0;
		_materialRefreshPasses = 0;
		ApplyPowerVisuals( _lastPowered );
	}

	/// <summary>Called from <see cref="LpBitcoinHubEntity"/> when power toggles.</summary>
	public void ApplyPowerVisuals( bool powered )
	{
		if ( !_bodyRenderer.IsValid() )
		{
			_bodyRenderer = GameObject.Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
			                 ?? GameObject.Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;
		}

		LpBitcoinPowerLeds.ApplyHubStatusLed( _bodyRenderer, powered );
		UpdateHubFanSounds( powered );
		_lastPowered = powered;

		if ( !powered )
		{
			_fanSpeed = 0f;
			_fanAngle = 0f;
		}
	}

	private static void RemoveLegacyStatusLightChildren( GameObject root )
	{
		foreach ( var child in root.Children.ToList() )
		{
			if ( !child.IsValid() )
				continue;

			if ( child.Name.Equals( "status_led", System.StringComparison.OrdinalIgnoreCase )
			     || child.Name.Equals( "hub_status_glow", System.StringComparison.OrdinalIgnoreCase ) )
				child.Destroy();
		}
	}

	private void RemoveLegacyStatusLightChildren()
		=> RemoveLegacyStatusLightChildren( GameObject );

	private void CacheFanChild()
	{
		_fanChild = GameObject.Children
			.FirstOrDefault( child => child.IsValid()
			                          && child.Name.StartsWith( "fan_spin", System.StringComparison.OrdinalIgnoreCase ) );

		if ( !_fanChild.IsValid() )
			return;

		_fanChild.Flags |= GameObjectFlags.NoInterpolation;
		_fanBaseLocalRotation = Rotation.Identity;
		_fanChild.LocalRotation = _fanBaseLocalRotation;
		_fanAngle = 0f;
	}

	private void TryAlignFanToGrille()
	{
		if ( !AutoAlignFanToGrille || !_fanChild.IsValid() || !_bodyRenderer.IsValid() )
			return;

		var fanRenderer = _fanChild.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( !fanRenderer.IsValid() )
			return;

		var bodyBounds = _bodyRenderer.LocalBounds;
		var fanBounds = fanRenderer.LocalBounds;
		if ( bodyBounds.Size.Length < 0.01f || fanBounds.Size.Length < 0.01f )
			return;

		// Front grill sits on +X after Y=90 ModelDoc import — inset fan center behind the cage.
		var fanExtent = MathF.Max( fanBounds.Size.x, MathF.Max( fanBounds.Size.y, fanBounds.Size.z ) );
		var targetCenter = new Vector3(
			bodyBounds.Maxs.x - fanExtent * 0.35f,
			bodyBounds.Center.y,
			bodyBounds.Center.z ) + FanManualOffset;

		_fanChild.LocalPosition = targetCenter - fanBounds.Center;
		_fanBaseLocalRotation = Rotation.Identity;
		_fanChild.LocalRotation = Rotation.FromAxis( FanSpinAxis, _fanAngle ) * _fanBaseLocalRotation;
	}

	protected override void OnUpdate()
	{
		if ( !Hub.IsValid() )
			return;

		if ( _fanAlignPending )
		{
			TryAlignFanToGrille();
			_fanAlignPending = false;
		}

		if ( Hub.IsPowered != _lastPowered )
			ApplyPowerVisuals( Hub.IsPowered );

		// Fence-led vmats/textures can compile a frame after spawn — reapply emissive briefly.
		if ( _materialRefreshPasses < 6 && _sinceStart > _materialRefreshPasses * 0.35f )
		{
			_materialRefreshPasses++;
			ApplyPowerVisuals( Hub.IsPowered );
		}

		UpdateFanRamp();

		if ( !_fanChild.IsValid() || !_fanChild.Enabled || _fanSpeed <= 0f )
			return;

		_fanAngle += FanSpinSign * _fanSpeed * Time.Delta;
		_fanChild.LocalRotation = Rotation.FromAxis( FanSpinAxis, _fanAngle ) * _fanBaseLocalRotation;
	}

	private void UpdateFanRamp()
	{
		if ( !_fanChild.IsValid() || !_fanChild.Enabled )
			return;

		var target = Hub.IsPowered ? FanMaxSpeed : 0f;
		var step = ( FanMaxSpeed / FanRampSeconds ) * Time.Delta;

		if ( _fanSpeed < target )
			_fanSpeed = MathF.Min( _fanSpeed + step, target );
		else if ( _fanSpeed > target )
			_fanSpeed = MathF.Max( _fanSpeed - step, target );
	}

	private void UpdateHubFanSounds( bool powered )
	{
		// Phase A — hub fan loop parked until fan child GO is positioned (HUB_FAN_SETUP.md).
	}
}
