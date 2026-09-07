// -----------------------------------------------------------------------------
// PROPRIETARY & CONFIDENTIAL - (c) 2026 lifepunch.co. All rights reserved.
//
// LIFEPUNCH Player Hub for DXRP
// s&box ident: lifepunch.playerhub
// addon ident: playerhub
// -----------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace LifePunch.DXRP.Addons.PlayerHub;

public interface IProgressionFileIo
{
	bool FileExists( string path );
	string ReadAllText( string path );
	void WriteAllText( string path, string contents );
}

public interface ILpPlayerHubProgressionLog
{
	void Error( string message );
}

internal sealed class LpPlayerHubStoreLoadResult
{
	public bool Success { get; init; }
	public bool CanCommitNewOperation { get; init; }
	public LpPlayerHubProgressionState? State { get; init; }
}

internal sealed class LpPlayerHubStoreCommitResult
{
	public bool Authoritative { get; init; }
	public bool Materialized { get; init; }
}

/// <summary>
/// Engine-free, per-player journal + state store. The sole logical commit point
/// is a checksum-valid readback of a commitMarker=true journal candidate.
/// </summary>
public sealed class LpPlayerHubProgressionStore
{
	public const int StoreVersion = 1;
	public const string MigrationNamespace = "6E1FD3A4-4B6C-5A2E-9F0B-8C7D1A2E4B60";

	private static readonly JsonSerializerOptions JsonOptions = CreateJsonOptions();

	private readonly IProgressionFileIo _io;
	private readonly ILpPlayerHubProgressionLog _log;
	private readonly string _catalogVersion;
	private readonly ILpPlayerHubClock _clock;
	private readonly string _migratorBuild;

	public LpPlayerHubProgressionStore(
		IProgressionFileIo io,
		ILpPlayerHubProgressionLog log,
		string catalogVersion,
		ILpPlayerHubClock clock,
		string migratorBuild )
	{
		_io = io ?? throw new ArgumentNullException( nameof(io) );
		_log = log ?? throw new ArgumentNullException( nameof(log) );
		_catalogVersion = catalogVersion ?? throw new ArgumentNullException( nameof(catalogVersion) );
		_clock = clock ?? throw new ArgumentNullException( nameof(clock) );
		_migratorBuild = migratorBuild ?? string.Empty;
	}

	public static string StateKey( ulong steamId )
		=> $"playerhub/progression/{steamId.ToString( CultureInfo.InvariantCulture )}.state.json";

	public static string JournalKey( ulong steamId )
		=> $"playerhub/progression/{steamId.ToString( CultureInfo.InvariantCulture )}.journal.json";

	public static string RetiredV0Key( ulong steamId )
		=> $"playerhub/progression/{steamId.ToString( CultureInfo.InvariantCulture )}.v0.retired.json";

