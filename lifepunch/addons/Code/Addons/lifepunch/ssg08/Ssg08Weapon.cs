// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "SSG 08" (s&box ident: lifepunch.ssg08 · addon ident: ssg08) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.Ssg08;

/// <summary>Runtime weapon state stub â€” tune stats in Ssg08.cs, wire prefab Functions in editor.</summary>
public sealed class Ssg08Weapon : Component
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
		ClipContents = Ssg08.Stats.MagazineSize;
		ReserveAmmo = Ssg08.Stats.ReserveAmmo;
		IsReloading = false;
	}
}