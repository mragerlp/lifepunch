
// ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ
// PROPRIETARY & CONFIDENTIAL ΓÇö ┬⌐ 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining ┬╖ addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity ΓÇö including DXRP and
// LifePunch staff, contributors, or community ΓÇö EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ

using System;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using Dxura.RP.Game.UI;
#endif

namespace LifePunch.DXRP.Addons.BitcoinMining;

public enum BitminerUpgradeType
{
	Cpu,
	Cores
}

/// <summary>
/// LifePunch Bitcoin Miner interactive entity.
///
/// DUAL-BUILD (see <c>docs/RUNTIME_PATTERN.md</c>):
/// All simulation, networked state, fan/sound cosmetics, screen text, interaction, RPCs and the
/// terminal hook are shared Sandbox code. Only the gamemode-coupled touch-points are branched:
///   * <c>#if LIFEPUNCH_LOCAL</c>  ΓÇö compile-safe Sandbox-only stub (local / editor build).
///   * <c>#else</c>                ΓÇö real <c>Dxura.RP.Game</c> implementation (dxrp.net build).
/// </summary>
[Title( "Bitcoin Miner" )]
[Category( "LifePunch/Bitcoin Mining" )]
#if LIFEPUNCH_LOCAL
public sealed partial class BitminerEntity : Component, Component.IPressable
#else
public sealed partial class BitminerEntity : BaseEntity, Component.IPressable, IGameEvents, IAreaDamageReceiver
#endif
{
#if !LIFEPUNCH_LOCAL
	public void ApplyAreaDamage( AreaDamage component )
	{
		var dmg = new Dxura.RP.Game.DamageInfo( component.Attacker, component.Damage, component.Inflictor,
			component.WorldPosition, Flags: component.DamageFlags );
		HealthComponent?.TakeDamageHost( dmg );
	}
#endif

	// ----------------------------
	// COMPONENT REFERENCES (bound by bitcoin-miner.prefab)
	// ----------------------------

	[Property] public TextRenderer TextRender { get; set; }
	/// <summary>Advanced Bitcoin Miner prefab sets this ΓÇö doubles mining yield (stacked gpu-rack).</summary>
	[Property] public bool AdvancedRack { get; set; }
	[Property] public required GameObject BitminerFan { get; set; }
	[Property] public GameObject BitminerFan2 { get; set; }
	[Property] public GameObject BitminerFan3 { get; set; }
	[Property] public ModelRenderer ModelRenderer { get; set; }

	// ----------------------------
	// EFFECTS
	// ----------------------------

	[Property, Group( "Effects" )] public required GameObject Explosion { get; set; }
	[Property, Group( "Effects" )] public GameObject SmokeEffect { get; set; }
	[Property, Group( "Effects" ), Range( 2, 6 )] public float MinSmokeTime { get; set; } = 2.5f;
	[Property, Group( "Effects" ), Range( 2, 6 )] public float MaxSmokeTime { get; set; } = 2.5f;
	[Property, Group( "Effects" )] private SoundEvent ErrorBeepSound { get; set; }
	[Property, Group( "Effects" )] private SoundEvent GlitchSound { get; set; }

	private GameObject _activeSmoke;
	private bool _isExploding;

	// ----------------------------
	// NETWORKED STATE
	// ----------------------------

	[Sync( SyncFlags.FromHost )] public bool IsMining { get; set; }
	[Sync( SyncFlags.FromHost )] public float BitcoinAmount { get; set; }
	[Sync( SyncFlags.FromHost )] public int CpuUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public int CoreUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public float ClockSpeed { get; set; } = 2.44f;
	[Sync( SyncFlags.FromHost )] public int CoreCount { get; set; } = 1;
	[Sync( SyncFlags.FromHost )] public float MiningProgress { get; set; }

	// ----------------------------
	// CONFIG VALUES
	// ----------------------------

	private const float BaseSpeed = 0.005f;
	private const float AdvancedRackYield = 2f;
	private float RackYield => AdvancedRack ? AdvancedRackYield : 1f;

	/// <summary>Displayed BTC/min ΓÇö includes advanced rack multiplier when set on prefab.</summary>
	public float MiningRatePerMinute => ClockSpeed * BaseSpeed * CoreCount * RackYield;
	private const float MiningInterval = 60f;
	public const float BitcoinValue = 1500f;

	public static readonly int[] CpuUpgradeCosts = { 2000, 4000, 8000, 16000, 32000, 64000, 128000 };
	public static readonly int[] CoreUpgradeCosts = { 50000, 100000, 175000 };

#if LIFEPUNCH_LOCAL
	private static readonly string PocketTag = "pocket";
	private static readonly string PocketItemTag = "pocket_item";
#else
	private static readonly string PocketTag = Constants.PocketTag;
	private static readonly string PocketItemTag = Constants.PocketItemTag;
#endif

	// ----------------------------
	// RUNTIME STATE
	// ----------------------------

	private TimeSince _lastMiningTick = 0f;
	private bool _occluded;
	private SoundHandle _humHandle;
	private bool _humPlaying;
	private float _fanSpeed;
	private float _humVolume;
	private const float FanMaxSpeed = 1200f;
	private const float FanRampSeconds = 8f;
	private const float HumMaxVolume = 1f;
	private const float HumRampSeconds = 8f;

	// ----------------------------
	// INITIALIZATION
	// ----------------------------

	protected override void OnStart()
	{
		base.OnStart();

		GameObject.Tags.Add( "bitminer" );

		BitcoinAmount = 0f;
		IsMining = false;

		if ( TextRender.IsValid() )
			TextRender.Color = Color.Parse( "#f0a500" ) ?? Color.White;

		var correction = Rotation.FromAxis( Vector3.Right, 10f );

		if ( BitminerFan.IsValid() )
		{
			BitminerFan.Flags |= GameObjectFlags.NoInterpolation;
			BitminerFan.LocalRotation = correction;
		}

		if ( BitminerFan2.IsValid() )
		{
			BitminerFan2.Flags |= GameObjectFlags.NoInterpolation;
			BitminerFan2.LocalRotation = correction;
		}

		if ( BitminerFan3.IsValid() )
		{
			BitminerFan3.Flags |= GameObjectFlags.NoInterpolation;
			BitminerFan3.LocalRotation = correction;
		}
	}

	// ----------------------------
	// SERVER TICK
	// ----------------------------

	private void HostTick()
	{
		if ( GameObject.Tags.Has( PocketTag ) )
		{
			if ( _humPlaying )
				BroadcastHumState( false );

			return;
		}

		if ( !IsMining )
			return;

		if ( _lastMiningTick >= MiningInterval )
		{
			MineBitcoin();
			_lastMiningTick = 0f;
			MiningProgress = 0f;
		}
		else
		{
			MiningProgress = _lastMiningTick / MiningInterval;
		}
	}

#if !LIFEPUNCH_LOCAL
	public void OnSecondlyUpdate()
	{
		if ( !Networking.IsHost )
			return;

		HostTick();
	}

	public override void OnOcclusionChanged( bool occlude )
	{
		base.OnOcclusionChanged( occlude );
		_occluded = occlude;
	}
#endif

	// ----------------------------
	// CLIENT / SHARED UPDATE
	// ----------------------------

	protected override void OnUpdate()
	{
		base.OnUpdate();

#if LIFEPUNCH_LOCAL
		if ( Networking.IsHost )
			HostTick();
#endif

		try
		{
			if ( _humPlaying )
			{
				if ( GameObject.Tags.Has( PocketTag ) )
				{
					_humHandle.Stop();
					_humPlaying = false;
				}
				else
				{
					_humHandle.Position = WorldPosition;
				}
			}
		}
		catch { }

		if ( _occluded )
			return;

#if !LIFEPUNCH_LOCAL
		if ( GameManager.IsHeadless )
			return;
#endif

		UpdateScreenText();
		UpdateFanRamp();
		UpdateRgbFanLeds();
		SpinFan();
		UpdateHumVolume();
	}

	/// <summary>Called by <see cref="BitminerTerminalProp"/> when the LCD lives on a separate entity.</summary>
	public void BindScreen( TextRenderer screen )
	{
		if ( !screen.IsValid() )
			return;

		TextRender = screen;
		if ( TextRender.IsValid() )
			TextRender.Color = Color.Parse( "#f0a500" ) ?? Color.White;

		UpdateScreenText();
	}

	private void UpdateScreenText()
	{
		if ( !TextRender.IsValid() )
			return;

		var filled = (int)( MiningProgress * 8 );
		var bar = new string( 'Γûê', filled );
		var pct = (int)( MiningProgress * 100 );
		var rate = ClockSpeed * BaseSpeed * CoreCount * RackYield;
		var status = IsMining ? "ΓùÅ MINING" : "Γùï IDLE";

		TextRender.Text = IsMining
			? $"{status}\n" +
			  $"ΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇò\n" +
			  $"Γé┐ {BitcoinAmount:0.00000000} BTC\n" +
			  $"\n" +
			  $"MINING RATE  {rate:0.00000} BTC/min\n" +
			  $"HASH RATE    {ClockSpeed:0.000} GHz (Lv {CpuUpgradeLevel}/{CpuUpgradeCosts.Length})\n" +
			  $"CORES        {CoreCount} (Lv {CoreUpgradeLevel}/{CoreUpgradeCosts.Length})\n" +
			  $"VALUE        ${BitcoinAmount * BitcoinValue:N0}\n" +
			  $"ΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇò\n" +
			  $"{bar}\n" +
			  $"{pct}%"
			: $"{status}\n" +
			  $"ΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇò\n" +
			  $"Γé┐ {BitcoinAmount:0.00000000} BTC\n" +
			  $"\n" +
			  $"MINING RATE  0.00000 BTC/min\n" +
			  $"HASH RATE    {ClockSpeed:0.000} GHz (Lv {CpuUpgradeLevel}/{CpuUpgradeCosts.Length})\n" +
			  $"CORES        {CoreCount} (Lv {CoreUpgradeLevel}/{CoreUpgradeCosts.Length})\n" +
			  $"VALUE        ${BitcoinAmount * BitcoinValue:N0}\n" +
			  $"ΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇòΓÇò\n" +
			  $"0%";
	}

	// ----------------------------
	// MINING LOGIC
	// ----------------------------

	private void MineBitcoin()
	{
		BitcoinAmount += ( ClockSpeed * BaseSpeed ) * CoreCount * RackYield;
	}

	// ----------------------------
	// RACK POWER ANIMATION
	// ----------------------------
	// TODO (BITMINER-01): Drive gpu-rack.vmdl sequences power_on / power_off from IsMining.
	// Deprecate Evo child-fan spin below once ModelDoc anim is on the prefab.
	// RGB fan LED rings: lifepunch_rgb_fan_led.shader on gpu-rack-gpu.vmat (see gpu-rack/RGB_FAN_LED_SHADER.md).

	private void UpdateRgbFanLeds()
	{
		if ( !ModelRenderer.IsValid() )
			return;

		var sceneObject = ModelRenderer.SceneObject;
		if ( !sceneObject.IsValid() )
			return;

		var ledActive = 0f;
		if ( IsMining && !GameObject.Tags.Has( PocketTag ) && FanMaxSpeed > 0f )
			ledActive = MathF.Clamp( _fanSpeed / FanMaxSpeed, 0f, 1f );

		sceneObject.Attributes.Set( "g_flLedActive", ledActive );
	}

	private void SpinFan()
	{
		if ( _fanSpeed <= 0f )
			return;

		var rot = Rotation.FromAxis( Vector3.Forward, _fanSpeed * Time.Delta );

		if ( BitminerFan.IsValid() ) BitminerFan.LocalRotation *= rot;
		if ( BitminerFan2.IsValid() ) BitminerFan2.LocalRotation *= rot;
		if ( BitminerFan3.IsValid() ) BitminerFan3.LocalRotation *= rot;
	}

	private void UpdateFanRamp()
	{
		var fanTarget = IsMining ? FanMaxSpeed : 0f;
		var fanStep = ( FanMaxSpeed / FanRampSeconds ) * Time.Delta;

		if ( _fanSpeed < fanTarget )
			_fanSpeed = MathF.Min( _fanSpeed + fanStep, fanTarget );
		else if ( _fanSpeed > fanTarget )
			_fanSpeed = MathF.Max( _fanSpeed - fanStep, fanTarget );
	}

	private void UpdateHumVolume()
	{
		var humTarget = _humPlaying ? HumMaxVolume : 0f;
		var humStep = ( HumMaxVolume / HumRampSeconds ) * Time.Delta;

		if ( _humVolume < humTarget )
		{
			_humVolume = MathF.Min( _humVolume + humStep, humTarget );
		}
		else if ( _humVolume > humTarget )
		{
			_humVolume = MathF.Max( _humVolume - humStep, 0f );
			try { _humHandle.Volume = _humVolume; } catch { }
			if ( _humVolume <= 0f )
				try { _humHandle.Stop(); } catch { }
		}

		if ( _humPlaying )
			try { _humHandle.Volume = _humVolume; } catch { }
	}

	// ----------------------------
	// PLAYER INTERACTION
	// ----------------------------

	public bool Press( IPressable.Event e )
	{
		if ( Input.Down( "Attack1" ) )
			return false;

		RequestOpenTerminal();
		return true;
	}

	public void RequestOpenTerminal() => OpenTerminalHost();

	[Rpc.Host]
	private void OpenTerminalHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;

		var player = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		if ( player.IsValid() && player.CantSwitch )
			return;
#endif

		OpenTerminal( Rpc.CallerId );
	}

	[Rpc.Broadcast]
	private void OpenTerminal( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		BitminerTerminal.Open( this );
	}

	// ----------------------------
	// MINING TOGGLE
	// ----------------------------

	[Rpc.Host]
	public void SetMiningState( bool enabled )
	{
		IsMining = enabled;

		if ( enabled )
		{
			_lastMiningTick = 0f;
			MiningProgress = 0f;
		}

		BroadcastHumState( enabled );
	}

	[Rpc.Broadcast]
	private void BroadcastHumState( bool enabled )
	{
		if ( enabled )
		{
			_humHandle = Sound.Play( Bitminer.HumSoundPath, WorldPosition );
			if ( _humHandle is null )
			{
				_humPlaying = false;
				return;
			}

			_humHandle.Volume = 0f;
			_humVolume = 0f;
			_humPlaying = true;
		}
		else
		{
			_humPlaying = false;
		}
	}

	// ----------------------------
	// SELL BITCOIN
	// ----------------------------

	[Rpc.Host]
	private async void SellBitcoinHost()
	{
		var callerId = Rpc.CallerId;

		if ( BitcoinAmount <= 0 )
			return;

		var value = (uint)( BitcoinAmount * BitcoinValue );

		if ( !await TryPayPlayer( callerId, value, "Sold mined bitcoin" ) )
			return;

		BitcoinAmount = 0f;
	}