	internal LpPlayerHubStoreLoadResult Load( ulong steamId )
	{
		var stateKey = StateKey( steamId );
		var journalKey = JournalKey( steamId );

		if ( !TryReadOptional( stateKey, out var stateRaw, out var stateExists ) ||
		     !TryReadOptional( journalKey, out var journalRaw, out var journalExists ) )
		{
			LogFailure( steamId, "artifact read failed; authoritative outcome unavailable" );
			return Failed();
		}

		var stateArtifact = ClassifyState( steamId, stateRaw, stateExists );
		var journalArtifact = ClassifyJournal( steamId, journalRaw, journalExists );

		if ( stateArtifact.Kind == ArtifactKind.Unsupported ||
		     journalArtifact.Kind == ArtifactKind.Unsupported )
		{
			QuarantineUnsupported( stateKey, stateRaw, stateExists, steamId );
			QuarantineUnsupported( journalKey, journalRaw, journalExists, steamId );
			LogFailure( steamId, "unsupported progression storeVersion; source retained byte-for-byte" );
			return Failed();
		}

		if ( stateArtifact.Kind == ArtifactKind.LegacyV0 )
		{
			if ( journalArtifact.Kind == ArtifactKind.ValidJournal )
				return RecoverJournal( steamId, journalArtifact.Journal!, journalKey );

			if ( journalArtifact.Kind == ArtifactKind.Invalid )
				TryClearJournal( journalKey, steamId );

			return MigrateV0( steamId, stateRaw );
		}

		if ( stateArtifact.Kind == ArtifactKind.ValidState &&
		     journalArtifact.Kind == ArtifactKind.ValidJournal )
		{
			var state = stateArtifact.State!;
			var journal = journalArtifact.Journal!;

			if ( journal.Generation > state.Generation )
				return RecoverJournal( steamId, journal, journalKey );

			if ( journal.Generation < state.Generation )
			{
				TryClearJournal( journalKey, steamId );
				return Succeeded( state.State );
			}

			if ( !StatesAgree( state.State, journal.State ) )
			{
				Quarantine( stateKey, stateRaw, "corrupt", steamId );
				Quarantine( journalKey, journalRaw, "corrupt", steamId );
				LogFailure( steamId, "equal-generation state/journal disagreement; player failed closed" );
				return Failed();
			}

			TryClearJournal( journalKey, steamId );
			return Succeeded( state.State );
		}

		if ( journalArtifact.Kind == ArtifactKind.ValidJournal )
			return RecoverJournal( steamId, journalArtifact.Journal!, journalKey );

		if ( stateArtifact.Kind == ArtifactKind.ValidState )
		{
			if ( journalArtifact.Kind == ArtifactKind.Invalid )
				TryClearJournal( journalKey, steamId );
			return Succeeded( stateArtifact.State!.State );
		}

		if ( stateArtifact.Kind == ArtifactKind.Invalid &&
		     journalArtifact.Kind == ArtifactKind.Invalid )
		{
			Quarantine( stateKey, stateRaw, "corrupt", steamId );
			Quarantine( journalKey, journalRaw, "corrupt", steamId );
			LogFailure( steamId, "both progression artifacts checksum-invalid; player failed closed" );
			return Failed();
		}

		if ( stateArtifact.Kind == ArtifactKind.Invalid )
		{
			Quarantine( stateKey, stateRaw, "corrupt", steamId );
			LogFailure( steamId, "state artifact invalid with no authoritative journal; player failed closed" );
			return Failed();
		}

		if ( journalArtifact.Kind == ArtifactKind.Invalid )
			TryClearJournal( journalKey, steamId );

		return Succeeded( NewState( steamId ) );
	}

	internal LpPlayerHubStoreCommitResult CommitLive(
		LpPlayerHubProgressionState candidate,
		LpPlayerHubOperationRecord operation )
	{
		var journal = CreateJournal( candidate, new[] { operation } );
		return CommitCandidate( candidate.PlayerSteamId, journal );
	}

	public static string CreateMigrationOperationId( ulong steamId, long seq )
	{
		var name = $"migration:{steamId.ToString( CultureInfo.InvariantCulture )}:{seq.ToString( CultureInfo.InvariantCulture )}";
		return CreateUuidV5( Guid.Parse( MigrationNamespace ), name );
	}

	private LpPlayerHubStoreCommitResult CommitCandidate(
		ulong steamId,
		JournalDocument journal )
	{
		var journalKey = JournalKey( steamId );
		var journalJson = SerializeJournal( journal );

		try
		{
			_io.WriteAllText( journalKey, journalJson );
		}
		catch ( Exception exception )
		{
			LogFailure( steamId, $"journal write failed before verification: {exception.Message}" );
			return NotAuthoritative();
		}

		JournalDocument? verifiedJournal;
		try
		{
			var readback = _io.ReadAllText( journalKey );
			verifiedJournal = ParseValidJournal( steamId, readback );
		}
		catch ( Exception exception )
		{
			LogFailure( steamId, $"journal readback indeterminate: {exception.Message}" );
			return NotAuthoritative();
		}

		if ( verifiedJournal is null ||
		     !string.Equals( verifiedJournal.Checksum, journal.Checksum, StringComparison.Ordinal ) )
		{
			LogFailure( steamId, "journal readback checksum invalid; no authoritative commit established" );
			return NotAuthoritative();
		}

		// The verified marked journal above is the commit point. Everything below
		// is best-effort recovery work and cannot change the persisted outcome.
		var materialized = TryMaterializeStateAndClear( steamId, verifiedJournal, journalKey );
		return Authoritative( materialized );
	}

	private LpPlayerHubStoreLoadResult RecoverJournal(
		ulong steamId,
		JournalDocument journal,
		string journalKey )
	{
		var materialized = TryMaterializeStateAndClear( steamId, journal, journalKey );
		return Succeeded( journal.State, canCommitNewOperation: materialized );
	}

