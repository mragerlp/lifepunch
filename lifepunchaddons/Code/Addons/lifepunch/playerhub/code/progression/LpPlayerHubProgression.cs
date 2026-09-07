// -----------------------------------------------------------------------------
// PROPRIETARY & CONFIDENTIAL - (c) 2026 lifepunch.co. All rights reserved.
//
// LIFEPUNCH Player Hub for DXRP
// s&box ident: lifepunch.playerhub
// addon ident: playerhub
// -----------------------------------------------------------------------------

using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace LifePunch.DXRP.Addons.PlayerHub;

public enum LpPlayerHubProgressionResultCode
{
	Committed,
	InsufficientPoints,
	UnknownSkill,
	TierOrderViolation,
	CatalogVersionMismatch,
	Denied,
	StoreFailure,
	MalformedRequest,
}

public enum LpPlayerHubOperationKind
{
	Earn,
	Spend,
}

public sealed class LpPlayerHubOperationRecord
{
	public string OperationId { get; set; } = string.Empty;
	public ulong PlayerSteamId { get; set; }
	public LpPlayerHubOperationKind Kind { get; set; }
	public string SkillId { get; set; } = string.Empty;
	public int Tier { get; set; }
	public int PointsDelta { get; set; }
	public int PointBalanceAfter { get; set; }
	public string SourceEventId { get; set; } = string.Empty;
	public string CatalogVersion { get; set; } = string.Empty;
	public LpPlayerHubProgressionResultCode ResultCode { get; set; }
	public DateTime CommittedAtUtc { get; set; }
	public long Seq { get; set; }
	public long Generation { get; set; }

	public LpPlayerHubOperationRecord Clone() => new()
	{
		OperationId = OperationId,
		PlayerSteamId = PlayerSteamId,
		Kind = Kind,
		SkillId = SkillId,
		Tier = Tier,
		PointsDelta = PointsDelta,
		PointBalanceAfter = PointBalanceAfter,
		SourceEventId = SourceEventId,
		CatalogVersion = CatalogVersion,
		ResultCode = ResultCode,
		CommittedAtUtc = CommittedAtUtc,
		Seq = Seq,
		Generation = Generation,
	};
}

public sealed class LpPlayerHubMigrationMetadata
{
	public int MigratedFromVersion { get; set; }
	public DateTime MigrationUtc { get; set; }
	public string MigratorBuild { get; set; } = string.Empty;

	public LpPlayerHubMigrationMetadata Clone() => new()
	{
		MigratedFromVersion = MigratedFromVersion,
		MigrationUtc = MigrationUtc,
		MigratorBuild = MigratorBuild,
	};
}

/// <summary>
/// Host-authoritative progression projection. Callers receive a detached copy;
/// mutation is owned by <see cref="LpPlayerHubProgression"/>.
/// </summary>
public sealed class LpPlayerHubProgressionState
{
	public ulong PlayerSteamId { get; set; }
	public int PointBalance { get; set; }
	public Dictionary<string, int> Ranks { get; set; } = new( StringComparer.Ordinal );
	public List<LpPlayerHubOperationRecord> Operations { get; set; } = new();
	public long Generation { get; set; }
	public long Seq { get; set; }
	public LpPlayerHubMigrationMetadata? Migration { get; set; }

	public LpPlayerHubProgressionState Clone() => new()
	{
		PlayerSteamId = PlayerSteamId,
		PointBalance = PointBalance,
		Ranks = new Dictionary<string, int>( Ranks, StringComparer.Ordinal ),
		Operations = Operations.Select( operation => operation.Clone() ).ToList(),
		Generation = Generation,
		Seq = Seq,
		Migration = Migration?.Clone(),
	};
}

/// <summary>
/// Internal/trusted spend result. Batch 2 deliberately has no client response
/// RPC; transport projection is deferred to Batch 3.
/// </summary>
public sealed class LpPlayerHubSpendResult
{
	public string OperationId { get; init; } = string.Empty;
	public LpPlayerHubProgressionResultCode ResultCode { get; init; }
	public bool Replayed { get; init; }
	public int? PointBalanceAfter { get; init; }
	public string SkillId { get; init; } = string.Empty;
	public int? TierGranted { get; init; }
	public string CatalogVersion { get; init; } = string.Empty;
	public DateTime? CommittedAtUtc { get; init; }
	public long? Seq { get; init; }
}

