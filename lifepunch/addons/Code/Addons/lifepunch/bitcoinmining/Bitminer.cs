namespace LifePunch.BitcoinMining;

/// <summary>
/// LifePunch Bitminer package identity and mounted content paths.
/// Mirrors the AK-47 pattern (see <c>Code/Addons/lifepunch/ak47/AK47.cs</c>).
/// Reference values here are the source of truth for the manifest content row in
/// <c>config/addons.json</c> and for the dxrp.net content fields.
/// </summary>
public static class Bitminer
{
	public const string Package = "lifepunch.bitcoinmining";
	public const string Ident = "bitcoinmining";
	public const string Slug = "bitminer";
	public const string DisplayName = "Bitminer S1";
	public const string Description = "A bitcoin mining rig. Interact to open the BitOS terminal, mine, upgrade, and sell BTC.";

	/// <summary>DXRP entity content uses <c>type: 0</c>.</summary>
	public const int ContentType = 0;

	/// <summary>Spawn-menu grouping/category for entities.</summary>
	public const string Grouping = "Entities";

	public const string WorldPrefabPath = "addons/lifepunch/bitcoinmining/entities/bitminer/bitminer.prefab";

	// Body + fans are served by evo's published cloud packages (fully textured), NOT local
	// addon models. The content-row World Model and the prefab body ModelRenderer both use
	// this cloud VFS path so DXRP doesn't render a gray local model as a shell around the rig.
	public const string WorldModelPath = "models/bitminer/bitminer.vmdl";

	public const string HumSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitminer/server_hum.sound";
	public const string KeyboardSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitminer/keyboard.sound";
	public const string GlitchSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitminer/glitch.sound";
	public const string ErrorSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitminer/error.sound";
}