	private bool TryMaterializeStateAndClear(
		ulong steamId,
		JournalDocument journal,
		string journalKey )
	{
		var stateDocument = CreateStateDocument( journal.State );
		var stateJson = SerializeState( stateDocument );
		var stateKey = StateKey( steamId );

		try
		{
			_io.WriteAllText( stateKey, stateJson );
			var stateReadback = _io.ReadAllText( stateKey );
			var verifiedState = ParseValidState( steamId, stateReadback );
			if ( verifiedState is null ||
			     !string.Equals( verifiedState.Checksum, stateDocument.Checksum, StringComparison.Ordinal ) )
			{
				LogFailure( steamId, "post-commit state readback checksum invalid; journal retained for recovery" );
				return false;
			}
		}
		catch ( Exception exception )
		{
			LogFailure( steamId, $"post-commit state materialization failed; journal retained: {exception.Message}" );
			return false;
		}

		TryClearJournal( journalKey, steamId );
		return true;
	}

	private LpPlayerHubStoreLoadResult MigrateV0( ulong steamId, string raw )
	{
		if ( !TryParseLegacyV0( raw, out var legacy ) )
		{
			Quarantine( StateKey( steamId ), raw, "corrupt", steamId );
			LogFailure( steamId, "legacy v0 parse failed; player failed closed" );
			return Failed();
		}

		if ( legacy.SteamId != steamId )
		{
			Quarantine( StateKey( steamId ), raw, "identity-mismatch", steamId );
			LogFailure(
				steamId,
				$"legacy v0 embedded steamId {legacy.SteamId} does not match path identity; player failed closed" );
			return Failed();
		}

		if ( !TryRetireLegacyV0( steamId, raw ) )
			return Failed();

		var migrationUtc = _clock.GetUtcNow().ToUniversalTime();
		var metadata = new LpPlayerHubMigrationMetadata
		{
			MigratedFromVersion = 0,
			MigrationUtc = migrationUtc,
			MigratorBuild = _migratorBuild,
		};

		var state = NewState( steamId );
		state.PointBalance = legacy.Points;
		state.Generation = 1;
		state.Migration = metadata;

		var operations = new List<LpPlayerHubOperationRecord>();
		var seq = 1L;
		operations.Add( CreateGenesisOperation(
			steamId,
			seq++,
			LpPlayerHubOperationKind.Earn,
			string.Empty,
			tier: 0,
			pointsDelta: legacy.Points,
			legacy.Points,
			migrationUtc ) );

		foreach ( var rank in legacy.Ranks.OrderBy( pair => pair.Key, StringComparer.Ordinal ) )
		{
			for ( var tier = 1; tier <= rank.Value; tier++ )
			{
				operations.Add( CreateGenesisOperation(
					steamId,
					seq++,
					LpPlayerHubOperationKind.Spend,
					rank.Key,
					tier,
					pointsDelta: 0,
					legacy.Points,
					migrationUtc ) );
			}

			state.Ranks[rank.Key] = rank.Value;
		}

		state.Operations = operations.Select( operation => operation.Clone() ).ToList();
		state.Seq = operations.Count;

		var journal = CreateJournal( state, operations );
		var commit = CommitCandidate( steamId, journal );
		return commit.Authoritative
			? Succeeded( state, canCommitNewOperation: commit.Materialized )
			: Failed();
	}

	private bool TryRetireLegacyV0( ulong steamId, string raw )
	{
		var retiredKey = RetiredV0Key( steamId );
		try
		{
			if ( _io.FileExists( retiredKey ) )
			{
				var existing = _io.ReadAllText( retiredKey );
				if ( !HashesMatch( raw, existing ) )
				{
					LogFailure( steamId, "legacy retirement copy differs from authoritative v0 bytes" );
					return false;
				}

				return true;
			}

			_io.WriteAllText( retiredKey, raw );
			var readback = _io.ReadAllText( retiredKey );
			if ( !HashesMatch( raw, readback ) )
			{
				LogFailure( steamId, "legacy retirement copy hash verification failed" );
				return false;
			}

			return true;
		}
		catch ( Exception exception )
		{
			LogFailure( steamId, $"legacy retirement failed before migration commit: {exception.Message}" );
			return false;
		}
	}

