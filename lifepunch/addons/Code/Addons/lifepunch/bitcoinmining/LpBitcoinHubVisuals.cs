// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Hub world visuals — fence emissive status LED (green ON / red OFF), fan child spin, fan loop audio.
/// Chassis vmdl stays static; no model anims or world point lights on the panel.
/// </summary>
public sealed class LpBitcoinHubVisuals : Component
{
	private const float FanMaxSpeed = 900f;
	private const float FanRampSeconds = 6f;
	private const float FanLoopMaxVolume = 1f;

	/// <summary>Blender fanAction spins around world +Y; matches grill after ModelDoc Y=90 import.</summary>
	private static readonly Vector3 FanSpinAxis = Vector3.Up;

	/// <summary>Counter-clockwise when viewed from the front grill (matches fanAction).</summary>
	private const float FanSpinSign = -1f;

	[Property] public LpBitcoinHubEntity Hub { get; set; }

	/// <summary>Seat fan child behind the front grill using body + fan renderer bounds.</summary>
	[Property] public bool AutoAlignFanToGrille { get; set; } = true;

	/// <summary>Fine-tune after auto-align (prefab editor values stack on top).</summary>
	[Property] public Vector3 FanManualOffset { get; set; }

	private GameObject _fanChild;
	private Rotation _fanBaseLocalRotation = Rotation.Identity;
	private float _fanSpeed;
	private float _fanAngle;
	private bool _lastPowered;
	private bool _fanAlignPending = true;

	private ModelRenderer _bodyRenderer;

	private bool FanVisualActive => _fanChild.IsValid() && _fanChild.Enabled;

#if !LIFEPUNCH_LOCAL
	private SoundHandle _fanLoopHandle;
	private bool _fanLoopPlaying;
	private float _fanLoopVolume;
#endif

	protected override void OnStart()
	{
		if ( !Hub.IsValid() )
			Hub = Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelf );

		_bodyRenderer = GameObject.Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
		                 ?? GameObject.Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;

		CacheFanChild();

		_lastPowered = Hub is { IsPowered: true };
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

		UpdateFanRamp();
		UpdateFanLoopVolume();

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

#if !LIFEPUNCH_LOCAL
	private void UpdateHubFanSounds( bool powered )
	{
		if ( !FanVisualActive )
		{
			if ( _fanLoopPlaying && _fanLoopHandle is not null )
			{
				_fanLoopHandle.Stop();
				_fanLoopPlaying = false;
			}

			return;
		}

		if ( powered )
		{
			if ( _fanLoopPlaying )
				return;

			Sound.Play( LpBitcoinIdent.HubStartupSoundPath, WorldPosition );
			_fanLoopHandle = Sound.Play( LpBitcoinIdent.HubFanLoopSoundPath, WorldPosition );
			if ( _fanLoopHandle is null )
			{
				_fanLoopPlaying = false;
				return;
			}

			_fanLoopHandle.Volume = 0f;
			_fanLoopVolume = 0f;
			_fanLoopPlaying = true;
			return;
		}

		if ( !_fanLoopPlaying )
			return;

		Sound.Play( LpBitcoinIdent.HubFanDownSoundPath, WorldPosition );
		_fanLoopPlaying = false;
	}

	private void UpdateFanLoopVolume()
	{
		if ( !_fanLoopPlaying || _fanLoopHandle is null )
			return;

		try
		{
			_fanLoopHandle.Position = WorldPosition;

			var target = Hub.IsPowered ? FanLoopMaxVolume : 0f;
			var step = ( FanLoopMaxVolume / FanRampSeconds ) * Time.Delta;

			if ( _fanLoopVolume < target )
				_fanLoopVolume = MathF.Min( _fanLoopVolume + step, target );
			else if ( _fanLoopVolume > target )
				_fanLoopVolume = MathF.Max( _fanLoopVolume - step, 0f );

			_fanLoopHandle.Volume = _fanLoopVolume;

			if ( !Hub.IsPowered && _fanLoopVolume <= 0f )
			{
				_fanLoopHandle.Stop();
				_fanLoopPlaying = false;
			}
		}
		catch
		{
			_fanLoopPlaying = false;
		}
	}
#endif
}
