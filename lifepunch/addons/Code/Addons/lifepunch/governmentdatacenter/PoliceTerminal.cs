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
/// Police job terminal identity (lifepunchnet ops). UI shell lands Phase 2 on Red.
/// Placed near <see cref="GovernmentTaxMiner"/> nodes for counter-intrusion / audit flows.
/// </summary>
public static class PoliceTerminal
{
	public const string DevUiCommand = "lp_lifepunch_ops_ui";
	public const string DevSpawnCommand = "lp_spawn_police_terminal";
	public const string KeyboardSoundPath = "addons/lifepunch/governmentdatacenter/sounds/police-terminal/keyboard.sound";
}
