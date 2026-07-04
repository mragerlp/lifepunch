# DXRP Issue #97 — Addon Content: `System` (implementation spec)

**Lane:** DXRP upstream (`mragerlp/dxrp-public` → `dxura/dxrp:develop`) — see `DXRP_CONTRIBUTOR_LANE.md`.
**Status:** Planning only. **No fork edits** until PR #137 (party fixes) is merged/settled and Dimmer answers the three open questions below.
**Clone:** `C:\Users\jared\Projects\dxrp-public` — vanilla DXRP only, **no LifePunch IP / headers / paths**.
**Related:** Issue #97 (this), PR #137 (party UX), Party system (`PartySystem`) is the first `System` consumer.

---

## 1. What #97 actually is

Make a **game system** (Party first; later e.g. Governance, CoinFlip) an **operator-configurable, toggleable content item** in the portal — the same way Entities and Equipment already are — instead of a hardcoded always-on singleton.

An operator can then:
- **Enable / disable** the Party system per game mode (add/remove the content).
- **Tune it** via a config override (`MaxPartySize`, `PreventPartyDamage`, `InviteExpireSeconds`, `AllowMemberOutline`) with **no code change**.

This is not a new subsystem — it reuses the existing addon-content plumbing end to end.

---

## 2. Why this is small (plumbing already exists)

Verified read-only against `dxrp-public` @ current `develop`/`mragerlp-party-browse`:

| Piece | File | State |
|-------|------|-------|
| Content type enum | `game/Code/Api/Enums/AddonContentType.cs` | `Entity`, `Equipment` — **add `System`** (1 line) |
| Transport DTO | `game/Code/Api/Dtos/GameModeAddonContentDto.cs` | Already carries `Type`, `BaseConfig`, `ConfigOverride` — **no change** |
| Content aggregation | `game/Code/Utilities/Resource/GameModeAddonContents.cs` | `Addons.SelectMany(a => a.Contents)` — System flows through — **no change** |
| Config merge | `game/Code/Config/Config.GameMode.cs` → `Content<TConfig>(Guid id)` | Merges `BaseConfig` + `ConfigOverride` — **reuse as-is** |
| Config event | `game/Code/Config/IConfigEvents.cs` → `OnConfigOverride()` | Fires on every config apply — **enable/disable hook point** |
| Reader pattern | `game/Code/Utilities/Resource/GameModeEntities.cs` / `GameModeEquipments.cs` | Copy shape for a new `GameModeSystems` reader |
| Party config type | `game/Code/System/RP/PartySystem.cs` → `PartySystemConfig` | **Already exists** and its docstring already says *"Exposed as a 'System' content type config override … in the web portal."* |
| Party wiring stub | `PartySystem.Settings = new()` | Comment already says *"portal 'System' config-override plumbing is wired separately."* — **this is the swap point** |

**Takeaway:** #97 is mostly connecting a stub the DXRP author already carved out. The party code was written anticipating this.

---

## 3. Game-side changes (the PR)

### 3.1 Enum — `AddonContentType.cs`
```csharp
public enum AddonContentType
{
	Entity,
	Equipment,
	System
}
```

### 3.2 New reader — `game/Code/Utilities/Resource/GameModeSystems.cs`
Mirror `GameModeEquipments` exactly. `All` filters aggregated content by `Type == System`.
```csharp
using Dxura.RP.Shared;

namespace Dxura.RP.Game;

public static class GameModeSystems
{
	public static IReadOnlyList<GameModeAddonContentDto> All =>
		GameModeAddonContents.All.Where( x => x.Type == AddonContentType.System ).ToList();

	public static GameModeAddonContentDto? FindById( Guid contentId ) =>
		All.FirstOrDefault( x => x.GameModeAddonContentId == contentId );

	// Identifier lookup — SEE OPEN QUESTION Q2 (well-known Guid vs slug).
	public static GameModeAddonContentDto? FindWellKnown( Guid wellKnownId ) =>
		All.FirstOrDefault( x => x.AddonContentId == wellKnownId );

	public static bool IsEnabled( Guid wellKnownId ) => FindWellKnown( wellKnownId ) != null;
}
```
> Note: `GameModeAddonContents` currently exposes `FindById`; confirm/`All` accessor exists or add a public `All` there mirroring `GameModeEntities.All`.

### 3.3 Lifecycle contract — `IContentSystem`
A tiny interface each toggleable system implements. Keeps enable/disable/teardown uniform.
```csharp
namespace Dxura.RP.Game;

/// <summary>A game system that can be enabled/disabled and tuned as "System" addon content.</summary>
public interface IContentSystem
{
	/// <summary>Well-known content id used to locate this system in the game mode (see Constants).</summary>
	static abstract Guid WellKnownId { get; }

	/// <summary>Called when the system's content is present (enabled) — apply merged config.</summary>
	void OnSystemEnabled();

	/// <summary>Called when the system's content is absent (disabled) — tear down all state.</summary>
	void OnSystemDisabled();
}
```