#if LIFEPUNCH_LOCAL
	private static async System.Threading.Tasks.Task<bool> TryPayPlayer( Guid callerId, uint amount, string reason )
	{
		await System.Threading.Tasks.Task.CompletedTask;
		return true;
	}
#else
	private async System.Threading.Tasks.Task<bool> TryPayPlayer( Guid callerId, uint amount, string reason )
	{
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		return player.IsValid() && await player.PayHost( amount, reason );
	}
#endif

	public void RequestSellBitcoin() => SellBitcoinHost();

	// ----------------------------
	// UPGRADES
	// ----------------------------

	[Rpc.Host]
	private async void PurchaseUpgradeHost( BitminerUpgradeType type )
	{
		var callerId = Rpc.CallerId;

		switch ( type )
		{
			case BitminerUpgradeType.Cpu:
			{
				if ( CpuUpgradeLevel >= CpuUpgradeCosts.Length )
					return;

				if ( !await TryChargePlayer( callerId, (uint)CpuUpgradeCosts[CpuUpgradeLevel], "Bitminer CPU upgrade" ) )
					return;

				CpuUpgradeLevel++;
				ClockSpeed += 1.5f;
				break;
			}

			case BitminerUpgradeType.Cores:
			{
				if ( CoreUpgradeLevel >= CoreUpgradeCosts.Length )
					return;

				if ( !await TryChargePlayer( callerId, (uint)CoreUpgradeCosts[CoreUpgradeLevel], "Bitminer core upgrade" ) )
					return;

				CoreUpgradeLevel++;
				CoreCount += 2;
				break;
			}
		}
	}