	private LpPlayerHubOperationRecord CreateGenesisOperation(
		ulong steamId,
		long seq,
		LpPlayerHubOperationKind kind,
		string skillId,
		int tier,
		int pointsDelta,
		int pointBalanceAfter,
		DateTime migrationUtc )
	{
		return new LpPlayerHubOperationRecord
		{
			OperationId = CreateMigrationOperationId( steamId, seq ),
			PlayerSteamId = steamId,
			Kind = kind,
			SkillId = skillId,
			Tier = tier,
			PointsDelta = pointsDelta,
			PointBalanceAfter = pointBalanceAfter,
			SourceEventId = $"migration:v0:{steamId.ToString( CultureInfo.InvariantCulture )}:{seq.ToString( CultureInfo.InvariantCulture )}",
			CatalogVersion = _catalogVersion,
			ResultCode = LpPlayerHubProgressionResultCode.Committed,
			CommittedAtUtc = migrationUtc,
			Seq = seq,
			Generation = 1,
		};
	}

	private static bool TryParseLegacyV0( string raw, out LegacyV0 legacy )
	{
		legacy = new LegacyV0();
		try
		{
			using var document = JsonDocument.Parse( raw );
			var root = document.RootElement;
			if ( root.ValueKind != JsonValueKind.Object ||
			     !root.TryGetProperty( "steamId", out var steamIdElement ) ||
			     steamIdElement.ValueKind != JsonValueKind.String ||
			     !ulong.TryParse(
				     steamIdElement.GetString(),
				     NumberStyles.None,
				     CultureInfo.InvariantCulture,
				     out var steamId ) ||
			     !root.TryGetProperty( "points", out var pointsElement ) ||
			     !pointsElement.TryGetInt32( out var points ) ||
			     points < 0 ||
			     !root.TryGetProperty( "ranks", out var ranksElement ) ||
			     ranksElement.ValueKind != JsonValueKind.Object )
			{
				return false;
			}

			var ranks = new Dictionary<string, int>( StringComparer.Ordinal );
			foreach ( var rank in ranksElement.EnumerateObject() )
			{
				if ( string.IsNullOrEmpty( rank.Name ) ||
				     !rank.Value.TryGetInt32( out var tier ) ||
				     tier is < 1 or > 5 ||
				     !ranks.TryAdd( rank.Name, tier ) )
				{
					return false;
				}
			}

			legacy = new LegacyV0
			{
				SteamId = steamId,
				Points = points,
				Ranks = ranks,
			};
			return true;
		}
		catch
		{
			return false;
		}
	}

	private Artifact ClassifyState( ulong steamId, string raw, bool exists )
	{
		if ( !exists )
			return Artifact.Absent();

		if ( TryReadStoreVersion( raw, out var version, out var hasVersion ) )
		{
			if ( hasVersion && version >= 2 )
				return Artifact.Unsupported();
			if ( !hasVersion || version == 0 )
				return Artifact.Legacy();
		}

		var state = ParseValidState( steamId, raw );
		return state is null ? Artifact.Invalid() : Artifact.Valid( state );
	}

	private Artifact ClassifyJournal( ulong steamId, string raw, bool exists )
	{
		if ( !exists || string.IsNullOrEmpty( raw ) )
			return Artifact.Absent();

		if ( TryReadStoreVersion( raw, out var version, out var hasVersion ) &&
		     hasVersion &&
		     version >= 2 )
		{
			return Artifact.Unsupported();
		}

		var journal = ParseValidJournal( steamId, raw );
		return journal is null ? Artifact.Invalid() : Artifact.Valid( journal );
	}

	private static bool TryReadStoreVersion( string raw, out int version, out bool hasVersion )
	{
		version = 0;
		hasVersion = false;
		try
		{
			using var document = JsonDocument.Parse( raw );
			if ( document.RootElement.ValueKind != JsonValueKind.Object )
				return false;

			if ( !document.RootElement.TryGetProperty( "storeVersion", out var versionElement ) )
				return true;

			hasVersion = true;
			return versionElement.TryGetInt32( out version );
		}
		catch
		{
			return false;
		}
	}

