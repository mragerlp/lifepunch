// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "MP9" (s&box ident: lifepunch.mp9 · addon ident: mp9) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.Mp9;

public static class Mp9
{
	public const string Package = "lifepunch.mp9";
	public const string Ident = "mp9";
	public const string DisplayName = "MP9";
	public const string Grouping = "Secondary";
	public const string WeaponClass = "smg";
	public const string DxrpClassReference = "mp5";
	public const string Cs2ReferenceMesh = "weapon_smg_mp9";

	public const string WorldPrefabPath = "addons/lifepunch/mp9/equipment/w_mp9/w_mp9.prefab";
	public const string ViewModelPrefabPath = "addons/lifepunch/mp9/equipment/vm_mp9/vm_mp9.prefab";
	public const string WorldModelPath = "addons/lifepunch/mp9/models/lifepunch/mp9/w_mp9/w_mp9.vmdl";
	public const string ClassWorldPrefabPlaceholder = "gameplay/equipment/weapons/mp5/w_mp5.prefab";
	public const string ClassViewModelPlaceholder = "gameplay/equipment/weapons/mp5/vm_mp5.prefab";
	public const string FireSoundPath = "addons/lifepunch/mp9/sounds/mp9_shot.sound";
	public const string FireDistantSoundPath = "addons/lifepunch/mp9/sounds/mp9_shot_distant.sound";
	public const string ReloadSoundPath = "addons/lifepunch/mp9/sounds/mp9_reload.sound";
	public const string CockSoundPath = "addons/lifepunch/mp9/sounds/mp9_cock.sound";
	public const string DrawSoundPath = "addons/lifepunch/mp9/sounds/mp9_draw.sound";
	public const string IconPath = "addons/lifepunch/mp9/ui/mp9_killfeed.png";
	public const string DevGiveCommand = "lp_give_mp9";

	// MP5 class baseline (dxrp-public w_mp5) biased for MP9 ROF profile.
	public static Mp9WeaponStats Stats { get; } = new()
	{
		Damage = 11,
		RoundsPerMinute = 857,
		MagazineSize = 30,
		ReserveAmmo = 90,
		ReloadSeconds = 1.4f,
		RangeMeters = 65,
		SpreadDegrees = 2.2f,
		RecoilPitch = 3.0f,
		RecoilYaw = 2.0f,
		Automatic = true
	};
}

public sealed class Mp9WeaponStats
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