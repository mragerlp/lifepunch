// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using Dxura.RP.Shared;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Client-side GPU rack visuals — mirrors DXRP <see cref="PrinterEntity"/> fan spin + idle hum pattern.
/// Host simulation stays on <see cref="LpBitcoinRackEntity"/>; this is display/audio only.
/// </summary>
public sealed class LpBitcoinRackVisuals : Component
{
	private const float FanMaxSpeed = 1200f;
	private const float FanRampSeconds = 4f;
	private const float VisualTickSeconds = 0.05f;

	[Property] public LpBitcoinRackEntity Rack { get; set; }

	private GameObject[] _fanChildren = Array.Empty<GameObject>();
	private ModelRenderer _modelRenderer;
	private bool _vmdlAnimActive;
	private float _fanSpeed;
	private bool _occluded;
#if !LIFEPUNCH_LOCAL
	private SoundEvent _miningHumEvent;
	private SoundHandle _miningHumHandle;
#endif

	protected override void OnStart()
	{
		if ( !Rack.IsValid() )
			Rack = Components.Get<LpBitcoinRackEntity>( FindMode.EverythingInSelf );

		CacheFanChildren();
		_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
#if !LIFEPUNCH_LOCAL
		var soundPoint = Components.Get<ContinuousSoundPoint>( FindMode.EverythingInSelf );
		if ( soundPoint.IsValid() && soundPoint.SoundEvent.IsValid() )
			_miningHumEvent = soundPoint.SoundEvent;
#endif
	}

	private void CacheFanChildren()
	{
		if ( !GameObject.IsValid() )
			return;

		_fanChildren = GameObject.Children
			.Where( child => child.IsValid() && child.Name.StartsWith( "fan_placeholder", StringComparison.OrdinalIgnoreCase ) )
			.ToArray();

		foreach ( var fan in _fanChildren )
			fan.Flags |= GameObjectFlags.NoInterpolation;
	}

#if !LIFEPUNCH_LOCAL
	public void OnOcclusionChanged( bool occlude ) => _occluded = occlude;
#endif

	protected override void OnUpdate()
	{
#if LIFEPUNCH_LOCAL
		return;
#else
		if ( !Rack.IsValid() || _occluded || GameManager.IsHeadless )
			return;

		if ( Cooldown.Current.CheckAndStartCooldown( $"{GameObject.Id}:rack-vis", VisualTickSeconds ) )
			return;

		UpdateFanRamp();
		UpdateMiningHum();
		UpdateMiningLeds();
		SpinFans();
#endif
	}

	internal void SetVmdlAnimActive( bool active ) => _vmdlAnimActive = active;

	private void UpdateFanRamp()
	{
		if ( _vmdlAnimActive )
		{
			_fanSpeed = Rack.IsMining ? FanMaxSpeed : 0f;
			return;
		}

		var hub = Rack.GetLinkedHub();
		var mining = Rack.IsMining && hub is { IsPowered: true };
		var target = mining ? FanMaxSpeed : 0f;
		var step = ( FanMaxSpeed / FanRampSeconds ) * Time.Delta;

		if ( _fanSpeed < target )
			_fanSpeed = MathF.Min( _fanSpeed + step, target );
		else if ( _fanSpeed > target )
			_fanSpeed = MathF.Max( _fanSpeed - step, target );
	}

	private void SpinFans()
	{
		if ( _vmdlAnimActive || _fanSpeed <= 0f || _fanChildren.Length == 0 )
			return;

		var rot = Rotation.FromAxis( Vector3.Forward, _fanSpeed * Time.Delta );
		foreach ( var fan in _fanChildren )
		{
			if ( fan.IsValid() )
				fan.LocalRotation *= rot;
		}
	}

	private void UpdateMiningHum()
	{
		var hub = Rack.GetLinkedHub();
		var shouldHum = Rack.IsMining && hub is { IsPowered: true } && !_occluded;

		if ( shouldHum )
		{
			if ( !_miningHumHandle.IsValid() && _miningHumEvent.IsValid() )
				_miningHumHandle = Sound.Play( _miningHumEvent, WorldPosition );

			if ( _miningHumHandle.IsValid() )
				_miningHumHandle.Position = WorldPosition;
		}
		else if ( _miningHumHandle.IsValid() )
		{
			_miningHumHandle.Stop( 0.15f );
			_miningHumHandle = default;
		}
	}

	private void UpdateMiningLeds()
	{
		if ( !_modelRenderer.IsValid() )
			_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf );

		if ( !_modelRenderer.IsValid() )
			return;

		var hub = Rack.GetLinkedHub();
		var mining = Rack.IsMining && hub is { IsPowered: true };
		var ledIntensity = mining && FanMaxSpeed > 0f ? Math.Clamp( _fanSpeed / FanMaxSpeed, 0f, 1f ) : 0f;
		LpBitcoinPowerLeds.ApplyRackGpuLeds( _modelRenderer, mining, ledIntensity );
	}

	protected override void OnDestroy()
	{
#if !LIFEPUNCH_LOCAL
		if ( _miningHumHandle.IsValid() )
			_miningHumHandle.Stop( 0.1f );
#endif
		base.OnDestroy();
	}
}
