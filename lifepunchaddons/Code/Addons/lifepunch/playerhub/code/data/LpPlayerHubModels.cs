// -----------------------------------------------------------------------------
// PROPRIETARY & CONFIDENTIAL - (c) 2026 lifepunch.co. All rights reserved.
//
// LIFEPUNCH Player Hub for DXRP
// s&box ident: lifepunch.playerhub
// addon ident: playerhub
// -----------------------------------------------------------------------------

using System;
using System.Collections.Generic;

namespace LifePunch.DXRP.Addons.PlayerHub;

public enum LpPlayerHubTab
{
	Overview,
	Skills,
	Store,
	Stats,
}

public sealed record LpPlayerHubShellVm(
	string PlayerName,
	string RankLabel,
	int Level,
	long LpBalance,
	LpPlayerHubTab ActiveTab,
	int SkillsBadgeCount,
	bool IsFixture);

/// <summary>
/// Repository-proven callback carrier. Razor children receive this model through
/// [Property], then bind the parameterless action directly to onclick.
/// </summary>
public sealed record LpHubActionVm(
	string Id,
	string Label,
	string Icon,
	string Hint,
	bool Enabled,
	Action? OnSelected);

public sealed record LpOverviewVm(
	bool IsFixture,
	long LpBalance,
	int Level,
	int XpIntoLevel,
	int XpForNextLevel,
	int SkillPointsAvailable,
	int SkillsUnlocked,
	string NextUnlockLabel,
	IReadOnlyList<LpEarnRouteVm> EarnRoutes,
	IReadOnlyList<LpRecentProgressVm> RecentEvents,
	IReadOnlyList<LpOverviewStatVm> StatSnapshot,
	IReadOnlyList<LpHubActionVm> Actions);

public sealed record LpEarnRouteVm(
	string Icon,
	string Title,
	string Body,
	string RewardHint);

public sealed record LpRecentProgressVm(
	string Icon,
	string Title,
	string Detail,
	string When);

public sealed record LpOverviewStatVm(
	string Label,
	string Value,
	string Hint);

public sealed record LpStatsVm(
	bool IsFixture,
	IReadOnlyList<LpStatPlateVm> HeroPlates,
	IReadOnlyList<LpActivityBarVm> ActivityTrend,
	string ActivitySummary,
	IReadOnlyList<LpStatHighlightVm> Highlights,
	IReadOnlyList<LpStatSectionVm> Sections);

public sealed record LpStatPlateVm(
	string Icon,
	string Label,
	string Value,
	string Hint);

public sealed record LpActivityBarVm(
	string Label,
	int Percent,
	string Value);

public sealed record LpStatHighlightVm(
	string Label,
	string Value,
	string Hint);

public sealed record LpStatSectionVm(
	string Title,
	IReadOnlyList<LpStatRowVm> Rows);

public sealed record LpStatRowVm(
	string Label,
	string Value,
	string Hint);

public enum LpSkillNodeState
{
	Locked,
	Available,
	Unlocked,
	Maxed,
}

public sealed record LpSkillsVm(
	bool IsFixture,
	int SkillPointsAvailable,
	IReadOnlyList<LpSkillTrackVm> Tracks,
	IReadOnlyList<LpSkillNodeVm> Nodes,
	string SelectedTrackId,
	string SelectedNodeId);

public sealed record LpSkillTrackVm(
	string Id,
	string Label,
	string Description,
	string Icon,
	Action? OnSelected);

public sealed record LpSkillNodeVm(
	string Id,
	string TrackId,
	string Title,
	string Description,
	string Effect,
	int Tier,
	int Rank,
	int MaxRank,
	int PointCost,
	bool CanUnlock,
	LpSkillNodeState State,
	string Requirement,
	Action? OnSelected);

