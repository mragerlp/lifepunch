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
	int SkillRanksPurchased,
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
	LpStatsIdentityVm Identity,
	IReadOnlyList<LpStatHighlightVm> Highlights,
	IReadOnlyList<LpStatSectionVm> Sections);

public sealed record LpStatPlateVm(
	string Icon,
	string Label,
	string Value,
	string Hint);

public sealed record LpStatsIdentityVm(
	int Level,
	string PlaytimeTitle,
	string TitleHint,
	string StatusLabel,
	string StatusHint,
	IReadOnlyList<LpStatsTrackProgressVm> Tracks);

public sealed record LpStatsTrackProgressVm(
	string Id,
	string Label,
	int RanksPurchased,
	int TotalRanks);

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

public enum LpSkillState
{
	Locked,
	Available,
	Unlocked,
	Maxed,
}

public enum LpSkillTierState
{
	Locked,
	Next,
	Earned,
}

public sealed record LpSkillsVm(
	bool IsFixture,
	string CatalogVersion,
	int SkillPointsAvailable,
	int TracksMastered,
	bool GrandMasteryActive,
	IReadOnlyList<LpSkillTrackVm> Tracks,
	IReadOnlyList<LpSkillVm> Skills,
	string SelectedTrackId,
	string SelectedSkillId);

public sealed record LpSkillTrackVm(
	string Id,
	string Label,
	string Description,
	string Icon,
	int RanksPurchased,
	int TotalRanks,
	int SkillsMastered,
	string KeystoneTitle,
	string KeystoneEffect,
	bool KeystoneActive,
	Action? OnSelected);

public sealed record LpSkillVm(
	string Id,
	string TrackId,
	string Title,
	string Description,
	string CurrentEffect,
	string NextTierEffect,
	IReadOnlyList<LpSkillTierVm> Tiers,
	int Rank,
	int MaxRank,
	int PointCost,
	bool CanUnlock,
	LpSkillState State,
	string Requirement,
	Action? OnSelected);