	private static StateDocument? ParseValidState( ulong steamId, string raw )
	{
		try
		{
			var document = JsonSerializer.Deserialize<StateDocument>( raw, JsonOptions );
			if ( document is null ||
			     document.StoreVersion != StoreVersion ||
			     !IsSha256( document.Checksum ) )
			{
				return null;
			}

			var expected = document.Checksum;
			document.Checksum = string.Empty;
			NormalizeState( document.State );
			var actual = HashUtf8( JsonSerializer.Serialize( document, JsonOptions ) );
			document.Checksum = expected;

			if ( !string.Equals( expected, actual, StringComparison.Ordinal ) ||
			     !ValidateState( steamId, document.Generation, document.Seq, document.State ) )
			{
				return null;
			}

			return document;
		}
		catch
		{
			return null;
		}
	}

	private static JournalDocument? ParseValidJournal( ulong steamId, string raw )
	{
		try
		{
			var document = JsonSerializer.Deserialize<JournalDocument>( raw, JsonOptions );
			if ( document is null ||
			     document.StoreVersion != StoreVersion ||
			     !document.CommitMarker ||
			     !IsSha256( document.Checksum ) )
			{
				return null;
			}

			var expected = document.Checksum;
			document.Checksum = string.Empty;
			NormalizeState( document.State );
			document.OperationRecords = document.OperationRecords
				.OrderBy( operation => operation.Seq )
				.Select( operation => operation.Clone() )
				.ToList();
			var actual = HashUtf8( JsonSerializer.Serialize( document, JsonOptions ) );
			document.Checksum = expected;

			if ( !string.Equals( expected, actual, StringComparison.Ordinal ) ||
			     !ValidateState( steamId, document.Generation, document.Seq, document.State ) ||
			     !ValidateJournalCardinality( document ) )
			{
				return null;
			}

			return document;
		}
		catch
		{
			return null;
		}
	}

	private static bool ValidateState(
		ulong steamId,
		long generation,
		long seq,
		LpPlayerHubProgressionState state )
	{
		if ( state is null ||
		     state.PlayerSteamId != steamId ||
		     state.PointBalance < 0 ||
		     state.Generation != generation ||
		     state.Seq != seq ||
		     generation < 0 ||
		     seq < 0 ||
		     state.Operations.Count != seq ||
		     state.Ranks.Any( rank => string.IsNullOrEmpty( rank.Key ) || rank.Value is < 1 or > 5 ) )
		{
			return false;
		}

		for ( var index = 0; index < state.Operations.Count; index++ )
		{
			var operation = state.Operations[index];
			if ( operation.PlayerSteamId != steamId ||
			     operation.Seq != index + 1 ||
			     operation.Generation is < 1 ||
			     operation.Generation > generation ||
			     !Guid.TryParseExact( operation.OperationId, "D", out var operationGuid ) ||
			     !string.Equals(
				     operation.OperationId,
				     operationGuid.ToString( "D" ).ToLowerInvariant(),
				     StringComparison.Ordinal ) )
			{
				return false;
			}
		}

		return true;
	}

	private static bool ValidateJournalCardinality( JournalDocument journal )
	{
		var isMigrationCandidate = journal.Generation == 1 &&
		                           journal.State.Migration is not null;
		if ( isMigrationCandidate )
			return ValidateMigrationGenesisCollection( journal );

		if ( journal.OperationRecords.Count != 1 )
			return false;

		var candidate = journal.OperationRecords[0];
		var finalStateRecord = journal.State.Operations.LastOrDefault();
		return finalStateRecord is not null &&
		       candidate.Generation == journal.Generation &&
		       candidate.Seq == journal.Seq &&
		       OperationRecordsEqual( candidate, finalStateRecord );
	}

