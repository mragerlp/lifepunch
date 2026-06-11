// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LifePunch Dev Tools" (s&box ident: lifepunch.dev · addon ident: dev) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL
using System;
using System.Linq;
using Dxura.RP.Game;
using Ak47Weapon = LifePunch.DXRP.Addons.AK47.AK47;
using DeagleWeapon = LifePunch.DXRP.Addons.Deagle.Deagle;
using Mp9Weapon = LifePunch.DXRP.Addons.Mp9.Mp9;
using Ssg08Weapon = LifePunch.DXRP.Addons.Ssg08.Ssg08;
using Xm1014Weapon = LifePunch.DXRP.Addons.Xm1014.Xm1014;
using Sandbox;

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// DEV / EDITOR-TEST ONLY — excluded from publish (<c>*DevGive.cs</c> / <c>_dev/</c>).
/// Clones weapon prefabs directly so designers can test first-person viewmodels without a portal Equipment row.
/// </summary>
public static class WeaponDevGive
{
	/// <summary>AK baseline — same as <see cref="GiveAkClass"/> (LifePunch sounds + class M4 hold/vm).</summary>
	[ConCmd( "lp_give_ak" )]
	public static void GiveAk() => GiveAkClass();

	/// <summary>
	/// AK baseline: LifePunch <c>w_ak47</c> world prefab + M4 class <c>vm_m4a1</c> until FP rig lands.
	/// </summary>
	[ConCmd( "lp_give_ak_class" )]
	public static void GiveAkClass() => GiveClassToPlayer(
		Player.Local,
		Ak47Weapon.Ident,
		Ak47Weapon.WorldPrefabPath,
		Ak47Weapon.ClassWorldPrefabPlaceholder,
		Ak47Weapon.ClassViewModelPlaceholder,
		Ak47Weapon.DisplayName );

	/// <summary>Equip AK baseline on a spawned test bot — best 3P hold check (orbit camera on Greg).</summary>
	[ConCmd( "lp_give_ak_bot" )]
	public static void GiveAkBot( string botName = "Greg" ) => GiveClassToPlayer(
		ResolveTestPlayer( botName ),
		Ak47Weapon.Ident,
		Ak47Weapon.WorldPrefabPath,
		Ak47Weapon.ClassWorldPrefabPlaceholder,
		Ak47Weapon.ClassViewModelPlaceholder,
		$"{Ak47Weapon.DisplayName} — {botName}" );

	/// <summary>Spawn Greg + equip AK — one-shot 3P smoke.</summary>
	[ConCmd( "lp_smoke_ak_bot" )]
	public static void SmokeAkBot()
	{
		if ( !Application.IsEditor || !Networking.IsHost )
		{
			Log.Warning( "lp_smoke_ak_bot: editor host-only." );
			return;
		}

		StaffMenuTestBots.SpawnTestBot( "Greg" );
		GiveAkBot( "Greg" );
		Log.Info( "lp_smoke_ak_bot: orbit Greg — 3P rifle hold + drop test. Compare lp_give_ak_class on local for 1P." );
	}

	[ConCmd( "lp_give_deagle" )]
	public static void GiveDeagle() => Give( DeagleWeapon.Ident, DeagleWeapon.WorldPrefabPath, DeagleWeapon.ClassWorldPrefabPlaceholder, DeagleWeapon.DisplayName );

	[ConCmd( "lp_give_mp9" )]
	public static void GiveMp9() => Give( Mp9Weapon.Ident, Mp9Weapon.WorldPrefabPath, Mp9Weapon.ClassWorldPrefabPlaceholder, Mp9Weapon.DisplayName );

	[ConCmd( "lp_give_ssg08" )]
	public static void GiveSsg08() => Give( Ssg08Weapon.Ident, Ssg08Weapon.WorldPrefabPath, Ssg08Weapon.ClassWorldPrefabPlaceholder, Ssg08Weapon.DisplayName );

