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

/// <summary>Owner canon HP — wire to prefab <c>HealthComponent.MaxHealth</c> on ModelDoc pass.</summary>
public static class BitcoinMiningCombatStats
{
	public const int HubMaxHealth = 250;
	public const int GpuRackMaxHealth = 500;
	public const int LargeGpuRackMaxHealth = 2000;

	public const int MaxHubsPerPlayer = 2;
	public const int MaxSmallRacksPerHub = 3;
	public const int MaxLargeRacksPerHub = 1;
}
