// -----------------------------------------------------------------------------
// PROPRIETARY & CONFIDENTIAL - (c) 2026 lifepunch.co. All rights reserved.
//
// LIFEPUNCH Player Hub for DXRP
// s&box ident: lifepunch.playerhub
// addon ident: playerhub
// -----------------------------------------------------------------------------

#if !LIFEPUNCH_LOCAL
using System;
using System.Linq;
using Dxura.RP.Game;
using Dxura.RP.Game.Addons;
using Sandbox;

namespace LifePunch.DXRP.Addons.PlayerHub;

/// <summary>
/// Sandbox boundary for the neutral progression owner. Batch 2 intentionally
/// exposes exactly one write-only request RPC and no client response/read RPC.
/// </summary>
[AddonService]
public sealed class LpPlayerHubProgressionHost : SingletonComponent<LpPlayerHubProgressionHost>
{
	private const string MigratorBuild = "playerhub-batch2-rev-d3";
	private LpPlayerHubProgression? _progression;

	[Rpc.Host]
	public void RequestSpend(
		string operationId,
		string catalogVersion,
		string skillId,
		int tier )
	{
		var player = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		if ( !player.IsValid() || player.SteamId <= 0 )
			return;

		_ = ExecuteSpendFor(
			checked((ulong)player.SteamId),
			operationId,
			catalogVersion,
			skillId,
			tier );
	}

	/// <summary>
	/// Trusted internal return path. A filtered client result transport is deferred
	/// to Batch 3 and is deliberately absent here.
	/// </summary>
	internal LpPlayerHubSpendResult ExecuteSpendFor(
		ulong trustedSteamId,
		string operationId,
		string catalogVersion,
		string skillId,
		int tier )
	{
		return Progression.ExecuteSpendFor(
			trustedSteamId,
			operationId,
			catalogVersion,
			skillId,
			tier );
	}

	/// <summary>Trusted non-RPC read for host tests/probes only.</summary>
	internal LpPlayerHubProgressionState? GetStateFor( ulong trustedSteamId )
		=> Progression.GetStateFor( trustedSteamId );

	private LpPlayerHubProgression Progression
	{
		get
		{
			_progression ??= CreateProgression();
			return _progression;
		}
	}

	private static LpPlayerHubProgression CreateProgression()
	{
		var clock = new SystemClock();
		var catalog = new CatalogAdapter();
		var store = new LpPlayerHubProgressionStore(
			new SandboxFileIo(),
			new SandboxProgressionLog(),
			catalog.Version,
			clock,
			MigratorBuild );
		return new LpPlayerHubProgression(
			store,
			catalog,
			new LpPlayerHubDenyAllCostPolicy(),
			clock );
	}

	private sealed class CatalogAdapter : ILpPlayerHubProgressionCatalog
	{
		public string Version => LpPlayerHubCatalog.Version;

		public bool ContainsSkill( string skillId )
			=> LpPlayerHubCatalog.Skills.Any( skill =>
				string.Equals( skill.Id, skillId, StringComparison.Ordinal ) );

		public int MaxTier( string skillId )
			=> LpPlayerHubCatalog.Skills
				.FirstOrDefault( skill =>
					string.Equals( skill.Id, skillId, StringComparison.Ordinal ) )
				?.Tiers.Count ?? 0;
	}

	private sealed class SandboxFileIo : IProgressionFileIo
	{
		public bool FileExists( string path ) => FileSystem.Data.FileExists( path );
		public string ReadAllText( string path ) => FileSystem.Data.ReadAllText( path );
		public void WriteAllText( string path, string contents )
			=> FileSystem.Data.WriteAllText( path, contents );
	}

	private sealed class SandboxProgressionLog : ILpPlayerHubProgressionLog
	{
		public void Error( string message ) => Log.Error( message );
	}

	private sealed class SystemClock : ILpPlayerHubClock
	{
		public DateTime GetUtcNow() => DateTime.UtcNow;
	}
}
#endif