	[ConCmd( "lp_give_xm1014" )]
	public static void GiveXm1014() => Give( Xm1014Weapon.Ident, Xm1014Weapon.WorldPrefabPath, Xm1014Weapon.ClassWorldPrefabPlaceholder, Xm1014Weapon.DisplayName );

	/// <summary>Generic: <c>lp_give_weapon ak47</c> · <c>lp_give_weapon deagle</c> · etc.</summary>
	[ConCmd( "lp_give_weapon" )]
	public static void GiveWeaponCmd( string ident = "" )
	{
		switch ( ( ident ?? "" ).Trim().ToLowerInvariant() )
		{
			case "ak":
			case "ak47":
				GiveAkClass();
				break;
			case "deagle":
				GiveDeagle();
				break;
			case "mp9":
				GiveMp9();
				break;
			case "ssg08":
			case "ssg":
				GiveSsg08();
				break;
			case "xm1014":
			case "xm":
				GiveXm1014();
				break;
			default:
				Log.Warning( "lp_give_weapon: usage — lp_give_weapon ak47|deagle|mp9|ssg08|xm1014" );
				break;
		}
	}

	private static void Give( string ident, string primaryPrefab, string classFallbackPrefab, string label )
	{
		if ( !Application.IsEditor )
		{
			Log.Warning( "lp_give_weapon: editor-only dev command." );
			return;
		}

		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_give_weapon: must be host (editor play)." );
			return;
		}

		var player = Player.Local;
		if ( !player.IsValid() || !player.WeaponGameObject.IsValid() )
		{
			Log.Warning( "lp_give_weapon: no local player / weapon holder." );
			return;
		}

		var prefabPath = ResolvePrefabPath( primaryPrefab, classFallbackPrefab );
		if ( prefabPath is null )
		{
			Log.Error( $"lp_give_weapon: no prefab for {ident}. Primary={primaryPrefab} fallback={classFallbackPrefab}" );
			return;
		}

