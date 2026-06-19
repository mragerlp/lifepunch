// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using Dxura.RP.Shared;
using DamageInfo = Dxura.RP.Game.DamageInfo;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>CRT terminal prop — world LCD telemetry + USE opens command console.</summary>
[Title( "LIFEPUNCH Bitcoin Terminal (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinTerminalEntity : Component, Component.IPressable
#else
public sealed class LpBitcoinTerminalEntity : BaseEntity, Component.IPressable, IAreaDamageReceiver
#endif
{
	private const float ScreenRefreshSeconds = 0.25f;

	[Property] public float LinkRange { get; set; } = 512f;
	[Property] public TextRenderer ScreenText { get; set; }

	/// <summary>When true, prefab <c>lcd_screen</c> transform is authoritative — no bounds auto-align on spawn.</summary>
	[Property] public bool ManualLcdPlacement { get; set; }

	/// <summary>Hub that registered this terminal via admin Settings — not proximity auto-link.</summary>
	[Sync( SyncFlags.FromHost )] public Guid LinkedHubId { get; set; }

#if !LIFEPUNCH_LOCAL
	[Property]
	[Group( "Effects" )]
	public GameObject Explosion { get; set; }

	bool _isExploding;
	int _spawnDropGraceTicks;
	bool _colliderSyncedFromModel;
#endif

#if !LIFEPUNCH_LOCAL
	public override string DisplayName => LpBitcoinIdent.TerminalDisplayName;
#endif

	private string _cachedScreenText;
	private bool _occluded;

	protected override void OnAwake()
	{
		// Collider sync after spawn grace in OnFixedUpdate (printer-style drop).
	}

	protected override void OnStart()
	{
		base.OnStart();
#if !LIFEPUNCH_LOCAL
		this.TryBindSpawnOwnerHost();
		if ( Networking.IsHost )
		{
			if ( HealthComponent.IsValid() )
			{
				HealthComponent.MaxHealth = LpBitcoinIdent.TerminalMaxHealth;
				if ( HealthComponent.Health <= 0f || HealthComponent.Health > HealthComponent.MaxHealth )
					HealthComponent.Health = HealthComponent.MaxHealth;
			}

			_spawnDropGraceTicks = 45;
			_colliderSyncedFromModel = false;
			LifePunchPropPhysics.BeginGrabbablePrinterDrop( GameObject, syncColliderFromModel: false );
			Log.Info( $"TERMINAL_SPAWN_PHYSICS pos={GameObject.WorldPosition} gravity=on (printer drop, no ground snap)" );
		}
#endif

		if ( !ScreenText.IsValid() )
			ScreenText = GameObject.Children.FirstOrDefault( c => c.Name == "lcd_screen" )?.GetComponent<TextRenderer>();

		if ( ScreenText.IsValid() && !ManualLcdPlacement )
			LifePunchTerminalLcd.TryAlignHashdScreen( GameObject, ScreenText );

		RefreshScreenIdle();
	}

	/// <summary>Re-align feet after dev recall / reposition.</summary>
	public void RestartPrinterSettle()
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost )
			return;

		_spawnDropGraceTicks = 45;
		_colliderSyncedFromModel = false;
		LifePunchPropPhysics.BeginGrabbablePrinterDrop( GameObject, syncColliderFromModel: false );
#endif
	}

	protected override void OnFixedUpdate()
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost )
			return;

		LifePunchPropPhysics.MaintainGrabbablePlaceableProp( GameObject );

		if ( _spawnDropGraceTicks > 0 )
		{
			_spawnDropGraceTicks--;
			return;
		}

		if ( !_colliderSyncedFromModel )
		{
			LifePunchPropPhysics.SyncBoxColliderFromModel( GameObject );
			_colliderSyncedFromModel = true;
		}
#endif
	}

#if !LIFEPUNCH_LOCAL
	public void ApplyAreaDamage( AreaDamage component )
	{
		var dmg = new DamageInfo(
			component.Attacker,
			component.Damage,
			component.Inflictor,
			component.WorldPosition,
			Flags: component.DamageFlags );

		HealthComponent?.TakeDamageHost( dmg );
	}

	protected override void OnDestroyed()
	{
		if ( Networking.IsHost && !_isExploding )
		{
			_isExploding = true;
			LifePunchMachineDestroyFx.SpawnPrinterStyleExplosion( this, Explosion, WorldPosition );
		}

		base.OnDestroyed();
	}

	public override void OnOcclusionChanged( bool occlude )
	{
		base.OnOcclusionChanged( occlude );
		_occluded = occlude;
	}
