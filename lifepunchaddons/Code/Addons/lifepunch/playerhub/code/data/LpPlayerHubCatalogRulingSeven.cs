// -----------------------------------------------------------------------------
// PROPRIETARY & CONFIDENTIAL - (c) 2026 lifepunch.co. All rights reserved.
//
// LIFEPUNCH Player Hub for DXRP
// s&box ident: lifepunch.playerhub
// addon ident: playerhub
// -----------------------------------------------------------------------------

using System.Collections.Generic;

namespace LifePunch.DXRP.Addons.PlayerHub;

/// <summary>
/// RULING-7 catalogue content, authored as an INERT dataset.
///
/// WHY THIS FILE EXISTS SEPARATELY FROM <see cref="LpPlayerHubCatalog"/>:
/// the live catalogue is held at placeholder state by a ratified instrument.
/// Test-PlayerHubSboxContracts.ps1 asserts, case-sensitively, that all 25 skill
/// titles read "Catalogue Slot N" and that OwnerHeldState is "HELD-ruling-7".
/// That gate is the mechanism enforcing "no catalogue content before the owner
/// rules". Writing this content into the live catalogue would fail it, and
/// editing the gate so a change passes is the one move the editor-gate law
/// forbids outright.
///
/// The source draft is stamped "Fable pitch, awaiting Bloodwave edits" - a
/// DRAFT, not a ratified ruling. So the content lands here, inert, behind
/// <see cref="Active"/> = false. Nothing reads it. Nothing renders it. Nothing
/// can reach a player.
///
/// TO ACTIVATE (owner action, one PR):
///   1. Bloodwave ratifies RULING 7 and fills the blanks below.
///   2. Flip <see cref="Active"/> to true.
///   3. Point LpPlayerHubCatalog.BuildTracks() at this content.
///   4. Update Test-PlayerHubSboxContracts.ps1 titles + version in the SAME PR.
/// Steps 3 and 4 are one commit or neither - a green gate over changed content
/// is the green-by-omission defect.
///
/// IDS ARE NOT LABELS. The slot ids (resilience-slot-1 ...) are persistence
/// keys: LpPlayerHubProgressionStore writes skillId into the WAL journal, and
/// the contract gate asserts the exact ordered id rows. Renaming them would
/// both fail the gate and orphan every persisted record through the UUIDv5
/// migration. Titles are content; ids are contract. They are deliberately
/// decoupled here.
/// </summary>
public static class LpPlayerHubCatalogRulingSeven
{
	/// <summary>
	/// PARKED - House Parked Pattern. Inert until Bloodwave ratifies RULING 7.
	/// No consumer reads this type while false. Do not flip without step 4 above.
	/// </summary>
	public const bool Active = false;

	/// <summary>Provenance of the content below. Not a ratification mark.</summary>
	public const string SourceMark = "ruling-7-draft-2026-07-25";

	/// <summary>Owner blank, preserved verbatim per the draft.</summary>
	public const string GrandMasteryEffect = "GRAND_MASTERY_TBD";

	/// <summary>
	/// Owner blank: the draft reads "+$X/tier" for Enterprise slot 3. Parked
	/// rather than guessed - a fabricated economy number is an economy defect.
	/// </summary>
	public const string SideHustleTrickleParked = "SIDE_HUSTLE_TRICKLE_TBD";

	/// <summary>
	/// Rank cost is NOT expressed here. Acquisition ships DENY-ALL:
	/// LpPlayerHubDenyAllCostPolicy returns Allowed:false unconditionally and is
	/// the policy wired in LpPlayerHubProgressionHost. Tier costs are an owner
	/// schedule ruling that has not landed.
	/// </summary>
	public const string RankCostParked = "RANK_COST_DENY_ALL_UNTIL_SCHEDULE_RULING";