public sealed record LpStoreVm(
	bool IsFixture,
	long LpBalance,
	IReadOnlyList<LpStoreCategoryVm> Categories,
	IReadOnlyList<LpStoreItemVm> Items,
	string SelectedCategoryId,
	string SelectedItemId);

public sealed record LpStoreCategoryVm(
	string Id,
	string Label,
	string Icon,
	Action? OnSelected);

public sealed record LpStoreItemVm(
	string Id,
	string Title,
	string Description,
	string CategoryId,
	string Icon,
	string DurationLabel,
	string CombatImpact,
	long PriceLp,
	bool Owned,
	bool Affordable,
	Action? OnSelected);

public sealed record LpHubStateVm(
	string Icon,
	string Title,
	string Message,
	string ActionLabel,
	bool ShowAction,
	Action? OnSelected);

/// <summary>
/// Deterministic display fixtures for Slices 1-5. They exercise layout and
/// selection only; none of these values are a live progression or economy seam.
/// </summary>
public static class LpPlayerHubFixture
{
	public const int Level = 24;
	public const long LpBalance = 1280;
	public const int SkillPointsAvailable = 2;

	public static LpPlayerHubShellVm Shell( LpPlayerHubTab activeTab ) => new(
		PlayerName: "PLAYER",
		RankLabel: "Member",
		Level: Level,
		LpBalance: LpBalance,
		ActiveTab: activeTab,
		SkillsBadgeCount: SkillPointsAvailable,
		IsFixture: true);

	public static LpOverviewVm Overview( IReadOnlyList<LpHubActionVm> actions ) => new(
		IsFixture: true,
		LpBalance: LpBalance,
		Level: Level,
		XpIntoLevel: 3750,
		XpForNextLevel: 5000,
		SkillPointsAvailable: SkillPointsAvailable,
		SkillsUnlocked: 2,
		NextUnlockLabel: "Quick Draw - Tier II",
		EarnRoutes: new[]
		{
			new LpEarnRouteVm(
				Icon: "work",
				Title: "Stay active on a job",
				Body: "Complete normal job loops and server objectives.",
				RewardHint: "Play-earned route"),
			new LpEarnRouteVm(
				Icon: "groups",
				Title: "Join server events",
				Body: "Participate in scheduled events and community rounds.",
				RewardHint: "Event reward preview"),
			new LpEarnRouteVm(
				Icon: "verified",
				Title: "Finish progression goals",
				Body: "Advance approved tracks without a real-money shortcut.",
				RewardHint: "Progress reward preview"),
		},
		RecentEvents: new[]
		{
			new LpRecentProgressVm(
				Icon: "trending_up",
				Title: "Level progress",
				Detail: "+420 XP from active play",
				When: "This session"),
			new LpRecentProgressVm(
				Icon: "account_tree",
				Title: "Skill point available",
				Detail: "Browse the Skills tab to inspect eligible nodes",
				When: "Preview"),
		},
		StatSnapshot: new[]
		{
			new LpOverviewStatVm( Label: "Sessions", Value: "18", Hint: "Fixture snapshot" ),
			new LpOverviewStatVm( Label: "Jobs completed", Value: "46", Hint: "Fixture snapshot" ),
			new LpOverviewStatVm( Label: "Event entries", Value: "12", Hint: "Fixture snapshot" ),
		},
		Actions: actions);

