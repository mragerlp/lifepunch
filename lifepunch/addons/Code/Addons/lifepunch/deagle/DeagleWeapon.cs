// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Desert Eagle" (s&box ident: lifepunch.deagle · addon ident: deagle) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.Deagle;

/// <summary>Runtime weapon state stub â€” tune stats in Deagle.cs, wire prefab Functions in editor.</summary>
public sealed class DeagleWeapon : Component
{
	public int ClipContents { get; private set; }
	public int ReserveAmmo { get; private set; }
	public bool IsReloading { get; private set; }

	protected override void OnAwake()
	{
		base.OnAwake();
		ResetAmmo();
	}

	public void ResetAmmo()
	{
		ClipContents = Deagle.Stats.MagazineSize;
		ReserveAmmo = Deagle.Stats.ReserveAmmo;
		IsReloading = false;
	}
}