public interface ILpPlayerHubProgressionCatalog
{
	string Version { get; }
	bool ContainsSkill( string skillId );
	int MaxTier( string skillId );
}

public readonly record struct LpPlayerHubCostDecision( bool Allowed, int Cost );

public interface ILpPlayerHubCostPolicy
{
	LpPlayerHubCostDecision Evaluate( string catalogVersion, string skillId, int tier );
}

public interface ILpPlayerHubClock
{
	DateTime GetUtcNow();
}

/// <summary>
/// Batch-2 shipping policy. Otherwise-valid, previously unseen live spends
/// reaching precedence rung seven are persisted as Denied.
/// </summary>
public sealed class LpPlayerHubDenyAllCostPolicy : ILpPlayerHubCostPolicy
{
	public LpPlayerHubCostDecision Evaluate( string catalogVersion, string skillId, int tier )
		=> new( Allowed: false, Cost: 0 );
}

/// <summary>
/// Engine-free neutral progression owner. Identity is already trusted when it
/// crosses this boundary; the Sandbox adapter is solely responsible for deriving
/// that identity from Rpc.CallerId.
/// </summary>
public sealed class LpPlayerHubProgression
{
	private static readonly ConcurrentDictionary<ulong, object> PlayerGates = new();

	private readonly LpPlayerHubProgressionStore _store;
	private readonly ILpPlayerHubProgressionCatalog _catalog;
	private readonly ILpPlayerHubCostPolicy _costPolicy;
	private readonly ILpPlayerHubClock _clock;

	public LpPlayerHubProgression(
		LpPlayerHubProgressionStore store,
		ILpPlayerHubProgressionCatalog catalog,
		ILpPlayerHubCostPolicy costPolicy,
		ILpPlayerHubClock clock )
	{
		_store = store ?? throw new ArgumentNullException( nameof(store) );
		_catalog = catalog ?? throw new ArgumentNullException( nameof(catalog) );
		_costPolicy = costPolicy ?? throw new ArgumentNullException( nameof(costPolicy) );
		_clock = clock ?? throw new ArgumentNullException( nameof(clock) );
	}

