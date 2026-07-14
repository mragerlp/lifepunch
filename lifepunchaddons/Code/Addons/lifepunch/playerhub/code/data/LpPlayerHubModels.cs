// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Player Hub for DXRP" (s&box ident: lifepunch.playerhub · addon ident: playerhub)
// ─────────────────────────────────────────────────────────────────────────────

using System;

namespace LifePunch.DXRP.Addons.PlayerHub;

/// <summary>
/// The hub's four top-level destinations. Category filters inside a tab are a
/// secondary filter, never a second top-level navigation system.
/// </summary>
public enum LpPlayerHubTab
{
	Overview,
	Skills,
	Store,
	Stats,
}

/// <summary>
/// Slice 1 shell view-model. Display-only.
/// </summary>
/// <remarks>
/// <para>
/// SLICE 1 IS FIXTURE-BACKED. Every value reaching this record today comes from
/// <see cref="LpPlayerHubFixture"/> and is NOT live player state. The hub renders a visible
/// PREVIEW marker while <see cref="IsFixture"/> is true so that a screenshot of this slice can
/// never be mistaken for live data. Slice 8 replaces the fixture with a real projection and the
/// marker disappears on its own, because it is bound to the flag rather than to a build constant.
/// </para>
/// <para>
/// LpBalance is READ-ONLY here. No spend path, no mutation, and no optimistic deduction exists in
/// this slice -- the debit rails do not open until Slice 6, which is an atomicity/idempotency
/// design slice under existing economy law, NOT a plumbing slice.
/// </para>
/// </remarks>
public sealed record LpPlayerHubShellVm(
	string PlayerName,
	string RankLabel,
	int Level,
	long LpBalance,
	LpPlayerHubTab ActiveTab,
	int SkillsBadgeCount,
	bool IsFixture );

/// <summary>
/// The Slice 1 stand-in for a live data source.
/// </summary>
/// <remarks>
/// Named "Fixture", not "Default" or "Sample", on purpose: a fixture announces that it is not real.
/// Absence of a contract is a blocker, not permission to invent a local substitute -- these numbers
/// exist to exercise the SHELL's layout and nothing else. They are not a progression model, they are
/// not a balance, and no other slice may read them.
/// </remarks>
public static class LpPlayerHubFixture
{
	public static LpPlayerHubShellVm Shell( LpPlayerHubTab activeTab ) => new(
		PlayerName: "PLAYER",
		RankLabel: "Member",
		Level: 24,
		LpBalance: 1280,
		ActiveTab: activeTab,
		SkillsBadgeCount: 2,
		IsFixture: true );
}

/// <summary>
/// Tab presentation metadata. Kept beside the enum so a new tab cannot be added without giving it a
/// label and a glyph.
/// </summary>
public static class LpPlayerHubTabInfo
{
	public static string Label( LpPlayerHubTab tab ) => tab switch
	{
		LpPlayerHubTab.Overview => "Overview",
		LpPlayerHubTab.Skills => "Skills",
		LpPlayerHubTab.Store => "$LP Store",
		LpPlayerHubTab.Stats => "Stats",
		_ => tab.ToString(),
	};

	/// <summary>Material icon ligature. Glyphs sit inline and bare -- never in an icon tile.</summary>
	public static string Icon( LpPlayerHubTab tab ) => tab switch
	{
		LpPlayerHubTab.Overview => "dashboard",
		LpPlayerHubTab.Skills => "account_tree",
		LpPlayerHubTab.Store => "storefront",
		LpPlayerHubTab.Stats => "insights",
		_ => "circle",
	};

	/// <summary>Eyebrow shown above the page title in the content region.</summary>
	public static string Eyebrow( LpPlayerHubTab tab ) => tab switch
	{
		LpPlayerHubTab.Overview => "OVERVIEW",
		LpPlayerHubTab.Skills => "SKILLS",
		LpPlayerHubTab.Store => "$LP STORE",
		LpPlayerHubTab.Stats => "PLAYER STATS",
		_ => string.Empty,
	};

	public static string Blurb( LpPlayerHubTab tab ) => tab switch
	{
		LpPlayerHubTab.Overview => "Your progression, currency and next available actions.",
		LpPlayerHubTab.Skills => "Select a track, inspect requirements, then unlock with skill points.",
		LpPlayerHubTab.Store => "Spend earned $LP on cosmetics and approved non-combat perks.",
		LpPlayerHubTab.Stats => "Activity recorded across LIFEPUNCH systems.",
		_ => string.Empty,
	};
}
