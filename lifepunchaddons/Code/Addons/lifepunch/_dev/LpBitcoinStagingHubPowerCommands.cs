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
using LifePunch.DXRP.Addons;
using LifePunch.DXRP.Addons.Bitcoin;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using DamageInfo = Dxura.RP.Game.DamageInfo;
#endif

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>ConCmds for staging hub OFF/ON lights + panel.</summary>
public static class LpBitcoinStagingHubPowerCommands
{
	[ConCmd( "lp_staging_hub_power_toggle" )]
	public static void PowerToggle()
	{
		if ( !TryGetHub( out var hub ) )
			return;

		hub.SetPowered( !hub.IsPowered );
		Log.Info( $"lp_staging_hub_power_toggle: IsPowered={hub.IsPowered} (green=ON, red=OFF fence LED)." );
	}

	[ConCmd( "lp_staging_hub_power_on" )]
	public static void PowerOn()
	{
		if ( !TryGetHub( out var hub ) )
			return;

		hub.SetPowered( true );
		Log.Info( "lp_staging_hub_power_on: fence LED + status light -> ON (green)." );
	}

	[ConCmd( "lp_staging_hub_power_off" )]
	public static void PowerOff()
	{
		if ( !TryGetHub( out var hub ) )
			return;

		hub.SetPowered( false );
		Log.Info( "lp_staging_hub_power_off: fence LED + status light -> OFF (red)." );
	}

	[ConCmd( "lp_staging_hub_collision_fix" )]
	public static void CollisionFix()
	{
		if ( !TryGetHub( out var hub ) )
			return;

		LifePunchPropPhysics.ClearHandsGrabCollisionTags( hub.GameObject );
		LifePunchPropPhysics.SetupGrabbablePlaceableProp( hub.GameObject, alignGround: false );
		LifePunchPropPhysics.LogModelPhysics( hub.GameObject, "staging_hub_collision_fix" );
		Log.Info( "lp_staging_hub_collision_fix: cleared ghost tags, grabbable collider restored." );
	}

	[ConCmd( "lp_staging_hub_ui" )]
	public static void OpenUi()
	{
		if ( !TryGetHub( out var hub ) )
			return;

		LpBitcoinStagingHubUiHost.Open( hub );
		Log.Info( "lp_staging_hub_ui: staging power panel opened." );
	}

	[ConCmd( "lp_staging_status_led_tune" )]
	public static void StatusLedTune()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_status_led_tune: no active scene." );
			return;
		}

		foreach ( var hub in scene.GetAllComponents<LpBitcoinStagingHubPower>().Where( h => h.IsValid() ) )
		{
			Log.Info( $"LPBITCOIN_STAGING_STATUS_LED powered={hub.IsPowered} mode=mesh-emissive" );
		}
	}

	public static bool TryGetHub( out LpBitcoinStagingHubPower hub )
	{
		hub = default;
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_hub: no active scene — Host Play first." );
			return false;
		}

		hub = scene.GetAllComponents<LpBitcoinStagingHubPower>()
			.FirstOrDefault( h => h.IsValid() && h.GameObject.Name == "lpbitcoin_staging_hub" );

		if ( !hub.IsValid() )
			hub = scene.GetAllComponents<LpBitcoinStagingHubPower>().FirstOrDefault( h => h.IsValid() );

		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_staging_hub: no staging hub — run lp_spawn_staging_hub first." );
			return false;
		}

		return true;
	}

	internal static void EnsureHubGameplayStack( GameObject go )
	{
		EnsureHubPowerStack( go );

		// Production prefab carries LpBitcoinHubEntity — skip duplicate staging physics/death stack.
		if ( go.Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelf ).IsValid() )
			return;

		EnsureHubPhysics( go );
	}

	internal static void EnsureHubPowerStack( GameObject go )
	{
		if ( !go.IsValid() )
			return;

		var power = go.Components.Get<LpBitcoinStagingHubPower>( FindMode.EverythingInSelf );
		if ( !power.IsValid() )
			power = go.AddComponent<LpBitcoinStagingHubPower>();

		power.EnsureVisuals();
	}

	static void EnsureHubPhysics( GameObject go )
	{
		if ( !go.IsValid() )
			return;

		var physics = go.Components.Get<LpBitcoinStagingHubPhysics>( FindMode.EverythingInSelf );
		if ( !physics.IsValid() )
			physics = go.AddComponent<LpBitcoinStagingHubPhysics>();

		var health = go.Components.Get<HealthComponent>( FindMode.EverythingInSelf );
		if ( health.IsValid() )
			physics.HealthComponent = health;
	}

#if !LIFEPUNCH_LOCAL
	[ConCmd( "lp_staging_hub_health_probe" )]
	public static void HealthProbe()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_hub_health_probe: no active scene." );
			return;
		}

		foreach ( var hub in scene.GetAllComponents<LpBitcoinStagingHubPower>() )
		{
			if ( !hub.IsValid() )
				continue;

			var go = hub.GameObject;
			var health = go.Components.Get<HealthComponent>( FindMode.EverythingInSelf );
			var destroyFx = go.Components.Get<LpBitcoinStagingHubPhysics>( FindMode.EverythingInSelf );
			if ( !health.IsValid() )
			{
				Log.Info( $"LPBITCOIN_HUB_PROBE {go.Name}: no HealthComponent" );
				continue;
			}

			Log.Info(
				$"LPBITCOIN_HUB_PROBE {go.Name}: health={health.Health:F2}/{health.MaxHealth:F0} state={health.State} hubPhysics={destroyFx.IsValid()} hands_interact={go.Tags.Has( "hands_interact" )} host={Networking.IsHost}" );
		}
	}

	[ConCmd( "lp_staging_hub_kill_test" )]
	public static void KillTest()
	{
		if ( !TryGetHub( out var hub ) )
			return;

		var health = hub.Components.Get<HealthComponent>( FindMode.EverythingInSelf );
		if ( !health.IsValid() )
		{
			Log.Warning( "lp_staging_hub_kill_test: hub has no HealthComponent." );
			return;
		}

		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_staging_hub_kill_test: host only." );
			return;
		}

		health.TakeDamageHost( new DamageInfo( hub, health.MaxHealth + 1f ) );
		Log.Info( "lp_staging_hub_kill_test: applied lethal damage — expect printer-style explosion." );
	}
#endif
}