	private static bool ValidateMigrationGenesisCollection( JournalDocument journal )
	{
		var state = journal.State;
		var metadata = state.Migration;
		if ( metadata is null ||
		     metadata.MigratedFromVersion != 0 ||
		     journal.OperationRecords.Count == 0 ||
		     journal.OperationRecords.Count != state.Operations.Count )
		{
			return false;
		}

		for ( var index = 0; index < journal.OperationRecords.Count; index++ )
		{
			if ( !OperationRecordsEqual(
				    journal.OperationRecords[index],
				    state.Operations[index] ) )
			{
				return false;
			}
		}

		var expectedRanks = state.Ranks
			.OrderBy( rank => rank.Key, StringComparer.Ordinal )
			.SelectMany( rank => Enumerable.Range( 1, rank.Value )
				.Select( tier => (rank.Key, Tier: tier) ) )
			.ToList();
		if ( journal.OperationRecords.Count != expectedRanks.Count + 1 )
			return false;

		var catalogVersion = journal.OperationRecords[0].CatalogVersion;
		var earn = journal.OperationRecords[0];
		if ( string.IsNullOrEmpty( catalogVersion ) ||
		     !ValidateGenesisRecord(
			     earn,
			     state.PlayerSteamId,
			     seq: 1,
			     LpPlayerHubOperationKind.Earn,
			     string.Empty,
			     tier: 0,
			     pointsDelta: state.PointBalance,
			     state.PointBalance,
			     catalogVersion,
			     metadata.MigrationUtc ) )
		{
			return false;
		}

		for ( var index = 0; index < expectedRanks.Count; index++ )
		{
			var expected = expectedRanks[index];
			if ( !ValidateGenesisRecord(
				    journal.OperationRecords[index + 1],
				    state.PlayerSteamId,
				    seq: index + 2,
				    LpPlayerHubOperationKind.Spend,
				    expected.Key,
				    expected.Tier,
				    pointsDelta: 0,
				    state.PointBalance,
				    catalogVersion,
				    metadata.MigrationUtc ) )
			{
				return false;
			}
		}

		return true;
	}

	private static bool ValidateGenesisRecord(
		LpPlayerHubOperationRecord operation,
		ulong steamId,
		long seq,
		LpPlayerHubOperationKind kind,
		string skillId,
		int tier,
		int pointsDelta,
		int pointBalanceAfter,
		string catalogVersion,
		DateTime migrationUtc )
	{
		return string.Equals(
			       operation.OperationId,
			       CreateMigrationOperationId( steamId, seq ),
			       StringComparison.Ordinal ) &&
		       operation.PlayerSteamId == steamId &&
		       operation.Kind == kind &&
		       string.Equals( operation.SkillId, skillId, StringComparison.Ordinal ) &&
		       operation.Tier == tier &&
		       operation.PointsDelta == pointsDelta &&
		       operation.PointBalanceAfter == pointBalanceAfter &&
		       string.Equals(
			       operation.SourceEventId,
			       $"migration:v0:{steamId.ToString( CultureInfo.InvariantCulture )}:{seq.ToString( CultureInfo.InvariantCulture )}",
			       StringComparison.Ordinal ) &&
		       string.Equals( operation.CatalogVersion, catalogVersion, StringComparison.Ordinal ) &&
		       operation.ResultCode == LpPlayerHubProgressionResultCode.Committed &&
		       operation.CommittedAtUtc == migrationUtc &&
		       operation.Seq == seq &&
		       operation.Generation == 1;
	}

	private static bool OperationRecordsEqual(
		LpPlayerHubOperationRecord left,
		LpPlayerHubOperationRecord right )
	{
		return string.Equals( left.OperationId, right.OperationId, StringComparison.Ordinal ) &&
		       left.PlayerSteamId == right.PlayerSteamId &&
		       left.Kind == right.Kind &&
		       string.Equals( left.SkillId, right.SkillId, StringComparison.Ordinal ) &&
		       left.Tier == right.Tier &&
		       left.PointsDelta == right.PointsDelta &&
		       left.PointBalanceAfter == right.PointBalanceAfter &&
		       string.Equals( left.SourceEventId, right.SourceEventId, StringComparison.Ordinal ) &&
		       string.Equals( left.CatalogVersion, right.CatalogVersion, StringComparison.Ordinal ) &&
		       left.ResultCode == right.ResultCode &&
		       left.CommittedAtUtc == right.CommittedAtUtc &&
		       left.Seq == right.Seq &&
		       left.Generation == right.Generation;
	}

	private static StateDocument CreateStateDocument( LpPlayerHubProgressionState state )
	{
		var document = new StateDocument
		{
			StoreVersion = StoreVersion,
			Generation = state.Generation,
			Seq = state.Seq,
			State = state.Clone(),
			Checksum = string.Empty,
		};
		NormalizeState( document.State );
		document.Checksum = HashUtf8( JsonSerializer.Serialize( document, JsonOptions ) );
		return document;
	}

	private static JournalDocument CreateJournal(
		LpPlayerHubProgressionState state,
		IEnumerable<LpPlayerHubOperationRecord> operationRecords )
	{
		var document = new JournalDocument
		{
			StoreVersion = StoreVersion,
			Generation = state.Generation,
			Seq = state.Seq,
			State = state.Clone(),
			OperationRecords = operationRecords
				.OrderBy( operation => operation.Seq )
				.Select( operation => operation.Clone() )
				.ToList(),
			CommitMarker = true,
			Checksum = string.Empty,
		};
		NormalizeState( document.State );
		document.Checksum = HashUtf8( JsonSerializer.Serialize( document, JsonOptions ) );
		return document;
	}