public sealed record LpSkillTierVm(
	int Rank,
	string Label,
	string Effect,
	LpSkillTierState State);

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
	private const int ResilienceRanksPurchased = 2;

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
		SkillRanksPurchased: 2,
		NextUnlockLabel: "Resilience slot 1 - Tier III",
		EarnRoutes: new[]
		{
			new LpEarnRouteVm(
				Icon: "route",
				Title: "Gameplay route",
				Body: "No approved play-earned $LP source is wired.",
				RewardHint: "HOOK NEEDED"),
			new LpEarnRouteVm(
				Icon: "event_busy",
				Title: "Event route",
				Body: "Eligibility and settlement remain owner decisions.",
				RewardHint: "OWNER DECISION"),
			new LpEarnRouteVm(
				Icon: "verified_user",
				Title: "Progression route",
				Body: "No authoritative award ledger exists in this slice.",
				RewardHint: "CONTRACT PENDING"),
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
				Detail: "Browse the Skills tab to inspect tier requirements",
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
			new LpStatPlateVm( Icon: "trending_up", Label: "Total XP", Value: "58,750", Hint: "Fixture total" ),
			new LpStatPlateVm( Icon: "account_tree", Label: "Skill ranks", Value: "2", Hint: "Fixture ranks" ),
			new LpStatPlateVm( Icon: "savings", Label: "$LP earned", Value: "--", Hint: "No award ledger" ),
		},
		Identity: new LpStatsIdentityVm(
			Level: Level,
			PlaytimeTitle: "Fixture Veteran",
			TitleHint: "Preview title - portal contract pending",
			StatusLabel: "Clean Player",
			StatusHint: "Fixture conduct status",
			Tracks: BuildStatsTracks()),
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
					new LpStatRowVm( Label: "$LP earned", Value: "--", Hint: "No award ledger" ),
					new LpStatRowVm( Label: "Store purchases", Value: "--", Hint: "Slice 6 not open" ),
				}),
			new LpStatSectionVm(
				Title: "PROGRESSION",
				Rows: new[]
				{
					new LpStatRowVm( Label: "Current level", Value: Level.ToString(), Hint: "Fixture" ),
					new LpStatRowVm( Label: "Skill ranks", Value: "2", Hint: "Fixture" ),
					new LpStatRowVm( Label: "Available points", Value: SkillPointsAvailable.ToString(), Hint: "Fixture" ),
				}),
		});

	private static IReadOnlyList<LpStatsTrackProgressVm> BuildStatsTracks()
	{
		var catalogTracks = LpPlayerHubCatalog.Tracks;
		var tracks = new List<LpStatsTrackProgressVm>( catalogTracks.Count );

		for ( var trackIndex = 0; trackIndex < catalogTracks.Count; trackIndex++ )
		{
			var catalogTrack = catalogTracks[trackIndex];
			var totalRanks = 0;

			foreach ( var skill in catalogTrack.Skills )
			{
				totalRanks += skill.Tiers.Count;
			}

			tracks.Add( new LpStatsTrackProgressVm(
				Id: catalogTrack.Id,
				Label: catalogTrack.Label,
				RanksPurchased: trackIndex == 0 ? ResilienceRanksPurchased : 0,
				TotalRanks: totalRanks ));
		}

		return tracks;
	}

	public static LpSkillsVm Skills(
		string selectedTrackId,
		string selectedSkillId,
		Action<string> onTrackSelected,
		Action<string> onSkillSelected )
	{
		var catalogTracks = LpPlayerHubCatalog.Tracks;
		var firstCatalogTrack = catalogTracks[0];
		selectedTrackId = string.IsNullOrWhiteSpace( selectedTrackId )
			? firstCatalogTrack.Id
			: selectedTrackId;
		selectedSkillId = string.IsNullOrWhiteSpace( selectedSkillId )
			? firstCatalogTrack.Skills[0].Id
			: selectedSkillId;

		var tracks = new List<LpSkillTrackVm>( catalogTracks.Count );
		var skills = new List<LpSkillVm>();

		for ( var trackIndex = 0; trackIndex < catalogTracks.Count; trackIndex++ )
		{
			var catalogTrack = catalogTracks[trackIndex];
			var trackId = catalogTrack.Id;
			var firstSkillRank = trackIndex == 0 ? ResilienceRanksPurchased : 0;
			var totalRanks = 0;

			for ( var skillIndex = 0; skillIndex < catalogTrack.Skills.Count; skillIndex++ )
			{
				var catalogSkill = catalogTrack.Skills[skillIndex];
				var skillId = catalogSkill.Id;
				var rank = skillIndex == 0 ? firstSkillRank : 0;
				var state = SkillState( rank, skillIndex, firstSkillRank, catalogSkill.Tiers.Count );
				var tiers = ProjectSkillTiers(
					catalogSkill.Tiers,
					rank,
					state != LpSkillState.Locked );

				totalRanks += catalogSkill.Tiers.Count;
				skills.Add( new LpSkillVm(
					Id: catalogSkill.Id,
					TrackId: catalogSkill.TrackId,
					Title: catalogSkill.Title,
					Description: "Hook-backed skill definition pending owner approval.",
					CurrentEffect: CurrentEffect( rank ),
					NextTierEffect: NextTierEffect( catalogSkill, rank ),
					Tiers: tiers,
					Rank: rank,
					MaxRank: catalogSkill.Tiers.Count,
					PointCost: 1,
					CanUnlock: false,
					State: state,
					Requirement: state == LpSkillState.Locked
						? "Catalogue approval required"
						: "Progression contract pending",
					OnSelected: () => onSkillSelected( skillId )));
			}

			tracks.Add( new LpSkillTrackVm(
				Id: catalogTrack.Id,
				Label: catalogTrack.Label,
				Description: catalogTrack.Description,
				Icon: catalogTrack.Icon,
				RanksPurchased: firstSkillRank,
				TotalRanks: totalRanks,
				SkillsMastered: 0,
				KeystoneTitle: catalogTrack.Label + " " + catalogTrack.Keystone.Title,
				KeystoneEffect: "Category effect pending hook-backed catalogue approval.",
				KeystoneActive: false,
				OnSelected: () => onTrackSelected( trackId )));
		}

		return new LpSkillsVm(
			IsFixture: true,
			CatalogVersion: LpPlayerHubCatalog.Version,
			SkillPointsAvailable: SkillPointsAvailable,
			TracksMastered: 0,
			GrandMasteryActive: false,
			Tracks: tracks,
			Skills: skills,
			SelectedTrackId: selectedTrackId,
			SelectedSkillId: selectedSkillId);
	}

	private static LpSkillState SkillState(
		int rank,
		int skillIndex,
		int firstSkillRank,
		int maxRank )
	{
		if ( rank >= maxRank )
			return LpSkillState.Maxed;

		if ( rank > 0 )
			return LpSkillState.Unlocked;

		if ( skillIndex == 0 || (skillIndex == 1 && firstSkillRank > 0) )
			return LpSkillState.Available;

		return LpSkillState.Locked;
	}

	private static string CurrentEffect( int rank )
	{
		return rank > 0
			? "Fixture rank " + rank + ". No live modifier."
			: "Base behavior unchanged.";
	}

	private static string NextTierEffect( LpPlayerHubCatalogSkill skill, int rank )
	{
		return rank >= skill.Tiers.Count
			? "Tier V fixture complete."
			: "Tier " + skill.Tiers[rank].Rank + " values pending hook approval.";
	}

	private static IReadOnlyList<LpSkillTierVm> ProjectSkillTiers(
		IReadOnlyList<LpPlayerHubCatalogTier> catalogTiers,
		int purchasedRank,
		bool showNext )
	{
		var tiers = new List<LpSkillTierVm>( catalogTiers.Count );

		foreach ( var catalogTier in catalogTiers )
		{
			var state = catalogTier.Rank <= purchasedRank
				? LpSkillTierState.Earned
				: showNext && catalogTier.Rank == purchasedRank + 1
					? LpSkillTierState.Next
					: LpSkillTierState.Locked;

			tiers.Add( new LpSkillTierVm(
				Rank: catalogTier.Rank,
				Label: catalogTier.Label,
				Effect: "Hook-backed Tier " + catalogTier.Label + " value pending owner approval.",
				State: state ));
		}

		return tiers;
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

	public static string Blurb( LpPlayerHubTab tab ) => tab switch
	{
		LpPlayerHubTab.Overview => "Fixture-backed progression, currency and route-readiness placeholders.",
		LpPlayerHubTab.Skills => "Browse five tracks, independent skill ranks and mastery status.",
		LpPlayerHubTab.Store => "Browse the $LP preview catalog. Purchasing is not open.",
		LpPlayerHubTab.Stats => "Read-only fixture activity. Unknown lifetime data stays unknown.",
		_ => string.Empty,
	};
}