### 3.4 `PartySystem` wiring
- Implement `IContentSystem`.
- Add a well-known id (Q2): mirror `Constants.ToolEquipmentId`.
- Replace the `Settings = new()` stub with the merged config read, driven by `OnConfigOverride`.

```csharp
public sealed class PartySystem : SingletonComponent<PartySystem>,
	Component.INetworkListener, IConfigEvents, IContentSystem
{
	public static Guid WellKnownId => Constants.PartySystemId; // Q2

	public PartySystemConfig Settings { get; private set; } = new();

	public bool SystemEnabled { get; private set; }

	void IConfigEvents.OnConfigOverride() => ReconcileFromConfig();

	protected override void OnStart()
	{
		base.OnStart();
		ReconcileFromConfig();
	}

	private void ReconcileFromConfig()
	{
		var content = GameModeSystems.FindWellKnown( WellKnownId );
		if ( content == null )
		{
			if ( SystemEnabled ) OnSystemDisabled();
			return;
		}

		Settings = Config.Current.GameMode.Content<PartySystemConfig>( content.GameModeAddonContentId );
		if ( !SystemEnabled ) OnSystemEnabled();
	}

	public void OnSystemEnabled()  { SystemEnabled = true;  /* register /party cmd, allow HUD */ }
	public void OnSystemDisabled() { SystemEnabled = false; TeardownParties(); }
}
```

### 3.5 Party teardown (Q3 — how deep)
`TeardownParties()` must leave zero residue when the system is disabled:
- [ ] Disband every party in `Parties` (clear the `NetDictionary`), replicate the empty state.
- [ ] Cancel all pending invite expiry timers and clear `_inviteTokens`.
- [ ] Suppress the `/party` chat command (no-op or "system disabled" when `!SystemEnabled`).
- [ ] Hide party HUD / party menu tab (client reads `PartySystem.Instance?.SystemEnabled`).
- [ ] Clear nameplate party color / member outline post-process.
- [ ] Guard every host mutation entrypoint (`Invite`/`Accept`/`Leave`/…) with `if ( !SystemEnabled ) return;`.

### 3.6 Client gating
Party menu and HUD components check `SystemEnabled` before rendering. When disabled, the Parties tab/entry is hidden (mirrors how equipment content that isn't present simply doesn't appear).

---

## 4. Portal / backend side (out of the PR — Dimmer owns)

The game reads content the backend emits. For Party to appear as a tunable `System`, the backend must:
- Recognize `AddonContentType.System` when seeding/serializing content.
- Emit a `System` content row for Party with a **stable identifier** (Q2) and a `PartySystemConfig` `BaseConfig` (defaults) so operators get a config panel.
- **Q1:** confirm whether this is auto-seeded per game mode or operator-added like any addon content.

The PR should ship the game-side enum + readers + wiring so it's **inert until** the backend emits a `System` row — safe to merge ahead of portal work (party stays on by default via a seeded well-known row, or off until added — depends on Q1).

---

## 5. Open questions for Dimmer (narrowed)

**Q1 — Emission / default state.** Does the backend auto-seed the Party `System` content per game mode (party on by default, tunable), or is it operator-added like other addon content (party off until added)? This decides whether `ReconcileFromConfig` treats "no content row" as *disabled* or *defaults*.

**Q2 — Identifier.** For locating a specific system in the content list, follow the existing **well-known `Guid` constant** pattern (`Constants.ToolEquipmentId`) → add `Constants.PartySystemId`? Or introduce a **string slug** field (e.g. `"party"`) on content for systems? Guid-constant is the smaller change and matches equipment.

**Q3 — Teardown depth.** Is the §3.5 checklist (full disband + HUD/command/nameplate teardown on disable) the expected behavior, or is a lighter "hide UI, keep runtime dormant" acceptable for v1?

---

## 6. Merge order / guardrails

1. **PR #137 (party UX) settles first.** Do not branch #97 off a dirty `mragerlp-party-browse`.
2. Cut #97 branch from **fresh `upstream/develop`** (`lifepunch\scripts\sync-dxrp-fork.ps1`).
3. Keep the PR game-side only + inert-by-default; portal emission lands separately.
4. Cite `#97` in the PR title/body, not every commit (commit hygiene rule).
5. No LifePunch headers/paths/branding anywhere in the fork.

---

## 7. Definition of done (game-side PR)

- [ ] `AddonContentType.System` added.
- [ ] `GameModeSystems` reader added (mirrors `GameModeEquipments`).
- [ ] `IContentSystem` interface added.
- [ ] `PartySystem` implements it; `Settings` sourced from `Content<PartySystemConfig>` via `OnConfigOverride`.
- [ ] `TeardownParties()` implemented per §3.5.
- [ ] Party menu/HUD gate on `SystemEnabled`.
- [ ] Behaves identically to today when a seeded/default Party row exists (no regression to #137).
- [ ] Flatgrass proof: party works enabled; disabling the content removes party cleanly (no errors, no ghost HUD).
