// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Hub world visuals — fence emissive status LED (green ON / red OFF).
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

	/// <summary>Place <c>status_led</c> on the front-panel fence strip from body bounds (+X face).</summary>
	[Property] public bool AutoAlignStatusLed { get; set; } = true;

	/// <summary>Used when <see cref="AutoAlignStatusLed"/> is false — or nudge after auto-align.</summary>
	[Property] public Vector3 StatusLedManualOffset { get; set; }

	private GameObject _statusLedChild;
	private PointLight _statusLight;
	private GameObject _fanChild;
	private Rotation _fanBaseLocalRotation = Rotation.Identity;
	private float _fanSpeed;
	private float _fanAngle;
	private bool _lastPowered;
	private bool _fanAlignPending = true;
	private TimeSince _sinceStart;
	private int _materialRefreshPasses;

	private ModelRenderer _bodyRenderer;

	private bool FanVisualActive => _fanChild.IsValid() && _fanChild.Enabled;

	protected override void OnStart()
	{
		if ( !Hub.IsValid() )
			Hub = Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelf );

		_bodyRenderer = GameObject.Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
		                 ?? GameObject.Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;

		CacheFanChild();
		EnsureStatusLed();

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
		UpdateStatusLight( powered );
		UpdateHubFanSounds( powered );
		_lastPowered = powered;

		if ( !powered )
		{
			_fanSpeed = 0f;
			_fanAngle = 0f;
		}
	}

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

	private void EnsureStatusLed()
	{
		_statusLedChild = GameObject.Children
			.FirstOrDefault( child => child.IsValid()
			                          && child.Name.Equals( "status_led", System.StringComparison.OrdinalIgnoreCase ) );

		if ( !_statusLedChild.IsValid() )
		{
			_statusLedChild = new GameObject( true, "status_led" );
			_statusLedChild.Parent = GameObject;
			_statusLedChild.LocalRotation = Rotation.Identity;
		}

		_statusLight = _statusLedChild.Components.Get<PointLight>( FindMode.EverythingInSelf );
		if ( !_statusLight.IsValid() )
			_statusLight = _statusLedChild.AddComponent<PointLight>();

		_statusLight.Radius = 40f;
		_statusLight.Attenuation = 2f;
		_statusLight.Shadows = false;
		AlignStatusLedPosition();
	}

	private void AlignStatusLedPosition()
	{
		if ( !_statusLedChild.IsValid() )
			return;

		if ( !AutoAlignStatusLed )
		{
			_statusLedChild.LocalPosition = StatusLedManualOffset;
			return;
		}

		if ( !_bodyRenderer.IsValid() )
			_bodyRenderer = GameObject.Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
			                 ?? GameObject.Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;

		if ( !_bodyRenderer.IsValid() )
			return;

		var bounds = _bodyRenderer.LocalBounds;
		if ( bounds.Size.Length < 0.01f )
			return;

		// Front grill / panel strip sits on +X after Y=90 ModelDoc import (see MODEL_BUILD.md).
		_statusLedChild.LocalPosition = new Vector3(
			bounds.Maxs.x - bounds.Size.x * 0.06f,
			bounds.Center.y + bounds.Size.y * 0.12f,
			bounds.Center.z ) + StatusLedManualOffset;
	}

	private void UpdateStatusLight( bool powered )
	{
		if ( !_statusLight.IsValid() )
			EnsureStatusLed();

		if ( !_statusLight.IsValid() )
			return;

		_statusLight.Enabled = true;
		_statusLight.LightColor = powered
			? new Color( 0.2f, 1f, 0.45f )
			: new Color( 1f, 0.15f, 0.08f );
	}
}
