// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Additional Drop Locations" (s&box ident: lifepunch.additionaldroplocations · addon ident: additionaldroplocations) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using Sandbox;

namespace LifePunch.DXRP.Addons.AdditionalDropLocations;

/// <summary>
/// Constants for the Additional Drop Locations addon — extra <c>weed_brick</c> sell zones on LifePunch maps.
/// Spawns the core gamemode <see cref="DrugDropPrefabPath"/> prefab; cosmetic subway/truck props ship separately.
/// </summary>
public static class AdditionalDropLocations
{
	public const string Package = "lifepunch.additionaldroplocations";
	public const string Ident = "additionaldroplocations";
	public const string DisplayName = "Additional Drop Locations";

	/// <summary>DXRP gamemode prefab — sells objects tagged <c>weed_brick</c>.</summary>
	public const string DrugDropPrefabPath = "prefabs/world/drug_drop.prefab";

	/// <summary>
	/// Drop sites to spawn after map fitting. Positions are placeholders until VENGEANCE editor pass.
	/// Machine-readable mirror: <c>config/drop-sites.json</c>.
	/// </summary>
	public static IReadOnlyList<DropSite> Sites { get; } =
	[
		new DropSite(
			Ident: "subway",
			Label: "Subway Carriage",
			MapIdent: "*",
			Enabled: false,
			Position: new Vector3( 0, 0, 0 ),
			Rotation: Rotation.Identity,
			CosmeticModelPath: "",
			Notes: "Blender source at reference-intake/additional-drug-drops/subway. Set world position on downtown (or target map), then enable."
		),
		new DropSite(
			Ident: "truck",
			Label: "Delivery Truck",
			MapIdent: "*",
			Enabled: false,
			Position: new Vector3( 0, 0, 0 ),
			Rotation: Rotation.Identity,
			CosmeticModelPath: "",
			Notes: "Blender source at reference-intake/additional-drug-drops/truck. Set world position on target map, then enable."
		)
	];
}

/// <param name="MapIdent">Map name from <c>MapInstance.MapName</c>, or <c>*</c> for all maps.</param>
/// <param name="CosmeticModelPath">Future LifePunch prop vmdl under <c>addons/lifepunch/additionaldroplocations/</c>.</param>
public readonly record struct DropSite(
	string Ident,
	string Label,
	string MapIdent,
	bool Enabled,
	Vector3 Position,
	Rotation Rotation,
	string CosmeticModelPath,
	string Notes
);