		RemoveExisting( player, ident );

		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"lp_give_weapon: prefab could not load: {prefabPath}" );
			return;
		}

		var go = prefab.Clone( new CloneConfig
		{
			Transform = new Transform(),
			Parent = player.WeaponGameObject
		} );

		var equipment = go.Components.Get<Equipment>( FindMode.EverythingInSelfAndDescendants );
		if ( !equipment.IsValid() )
		{
			Log.Error( $"lp_give_weapon: prefab has no Equipment component: {prefabPath}" );
			go.Destroy();
			return;
		}

		equipment.Identifier = ident;
		equipment.OwnerId = player.Id;
		equipment.CanDrop = true;
		go.NetworkSpawn( player.Network.Owner );

		if ( !player.CantSwitch )
		{
			player.SetCurrentEquipment( equipment );
		}

		var usingFallback = !string.Equals( prefabPath, primaryPrefab, StringComparison.OrdinalIgnoreCase );
		Log.Info( $"lp_give_weapon: equipped {label} ({ident}) from {(usingFallback ? "class placeholder" : "LifePunch kit")}: {prefabPath}" );
		Log.Info( "lp_give_weapon: first person uses ViewModelPrefab on the equipment prefab (AK → vm_ak47; others → class vm_* until LifePunch vm ships)." );
	}

	/// <summary>
	/// Class-wiring baseline: LifePunch world prefab when available, forced class viewmodel prefab.
	/// </summary>
	private static void GiveClassToPlayer(
		Player player,
		string ident,
		string worldPrefab,
		string classWorldFallback,
		string classViewModelPrefab,
		string label )
	{
		if ( !Application.IsEditor )
		{
			Log.Warning( "lp_give_weapon: editor-only dev command." );
			return;
		}

		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_give_weapon: must be host (editor play)." );
			return;
		}

		if ( !player.IsValid() || !player.WeaponGameObject.IsValid() )
		{
			Log.Warning( "lp_give_weapon: target player invalid (spawn bot first: lifepunch_spawn_testbot Greg)." );
			return;
		}

		PreparePlayerForWeaponHold( player );

		var prefabPath = ResolvePrefabPath( worldPrefab, classWorldFallback );
		if ( prefabPath is null )
		{
			Log.Error( $"lp_give_weapon: no world prefab. Primary={worldPrefab} fallback={classWorldFallback}" );
			return;
		}

		var vmPrefab = GameObject.GetPrefab( classViewModelPrefab );
		if ( !vmPrefab.IsValid() )
		{
			Log.Error( $"lp_give_weapon: class viewmodel prefab could not load: {classViewModelPrefab}" );
			return;
		}

		RemoveExisting( player, ident );

		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"lp_give_weapon: prefab could not load: {prefabPath}" );
			return;
		}

		var go = prefab.Clone( new CloneConfig
		{
			Transform = new Transform(),
			Parent = player.WeaponGameObject
		} );

		var equipment = go.Components.Get<Equipment>( FindMode.EverythingInSelfAndDescendants );
		if ( !equipment.IsValid() )
		{
			Log.Error( $"lp_give_weapon: prefab has no Equipment component: {prefabPath}" );
			go.Destroy();
			return;
		}

		equipment.Identifier = ident;
		equipment.OwnerId = player.Id;
		equipment.CanDrop = true;
		equipment.ViewModelPrefab = vmPrefab;
		go.NetworkSpawn( player.Network.Owner );

		if ( !player.CantSwitch )
		{
			player.SetCurrentEquipment( equipment );
		}

		var usingClassWorld = string.Equals( prefabPath, classWorldFallback, StringComparison.OrdinalIgnoreCase );
		Log.Info( $"lp_give_weapon: {label} ({ident}) on {player.DisplayName} world={(usingClassWorld ? "class M4" : "LifePunch w_ak47")}: {prefabPath}" );
		Log.Info( $"lp_give_weapon: viewmodel: {classViewModelPrefab}" );
	}

	/// <summary>Test bots disable Controller by default — rifle hold IK breaks without this.</summary>
	private static void PreparePlayerForWeaponHold( Player player )
	{
		if ( player.Controller.IsValid() && !player.Controller.Enabled )
		{
			player.Controller.Enabled = true;
			Log.Info( $"lp_give_weapon: enabled Controller on {player.DisplayName} for weapon hold test." );
		}
	}

	private static Player ResolveTestPlayer( string token )
	{
		var name = ( token ?? "" ).Trim();
		if ( string.IsNullOrWhiteSpace( name ) )
		{
			name = "Greg";
		}

		var manager = GameNetworkManager.Instance;
		if ( !manager.IsValid() )
		{
			return null;
		}

		foreach ( var entry in manager.Players )
		{
			var player = entry.Value;
			if ( !player.IsValid() )
			{
				continue;
			}

			if ( player.DisplayName.Contains( name, StringComparison.OrdinalIgnoreCase )
				|| player.SteamName.Contains( name, StringComparison.OrdinalIgnoreCase ) )
			{
				return player;
			}
		}

		return null;
	}

	private static string ResolvePrefabPath( string primary, string fallback )
	{
		if ( !string.IsNullOrWhiteSpace( primary ) && GameObject.GetPrefab( primary ).IsValid() )
		{
			return primary;
		}

		if ( !string.IsNullOrWhiteSpace( fallback ) && GameObject.GetPrefab( fallback ).IsValid() )
		{
			return fallback;
		}

		return null;
	}

	private static void RemoveExisting( Player player, string ident )
	{
		foreach ( var weapon in player.Equipment.ToList() )
		{
			if ( !weapon.IsValid() )
			{
				continue;
			}

			if ( string.Equals( weapon.Identifier, ident, StringComparison.OrdinalIgnoreCase ) )
			{
				player.RemoveEquipment( weapon );
			}
		}
	}
}
#endif