#endif

	protected override void OnUpdate()
	{
#if !LIFEPUNCH_LOCAL
		if ( _occluded || GameManager.IsHeadless )
			return;

		if ( Cooldown.Current.CheckAndStartCooldown( $"{GameObject.Id}:lcd", ScreenRefreshSeconds ) )
			return;
#endif

		RefreshScreenIdle();
	}

	/// <summary>Push hub telemetry to every terminal linked to this hub.</summary>
	public static void RefreshForHub( LpBitcoinHubEntity hub )
	{
		if ( hub is null || !hub.IsValid() )
			return;

		var scene = hub.GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return;

		foreach ( var terminal in scene.GetAllComponents<LpBitcoinTerminalEntity>() )
		{
			if ( !terminal.IsValid() )
				continue;

			var linked = terminal.FindLinkedHub();
			if ( linked.IsValid() && linked.GameObject.Id == hub.GameObject.Id )
				terminal.RefreshScreenIdle();
		}
	}

	public bool IsLinkedToHub() => LinkedHubId != Guid.Empty && FindLinkedHub().IsValid();

	public void LinkToHub( LpBitcoinHubEntity hub )
	{
		if ( !hub.IsValid() )
			return;

		if ( !IsWithinLinkRange( hub ) )
			return;

		LinkedHubId = hub.GameObject.Id;
		RefreshScreenIdle();
	}

	public void UnlinkFromHub()
	{
		LinkedHubId = Guid.Empty;
		RefreshScreenIdle();
	}

	public bool IsWithinLinkRange( LpBitcoinHubEntity hub )
		=> hub.IsValid() && hub.WorldPosition.Distance( WorldPosition ) <= LinkRange;

	internal LpBitcoinHubEntity FindLinkedHub()
		=> LpBitcoinHubEntity.FindByGameObjectId( LinkedHubId, GameObject.Scene ?? Game.ActiveScene );

	/// <summary>Nearest unlinked terminal within range (hub Settings link action).</summary>
	internal static LpBitcoinTerminalEntity FindNearestUnlinked( LpBitcoinHubEntity hub )
	{
		if ( !hub.IsValid() )
			return null;

		var scene = hub.GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return null;

		LpBitcoinTerminalEntity best = null;
		var bestDist = float.MaxValue;

		foreach ( var terminal in scene.GetAllComponents<LpBitcoinTerminalEntity>() )
		{
			if ( !terminal.IsValid() || terminal.LinkedHubId != Guid.Empty )
				continue;

			if ( !terminal.IsWithinLinkRange( hub ) )
				continue;

			var dist = hub.WorldPosition.Distance( terminal.WorldPosition );
			if ( dist >= bestDist )
				continue;

			bestDist = dist;
			best = terminal;
		}

		return best;
	}

	public void RefreshScreenIdle()
	{
		if ( !ScreenText.IsValid() )
			return;

		var text = LpBitcoinTerminalScreen.Build( FindLinkedHub() );
		if ( string.Equals( text, _cachedScreenText, StringComparison.Ordinal ) )
			return;

		_cachedScreenText = text;
		ScreenText.Text = text;
	}

	public bool CanPress( IPressable.Event e )
		=> IsLinkedToHub() && LifePunchMenuInteractGate.CanPressMenu( GameObject );

	public bool Press( IPressable.Event e )
	{
		RequestOpenTerminal();
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	public void RequestOpenTerminal() => OpenTerminalHost();

	[Rpc.Host]
	private void OpenTerminalHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !LifePunchMenuInteractGate.IsCallerAllowed( Rpc.Caller, GameObject ) )
			return;
#else
		if ( !LifePunchMenuInteractGate.IsCallerAllowed( null, GameObject ) )
			return;
#endif

		var hub = FindLinkedHub();
		if ( hub is null )
		{
			Log.Warning( "[lifepunch.bitcoin] Terminal not linked — register at hub admin → Settings." );
			return;
		}

		if ( !hub.IsPowered )
		{
			Log.Warning( "[lifepunch.bitcoin] Hub power off — enable at hub admin panel." );
			return;
		}

		OpenTerminal( Rpc.CallerId, hub.GameObject.Id );
	}

	[Rpc.Broadcast]
	private void OpenTerminal( Guid callerId, Guid hubId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		var hub = ResolveHub( hubId );
		if ( hub is null )
			return;

		LpBitcoinTerminalUiHost.Open( hub );
	}

	private static LpBitcoinHubEntity ResolveHub( Guid hubId )
		=> LpBitcoinHubEntity.FindByGameObjectId( hubId );
}