#if LIFEPUNCH_LOCAL
	private static async System.Threading.Tasks.Task<bool> TryChargePlayer( Guid callerId, uint amount, string reason )
	{
		await System.Threading.Tasks.Task.CompletedTask;
		return true;
	}
#else
	private async System.Threading.Tasks.Task<bool> TryChargePlayer( Guid callerId, uint amount, string reason )
	{
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		return player.IsValid() && await player.ChargeHost( amount, reason );
	}
#endif

	public void RequestUpgrade( BitminerUpgradeType type ) => PurchaseUpgradeHost( type );

	// ----------------------------
	// DESTRUCTION
	// ----------------------------

	protected override void OnDisabled()
	{
		base.OnDisabled();
		try { _humHandle.Stop(); } catch { }
		_humPlaying = false;
	}

	protected override void OnEnabled()
	{
		base.OnEnabled();

		if ( IsMining )
		{
			try
			{
				_humHandle = Sound.Play( Bitminer.HumSoundPath, WorldPosition );
				if ( _humHandle is not null )
				{
					_humHandle.Volume = 0.05f;
					_humPlaying = true;
				}
			}
			catch { }
		}
	}

#if LIFEPUNCH_LOCAL
	protected override void OnDestroy() => HandleDestroyed();
#else
	protected override void OnDestroyed() => HandleDestroyed();
