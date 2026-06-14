// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Miner" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using LifePunch.DXRP.Addons;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// LifePunch Bitcoin Miner package identity. Original LIFEPUNCH IP — see <c>addons/docs/BITCOINMINING_IP_DOCTRINE.md</c>.
/// World meshes: LifePunch-owned <c>gpu-rack</c> / <c>gpu-rack-stacked</c> / <c>bitcoin-miner</c> hub — self-contained addon paths only.
/// </summary>
public static class BitcoinMiningAddon
{
	public const string Package = "lifepunch.bitcoinmining";
	public const string Ident = "bitcoinmining";
	public const string PackageDisplayName = "Bitcoin Miner";

	public const string HubEntitySlug = "bitcoin-miner";
	public const string EntitySlug = "gpu-rack";
	public const string AdvancedEntitySlug = "large-gpu-rack";
	public const string TerminalEntitySlug = "bitcoin-terminal";
	public const string ModelSlug = "gpu-rack";
	public const string StackedModelSlug = "gpu-rack-stacked";
	public const string HubModelSlug = "bitcoin-miner";

	public const string HubDisplayName = "Bitcoin Miner";
	public const string DisplayName = "GPU Rack";
	public const string AdvancedDisplayName = "Large GPU Rack";
	public const string TerminalDisplayName = "Bitcoin Terminal";
	public const string Description = "Placeable GPU mining rack — controlled from the linked LIFEPUNCH Bitcoin Miner hub.";

	public const int ContentType = 0;
	public const string Grouping = "Entities";

	// LPaddons oneliner folders on disk; portal slugs stay dashed.
	public const string HubPrefabPath = "addons/lifepunch/bitcoinmining/entities/bitcoinminer/bitcoin-miner.prefab";
	public const string WorldPrefabPath = "addons/lifepunch/bitcoinmining/entities/gpurack/gpu-rack.prefab";
	public const string AdvancedPrefabPath = "addons/lifepunch/bitcoinmining/entities/largegpurack/large-gpu-rack.prefab";
	public const string TerminalPrefabPath = "addons/lifepunch/bitcoinmining/entities/bitcoin-terminal/bitcoin-terminal.prefab";
	public const string HubModelPath = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/bitcoin-miner.vmdl";
	public const string WorldModelPath = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/gpu-rack.vmdl";
	public const string StackedModelPath = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack/gpu-rack-stacked.vmdl";
	public const string TerminalModelPath = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-terminal/bitcoin-terminal.vmdl";
	public const string HubModelRoot = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner";
	public const string ModelRoot = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/gpu-rack";

	public const string PublisherMark = LifePunchSourceMark.Mark;
	public const string PublisherName = LifePunchSourceMark.Publisher;
	public const string PublisherUrl = LifePunchSourceMark.PublisherUrl;
	public const string ProductTitle = "LIFEPUNCH™ Bitcoin Miner for DXRP";
	public const string UiVersionFooter = "lifepunch.bitcoin v1.0.0 - lifepunch.co";
	public const string HashdProgramName = "hashd";

	/// <summary>Seconds between server-authoritative BTC payout ticks while mining (LifePunch economy tuning).</summary>
	public const float MiningPayoutIntervalSeconds = 90f;

	public const string KeyboardSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitcoinminer/keyboard.sound";
}