	/// <summary>
	/// Exact nine-rung spend protocol. Dedupe/reconciliation precedes every
	/// remaining payload validation so a persisted ID always replays its original
	/// authoritative record.
	/// </summary>
	public LpPlayerHubSpendResult ExecuteSpendFor(
		ulong trustedSteamId,
		string operationId,
		string catalogVersion,
		string skillId,
		int tier )
	{
		if ( !TryCanonicalizeOperationId( operationId, out var canonicalOperationId ) )
		{
			return Transient(
				operationId,
				LpPlayerHubProgressionResultCode.MalformedRequest,
				skillId,
				catalogVersion );
		}

		lock ( PlayerGates.GetOrAdd( trustedSteamId, static _ => new object() ) )
		{
			var loaded = _store.Load( trustedSteamId );
			if ( !loaded.Success || loaded.State is null )
			{
				return Transient(
					canonicalOperationId,
					LpPlayerHubProgressionResultCode.StoreFailure,
					skillId,
					catalogVersion );
			}

			var state = loaded.State;
			var existing = state.Operations.FirstOrDefault( operation =>
				string.Equals( operation.OperationId, canonicalOperationId, StringComparison.Ordinal ) );
			if ( existing is not null )
				return Project( existing, replayed: true );

			if ( !loaded.CanCommitNewOperation )
			{
				return Transient(
					canonicalOperationId,
					LpPlayerHubProgressionResultCode.StoreFailure,
					skillId,
					catalogVersion );
			}

			if ( !IsBoundedNonEmptyUtf8( catalogVersion ) ||
			     !IsBoundedNonEmptyUtf8( skillId ) ||
			     tier is < 1 or > 5 )
			{
				return Transient(
					canonicalOperationId,
					LpPlayerHubProgressionResultCode.MalformedRequest,
					skillId,
					catalogVersion );
			}

			if ( !_catalog.ContainsSkill( skillId ) )
			{
				return PersistOutcome(
					state,
					canonicalOperationId,
					trustedSteamId,
					skillId,
					tier,
					catalogVersion,
					LpPlayerHubProgressionResultCode.UnknownSkill,
					pointsDelta: 0,
					pointBalanceAfter: state.PointBalance,
					grantTier: false );
			}

			if ( !string.Equals( catalogVersion, _catalog.Version, StringComparison.Ordinal ) )
			{
				return PersistOutcome(
					state,
					canonicalOperationId,
					trustedSteamId,
					skillId,
					tier,
					catalogVersion,
					LpPlayerHubProgressionResultCode.CatalogVersionMismatch,
					pointsDelta: 0,
					pointBalanceAfter: state.PointBalance,
					grantTier: false );
			}

			var currentTier = state.Ranks.TryGetValue( skillId, out var ownedTier ) ? ownedTier : 0;
			if ( tier != currentTier + 1 || tier > _catalog.MaxTier( skillId ) )
			{
				return PersistOutcome(
					state,
					canonicalOperationId,
					trustedSteamId,
					skillId,
					tier,
					catalogVersion,
					LpPlayerHubProgressionResultCode.TierOrderViolation,
					pointsDelta: 0,
					pointBalanceAfter: state.PointBalance,
					grantTier: false );
			}

			var cost = _costPolicy.Evaluate( catalogVersion, skillId, tier );
			if ( !cost.Allowed || cost.Cost < 0 )
			{
				return PersistOutcome(
					state,
					canonicalOperationId,
					trustedSteamId,
					skillId,
					tier,
					catalogVersion,
					LpPlayerHubProgressionResultCode.Denied,
					pointsDelta: 0,
					pointBalanceAfter: state.PointBalance,
					grantTier: false );
			}

			if ( cost.Cost > state.PointBalance )
			{
				return PersistOutcome(
					state,
					canonicalOperationId,
					trustedSteamId,
					skillId,
					tier,
					catalogVersion,
					LpPlayerHubProgressionResultCode.InsufficientPoints,
					pointsDelta: 0,
					pointBalanceAfter: state.PointBalance,
					grantTier: false );
			}

			return PersistOutcome(
				state,
				canonicalOperationId,
				trustedSteamId,
				skillId,
				tier,
				catalogVersion,
				LpPlayerHubProgressionResultCode.Committed,
				pointsDelta: -cost.Cost,
				pointBalanceAfter: state.PointBalance - cost.Cost,
				grantTier: true );
		}
	}

	/// <summary>
	/// Trusted, non-RPC earn seam. The host adapter exposes no client path to this
	/// method; Batch-2 tests inject point grants here without shipping a debug grant.
	/// </summary>
	internal LpPlayerHubSpendResult ExecuteEarnFor(
		ulong trustedSteamId,
		string operationId,
		int points,
		string sourceEventId )
	{
		if ( !TryCanonicalizeOperationId( operationId, out var canonicalOperationId ) ||
		     points < 0 ||
		     string.IsNullOrEmpty( sourceEventId ) )
		{
			return Transient(
				operationId,
				LpPlayerHubProgressionResultCode.MalformedRequest,
				string.Empty,
				_catalog.Version );
		}

		lock ( PlayerGates.GetOrAdd( trustedSteamId, static _ => new object() ) )
		{
			var loaded = _store.Load( trustedSteamId );
			if ( !loaded.Success || loaded.State is null )
			{
				return Transient(
					canonicalOperationId,
					LpPlayerHubProgressionResultCode.StoreFailure,
					string.Empty,
					_catalog.Version );
			}

			var state = loaded.State;
			var existing = state.Operations.FirstOrDefault( operation =>
				string.Equals( operation.OperationId, canonicalOperationId, StringComparison.Ordinal ) );
			if ( existing is not null )
				return Project( existing, replayed: true );

			if ( !loaded.CanCommitNewOperation )
			{
				return Transient(
					canonicalOperationId,
					LpPlayerHubProgressionResultCode.StoreFailure,
					string.Empty,
					_catalog.Version );
			}

			var nextBalance = (long)state.PointBalance + points;
			if ( nextBalance > int.MaxValue )
			{
				return Transient(
					canonicalOperationId,
					LpPlayerHubProgressionResultCode.MalformedRequest,
					string.Empty,
					_catalog.Version );
			}

			return PersistOutcome(
				state,
				canonicalOperationId,
				trustedSteamId,
				string.Empty,
				tier: 0,
				_catalog.Version,
				LpPlayerHubProgressionResultCode.Committed,
				pointsDelta: points,
				pointBalanceAfter: (int)nextBalance,
				grantTier: false,
				kind: LpPlayerHubOperationKind.Earn,
				sourceEventId: sourceEventId );
		}
	}