#endif

	private void HandleDestroyed()
	{
		if ( !Networking.IsHost )
			return;

		if ( _isExploding )
			return;

		GameObject.Tags.Remove( PocketItemTag );
		_isExploding = true;

		_ = TriggerSmokeAndExplosion();
	}

	private async System.Threading.Tasks.Task TriggerSmokeAndExplosion()
	{
		IsMining = false;
		MiningProgress = 0f;
		BroadcastHumState( false );

		if ( SmokeEffect.IsValid() )
		{
			_activeSmoke = SmokeEffect.Clone();
			_activeSmoke.Parent = GameObject;
			_activeSmoke.NetworkSpawn();
		}

		var smokeTime = Random.Shared.Float( MinSmokeTime, MaxSmokeTime );
		var elapsed = 0f;
		var interval = 0.75f;
		var stopSoundsAt = smokeTime - 3f;

		while ( elapsed < smokeTime )
		{
			if ( !GameObject.IsValid() )
				return;

			if ( elapsed < stopSoundsAt )
			{
#if LIFEPUNCH_LOCAL
				if ( ErrorBeepSound != null )
					Sound.Play( ErrorBeepSound, WorldPosition );
#else
				ErrorBeepSound?.Broadcast( WorldPosition );
#endif
				if ( GlitchSound != null )
					Sound.Play( GlitchSound, WorldPosition );
			}

			await GameTask.DelaySeconds( interval );
			elapsed += interval;
		}

		if ( !GameObject.IsValid() )
			return;

		_activeSmoke?.Destroy();
		_activeSmoke = null;

		if ( Explosion.IsValid() )
		{
			var explosion = Explosion.Clone( WorldPosition );
			explosion.NetworkSpawn();

#if !LIFEPUNCH_LOCAL
			var areaDamage = explosion.AddComponent<AreaDamage>();
			areaDamage.Damage = 60;
			areaDamage.Attacker = this;
			areaDamage.TimeLimit = 0.1f;
			areaDamage.DamageFlags = DamageFlags.Explosion;
#endif
		}

#if !LIFEPUNCH_LOCAL
		base.OnDestroyed();
#endif
	}
}
