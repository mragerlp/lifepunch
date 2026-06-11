// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "MP9" (s&box ident: lifepunch.mp9 · addon ident: mp9) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.Mp9;

/// <summary>Runtime weapon state stub â€” tune stats in Mp9.cs, wire prefab Functions in editor.</summary>
public sealed class Mp9Weapon : Component
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
		ClipContents = Mp9.Stats.MagazineSize;
		ReserveAmmo = Mp9.Stats.ReserveAmmo;
		IsReloading = false;
	}
}