	private static string SerializeState( StateDocument document )
		=> JsonSerializer.Serialize( document, JsonOptions );

	private static string SerializeJournal( JournalDocument document )
		=> JsonSerializer.Serialize( document, JsonOptions );

	private bool TryReadOptional(
		string key,
		out string raw,
		out bool exists )
	{
		raw = string.Empty;
		exists = false;
		try
		{
			exists = _io.FileExists( key );
			if ( exists )
				raw = _io.ReadAllText( key );
			return true;
		}
		catch
		{
			return false;
		}
	}

	private void TryClearJournal( string journalKey, ulong steamId )
	{
		try
		{
			// Direct-write clearing stays inside the verified FileSystem.Data
			// primitive set; empty is classified exactly like a missing journal.
			_io.WriteAllText( journalKey, string.Empty );
		}
		catch ( Exception exception )
		{
			LogFailure( steamId, $"journal clear failed; safe retry will reconcile it: {exception.Message}" );
		}
	}

	private void QuarantineUnsupported(
		string key,
		string raw,
		bool exists,
		ulong steamId )
	{
		if ( exists && !string.IsNullOrEmpty( raw ) )
			Quarantine( key, raw, "unsupported", steamId );
	}

	private void Quarantine(
		string sourceKey,
		string raw,
		string reason,
		ulong steamId )
	{
		if ( string.IsNullOrEmpty( raw ) )
			return;

		var timestamp = _clock.GetUtcNow().ToUniversalTime()
			.ToString( "yyyyMMddTHHmmssfffffffZ", CultureInfo.InvariantCulture );
		var quarantineKey = $"{sourceKey}.{reason}.{timestamp}.json";
		try
		{
			_io.WriteAllText( quarantineKey, raw );
			var readback = _io.ReadAllText( quarantineKey );
			if ( !HashesMatch( raw, readback ) )
				LogFailure( steamId, $"quarantine readback hash mismatch for {sourceKey}" );
		}
		catch ( Exception exception )
		{
			LogFailure( steamId, $"quarantine copy failed for {sourceKey}: {exception.Message}" );
		}
	}

	private void LogFailure( ulong steamId, string message )
		=> _log.Error( $"LP_PLAYERHUB_PROGRESSION steamId={steamId} {message}" );

	private static bool StatesAgree(
		LpPlayerHubProgressionState left,
		LpPlayerHubProgressionState right )
	{
		var leftClone = left.Clone();
		var rightClone = right.Clone();
		NormalizeState( leftClone );
		NormalizeState( rightClone );
		return string.Equals(
			JsonSerializer.Serialize( leftClone, JsonOptions ),
			JsonSerializer.Serialize( rightClone, JsonOptions ),
			StringComparison.Ordinal );
	}

	private static void NormalizeState( LpPlayerHubProgressionState state )
	{
		state.Ranks = state.Ranks
			.OrderBy( rank => rank.Key, StringComparer.Ordinal )
			.ToDictionary( rank => rank.Key, rank => rank.Value, StringComparer.Ordinal );
		state.Operations = state.Operations
			.OrderBy( operation => operation.Seq )
			.Select( operation => operation.Clone() )
			.ToList();
	}

	private static LpPlayerHubProgressionState NewState( ulong steamId ) => new()
	{
		PlayerSteamId = steamId,
		PointBalance = 0,
		Ranks = new Dictionary<string, int>( StringComparer.Ordinal ),
		Operations = new List<LpPlayerHubOperationRecord>(),
		Generation = 0,
		Seq = 0,
		Migration = null,
	};