	public static LpStatsVm Stats() => new(
		IsFixture: true,
		HeroPlates: new[]
		{
			new LpStatPlateVm( Icon: "schedule", Label: "Play time", Value: "42h 18m", Hint: "Fixture total" ),
			new LpStatPlateVm( Icon: "work", Label: "Jobs", Value: "46", Hint: "Completed" ),
			new LpStatPlateVm( Icon: "groups", Label: "Events", Value: "12", Hint: "Joined" ),
			new LpStatPlateVm( Icon: "bolt", Label: "Current streak", Value: "4", Hint: "Active sessions" ),
		},
		ActivityTrend: new[]
		{
			new LpActivityBarVm( Label: "Mon", Percent: 32, Value: "32m" ),
			new LpActivityBarVm( Label: "Tue", Percent: 58, Value: "58m" ),
			new LpActivityBarVm( Label: "Wed", Percent: 44, Value: "44m" ),
			new LpActivityBarVm( Label: "Thu", Percent: 76, Value: "1h 16m" ),
			new LpActivityBarVm( Label: "Fri", Percent: 64, Value: "1h 04m" ),
			new LpActivityBarVm( Label: "Sat", Percent: 92, Value: "1h 32m" ),
			new LpActivityBarVm( Label: "Sun", Percent: 51, Value: "51m" ),
		},
		ActivitySummary: "Fixture activity over the last seven sessions. No lifetime ledger is claimed.",
		Highlights: new[]
		{
			new LpStatHighlightVm( Label: "Most active lane", Value: "Public service", Hint: "Fixture category" ),
			new LpStatHighlightVm( Label: "Longest session", Value: "2h 14m", Hint: "Fixture duration" ),
			new LpStatHighlightVm( Label: "Unknown lifetime data", Value: "--", Hint: "No source contract" ),
		},
		Sections: new[]
		{
			new LpStatSectionVm(
				Title: "ACTIVITY",
				Rows: new[]
				{
					new LpStatRowVm( Label: "Sessions joined", Value: "18", Hint: "Fixture" ),
					new LpStatRowVm( Label: "Objectives completed", Value: "31", Hint: "Fixture" ),
					new LpStatRowVm( Label: "Average session", Value: "1h 08m", Hint: "Fixture" ),
				}),
			new LpStatSectionVm(
				Title: "ECONOMY",
				Rows: new[]
				{
					new LpStatRowVm( Label: "Jobs completed", Value: "46", Hint: "Fixture" ),
					new LpStatRowVm( Label: "$LP earned", Value: "1,280", Hint: "Preview only" ),
					new LpStatRowVm( Label: "Store purchases", Value: "--", Hint: "Slice 6 not open" ),
				}),
			new LpStatSectionVm(
				Title: "PROGRESSION",
				Rows: new[]
				{
					new LpStatRowVm( Label: "Current level", Value: Level.ToString(), Hint: "Fixture" ),
					new LpStatRowVm( Label: "Skills unlocked", Value: "7", Hint: "Fixture" ),
					new LpStatRowVm( Label: "Available points", Value: SkillPointsAvailable.ToString(), Hint: "Fixture" ),
				}),
		});

