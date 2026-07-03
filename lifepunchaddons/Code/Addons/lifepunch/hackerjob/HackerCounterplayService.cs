// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Failed-hack police counterplay — DXRP <c>/panic</c> (911 position ping) + optional Wanted status.
/// Detection upgrades on the server rack reduce trigger chance.
/// </summary>
public static class HackerCounterplayService
{
	/// <summary>Roll counterplay after a failed hack. Returns human-readable log line.</summary>
	public static string TryTriggerFailedHackAlert( HackerServerRackEntity rack, Vector3 suspectPosition )
	{
		if ( !rack.IsValid() )
			return "counterplay skipped — no server rack";

		var detectionTier = rack.DetectionTier;
		var chance = HackerUpgradeCatalog.GetDetectionAlertChance( detectionTier );
		if ( Game.Random.Float( 0f, 1f ) > chance )
			return $"counterplay suppressed — Detection L{detectionTier} ({(int)(chance * 100)}% roll missed)";

#if !LIFEPUNCH_LOCAL
		// Panic / 911 — clones red beacon at suspect position for police/medics (PanicCommand pattern).
		if ( GameManager.Instance.IsValid() )
			GameManager.Instance.BroadcastPanic( suspectPosition );

		// Wanted is a separate governance status — Phase 2: Governance.WantedHost when hacker identified.
		Log.Warning( $"[LIFEPUNCH Hacker] failed hack counterplay — panic broadcast at {suspectPosition}" );
		return "ALERT: 911 ping dispatched to government units.";
#else
		Log.Info( $"[LIFEPUNCH Hacker] counterplay stub — would BroadcastPanic at {suspectPosition} (Detection L{detectionTier})" );
		return "ALERT: 911 ping (local stub — DXRP build dispatches police marker).";
#endif
	}
}