	/// <summary>Hook verification verdicts. See LpRulingSevenSkill.HookState.</summary>
	public const string HookFound = "FOUND";
	public const string HookPartial = "PARTIAL";
	public const string HookMissing = "MISSING";
	public const string HookUnverified = "UNVERIFIED";

	/// <summary>Marks a per-tier magnitude the owner has not fixed.</summary>
	public const string MagnitudeParked = "PARKED";

	public static IReadOnlyList<LpRulingSevenTrack> Tracks => BuildTracks();

	private static IReadOnlyList<LpRulingSevenTrack> BuildTracks() => new[]
	{
		new LpRulingSevenTrack(
			Id: "resilience",
			Label: "Resilience",
			Keystone: new LpRulingSevenKeystone(
				Title: "SECOND WIND",
				Effect: "Once per life, survive a downing blow at 1 HP (long cooldown)."),
			Skills: new[]
			{
				new LpRulingSevenSkill(
					Id: "resilience-slot-1",
					TrackId: "resilience",
					Slot: 1,
					Title: "Iron Constitution",
					Description: "Raises maximum health.",
					PerTier: "+4 HP",
					AtFive: "+20 HP",
					HookId: "H1",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: ""),
				new LpRulingSevenSkill(
					Id: "resilience-slot-2",
					TrackId: "resilience",
					Slot: 2,
					Title: "Quick Clot",
					Description: "Healing you receive is stronger.",
					PerTier: "+3%",
					AtFive: "+15%",
					HookId: "H2",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: ""),
				new LpRulingSevenSkill(
					Id: "resilience-slot-3",
					TrackId: "resilience",
					Slot: 3,
					Title: "Thick Skull",
					Description: "Shorter stun and ragdoll recovery.",
					PerTier: "-5%",
					AtFive: "-25%",
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft marks the hook PENDING; needs an in-repo sweep."),
				new LpRulingSevenSkill(
					Id: "resilience-slot-4",
					TrackId: "resilience",
					Slot: 4,
					Title: "Dead Man Standing",
					Description: "Below 25% health, incoming damage is reduced.",
					PerTier: "-2%",
					AtFive: "-10%",
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft marks the hook PENDING; needs an in-repo sweep."),
				new LpRulingSevenSkill(
					Id: "resilience-slot-5",
					TrackId: "resilience",
					Slot: 5,
					Title: "Survivor's Appetite",
					Description: "Consumable effects last longer.",
					PerTier: "+6%",
					AtFive: "+30%",
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft marks the hook PENDING; needs an in-repo sweep."),
			}),

		new LpRulingSevenTrack(
			Id: "recovery",
			Label: "Recovery",
			Keystone: new LpRulingSevenKeystone(
				Title: "FIELD SURGEON",
				Effect: "Heals applied to others may overheal by up to 10% (decays)."),
			Skills: new[]
			{
				new LpRulingSevenSkill(
					Id: "recovery-slot-1",
					TrackId: "recovery",
					Slot: 1,
					Title: "Steady Hands",
					Description: "Healing you perform is stronger.",
					PerTier: "+3%",
					AtFive: "+15%",
					HookId: "H2-adjacent",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft marks this H2-adjacent, not H2. Shares the heal seam; needs its own verdict."),
				new LpRulingSevenSkill(
					Id: "recovery-slot-2",
					TrackId: "recovery",
					Slot: 2,
					Title: "Triage Instinct",
					Description: "Heal actions apply faster.",
					PerTier: "-4%",
					AtFive: "-20%",
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft marks the hook PENDING; needs an in-repo sweep."),
				new LpRulingSevenSkill(
					Id: "recovery-slot-3",
					TrackId: "recovery",
					Slot: 3,
					Title: "Second Opinion",
					Description: "Self-heal items are stronger.",
					PerTier: "+3%",
					AtFive: "+15%",
					HookId: "H2",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: ""),
				new LpRulingSevenSkill(
					Id: "recovery-slot-4",
					TrackId: "recovery",
					Slot: 4,
					Title: "Composure",
					Description: "Longer bleedout timer for you.",
					PerTier: "+5%",
					AtFive: MagnitudeParked,
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft gives no V total for this row; not extrapolated."),
				new LpRulingSevenSkill(
					Id: "recovery-slot-5",
					TrackId: "recovery",
					Slot: 5,
					Title: "Bedside Manner",
					Description: "Healing emote and morale flourish.",
					PerTier: "cosmetic",
					AtFive: "cosmetic",
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: true,
					ParkedNote: "Cosmetic row. Cosmetic Firewall applies: no yield or economy reference."),
			}),

		new LpRulingSevenTrack(
			Id: "enterprise",
			Label: "Enterprise",
			Keystone: new LpRulingSevenKeystone(
				Title: "PAYDAY",
				Effect: "Once per session, one salary payment is doubled."),
			Skills: new[]
			{
				new LpRulingSevenSkill(
					Id: "enterprise-slot-1",
					TrackId: "enterprise",
					Slot: 1,
					Title: "Overtime",
					Description: "Increases salary per payment.",
					PerTier: "+2%",
					AtFive: "+10%",
					HookId: "H3",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "ECONOMY SURFACE. Touches a payout rail; economy law review owed before wiring."),
				new LpRulingSevenSkill(
					Id: "enterprise-slot-2",
					TrackId: "enterprise",
					Slot: 2,
					Title: "Negotiator",
					Description: "Job and contract fees are reduced.",
					PerTier: "-4%",
					AtFive: MagnitudeParked,
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "ECONOMY SURFACE. Draft gives no V total; not extrapolated."),
				new LpRulingSevenSkill(
					Id: "enterprise-slot-3",
					TrackId: "enterprise",
					Slot: 3,
					Title: "Side Hustle",
					Description: "Small passive trickle while on duty.",
					PerTier: SideHustleTrickleParked,
					AtFive: SideHustleTrickleParked,
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "OWNER BLANK: draft reads '+$X/tier'. A faucet with an invented rate is an economy defect - parked, not guessed. See OQ-9."),
				new LpRulingSevenSkill(
					Id: "enterprise-slot-4",
					TrackId: "enterprise",
					Slot: 4,
					Title: "Frugal",
					Description: "Vendor prices are better.",
					PerTier: "-1%",
					AtFive: "-5%",
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "ECONOMY SURFACE."),
				new LpRulingSevenSkill(
					Id: "enterprise-slot-5",
					TrackId: "enterprise",
					Slot: 5,
					Title: "Reputation",
					Description: "Nameplate and listing flourish, plus job-queue priority.",
					PerTier: "cosmetic",
					AtFive: "cosmetic",
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: true,
					ParkedNote: "MIXED ROW: the flourish is cosmetic, but job-queue priority is a real advantage. Not purely cosmetic. See OQ-10."),
			}),

		new LpRulingSevenTrack(
			Id: "infiltration",
			Label: "Infiltration",
			Keystone: new LpRulingSevenKeystone(
				Title: "CLEAN GETAWAY",
				Effect: "After a successful pry or breach, a brief no-telemetry window."),
			Skills: new[]
			{
				new LpRulingSevenSkill(
					Id: "infiltration-slot-1",
					TrackId: "infiltration",
					Slot: 1,
					Title: "Nimble Fingers",
					Description: "Faster pry and lockpick.",
					PerTier: "-4%",
					AtFive: "-20%",
					HookId: "H4",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: ""),
				new LpRulingSevenSkill(
					Id: "infiltration-slot-2",
					TrackId: "infiltration",
					Slot: 2,
					Title: "Job Well Done",
					Description: "Better rewards on a successful pry or breach.",
					PerTier: "+5%",
					AtFive: MagnitudeParked,
					HookId: "H5",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "ECONOMY SURFACE. Draft gives no V total; not extrapolated."),
				new LpRulingSevenSkill(
					Id: "infiltration-slot-3",
					TrackId: "infiltration",
					Slot: 3,
					Title: "Soft Step",
					Description: "Quieter movement.",
					PerTier: "-5%",
					AtFive: MagnitudeParked,
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft gives no V total; not extrapolated."),
				new LpRulingSevenSkill(
					Id: "infiltration-slot-4",
					TrackId: "infiltration",
					Slot: 4,
					Title: "Escape Artist",
					Description: "Faster struggle while restrained.",
					PerTier: "-5%",
					AtFive: MagnitudeParked,
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft gives no V total; not extrapolated."),
				new LpRulingSevenSkill(
					Id: "infiltration-slot-5",
					TrackId: "infiltration",
					Slot: 5,
					Title: "Casing the Joint",
					Description: "Idle-crouch highlights breachable targets.",
					PerTier: "quality of life",
					AtFive: "quality of life",
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft marks this QoL, not cosmetic. Target highlighting is an information advantage, not a flourish. See OQ-10."),
			}),

		new LpRulingSevenTrack(
			Id: "enforcement",
			Label: "Enforcement",
			Keystone: new LpRulingSevenKeystone(
				Title: "RAPID RESPONSE",
				Effect: "One action-cooldown reset per life."),
			Skills: new[]
			{
				new LpRulingSevenSkill(
					Id: "enforcement-slot-1",
					TrackId: "enforcement",
					Slot: 1,
					Title: "Drilled Routine",
					Description: "Qualifying action cooldowns are reduced.",
					PerTier: "-3%",
					AtFive: "-15%",
					HookId: "H6",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: ""),
				new LpRulingSevenSkill(
					Id: "enforcement-slot-2",
					TrackId: "enforcement",
					Slot: 2,
					Title: "Ram Discipline",
					Description: "Battering ram cooldown is reduced.",
					PerTier: "-4%",
					AtFive: MagnitudeParked,
					HookId: "H6",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Shares H6 with slot 1. Two rows on one hook needs a stacking rule. See OQ-11."),
				new LpRulingSevenSkill(
					Id: "enforcement-slot-3",
					TrackId: "enforcement",
					Slot: 3,
					Title: "Marksman Training",
					Description: "Reduced sway and recoil while on duty.",
					PerTier: "-3%",
					AtFive: MagnitudeParked,
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "COMBAT SURFACE. Recoil and sway are PvP-relevant; check against the $LP combat-line law before any wiring. See OQ-12."),
				new LpRulingSevenSkill(
					Id: "enforcement-slot-4",
					TrackId: "enforcement",
					Slot: 4,
					Title: "Restraint Expert",
					Description: "Faster cuff application.",
					PerTier: "-5%",
					AtFive: MagnitudeParked,
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: false,
					ParkedNote: "Draft gives no V total; not extrapolated."),
				new LpRulingSevenSkill(
					Id: "enforcement-slot-5",
					TrackId: "enforcement",
					Slot: 5,
					Title: "Commanding Presence",
					Description: "Arrest notice and uniform flourish.",
					PerTier: "cosmetic",
					AtFive: "cosmetic",
					HookId: "PENDING",
					HookState: HookUnverified,
					IsCosmetic: true,
					ParkedNote: "Cosmetic row. Cosmetic Firewall applies."),
			}),
	};
}

public sealed record LpRulingSevenTier(
	int Rank,
	string Label,
	string Effect);

public sealed record LpRulingSevenKeystone(
	string Title,
	string Effect);

public sealed record LpRulingSevenSkill(
	string Id,
	string TrackId,
	int Slot,
	string Title,
	string Description,
	string PerTier,
	string AtFive,
	string HookId,
	string HookState,
	bool IsCosmetic,
	string ParkedNote);

public sealed record LpRulingSevenTrack(
	string Id,
	string Label,
	LpRulingSevenKeystone Keystone,
	IReadOnlyList<LpRulingSevenSkill> Skills);
