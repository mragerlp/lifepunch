// -----------------------------------------------------------------------------
// PROPRIETARY & CONFIDENTIAL - (c) 2026 lifepunch.co. All rights reserved.
//
// LIFEPUNCH Player Hub for DXRP
// s&box ident: lifepunch.playerhub
// addon ident: playerhub
// -----------------------------------------------------------------------------

using System.Collections.Generic;

namespace LifePunch.DXRP.Addons.PlayerHub;

public sealed record LpPlayerHubCatalogTier(
	int Rank,
	string Label,
	string State,
	string EffectState);

public sealed record LpPlayerHubCatalogSkill(
	string Id,
	string TrackId,
	string Title,
	IReadOnlyList<LpPlayerHubCatalogTier> Tiers,
	string EffectState,
	string CategoryCapState,
	string SeamState,
	string OwnerState);

public sealed record LpPlayerHubCatalogKeystone(
	string Title,
	string State,
	string EffectState,
	string SeamState,
	string OwnerState);

public sealed record LpPlayerHubCatalogTrack(
	string Id,
	string Label,
	string Description,
	string Icon,
	LpPlayerHubCatalogKeystone Keystone,
	IReadOnlyList<LpPlayerHubCatalogSkill> Skills);

/// <summary>
/// Fixture-only catalog identity. All effects, caps, seams, and keystones remain
/// non-live until an owner-authored catalog version replaces fixture-v0.
/// </summary>
public static class LpPlayerHubCatalog
{
	public const string Version = "fixture-v0";
	public const string TierPendingState = "pending";
	public const string KeystonePlaceholderState = "placeholder";
	public const string SeamUnmappedState = "unmapped";
	public const string OwnerHeldState = "HELD-ruling-7";
	public const string MaxHealthContractNote = "MaxHealth is [Property]; no host-sync contract exists.";

	public static IReadOnlyList<LpPlayerHubCatalogTrack> Tracks => BuildTracks();
	public static IReadOnlyList<LpPlayerHubCatalogSkill> Skills => FlattenSkills( Tracks );

	private static IReadOnlyList<LpPlayerHubCatalogTrack> BuildTracks() => new[]
	{
		CreateTrack(
			id: "resilience",
			label: "Resilience",
			description: "Working durability taxonomy.",
			icon: "shield",
			skills: new[]
			{
				CreateSkill(
					id: "resilience-slot-1",
					trackId: "resilience",
					title: "Catalogue Slot 1"),
				CreateSkill(
					id: "resilience-slot-2",
					trackId: "resilience",
					title: "Catalogue Slot 2"),
				CreateSkill(
					id: "resilience-slot-3",
					trackId: "resilience",
					title: "Catalogue Slot 3"),
				CreateSkill(
					id: "resilience-slot-4",
					trackId: "resilience",
					title: "Catalogue Slot 4"),
				CreateSkill(
					id: "resilience-slot-5",
					trackId: "resilience",
					title: "Catalogue Slot 5"),
			}),
		CreateTrack(
			id: "recovery",
			label: "Recovery",
			description: "Working restoration taxonomy.",
			icon: "medical_services",
			skills: new[]
			{
				CreateSkill(
					id: "recovery-slot-1",
					trackId: "recovery",
					title: "Catalogue Slot 1"),
				CreateSkill(
					id: "recovery-slot-2",
					trackId: "recovery",
					title: "Catalogue Slot 2"),
				CreateSkill(
					id: "recovery-slot-3",
					trackId: "recovery",
					title: "Catalogue Slot 3"),
				CreateSkill(
					id: "recovery-slot-4",
					trackId: "recovery",
					title: "Catalogue Slot 4"),
				CreateSkill(
					id: "recovery-slot-5",
					trackId: "recovery",
					title: "Catalogue Slot 5"),
			}),
		CreateTrack(
			id: "enterprise",
			label: "Enterprise",
			description: "Working economy taxonomy.",
			icon: "business_center",
			skills: new[]
			{
				CreateSkill(
					id: "enterprise-slot-1",
					trackId: "enterprise",
					title: "Catalogue Slot 1"),
				CreateSkill(
					id: "enterprise-slot-2",
					trackId: "enterprise",
					title: "Catalogue Slot 2"),
				CreateSkill(
					id: "enterprise-slot-3",
					trackId: "enterprise",
					title: "Catalogue Slot 3"),
				CreateSkill(
					id: "enterprise-slot-4",
					trackId: "enterprise",
					title: "Catalogue Slot 4"),
				CreateSkill(
					id: "enterprise-slot-5",
					trackId: "enterprise",
					title: "Catalogue Slot 5"),
			}),
		CreateTrack(
			id: "infiltration",
			label: "Infiltration",
			description: "Working interaction taxonomy.",
			icon: "key",
			skills: new[]
			{
				CreateSkill(
					id: "infiltration-slot-1",
					trackId: "infiltration",
					title: "Catalogue Slot 1"),
				CreateSkill(
					id: "infiltration-slot-2",
					trackId: "infiltration",
					title: "Catalogue Slot 2"),
				CreateSkill(
					id: "infiltration-slot-3",
					trackId: "infiltration",
					title: "Catalogue Slot 3"),
				CreateSkill(
					id: "infiltration-slot-4",
					trackId: "infiltration",
					title: "Catalogue Slot 4"),
				CreateSkill(
					id: "infiltration-slot-5",
					trackId: "infiltration",
					title: "Catalogue Slot 5"),
			}),
		CreateTrack(
			id: "enforcement",
			label: "Enforcement",
			description: "Working public-safety taxonomy.",
			icon: "gavel",
			skills: new[]
			{
				CreateSkill(
					id: "enforcement-slot-1",
					trackId: "enforcement",
					title: "Catalogue Slot 1"),
				CreateSkill(
					id: "enforcement-slot-2",
					trackId: "enforcement",
					title: "Catalogue Slot 2"),
				CreateSkill(
					id: "enforcement-slot-3",
					trackId: "enforcement",
					title: "Catalogue Slot 3"),
				CreateSkill(
					id: "enforcement-slot-4",
					trackId: "enforcement",
					title: "Catalogue Slot 4"),
				CreateSkill(
					id: "enforcement-slot-5",
					trackId: "enforcement",
					title: "Catalogue Slot 5"),
			}),
	};