	public static LpSkillsVm Skills(
		string selectedTrackId,
		string selectedNodeId,
		Action<string> onTrackSelected,
		Action<string> onNodeSelected )
	{
		selectedTrackId = string.IsNullOrWhiteSpace( selectedTrackId ) ? "fieldcraft" : selectedTrackId;
		selectedNodeId = string.IsNullOrWhiteSpace( selectedNodeId ) ? "steady-hands" : selectedNodeId;

		return new LpSkillsVm(
			IsFixture: true,
			SkillPointsAvailable: SkillPointsAvailable,
			Tracks: new[]
			{
				new LpSkillTrackVm(
					Id: "fieldcraft",
					Label: "Fieldcraft",
					Description: "Handling and situational discipline.",
					Icon: "track_changes",
					OnSelected: () => onTrackSelected( "fieldcraft" )),
				new LpSkillTrackVm(
					Id: "enterprise",
					Label: "Enterprise",
					Description: "Earn routes and operational efficiency.",
					Icon: "business_center",
					OnSelected: () => onTrackSelected( "enterprise" )),
				new LpSkillTrackVm(
					Id: "support",
					Label: "Support",
					Description: "Team utility and recovery awareness.",
					Icon: "handshake",
					OnSelected: () => onTrackSelected( "support" )),
			},
			Nodes: new[]
			{
				new LpSkillNodeVm(
					Id: "steady-hands",
					TrackId: "fieldcraft",
					Title: "Steady Hands",
					Description: "Baseline handling discipline.",
					Effect: "Preview: reduced handling variance.",
					Tier: 1,
					Rank: 1,
					MaxRank: 1,
					PointCost: 1,
					CanUnlock: false,
					State: LpSkillNodeState.Maxed,
					Requirement: "Complete",
					OnSelected: () => onNodeSelected( "steady-hands" )),
				new LpSkillNodeVm(
					Id: "quick-draw",
					TrackId: "fieldcraft",
					Title: "Quick Draw",
					Description: "Improves readiness after switching equipment.",
					Effect: "Preview: faster ready cadence.",
					Tier: 2,
					Rank: 0,
					MaxRank: 1,
					PointCost: 1,
					CanUnlock: true,
					State: LpSkillNodeState.Available,
					Requirement: "Steady Hands",
					OnSelected: () => onNodeSelected( "quick-draw" )),
				new LpSkillNodeVm(
					Id: "prepared-kit",
					TrackId: "fieldcraft",
					Title: "Prepared Kit",
					Description: "Adds a higher-tier readiness option.",
					Effect: "Preview contract pending.",
					Tier: 3,
					Rank: 0,
					MaxRank: 1,
					PointCost: 2,
					CanUnlock: false,
					State: LpSkillNodeState.Locked,
					Requirement: "Quick Draw",
					OnSelected: () => onNodeSelected( "prepared-kit" )),
				new LpSkillNodeVm(
					Id: "route-reading",
					TrackId: "fieldcraft",
					Title: "Route Reading",
					Description: "Higher-tier situational planning.",
					Effect: "Preview contract pending.",
					Tier: 4,
					Rank: 0,
					MaxRank: 1,
					PointCost: 2,
					CanUnlock: false,
					State: LpSkillNodeState.Locked,
					Requirement: "Prepared Kit",
					OnSelected: () => onNodeSelected( "route-reading" )),
				new LpSkillNodeVm(
					Id: "field-master",
					TrackId: "fieldcraft",
					Title: "Field Master",
					Description: "Final fixture tier for the fieldcraft track.",
					Effect: "Preview contract pending.",
					Tier: 5,
					Rank: 0,
					MaxRank: 1,
					PointCost: 3,
					CanUnlock: false,
					State: LpSkillNodeState.Locked,
					Requirement: "Route Reading",
					OnSelected: () => onNodeSelected( "field-master" )),
				new LpSkillNodeVm(
					Id: "job-rhythm",
					TrackId: "enterprise",
					Title: "Job Rhythm",
					Description: "Recognizes consistent job participation.",
					Effect: "Preview: progression route visibility.",
					Tier: 1,
					Rank: 1,
					MaxRank: 1,
					PointCost: 1,
					CanUnlock: false,
					State: LpSkillNodeState.Unlocked,
					Requirement: "Complete",
					OnSelected: () => onNodeSelected( "job-rhythm" )),
				new LpSkillNodeVm(
					Id: "operations",
					TrackId: "enterprise",
					Title: "Operations",
					Description: "Inspects a future efficiency branch.",
					Effect: "Preview contract pending.",
					Tier: 2,
					Rank: 0,
					MaxRank: 1,
					PointCost: 1,
					CanUnlock: false,
					State: LpSkillNodeState.Locked,
					Requirement: "Job Rhythm",
					OnSelected: () => onNodeSelected( "operations" )),
				new LpSkillNodeVm(
					Id: "first-response",
					TrackId: "support",
					Title: "First Response",
					Description: "Surfaces the support progression lane.",
					Effect: "Preview: team utility awareness.",
					Tier: 1,
					Rank: 0,
					MaxRank: 1,
					PointCost: 1,
					CanUnlock: true,
					State: LpSkillNodeState.Available,
					Requirement: "Level 20",
					OnSelected: () => onNodeSelected( "first-response" )),
			},
			SelectedTrackId: selectedTrackId,
			SelectedNodeId: selectedNodeId);
	}

