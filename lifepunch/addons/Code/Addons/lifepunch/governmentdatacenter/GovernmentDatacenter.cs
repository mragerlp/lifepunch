// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Government Datacenter" (s&box ident: lifepunch.governmentdatacenter · addon ident: governmentdatacenter) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.GovernmentDatacenter;

/// <summary>
/// Government datacenter package — tax miners + police terminals.
/// Spec: <c>addons/docs/GOVERNMENT_DATABASE_SPEC.md</c>.
/// </summary>
public static class GovernmentDatacenter
{
	public const string Package = "lifepunch.governmentdatacenter";
	public const string Ident = "governmentdatacenter";
	public const string DisplayName = "Government Datacenter";
	public const string Description = "City treasury tax miners (always-on BTC) and lifepunchnet police terminals near govdb nodes.";

	public const string TaxMinerEntitySlug = "government-tax-miner";
	public const string TaxMinerDisplayName = "Government Tax Miner";
	public const string PoliceTerminalEntitySlug = "police-terminal";
	public const string PoliceTerminalDisplayName = "Police Terminal";
	public const string InGameProgramName = "lifepunch-ops.exe";

	public const string TaxMinerWorldPrefabPath = "addons/lifepunch/governmentdatacenter/entities/government-tax-miner/government-tax-miner.prefab";
	public const string TaxMinerWorldModelPath = "addons/lifepunch/governmentdatacenter/models/lifepunch/governmentdatacenter/government-tax-miner/government-tax-miner.vmdl";
	public const string PoliceTerminalWorldPrefabPath = "addons/lifepunch/governmentdatacenter/entities/police-terminal/police-terminal.prefab";
	public const string PoliceTerminalWorldModelPath = "addons/lifepunch/governmentdatacenter/models/lifepunch/governmentdatacenter/police-terminal/police-terminal.vmdl";

	/// <summary>lifepunchnet cyan — distinct from Cornerman green hashd and Vengeance red hacker rigs.</summary>
	public const string TerminalAccentHex = "#00D4FF";
	public const string TerminalBackgroundHex = "#0a0f12";
	public const string TerminalPrompt = "lifepunch@lifepunch.net:~$";
}
