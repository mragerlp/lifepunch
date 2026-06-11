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

	public const string WorldPrefabPath = "addons/lifepunch/mp9/equipment/w_mp9/w_mp9.prefab";
	public const string ViewModelPrefabPath = "addons/lifepunch/mp9/equipment/vm_mp9/vm_mp9.prefab";
	public const string WorldModelPath = "addons/lifepunch/mp9/models/lifepunch/mp9/w_mp9/w_mp9.vmdl";
	public const string ClassWorldPrefabPlaceholder = "gameplay/equipment/weapons/mp5/w_mp5.prefab";
	public const string ClassViewModelPlaceholder = "gameplay/equipment/weapons/mp5/vm_mp5.prefab";

	public static Mp9WeaponStats Stats { get; } = new()
	{
		Damage = 0,
		RoundsPerMinute = 0,
		MagazineSize = 0,
		ReserveAmmo = 0,
		ReloadSeconds = 0f,
		RangeMeters = 0,
		SpreadDegrees = 0f,
		RecoilPitch = 0f,
		RecoilYaw = 0f,
		Automatic = false
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