	private static string CreateUuidV5( Guid namespaceId, string name )
	{
		var namespaceBytes = namespaceId.ToByteArray();
		SwapGuidByteOrder( namespaceBytes );
		var nameBytes = Encoding.UTF8.GetBytes( name );
		var input = new byte[namespaceBytes.Length + nameBytes.Length];
		Buffer.BlockCopy( namespaceBytes, 0, input, 0, namespaceBytes.Length );
		Buffer.BlockCopy( nameBytes, 0, input, namespaceBytes.Length, nameBytes.Length );

		var hash = SHA1.HashData( input );
		var guidBytes = hash.Take( 16 ).ToArray();
		guidBytes[6] = (byte)((guidBytes[6] & 0x0F) | 0x50);
		guidBytes[8] = (byte)((guidBytes[8] & 0x3F) | 0x80);
		SwapGuidByteOrder( guidBytes );
		return new Guid( guidBytes ).ToString( "D" ).ToLowerInvariant();
	}

	private static void SwapGuidByteOrder( byte[] bytes )
	{
		(bytes[0], bytes[3]) = (bytes[3], bytes[0]);
		(bytes[1], bytes[2]) = (bytes[2], bytes[1]);
		(bytes[4], bytes[5]) = (bytes[5], bytes[4]);
		(bytes[6], bytes[7]) = (bytes[7], bytes[6]);
	}

	private static bool IsSha256( string checksum )
		=> checksum is { Length: 64 } &&
		   checksum.All( character =>
			   character is >= '0' and <= '9' or >= 'a' and <= 'f' );

	private static bool HashesMatch( string left, string right )
		=> string.Equals( HashUtf8( left ), HashUtf8( right ), StringComparison.Ordinal );

	private static string HashUtf8( string value )
		=> Convert.ToHexString( SHA256.HashData( Encoding.UTF8.GetBytes( value ) ) )
			.ToLowerInvariant();

	private static JsonSerializerOptions CreateJsonOptions()
	{
		var options = new JsonSerializerOptions
		{
			PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
			PropertyNameCaseInsensitive = false,
			WriteIndented = false,
		};
		options.Converters.Add( new JsonStringEnumConverter( JsonNamingPolicy.CamelCase ) );
		return options;
	}

	private static LpPlayerHubStoreLoadResult Succeeded(
		LpPlayerHubProgressionState state,
		bool canCommitNewOperation = true ) => new()
	{
		Success = true,
		CanCommitNewOperation = canCommitNewOperation,
		State = state.Clone(),
	};

	private static LpPlayerHubStoreLoadResult Failed() => new()
	{
		Success = false,
		CanCommitNewOperation = false,
		State = null,
	};

	private static LpPlayerHubStoreCommitResult Authoritative( bool materialized ) => new()
	{
		Authoritative = true,
		Materialized = materialized,
	};

	private static LpPlayerHubStoreCommitResult NotAuthoritative() => new()
	{
		Authoritative = false,
		Materialized = false,
	};

	private enum ArtifactKind
	{
		Absent,
		LegacyV0,
		ValidState,
		ValidJournal,
		Invalid,
		Unsupported,
	}

	private sealed class Artifact
	{
		public ArtifactKind Kind { get; init; }
		public StateDocument? State { get; init; }
		public JournalDocument? Journal { get; init; }

		public static Artifact Absent() => new() { Kind = ArtifactKind.Absent };
		public static Artifact Legacy() => new() { Kind = ArtifactKind.LegacyV0 };
		public static Artifact Invalid() => new() { Kind = ArtifactKind.Invalid };
		public static Artifact Unsupported() => new() { Kind = ArtifactKind.Unsupported };
		public static Artifact Valid( StateDocument state ) => new()
		{
			Kind = ArtifactKind.ValidState,
			State = state,
		};
		public static Artifact Valid( JournalDocument journal ) => new()
		{
			Kind = ArtifactKind.ValidJournal,
			Journal = journal,
		};
	}

	private sealed class StateDocument
	{
		public int StoreVersion { get; set; }
		public long Generation { get; set; }
		public long Seq { get; set; }
		public LpPlayerHubProgressionState State { get; set; } = new();
		public string Checksum { get; set; } = string.Empty;
	}

	private sealed class JournalDocument
	{
		public int StoreVersion { get; set; }
		public long Generation { get; set; }
		public long Seq { get; set; }
		public LpPlayerHubProgressionState State { get; set; } = new();
		public List<LpPlayerHubOperationRecord> OperationRecords { get; set; } = new();
		public bool CommitMarker { get; set; }
		public string Checksum { get; set; } = string.Empty;
	}

	private sealed class LegacyV0
	{
		public ulong SteamId { get; init; }
		public int Points { get; init; }
		public Dictionary<string, int> Ranks { get; init; } = new( StringComparer.Ordinal );
	}
}
