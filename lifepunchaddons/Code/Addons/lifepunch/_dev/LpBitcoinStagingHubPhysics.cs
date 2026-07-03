// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LifePunch Dev Tools" (s&box ident: lifepunch.dev · addon ident: dev) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;
using LifePunch.DXRP.Addons;
using LifePunch.DXRP.Addons.Bitcoin;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using DamageInfo = Dxura.RP.Game.DamageInfo;
#endif

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// Hub world machine — NOT a printer prop. Denies hands grab, recovers ghost tags, 250 HP death explosion.
/// Printer: <c>hands_interact</c> + dynamic RB + temporary CollideGuard. Hub: none of that.
/// </summary>
[Title( "LIFEPUNCH Staging Hub Physics" )]
[Category( "LifePunch/Bitcoin/Staging" )]
public sealed class LpBitcoinStagingHubPhysics : Component
#if !LIFEPUNCH_LOCAL
	, IDamageEvents, IAreaDamageReceiver
#endif
{
	[Property]
	[Group( "Setup" )]
	public HealthComponent HealthComponent { get; set; }

	[Property]
	[Group( "Effects" )]
	public GameObject Explosion { get; set; }

	bool _isExploding;
	int _printerSettleTicks;

	/// <summary>Dev recall — re-run printer-style drop after teleport.</summary>
	public void RestartPrinterSettle()
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost )
			return;

		LifePunchPropPhysics.EnablePrinterStyleSpawnPhysics( GameObject );
		_printerSettleTicks = 18;
#endif
	}

	protected override void OnAwake()
	{
		if ( !HealthComponent.IsValid() )
			HealthComponent = Components.Get<HealthComponent>( FindMode.EverythingInSelf );

		LifePunchPropPhysics.DenyHandsGrabTags( GameObject );
		// BoxCollider sync runs in SetupWorldMachine / OnStart after ground align — not here (trace would hit self).
	}

	protected override void OnStart()
	{
#if !LIFEPUNCH_LOCAL
		if ( Networking.IsHost )
		{
			// Printer reference: dynamic RB + gravity briefly, then freeze (see printer.prefab MotionEnabled=true).
			LifePunchPropPhysics.EnablePrinterStyleSpawnPhysics( GameObject );
			_printerSettleTicks = 18;

			if ( !Explosion.IsValid() )
				Explosion = GameObject.GetPrefab( LifePunchMachineDestroyFx.DxrpExplosionPrefabPath );

			if ( HealthComponent.IsValid() )
			{
				HealthComponent.MaxHealth = LpBitcoinIdent.HubMaxHealth;
				if ( HealthComponent.Health <= 0f || HealthComponent.Health > HealthComponent.MaxHealth )
					HealthComponent.Health = HealthComponent.MaxHealth;
			}
		}
		else
		{
			LifePunchPropPhysics.EnforceWorldMachine( GameObject );
		}
#else
		LifePunchPropPhysics.EnforceWorldMachine( GameObject );
#endif

		TryFinishDeathHost();
	}

	protected override void OnFixedUpdate()
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost )
			return;

		if ( _printerSettleTicks > 0 )
		{
			_printerSettleTicks--;
			if ( _printerSettleTicks == 0 )
				LifePunchPropPhysics.FinishSpawnAsWorldMachine( GameObject );

			return;
		}

		LifePunchPropPhysics.EnforceWorldMachine( GameObject );
		TryFinishDeathHost();
#endif
	}

#if !LIFEPUNCH_LOCAL
	public void ApplyAreaDamage( AreaDamage component )
	{
		if ( !HealthComponent.IsValid() )
			return;

		HealthComponent.TakeDamageHost( new DamageInfo(
			component.Attacker,
			component.Damage,
			component.Inflictor,
			component.WorldPosition,
			Flags: component.DamageFlags ) );
	}

	public void OnDamageTakenHost( Component victim, DamageInfo damageInfo )
	{
		_ = victim;
		_ = damageInfo;
		TryFinishDeathHost();
	}

	public void OnKillHost( Component victim, DamageInfo damage )
	{
		_ = victim;
		_ = damage;
		TryFinishDeathHost();
	}

	void TryFinishDeathHost()
	{
		if ( !Networking.IsHost || _isExploding || !HealthComponent.IsValid() )
			return;

		if ( HealthComponent.State != LifeState.Dead && HealthComponent.Health > 0f )
			return;

		_isExploding = true;
		LifePunchMachineDestroyFx.SpawnPrinterStyleExplosion( this, Explosion, WorldPosition );
		GameObject.Destroy();
	}
#endif
}