	/// <summary>
	/// Trusted non-RPC read only. Batch 2 adds no client-reachable state RPC.
	/// </summary>
	public LpPlayerHubProgressionState? GetStateFor( ulong trustedSteamId )
	{
		lock ( PlayerGates.GetOrAdd( trustedSteamId, static _ => new object() ) )
		{
			var loaded = _store.Load( trustedSteamId );
			return loaded.Success ? loaded.State?.Clone() : null;
		}
	}

	private LpPlayerHubSpendResult PersistOutcome(
		LpPlayerHubProgressionState state,
		string operationId,
		ulong trustedSteamId,
		string skillId,
		int tier,
		string catalogVersion,
		LpPlayerHubProgressionResultCode resultCode,
		int pointsDelta,
		int pointBalanceAfter,
		bool grantTier,
		LpPlayerHubOperationKind kind = LpPlayerHubOperationKind.Spend,
		string? sourceEventId = null )
	{
		var generation = checked(state.Generation + 1);
		var seq = checked(state.Seq + 1);
		var committedAtUtc = _clock.GetUtcNow().ToUniversalTime();
		var operation = new LpPlayerHubOperationRecord
		{
			OperationId = operationId,
			PlayerSteamId = trustedSteamId,
			Kind = kind,
			SkillId = skillId,
			Tier = tier,
			PointsDelta = pointsDelta,
			PointBalanceAfter = pointBalanceAfter,
			SourceEventId = sourceEventId ?? $"spend:{operationId}",
			CatalogVersion = catalogVersion,
			ResultCode = resultCode,
			CommittedAtUtc = committedAtUtc,
			Seq = seq,
			Generation = generation,
		};

		var candidate = state.Clone();
		candidate.PointBalance = pointBalanceAfter;
		candidate.Generation = generation;
		candidate.Seq = seq;
		if ( grantTier )
			candidate.Ranks[skillId] = tier;
		candidate.Operations.Add( operation.Clone() );

		var commit = _store.CommitLive( candidate, operation );
		if ( !commit.Authoritative )
		{
			return Transient(
				operationId,
				LpPlayerHubProgressionResultCode.StoreFailure,
				skillId,
				catalogVersion );
		}

		return Project( operation, replayed: false );
	}

	private static bool TryCanonicalizeOperationId( string operationId, out string canonical )
	{
		canonical = string.Empty;
		if ( string.IsNullOrEmpty( operationId ) ||
		     !Guid.TryParseExact( operationId, "D", out var parsed ) )
		{
			return false;
		}

		canonical = parsed.ToString( "D" ).ToLowerInvariant();
		return true;
	}

	private static bool IsBoundedNonEmptyUtf8( string value )
		=> !string.IsNullOrEmpty( value ) && Encoding.UTF8.GetByteCount( value ) <= 64;

	private static LpPlayerHubSpendResult Project(
		LpPlayerHubOperationRecord operation,
		bool replayed )
	{
		return new LpPlayerHubSpendResult
		{
			OperationId = operation.OperationId,
			ResultCode = operation.ResultCode,
			Replayed = replayed,
			PointBalanceAfter = operation.PointBalanceAfter,
			SkillId = operation.SkillId,
			TierGranted = operation.Kind == LpPlayerHubOperationKind.Spend &&
			              operation.ResultCode == LpPlayerHubProgressionResultCode.Committed
				? operation.Tier
				: null,
			CatalogVersion = operation.CatalogVersion,
			CommittedAtUtc = operation.CommittedAtUtc,
			Seq = operation.Seq,
		};
	}

	private static LpPlayerHubSpendResult Transient(
		string operationId,
		LpPlayerHubProgressionResultCode resultCode,
		string skillId,
		string catalogVersion )
	{
		return new LpPlayerHubSpendResult
		{
			OperationId = operationId ?? string.Empty,
			ResultCode = resultCode,
			Replayed = false,
			PointBalanceAfter = null,
			SkillId = skillId ?? string.Empty,
			TierGranted = null,
			CatalogVersion = catalogVersion ?? string.Empty,
			CommittedAtUtc = null,
			Seq = null,
		};
	}
}
