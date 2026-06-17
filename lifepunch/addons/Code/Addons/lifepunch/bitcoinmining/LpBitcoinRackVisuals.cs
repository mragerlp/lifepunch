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

/// Client-side GPU rack visuals — Evo Bitminer pattern: child fan vmdls on the prefab, not vmdl bone animation.

/// </summary>

public sealed class LpBitcoinRackVisuals : Component

{

	private const float FanMaxSpeed = 1200f;

	private const float FanRampSeconds = 4f;

	private const float VisualTickSeconds = 0.05f;

	private const float FanMeshTiltDegrees = 10f;



	[Property] public LpBitcoinRackEntity Rack { get; set; }



	private GameObject[] _fanChildren = Array.Empty<GameObject>();

	private Rotation[] _fanBaseLocalRotation = Array.Empty<Rotation>();

	private ModelRenderer _modelRenderer;

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

		_modelRenderer = ResolveBodyRenderer();

#if !LIFEPUNCH_LOCAL

		var soundPoint = Components.Get<ContinuousSoundPoint>( FindMode.EverythingInSelf );

		if ( soundPoint.IsValid() && soundPoint.SoundEvent.IsValid() )

			_miningHumEvent = soundPoint.SoundEvent;

#endif

	}



	private ModelRenderer ResolveBodyRenderer()

	{

		return Components.Get<ModelRenderer>( FindMode.EverythingInSelf )

		       ?? Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;

	}



	private void CacheFanChildren()

	{

		if ( !GameObject.IsValid() )

			return;



		_fanChildren = GameObject.Children

			.Where( child => child.IsValid()

			                   && ( child.Name.StartsWith( "fan_spin_", StringComparison.OrdinalIgnoreCase )

			                        || child.Name.StartsWith( "fan_placeholder", StringComparison.OrdinalIgnoreCase ) ) )

			.ToArray();



		_fanBaseLocalRotation = new Rotation[_fanChildren.Length];

		var tilt = Rotation.FromAxis( Vector3.Right, FanMeshTiltDegrees );



		for ( var i = 0; i < _fanChildren.Length; i++ )

		{

			var fan = _fanChildren[i];

			fan.Flags |= GameObjectFlags.NoInterpolation;

			_fanBaseLocalRotation[i] = tilt;

			fan.LocalRotation = tilt;

		}

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



	private void UpdateFanRamp()

	{

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

		if ( _fanSpeed <= 0f || _fanChildren.Length == 0 )

			return;



		var spin = Rotation.FromAxis( Vector3.Forward, _fanSpeed * Time.Delta );

		for ( var i = 0; i < _fanChildren.Length; i++ )

		{

			var fan = _fanChildren[i];

			if ( !fan.IsValid() )

				continue;



			fan.LocalRotation = _fanBaseLocalRotation[i];

			fan.LocalRotation *= spin;

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

			_modelRenderer = ResolveBodyRenderer();



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


