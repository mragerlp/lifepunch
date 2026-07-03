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
using System.Collections.Generic;
using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Explicit server rack ↔ terminal links via <see cref="HackerTerminalEntity.LinkedRack"/> (no proximity auto-link).
/// </summary>
public static class HackerServerRackRegistry
{
	public static HackerServerRackEntity FindRackForTerminal( HackerTerminalEntity terminal )
	{
		return terminal.IsValid() ? terminal.ResolveLinkedRack() : null;
	}

	public static IReadOnlyList<HackerTerminalEntity> GetLinkedTerminals( HackerServerRackEntity rack )
	{
		if ( !rack.IsValid() || rack.Scene is null )
			return Array.Empty<HackerTerminalEntity>();

		return rack.Scene.GetAllComponents<HackerTerminalEntity>()
			.Where( t => t.IsValid() && t.ResolveLinkedRack() == rack )
			.ToList();
	}

	public static bool IsTerminalPowered( HackerTerminalEntity terminal )
	{
		var rack = FindRackForTerminal( terminal );
		return rack.IsValid() && rack.IsPowered;
	}

	/// <summary>Terminals not linked to any rack; tier-matched to this rack when possible.</summary>
	public static IReadOnlyList<HackerTerminalEntity> ScanUnlinkedTerminals( HackerServerRackEntity rack )
	{
		if ( !rack.IsValid() || rack.Scene is null )
			return Array.Empty<HackerTerminalEntity>();

		var preferAdvanced = rack.RackTier == HackerRackTier.Advanced;
		var list = new List<HackerTerminalEntity>();

		foreach ( var terminal in rack.Scene.GetAllComponents<HackerTerminalEntity>() )
		{
			if ( !terminal.IsValid() || terminal.ResolveLinkedRack().IsValid() )
				continue;

			if ( terminal.IsAdvanced != preferAdvanced )
				continue;

			list.Add( terminal );
		}

		if ( list.Count == 0 )
		{
			foreach ( var terminal in rack.Scene.GetAllComponents<HackerTerminalEntity>() )
			{
				if ( !terminal.IsValid() || terminal.ResolveLinkedRack().IsValid() )
					continue;

				list.Add( terminal );
			}
		}

		return list.OrderBy( t => t.GameObject.Name ).ToList();
	}

	public static bool TryLinkTerminal( HackerServerRackEntity rack, HackerTerminalEntity terminal, out string error )
	{
		error = null;

		if ( !rack.IsValid() || !terminal.IsValid() )
		{
			error = "Invalid rack or terminal.";
			return false;
		}

		var existing = terminal.ResolveLinkedRack();
		if ( existing.IsValid() && existing != rack )
		{
			error = "Terminal is linked to another rack — unlink first.";
			return false;
		}

		terminal.SetLinkedRackHost( rack );
		return true;
	}

	public static void UnlinkAllFromRack( HackerServerRackEntity rack )
	{
		if ( !rack.IsValid() || rack.Scene is null )
			return;

		foreach ( var terminal in GetLinkedTerminals( rack ) )
			terminal.ClearLinkedRackHost();
	}

	public static bool TryUnlinkTerminalAt( HackerServerRackEntity rack, int index, out string error )
	{
		error = null;
		var linked = GetLinkedTerminals( rack ).ToList();
		if ( index < 0 || index >= linked.Count )
		{
			error = "Invalid unlink index.";
			return false;
		}

		linked[index].ClearLinkedRackHost();
		return true;
	}

	public static string GetTerminalLabel( HackerTerminalEntity terminal ) =>
		terminal.IsValid()
			? ( terminal.IsAdvanced ? HackerJob.AdvancedDisplayName : HackerJob.DisplayName ) + $" ({terminal.GameObject.Name})"
			: "terminal";
}