	public static LpStoreVm Store(
		string selectedCategoryId,
		string selectedItemId,
		Action<string> onCategorySelected,
		Action<string> onItemSelected )
	{
		selectedCategoryId = string.IsNullOrWhiteSpace( selectedCategoryId ) ? "all" : selectedCategoryId;
		selectedItemId = string.IsNullOrWhiteSpace( selectedItemId ) ? "identity-banner" : selectedItemId;

		return new LpStoreVm(
			IsFixture: true,
			LpBalance: LpBalance,
			Categories: new[]
			{
				new LpStoreCategoryVm(
					Id: "all",
					Label: "All",
					Icon: "apps",
					OnSelected: () => onCategorySelected( "all" )),
				new LpStoreCategoryVm(
					Id: "identity",
					Label: "Identity",
					Icon: "badge",
					OnSelected: () => onCategorySelected( "identity" )),
				new LpStoreCategoryVm(
					Id: "utility",
					Label: "Utility",
					Icon: "construction",
					OnSelected: () => onCategorySelected( "utility" )),
			},
			Items: new[]
			{
				new LpStoreItemVm(
					Id: "identity-banner",
					Title: "Blue Identity Banner",
					Description: "A profile presentation option for approved hub surfaces.",
					CategoryId: "identity",
					Icon: "flag",
					DurationLabel: "Permanent entitlement preview",
					CombatImpact: "None",
					PriceLp: 450,
					Owned: false,
					Affordable: true,
					OnSelected: () => onItemSelected( "identity-banner" )),
				new LpStoreItemVm(
					Id: "member-frame",
					Title: "Member Frame",
					Description: "A restrained profile-frame treatment.",
					CategoryId: "identity",
					Icon: "account_box",
					DurationLabel: "Permanent entitlement preview",
					CombatImpact: "None",
					PriceLp: 900,
					Owned: true,
					Affordable: true,
					OnSelected: () => onItemSelected( "member-frame" )),
				new LpStoreItemVm(
					Id: "job-route-card",
					Title: "Job Route Card",
					Description: "A future convenience surface with no power advantage.",
					CategoryId: "utility",
					Icon: "map",
					DurationLabel: "Feature contract pending",
					CombatImpact: "None",
					PriceLp: 1600,
					Owned: false,
					Affordable: false,
					OnSelected: () => onItemSelected( "job-route-card" )),
				new LpStoreItemVm(
					Id: "event-ticket",
					Title: "Event Ticket Preview",
					Description: "Illustrates a time-limited catalog row; settlement is not open.",
					CategoryId: "utility",
					Icon: "confirmation_number",
					DurationLabel: "7 day preview",
					CombatImpact: "None",
					PriceLp: 300,
					Owned: false,
					Affordable: true,
					OnSelected: () => onItemSelected( "event-ticket" )),
			},
			SelectedCategoryId: selectedCategoryId,
			SelectedItemId: selectedItemId);
	}
}

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

	public static string Icon( LpPlayerHubTab tab ) => tab switch
	{
		LpPlayerHubTab.Overview => "dashboard",
		LpPlayerHubTab.Skills => "account_tree",
		LpPlayerHubTab.Store => "storefront",
		LpPlayerHubTab.Stats => "insights",
		_ => "circle",
	};

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
		LpPlayerHubTab.Overview => "Fixture-backed progression, currency and play-earned routes.",
		LpPlayerHubTab.Skills => "Browse tracks and node requirements. Point spending is not open.",
		LpPlayerHubTab.Store => "Browse the $LP preview catalog. Purchasing is not open.",
		LpPlayerHubTab.Stats => "Read-only fixture activity. Unknown lifetime data stays unknown.",
		_ => string.Empty,
	};
}
