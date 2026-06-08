// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "DXRP Admin Menu" (s&box ident: lifepunch.ulx · addon ident: lifepunch.dxrpadminmenu) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL
using System.Threading.Tasks;
using Dxura.RP.Game;
using Dxura.RP.Game.Addons;
using Sandbox;

namespace LifePunch.DXRP.Addons.StaffMenu;

/// <summary>
/// Self-contained host bridge for the admin menu's owner-configurable Settings — DROP-IN, no DXRP core edits.
///
/// Owner customizations live in the host/token-scoped portal key-value store (<see cref="ServerApiClient"/>
/// needs the server authorization key), so the client-side menu can't read or write them directly. This
/// component is auto-attached to the networked core root on every peer by DXRP's <c>AddonServiceRegistry</c>
/// (via <see cref="AddonServiceAttribute"/>), giving the addon its OWN host RPCs: any viewer may request the
/// current settings (read), while writes are re-validated against the owner-grant permission host-side.
/// Mirrors the proven <see cref="WaypointSyncService"/> round-trip.
///
/// Server-agnostic by construction: each server reads/writes its own token-scoped store, so every owner sees
/// their own values with zero config — and because it lives entirely in the addon, it works on any DXRP
/// server the addon is dropped into without modifying core.
/// </summary>
[AddonService]
public sealed class StaffSettingsService : SingletonComponent<StaffSettingsService>
{
	// Token-scoped store key for the owner-configured network website. Namespaced under staffmenu:settings:
	// so future owner customizations slot in alongside it.
	private const string WebsiteStoreKey = "staffmenu:settings:website";

	// Owner-grant gate for writing settings. The Owner rank's "*" wildcard satisfies this automatically,
	// and an owner may grant it to other ranks in the portal. Mirrors StaffMenuHost.SettingsEditPermissionId.
	private const string SettingsEditPermission = "staffmenu.settings.edit";

	/// <summary>
	/// Client→host read of the current settings. Open to any viewer — the configured website is shown to all
	/// staff on the menu's network tag — then read + returned to just the calling client asynchronously.
	/// </summary>
	[Rpc.Host]
	public void RequestSettingsHost()
	{
		_ = SendSettingsToCaller( Rpc.Caller );
	}

	private async Task SendSettingsToCaller( Connection connection )
	{
		var website = string.Empty;
		try
		{
			website = await ServerApiClient.GetStore( WebsiteStoreKey ) ?? string.Empty;
		}
		catch ( System.Exception e )
		{
			// No portal/token (e.g. an unauthenticated dev session) — degrade to "unset" rather than fault.
			Log.Warning( $"[StaffMenu] website read failed (offline?): {e.Message}" );
		}

		await GameTask.MainThread();

		// A stale connection (caller disconnected mid-read) simply matches nothing here — safe no-op.
		using ( Rpc.FilterInclude( c => c == connection ) )
		{
			ReceiveSettingsClient( website );
		}
	}

	/// <summary>
	/// Client→host write of the network website URL, re-validating <c>staffmenu.settings.edit</c> host-side
	/// (the menu's UI gating is cosmetic only). An empty value clears it. Broadcasts the new value to every
	/// client so all open menus update live.
	/// </summary>
	[Rpc.Host]
	public void SetWebsiteHost( string url )
	{
		var caller = Rpc.Caller;
		if ( !RankSystem.HasPermission( caller.SteamId, SettingsEditPermission ) )
		{
			return;
		}

		_ = SaveWebsite( url );
	}

	private async Task SaveWebsite( string url )
	{
		url = ( url ?? string.Empty ).Trim();

		try
		{
			if ( url.Length == 0 )
			{
				await ServerApiClient.DeleteStore( WebsiteStoreKey );
			}
			else
			{
				await ServerApiClient.SetStore( WebsiteStoreKey, url );
			}
		}
		catch ( System.Exception e )
		{
			// Persist is best-effort: an unauthenticated dev session can't reach the portal store, but we
			// still broadcast below so the change is reflected live for the rest of the session.
			Log.Warning( $"[StaffMenu] website persist failed (offline?): {e.Message}" );
		}

		await GameTask.MainThread();

		// No filter → broadcast to all clients so every open menu reflects the change immediately, even
		// if the persist above failed.
		ReceiveSettingsClient( url );
	}

	[Rpc.Broadcast( NetFlags.HostOnly | NetFlags.Reliable )]
	private void ReceiveSettingsClient( string website )
	{
		StaffMenuHost.OnSettingsReceived( website );
	}
}
#endif