	private static LpPlayerHubCatalogTrack CreateTrack(
		string id,
		string label,
		string description,
		string icon,
		IReadOnlyList<LpPlayerHubCatalogSkill> skills )
	{
		return new LpPlayerHubCatalogTrack(
			Id: id,
			Label: label,
			Description: description,
			Icon: icon,
			Keystone: new LpPlayerHubCatalogKeystone(
				Title: "Keystone",
				State: KeystonePlaceholderState,
				EffectState: OwnerHeldState,
				SeamState: SeamUnmappedState,
				OwnerState: OwnerHeldState),
			Skills: skills);
	}

	private static LpPlayerHubCatalogSkill CreateSkill(
		string id,
		string trackId,
		string title )
	{
		return new LpPlayerHubCatalogSkill(
			Id: id,
			TrackId: trackId,
			Title: title,
			Tiers: PendingTiers(),
			EffectState: OwnerHeldState,
			CategoryCapState: OwnerHeldState,
			SeamState: SeamUnmappedState,
			OwnerState: OwnerHeldState);
	}

	private static IReadOnlyList<LpPlayerHubCatalogTier> PendingTiers() => new[]
	{
		new LpPlayerHubCatalogTier(
			Rank: 1,
			Label: "I",
			State: TierPendingState,
			EffectState: OwnerHeldState),
		new LpPlayerHubCatalogTier(
			Rank: 2,
			Label: "II",
			State: TierPendingState,
			EffectState: OwnerHeldState),
		new LpPlayerHubCatalogTier(
			Rank: 3,
			Label: "III",
			State: TierPendingState,
			EffectState: OwnerHeldState),
		new LpPlayerHubCatalogTier(
			Rank: 4,
			Label: "IV",
			State: TierPendingState,
			EffectState: OwnerHeldState),
		new LpPlayerHubCatalogTier(
			Rank: 5,
			Label: "V",
			State: TierPendingState,
			EffectState: OwnerHeldState),
	};

	private static IReadOnlyList<LpPlayerHubCatalogSkill> FlattenSkills(
		IReadOnlyList<LpPlayerHubCatalogTrack> tracks )
	{
		var skills = new List<LpPlayerHubCatalogSkill>( 25 );

		foreach ( var track in tracks )
		{
			foreach ( var skill in track.Skills )
			{
				skills.Add( skill );
			}
		}

		return skills;
	}
}
