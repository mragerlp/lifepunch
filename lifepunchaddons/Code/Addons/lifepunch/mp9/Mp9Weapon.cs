// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "MP9" (s&box ident: lifepunch.mp9 · addon ident: mp9) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.Mp9;

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

	public bool TrySpendRound()
	{
		if ( IsReloading || ClipContents <= 0 )
			return false;

		ClipContents--;
		return true;
	}

	public bool TryStartReload()
	{
		if ( !CanReload )
			return false;

		IsReloading = true;
		return true;
	}

	public void FinishReload()
	{
		if ( !IsReloading )
			return;

		var needed = Mp9.Stats.MagazineSize - ClipContents;
		var loaded = System.Math.Min( needed, ReserveAmmo );

		ClipContents += loaded;
		ReserveAmmo -= loaded;
		IsReloading = false;
	}

	public void CancelReload()
	{
		IsReloading = false;
	}

	public bool CanReload => !IsReloading
		&& ClipContents < Mp9.Stats.MagazineSize
		&& ReserveAmmo > 0;

	public float SecondsBetweenShots => Mp9.Stats.SecondsBetweenShots;
}
