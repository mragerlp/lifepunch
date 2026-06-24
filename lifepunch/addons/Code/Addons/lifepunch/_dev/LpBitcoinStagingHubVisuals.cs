// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LifePunch Dev Tools" (s&box ident: lifepunch.dev · addon ident: dev) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons.Bitcoin;

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// Hub OFF/ON world visuals — fence emissive plus subtle status glow spill (Phase A staging).
/// </summary>
public sealed class LpBitcoinStagingHubVisuals : Component
{
	private const float FanMaxSpeed = 900f;
	private const float FanRampSeconds = 6f;
	private static readonly Vector3 FanSpinAxis = Vector3.Up;
	private const float FanSpinSign = -1f;

	[Property] public LpBitcoinStagingHubPower Power { get; set; }

	[Property] public bool AutoAlignFanToGrille { get; set; } = true;

	[Property] public Vector3 FanManualOffset { get; set; }

	private GameObject _fanChild;
	private Rotation _fanBaseLocalRotation = Rotation.Identity;
	private float _fanSpeed;
	private float _fanAngle;
	private bool _lastPowered;
	private bool _fanAlignPending = true;

	private ModelRenderer _bodyRenderer;
	private GameObject _statusGlowGo;
	private PointLight _statusGlow;

	protected override void OnStart()
	{
		if ( !Power.IsValid() )
			Power = Components.Get<LpBitcoinStagingHubPower>( FindMode.EverythingInSelf );

		_bodyRenderer = GameObject.Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
		                 ?? GameObject.Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;

		CacheFanChild();

		_lastPowered = Power is { IsPowered: true };
		ApplyPowerVisuals( _lastPowered );
	}

	public void ApplyPowerVisuals( bool powered )
	{
		if ( !_bodyRenderer.IsValid() )
		{
			_bodyRenderer = GameObject.Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
			                 ?? GameObject.Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;
		}

		LpBitcoinStagingHubPowerLeds.ApplyHubStatusLed( _bodyRenderer, powered );
		UpdateStatusGlow( powered );
		_lastPowered = powered;

		if ( !powered )
		{
			_fanSpeed = 0f;
			_fanAngle = 0f;
		}
	}

	private void UpdateStatusGlow( bool powered )
	{
		if ( !_bodyRenderer.IsValid() )
			return;

		if ( !_statusGlow.IsValid() )
		{
			_statusGlowGo = new GameObject( true, "hub_status_glow" );
			_statusGlowGo.SetParent( GameObject );
			_statusGlow = _statusGlowGo.AddComponent<PointLight>();
			_statusGlow.Shadows = false;
			_statusGlow.Attenuation = LpBitcoinPowerLeds.HubStatusGlowAttenuation;
			_statusGlow.Radius = LpBitcoinPowerLeds.HubStatusGlowRadius;
		}

		_statusGlowGo.LocalPosition = LpBitcoinPowerLeds.GetHubStatusGlowLocalPosition( _bodyRenderer );
		_statusGlow.Enabled = true;
		_statusGlow.LightColor = LpBitcoinPowerLeds.GetHubStatusGlowColor( powered );
	}

	protected override void OnDestroy()
	{
		if ( _statusGlowGo.IsValid() )
			_statusGlowGo.Destroy();

		base.OnDestroy();
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
		if ( !Power.IsValid() )
			return;

		if ( _fanAlignPending )
		{
			TryAlignFanToGrille();
			_fanAlignPending = false;
		}

		if ( Power.IsPowered != _lastPowered )
			ApplyPowerVisuals( Power.IsPowered );

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

		var target = Power.IsPowered ? FanMaxSpeed : 0f;
		var step = ( FanMaxSpeed / FanRampSeconds ) * Time.Delta;

		if ( _fanSpeed < target )
			_fanSpeed = MathF.Min( _fanSpeed + step, target );
		else if ( _fanSpeed > target )
			_fanSpeed = MathF.Max( _fanSpeed - step, target );
	}
}
