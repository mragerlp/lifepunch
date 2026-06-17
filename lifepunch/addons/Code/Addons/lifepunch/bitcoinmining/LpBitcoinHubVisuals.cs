// ─────────────────────────────────────────────────────────────────────────────

// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.

//

// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)

// ─────────────────────────────────────────────────────────────────────────────



using System.Linq;

using Sandbox;



namespace LifePunch.DXRP.Addons.Bitcoin;



/// <summary>

/// Hub display — Evo Bitminer pattern: static chassis vmdl + prefab child fan mesh spins when powered.

/// Chassis, front panel, and back body never move.

/// </summary>

public sealed class LpBitcoinHubVisuals : Component

{

	private const float FanMaxSpeed = 900f;

	private const float FanRampSeconds = 6f;

	private const float FanMeshTiltDegrees = 10f;



	[Property] public LpBitcoinHubEntity Hub { get; set; }



	private GameObject _fanChild;

	private Rotation _fanBaseLocalRotation;

	private float _fanSpeed;

	private bool _lastPowered;



	protected override void OnStart()

	{

		if ( !Hub.IsValid() )

			Hub = Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelf );



		CacheFanChild();

		_lastPowered = Hub is { IsPowered: true };

	}



	private void CacheFanChild()

	{

		_fanChild = GameObject.Children

			.FirstOrDefault( child => child.IsValid()

			                          && child.Name.StartsWith( "fan_spin", System.StringComparison.OrdinalIgnoreCase ) );



		if ( !_fanChild.IsValid() )

			return;



		_fanChild.Flags |= GameObjectFlags.NoInterpolation;

		_fanBaseLocalRotation = Rotation.FromAxis( Vector3.Right, FanMeshTiltDegrees );

		_fanChild.LocalRotation = _fanBaseLocalRotation;

	}



	protected override void OnUpdate()

	{

		if ( !Hub.IsValid() )

			return;



		UpdateFanRamp();



		if ( !_fanChild.IsValid() || _fanSpeed <= 0f )

			return;



		var spin = Rotation.FromAxis( Vector3.Forward, _fanSpeed * Time.Delta );

		_fanChild.LocalRotation = _fanBaseLocalRotation;

		_fanChild.LocalRotation *= spin;

	}



	private void UpdateFanRamp()

	{

		var target = Hub.IsPowered ? FanMaxSpeed : 0f;

		var step = ( FanMaxSpeed / FanRampSeconds ) * Time.Delta;



		if ( _fanSpeed < target )

			_fanSpeed = MathF.Min( _fanSpeed + step, target );

		else if ( _fanSpeed > target )

			_fanSpeed = MathF.Max( _fanSpeed - step, target );



		if ( Hub.IsPowered == _lastPowered )

			return;



		_lastPowered = Hub.IsPowered;

		if ( !Hub.IsPowered )

			_fanSpeed = 0f;

	}

}


