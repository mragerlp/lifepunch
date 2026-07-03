// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "SSG 08" (s&box ident: lifepunch.ssg08 · addon ident: ssg08) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.Ssg08;

public static class Ssg08
{
	public const string Package = "lifepunch.ssg08";
	public const string Ident = "ssg08";
	public const string DisplayName = "SSG 08";
	public const string Grouping = "Secondary";
	public const string WeaponClass = "sniper";
	public const string DxrpClassReference = "m700";
	public const string Cs2ReferenceMesh = "weapon_snip_ssg08";

	public const string WorldPrefabPath = "addons/lifepunch/ssg08/equipment/w_ssg08/w_ssg08.prefab";
	public const string ViewModelPrefabPath = "addons/lifepunch/ssg08/equipment/vm_ssg08/vm_ssg08.prefab";
	public const string WorldModelPath = "addons/lifepunch/ssg08/models/lifepunch/ssg08/w_ssg08/w_ssg08.vmdl";
	public const string ClassWorldPrefabPlaceholder = "gameplay/equipment/weapons/m700/w_m700.prefab";
	public const string ClassViewModelPlaceholder = "gameplay/equipment/weapons/m700/vm_m700.prefab";
	public const string FireSoundPath = "addons/lifepunch/ssg08/sounds/ssg08_shot.sound";
	public const string FireDistantSoundPath = "addons/lifepunch/ssg08/sounds/ssg08_shot_distant.sound";
	public const string ReloadSoundPath = "addons/lifepunch/ssg08/sounds/ssg08_reload.sound";
	public const string BoltSoundPath = "addons/lifepunch/ssg08/sounds/ssg08_bolt.sound";
	public const string DrawSoundPath = "addons/lifepunch/ssg08/sounds/ssg08_draw.sound";
	public const string IconPath = "addons/lifepunch/ssg08/ui/ssg08_killfeed.png";
	public const string DevGiveCommand = "lp_give_ssg08";

	// M700 class baseline (dxrp-public w_m700) biased for scout rifle (SSG 08).
	public static Ssg08WeaponStats Stats { get; } = new()
	{
		Damage = 65,
		RoundsPerMinute = 60,
		MagazineSize = 10,
		ReserveAmmo = 30,
		ReloadSeconds = 2.2f,
		RangeMeters = 180,
		SpreadDegrees = 0.6f,
		RecoilPitch = 12f,
		RecoilYaw = 3.0f,
		Automatic = false
	};
}

public sealed class Ssg08WeaponStats
{
	public int Damage { get; init; }
	public int RoundsPerMinute { get; init; }
	public int MagazineSize { get; init; }
	public int ReserveAmmo { get; init; }
	public float ReloadSeconds { get; init; }
	public int RangeMeters { get; init; }
	public float SpreadDegrees { get; init; }
	public float RecoilPitch { get; init; }
	public float RecoilYaw { get; init; }
	public bool Automatic { get; init; }

	public float SecondsBetweenShots => RoundsPerMinute > 0 ? 60f / RoundsPerMinute : 0f;
}