// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// LifePunch Bitcoin Miner package identity. Pattern reference: <c>reference/evo-bitminer/</c> (study only).
/// World mesh is LifePunch-owned <c>gpu-rack</c> — not third-party cloud paths.
/// </summary>
public static class Bitminer
{
	public const string Package = "lifepunch.bitcoinmining";
	public const string Ident = "bitcoinmining";
	public const string EntitySlug = "bitcoin-miner";
	public const string ModelSlug = "gpu-rack";
	public const string DisplayName = "Bitcoin Miner";
	public const string Description = "A placeable GPU mining rig. Interact for the LIFEPUNCH hashd terminal — mine, upgrade, sell.";

	public const int ContentType = 0;
	public const string Grouping = "Entities";

	public const string WorldPrefabPath = "addons/lifepunch/bitcoinmining/entities/bitcoin-miner/bitcoin-miner.prefab";
	public const string WorldModelPath = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/gpu-rack.vmdl";
	public const string ModelRoot = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack";

	public const string HumSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitcoin-miner/server-hum.sound";
	public const string KeyboardSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitcoin-miner/keyboard.sound";
	public const string GlitchSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitcoin-miner/glitch.sound";
	public const string ErrorSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitcoin-miner/error.sound";
}
