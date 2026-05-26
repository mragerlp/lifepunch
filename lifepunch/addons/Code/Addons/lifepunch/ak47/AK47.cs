namespace LifePunch.DXRP.Addons.AK47;

public static class AK47
{
	public const string Package = "lifepunch.ak47";
	public const string Ident = "ak47";
	public const string DisplayName = "AK-47";
	public const string Grouping = "Secondary";

	public const string WorldPrefabPath = "equipment/w_ak47/w_ak47.prefab";
	public const string ViewModelPrefabPath = "equipment/vm_ak47/vm_ak47.prefab";
	public const string WorldModelPath = "addons/lifepunch/ak47/models/lifepunch/ak47/w_ak47/w_ak47.vmdl";
	public const string FireSoundPath = "addons/lifepunch/ak47/sounds/ak47_shot.sound";
	public const string FireDistantSoundPath = "addons/lifepunch/ak47/sounds/ak47_shot_distant.sound";
	public const string ReloadClipOutSoundPath = "addons/lifepunch/ak47/sounds/ak47_reload_clipout.sound";
	public const string ReloadClipInSoundPath = "addons/lifepunch/ak47/sounds/ak47_reload_clipin.sound";
	public const string CockSoundPath = "addons/lifepunch/ak47/sounds/ak47_cock.sound";
	public const string DrawSoundPath = "addons/lifepunch/ak47/sounds/ak47_draw.sound";

	public static AK47WeaponStats Stats { get; } = new()
	{
		Damage = 28,
		RoundsPerMinute = 600,
		MagazineSize = 30,
		ReserveAmmo = 90,
		ReloadSeconds = 2.4f,
		RangeMeters = 120,
		SpreadDegrees = 1.8f,
		RecoilPitch = 2.2f,
		RecoilYaw = 0.85f,
		Automatic = true
	};
}

public sealed class AK47WeaponStats
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

	public float SecondsBetweenShots => 60f / RoundsPerMinute;
}
