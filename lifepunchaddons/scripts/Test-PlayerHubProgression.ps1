# Player Hub Batch 2 engine-free behavioral contract harness.
# Compiles the production domain/store sources in place with .NET SDK 10.0.300.

[CmdletBinding()]
param(
	[switch] $KeepTemp
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = [IO.Path]::GetFullPath((Join-Path $scriptRoot '..\..'))
$domainPath = Join-Path $repoRoot 'lifepunchaddons\Code\Addons\lifepunch\playerhub\code\progression\LpPlayerHubProgression.cs'
$storePath = Join-Path $repoRoot 'lifepunchaddons\Code\Addons\lifepunch\playerhub\code\progression\LpPlayerHubProgressionStore.cs'
$hostPath = Join-Path $repoRoot 'lifepunchaddons\Code\Addons\lifepunch\playerhub\code\progression\LpPlayerHubProgressionHost.cs'

$productionPaths = @($domainPath, $storePath)
$missing = @($productionPaths | Where-Object { -not [IO.File]::Exists($_) })
if ($missing.Count -gt 0) {
	throw "RED: production source missing: $($missing -join ', ')"
}

$sdkLines = @(& dotnet --list-sdks)
if (-not ($sdkLines | Where-Object { $_ -match '^10\.0\.300\s' })) {
	throw 'Required .NET SDK 10.0.300 is unavailable.'
}

$beforeHashes = @{}
foreach ($path in $productionPaths) {
	$beforeHashes[$path] = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash
}

if (-not [IO.File]::Exists($hostPath)) {
	throw "RED: Sandbox host source missing: $hostPath"
}

$hostSource = [IO.File]::ReadAllText($hostPath)
$rpcMatches = [regex]::Matches($hostSource, '\[Rpc\.(?:Host|Broadcast)[^\]]*\]')
if ($rpcMatches.Count -ne 1 -or $rpcMatches[0].Value -ne '[Rpc.Host]') {
	throw "Host RPC surface mismatch: expected exactly one [Rpc.Host], found $($rpcMatches.Count)."
}

$requestPattern = '(?s)\[Rpc\.Host\]\s*public\s+void\s+RequestSpend\s*\(\s*string\s+operationId\s*,\s*string\s+catalogVersion\s*,\s*string\s+skillId\s*,\s*int\s+tier\s*\)'
if ($hostSource -notmatch $requestPattern) {
	throw 'Host RequestSpend signature is not the pinned (string,string,string,int) void RPC.'
}

if ($hostSource -match '\[Rpc\.[^\]]+\]\s*(?:public|private|internal|protected)\s+\S+\s+(?:Get|Read|State)\w*\s*\(') {
	throw 'A client-reachable progression read RPC exists.'
}

if ($hostSource -notmatch 'Rpc\.CallerId' -or $hostSource -notmatch 'GetPlayerByConnectionId') {
	throw 'Host caller identity is not derived from Rpc.CallerId.'
}

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("lifepunch-playerhub-progression-" + [Guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($tempRoot) | Out-Null

try {
	$globalJson = @'
{
  "sdk": {
    "version": "10.0.300",
    "rollForward": "disable"
  }
}
'@
	[IO.File]::WriteAllText((Join-Path $tempRoot 'global.json'), $globalJson, [Text.UTF8Encoding]::new($false))

	$domainXml = [Security.SecurityElement]::Escape($domainPath)
	$storeXml = [Security.SecurityElement]::Escape($storePath)
	$project = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <LangVersion>14.0</LangVersion>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="$domainXml" Link="LpPlayerHubProgression.cs" />
    <Compile Include="$storeXml" Link="LpPlayerHubProgressionStore.cs" />
    <Compile Include="Program.cs" />
  </ItemGroup>
</Project>
"@
	[IO.File]::WriteAllText((Join-Path $tempRoot 'Harness.csproj'), $project, [Text.UTF8Encoding]::new($false))

	$program = @'
using System.Collections.Concurrent;
using System.Security.Cryptography;
using System.Text;
using LifePunch.DXRP.Addons.PlayerHub;

internal static class Program
{
	private const ulong A = 76561198000000001UL;
	private const ulong B = 76561198000000002UL;
	private const string Version = "fixture-v0";
	private const string SkillA = "resilience-slot-1";
	private const string SkillB = "recovery-slot-1";
	private static int _passed;
	private static int _guidCounter = 100;

	private static int Main()
	{
		var cases = new (string Name, Action Body)[]
		{
			("operation_id_case_variant_replays_original", OperationIdCaseVariantReplaysOriginal),
			("malformed_operation_id_is_transient", MalformedOperationIdIsTransient),
			("malformed_catalog_fields_and_tier_are_transient", MalformedCatalogFieldsAndTierAreTransient),
			("persisted_id_malformed_payload_replays_original", PersistedIdMalformedPayloadReplaysOriginal),
			("unknown_skill_shadows_lower_rungs", UnknownSkillShadowsLowerRungs),
			("catalog_mismatch_shadows_lower_rungs", CatalogMismatchShadowsLowerRungs),
			("tier_order_shadows_policy_and_balance", TierOrderShadowsPolicyAndBalance),
			("deny_all_shadows_insufficient_points", DenyAllShadowsInsufficientPoints),
			("unknown_skill_rejection_persists", UnknownSkillRejectionPersists),
			("skipped_tier_rejection_persists", SkippedTierRejectionPersists),
			("catalog_version_mismatch_persists", CatalogVersionMismatchPersists),
			("duplicate_returns_original_verbatim", DuplicateReturnsOriginalVerbatim),
			("atomic_debit_rank_purchase_preverification_failure", AtomicDebitRankPurchasePreverificationFailure),
			("negative_balance_property_sweep", NegativeBalancePropertySweep),
			("same_operation_concurrent_commits_once", SameOperationConcurrentCommitsOnce),
			("two_spends_one_point_exactly_one_commits", TwoSpendsOnePointExactlyOneCommits),
			("preverification_failure_retry_executes_once", PreverificationFailureRetryExecutesOnce),
			("indeterminate_readback_valid_journal_replays", IndeterminateReadbackValidJournalReplays),
			("indeterminate_readback_invalid_journal_executes_once", IndeterminateReadbackInvalidJournalExecutesOnce),
			("postcommit_state_failure_recovers_original", PostcommitStateFailureRecoversOriginal),
			("recovery_materialization_failure_blocks_unseen_operation", RecoveryMaterializationFailureBlocksUnseenOperation),
			("torn_state_recovers_from_journal", TornStateRecoversFromJournal),
			("equal_generation_pair_clears_journal", EqualGenerationPairClearsJournal),
			("stale_journal_is_discarded", StaleJournalIsDiscarded),
			("new_journal_old_state_completes", NewJournalOldStateCompletes),
			("torn_journal_is_not_authoritative", TornJournalIsNotAuthoritative),
			("empty_existing_state_fails_closed", EmptyExistingStateFailsClosed),
			("journal_operation_collection_identity_rejected", JournalOperationCollectionIdentityRejected),
			("migration_wrong_cardinality_not_authoritative", MigrationWrongCardinalityNotAuthoritative),
			("dual_corruption_fails_closed", DualCorruptionFailsClosed),
			("unsupported_version_preserves_original", UnsupportedVersionPreservesOriginal),
			("migration_exact_fold_and_genesis", MigrationExactFoldAndGenesis),
			("migration_uuid_v5_known_answer", MigrationUuidV5KnownAnswer),
			("migration_steam_id_mismatch_fails_closed", MigrationSteamIdMismatchFailsClosed),
			("migration_retirement_failure_preserves_v0", MigrationRetirementFailurePreservesV0),
			("migration_preverification_failure_retries_atomically", MigrationPreverificationFailureRetriesAtomically),
			("migration_indeterminate_readback_reconciles", MigrationIndeterminateReadbackReconciles),
			("migration_torn_state_recovers", MigrationTornStateRecovers),
			("migration_post_state_preclear_recovers", MigrationPostStatePreclearRecovers),
			("migration_interruption_metadata_stable", MigrationInterruptionMetadataStable),
			("journal_cardinality_live_one_migration_all_genesis", JournalCardinalityLiveOneMigrationAllGenesis),
			("two_principal_file_scope_isolation", TwoPrincipalFileScopeIsolation),
			("cross_player_operations_complete_independently", CrossPlayerOperationsCompleteIndependently),
			("disconnect_during_commit_never_partial", DisconnectDuringCommitNeverPartial),
			("disconnect_after_commit_replays", DisconnectAfterCommitReplays),
			("restart_rejoin_authoritative_readback", RestartRejoinAuthoritativeReadback),
		};

		foreach (var test in cases)
		{
			try
			{
				test.Body();
				_passed++;
				Console.WriteLine($"GREEN {test.Name}");
			}
			catch (Exception ex)
			{
				Console.Error.WriteLine($"RED {test.Name}: {ex.Message}");
				return 1;
			}
		}

		Console.WriteLine($"PLAYERHUB_PROGRESSION_GREEN passed={_passed} total={cases.Length}");
		return 0;
	}

	private static Fixture NewFixture(
		MemoryFileIo? io = null,
		ILpPlayerHubCostPolicy? policy = null,
		MutableClock? clock = null)
	{
		io ??= new MemoryFileIo();
		clock ??= new MutableClock(new DateTime(2026, 7, 23, 12, 0, 0, DateTimeKind.Utc));
		var log = new MemoryLog();
		var catalog = new FixtureCatalog();
		var store = new LpPlayerHubProgressionStore(io, log, catalog.Version, clock, "batch2-test");
		var progression = new LpPlayerHubProgression(store, catalog, policy ?? new TestCostPolicy(1), clock);
		return new Fixture(io, log, clock, progression);
	}

	private static string Op()
	{
		var n = Interlocked.Increment(ref _guidCounter);
		return $"00000000-0000-4000-8000-{n:D12}";
	}

	private static LpPlayerHubSpendResult Earn(Fixture fx, int points, ulong steamId = A)
		=> ExecuteTrustedEarn(fx.Progression, steamId, Op(), points, $"test:earn:{points}");

	private static LpPlayerHubSpendResult ExecuteTrustedEarn(
		LpPlayerHubProgression progression,
		ulong steamId,
		string operationId,
		int points,
		string sourceEventId)
	{
		var method = typeof(LpPlayerHubProgression).GetMethod(
			"ExecuteEarnFor",
			System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
		if (method is null)
			throw new InvalidOperationException("trusted earn injection seam missing");
		return (LpPlayerHubSpendResult)method.Invoke(
			progression,
			new object[] { steamId, operationId, points, sourceEventId })!;
	}

	private static LpPlayerHubSpendResult Spend(
		Fixture fx,
		string? operationId = null,
		string version = Version,
		string skill = SkillA,
		int tier = 1,
		ulong steamId = A)
		=> fx.Progression.ExecuteSpendFor(steamId, operationId ?? Op(), version, skill, tier);

	private static void OperationIdCaseVariantReplaysOriginal()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		var id = "A4FBAE0F-14C8-4B37-86A6-82CC5529D95E";
		var first = Spend(fx, id);
		var second = Spend(fx, id.ToLowerInvariant(), version: "", skill: "", tier: 0);
		Eq(LpPlayerHubProgressionResultCode.Committed, first.ResultCode);
		True(second.Replayed);
		Eq(first.OperationId, second.OperationId);
		Eq("a4fbae0f-14c8-4b37-86a6-82cc5529d95e", second.OperationId);
		Eq(2, fx.Progression.GetStateFor(A)!.Operations.Count);
	}

	private static void MalformedOperationIdIsTransient()
	{
		var fx = NewFixture();
		var result = Spend(fx, "not-a-guid");
		Eq(LpPlayerHubProgressionResultCode.MalformedRequest, result.ResultCode);
		Eq<int?>(null, result.PointBalanceAfter);
		Eq(0, fx.Progression.GetStateFor(A)!.Operations.Count);
	}

	private static void MalformedCatalogFieldsAndTierAreTransient()
	{
		var fx = NewFixture();
		var values = new[]
		{
			Spend(fx, Op(), "", SkillA, 1),
			Spend(fx, Op(), new string('a', 65), SkillA, 1),
			Spend(fx, Op(), Version, "", 1),
			Spend(fx, Op(), Version, string.Concat(Enumerable.Repeat("é", 33)), 1),
			Spend(fx, Op(), Version, SkillA, 0),
			Spend(fx, Op(), Version, SkillA, 6),
		};
		True(values.All(x => x.ResultCode == LpPlayerHubProgressionResultCode.MalformedRequest));
		True(values.All(x => x.PointBalanceAfter is null));
		Eq(0, fx.Progression.GetStateFor(A)!.Operations.Count);
	}

	private static void PersistedIdMalformedPayloadReplaysOriginal()
	{
		var fx = NewFixture(policy: new LpPlayerHubDenyAllCostPolicy());
		var id = Op();
		var first = Spend(fx, id);
		var replay = Spend(fx, id, "", "", 99);
		Eq(LpPlayerHubProgressionResultCode.Denied, first.ResultCode);
		Eq(first.ResultCode, replay.ResultCode);
		True(replay.Replayed);
		Eq(1, fx.Progression.GetStateFor(A)!.Operations.Count);
	}

	private static void UnknownSkillShadowsLowerRungs()
	{
		var fx = NewFixture(policy: new LpPlayerHubDenyAllCostPolicy());
		var result = Spend(fx, version: "wrong", skill: "unknown", tier: 5);
		Eq(LpPlayerHubProgressionResultCode.UnknownSkill, result.ResultCode);
	}

	private static void CatalogMismatchShadowsLowerRungs()
	{
		var fx = NewFixture(policy: new LpPlayerHubDenyAllCostPolicy());
		var result = Spend(fx, version: "wrong", skill: SkillA, tier: 5);
		Eq(LpPlayerHubProgressionResultCode.CatalogVersionMismatch, result.ResultCode);
	}

	private static void TierOrderShadowsPolicyAndBalance()
	{
		var fx = NewFixture(policy: new LpPlayerHubDenyAllCostPolicy());
		var result = Spend(fx, tier: 2);
		Eq(LpPlayerHubProgressionResultCode.TierOrderViolation, result.ResultCode);
	}

	private static void DenyAllShadowsInsufficientPoints()
	{
		var fx = NewFixture(policy: new LpPlayerHubDenyAllCostPolicy());
		var result = Spend(fx);
		Eq(LpPlayerHubProgressionResultCode.Denied, result.ResultCode);
		Eq(0, result.PointBalanceAfter);
	}

	private static void UnknownSkillRejectionPersists()
		=> AssertPersistentRejection("missing", Version, 1, LpPlayerHubProgressionResultCode.UnknownSkill);

	private static void SkippedTierRejectionPersists()
		=> AssertPersistentRejection(SkillA, Version, 2, LpPlayerHubProgressionResultCode.TierOrderViolation);

	private static void CatalogVersionMismatchPersists()
		=> AssertPersistentRejection(SkillA, "fixture-v999", 1, LpPlayerHubProgressionResultCode.CatalogVersionMismatch);

	private static void AssertPersistentRejection(
		string skill,
		string version,
		int tier,
		LpPlayerHubProgressionResultCode expected)
	{
		var fx = NewFixture();
		var id = Op();
		var first = Spend(fx, id, version, skill, tier);
		var replay = Spend(fx, id, Version, SkillA, 1);
		Eq(expected, first.ResultCode);
		Eq(expected, replay.ResultCode);
		True(replay.Replayed);
		Eq(0, replay.PointBalanceAfter);
		Eq(1, fx.Progression.GetStateFor(A)!.Operations.Count);
	}

	private static void DuplicateReturnsOriginalVerbatim()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		var id = Op();
		var first = Spend(fx, id);
		fx.Clock.UtcNow = fx.Clock.UtcNow.AddDays(1);
		var replay = Spend(fx, id);
		Eq(first.ResultCode, replay.ResultCode);
		Eq(first.PointBalanceAfter, replay.PointBalanceAfter);
		Eq(first.SkillId, replay.SkillId);
		Eq(first.TierGranted, replay.TierGranted);
		Eq(first.CatalogVersion, replay.CatalogVersion);
		Eq(first.CommittedAtUtc, replay.CommittedAtUtc);
		Eq(first.Seq, replay.Seq);
		True(replay.Replayed);
	}

	private static void AtomicDebitRankPurchasePreverificationFailure()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		var before = fx.Progression.GetStateFor(A)!;
		var beforeBytes = fx.Io.Files[LpPlayerHubProgressionStore.StateKey(A)];
		fx.Io.AddFault(IoKind.Write, ".journal.json", FaultMode.ThrowBefore);
		var id = Op();
		var failed = Spend(fx, id);
		Eq(LpPlayerHubProgressionResultCode.StoreFailure, failed.ResultCode);
		var afterFailure = fx.Progression.GetStateFor(A)!;
		Eq(before.PointBalance, afterFailure.PointBalance);
		Eq(before.Ranks.Count, afterFailure.Ranks.Count);
		Eq(beforeBytes, fx.Io.Files[LpPlayerHubProgressionStore.StateKey(A)]);
		var retry = Spend(NewFixture(fx.Io).WithClock(fx.Clock), id);
		Eq(LpPlayerHubProgressionResultCode.Committed, retry.ResultCode);
		Eq(0, retry.PointBalanceAfter);
	}

	private static void NegativeBalancePropertySweep()
	{
		for (var balance = 0; balance <= 8; balance++)
		{
			for (var cost = 0; cost <= 12; cost++)
			{
				var fx = NewFixture(policy: new TestCostPolicy(cost));
				if (balance > 0) Earn(fx, balance);
				var result = Spend(fx);
				var state = fx.Progression.GetStateFor(A)!;
				True(state.PointBalance >= 0);
				if (cost > balance)
					Eq(LpPlayerHubProgressionResultCode.InsufficientPoints, result.ResultCode);
			}
		}
	}

	private static void SameOperationConcurrentCommitsOnce()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		var id = Op();
		var results = Task.WhenAll(
			Task.Run(() => Spend(fx, id)),
			Task.Run(() => Spend(fx, id))).GetAwaiter().GetResult();
		Eq(1, results.Count(x => x.ResultCode == LpPlayerHubProgressionResultCode.Committed && !x.Replayed));
		Eq(1, results.Count(x => x.ResultCode == LpPlayerHubProgressionResultCode.Committed && x.Replayed));
		Eq(2, fx.Progression.GetStateFor(A)!.Operations.Count);
	}

	private static void TwoSpendsOnePointExactlyOneCommits()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		var results = Task.WhenAll(
			Task.Run(() => Spend(fx, skill: SkillA)),
			Task.Run(() => Spend(fx, skill: SkillB))).GetAwaiter().GetResult();
		Eq(1, results.Count(x => x.ResultCode == LpPlayerHubProgressionResultCode.Committed));
		Eq(1, results.Count(x => x.ResultCode == LpPlayerHubProgressionResultCode.InsufficientPoints));
		Eq(0, fx.Progression.GetStateFor(A)!.PointBalance);
	}

	private static void PreverificationFailureRetryExecutesOnce()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Write, ".journal.json", FaultMode.ThrowBefore);
		var id = Op();
		Eq(LpPlayerHubProgressionResultCode.StoreFailure, Spend(fx, id).ResultCode);
		var retryFx = NewFixture(fx.Io);
		var retry = Spend(retryFx, id);
		Eq(LpPlayerHubProgressionResultCode.Committed, retry.ResultCode);
		Eq(2, retryFx.Progression.GetStateFor(A)!.Operations.Count);
	}

	private static void IndeterminateReadbackValidJournalReplays()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Read, ".journal.json", FaultMode.ThrowBefore, matchingOccurrence: 2);
		var id = Op();
		Eq(LpPlayerHubProgressionResultCode.StoreFailure, Spend(fx, id).ResultCode);
		var retryFx = NewFixture(fx.Io);
		var retry = Spend(retryFx, id);
		Eq(LpPlayerHubProgressionResultCode.Committed, retry.ResultCode);
		True(retry.Replayed);
		Eq(0, retry.PointBalanceAfter);
	}

	private static void IndeterminateReadbackInvalidJournalExecutesOnce()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Write, ".journal.json", FaultMode.CorruptWrite);
		var id = Op();
		Eq(LpPlayerHubProgressionResultCode.StoreFailure, Spend(fx, id).ResultCode);
		var retryFx = NewFixture(fx.Io);
		var retry = Spend(retryFx, id);
		Eq(LpPlayerHubProgressionResultCode.Committed, retry.ResultCode);
		True(!retry.Replayed);
	}

	private static void PostcommitStateFailureRecoversOriginal()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		var id = Op();
		var committed = Spend(fx, id);
		Eq(LpPlayerHubProgressionResultCode.Committed, committed.ResultCode);
		var retryFx = NewFixture(fx.Io);
		var replay = Spend(retryFx, id);
		True(replay.Replayed);
		Eq(committed.Seq, replay.Seq);
	}

	private static void RecoveryMaterializationFailureBlocksUnseenOperation()
	{
		var fx = NewFixture();
		Earn(fx, 2);
		fx.Io.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		var firstId = Op();
		var first = Spend(fx, firstId, skill: SkillA);
		Eq(LpPlayerHubProgressionResultCode.Committed, first.ResultCode);
		var authoritativeJournal = fx.Io.Files[LpPlayerHubProgressionStore.JournalKey(A)];

		fx.Io.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		fx.Io.AddFault(IoKind.Write, ".journal.json", FaultMode.CorruptWrite);
		var second = Spend(fx, Op(), skill: SkillB);
		Eq(LpPlayerHubProgressionResultCode.StoreFailure, second.ResultCode);
		Eq(authoritativeJournal, fx.Io.Files[LpPlayerHubProgressionStore.JournalKey(A)]);

		var restart = NewFixture(fx.Io);
		var recovered = restart.Progression.GetStateFor(A)!;
		Eq(1, recovered.PointBalance);
		Eq(1, recovered.Ranks[SkillA]);
		True(!recovered.Ranks.ContainsKey(SkillB));
		var replay = Spend(restart, firstId, skill: SkillA);
		True(replay.Replayed);
	}

	private static void TornStateRecoversFromJournal()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Write, ".state.json", FaultMode.CorruptWrite);
		var committed = Spend(fx);
		Eq(LpPlayerHubProgressionResultCode.Committed, committed.ResultCode);
		var restart = NewFixture(fx.Io);
		var state = restart.Progression.GetStateFor(A)!;
		Eq(0, state.PointBalance);
		Eq(1, state.Ranks[SkillA]);
	}

	private static void EqualGenerationPairClearsJournal()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Write, ".journal.json", FaultMode.ThrowBefore, matchingOccurrence: 2);
		var result = Spend(fx);
		Eq(LpPlayerHubProgressionResultCode.Committed, result.ResultCode);
		True(!string.IsNullOrEmpty(fx.Io.Files[LpPlayerHubProgressionStore.JournalKey(A)]));
		var restart = NewFixture(fx.Io);
		_ = restart.Progression.GetStateFor(A);
		True(string.IsNullOrEmpty(restart.Io.Files[LpPlayerHubProgressionStore.JournalKey(A)]));
	}

	private static void StaleJournalIsDiscarded()
	{
		var fx = NewFixture();
		fx.Io.AddFault(IoKind.Write, ".journal.json", FaultMode.ThrowBefore, matchingOccurrence: 2);
		Earn(fx, 2);
		var stale = fx.Io.Files[LpPlayerHubProgressionStore.JournalKey(A)];
		fx.Io.Files[LpPlayerHubProgressionStore.JournalKey(A)] = string.Empty;
		Earn(fx, 1);
		fx.Io.Files[LpPlayerHubProgressionStore.JournalKey(A)] = stale;
		var restart = NewFixture(fx.Io);
		var state = restart.Progression.GetStateFor(A)!;
		Eq(3, state.PointBalance);
		True(string.IsNullOrEmpty(restart.Io.Files[LpPlayerHubProgressionStore.JournalKey(A)]));
	}

	private static void NewJournalOldStateCompletes()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		_ = Spend(fx);
		var restart = NewFixture(fx.Io);
		var state = restart.Progression.GetStateFor(A)!;
		Eq(0, state.PointBalance);
		Eq(1, state.Ranks[SkillA]);
	}

	private static void TornJournalIsNotAuthoritative()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Write, ".journal.json", FaultMode.CorruptWrite);
		var id = Op();
		Eq(LpPlayerHubProgressionResultCode.StoreFailure, Spend(fx, id).ResultCode);
		var restart = NewFixture(fx.Io);
		Eq(1, restart.Progression.GetStateFor(A)!.PointBalance);
		var retry = Spend(restart, id);
		Eq(LpPlayerHubProgressionResultCode.Committed, retry.ResultCode);
	}

	private static void EmptyExistingStateFailsClosed()
	{
		var io = new MemoryFileIo();
		io.Files[LpPlayerHubProgressionStore.StateKey(A)] = string.Empty;
		var fx = NewFixture(io);
		Eq<LpPlayerHubProgressionState?>(null, fx.Progression.GetStateFor(A));
		Eq(LpPlayerHubProgressionResultCode.StoreFailure, Spend(fx).ResultCode);
		True(fx.Log.Messages.Any(x =>
			x.Contains("state artifact invalid", StringComparison.Ordinal)));
	}

	private static void JournalOperationCollectionIdentityRejected()
	{
		var fx = NewFixture();
		Earn(fx, 2);
		fx.Io.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		var committed = Spend(fx);
		Eq(LpPlayerHubProgressionResultCode.Committed, committed.ResultCode);

		var key = LpPlayerHubProgressionStore.JournalKey(A);
		fx.Io.Files[key] = RechecksumJson(
			fx.Io.Files[key],
			root =>
			{
				var records = root["operationRecords"]!.AsArray();
				records[0]!["pointBalanceAfter"] = 999;
			});

		var restart = NewFixture(fx.Io);
		var state = restart.Progression.GetStateFor(A)!;
		Eq(2, state.PointBalance);
		True(!state.Ranks.ContainsKey(SkillA));
	}

	private static void MigrationWrongCardinalityNotAuthoritative()
	{
		var sourceIo = new MemoryFileIo();
		sourceIo.Files[LpPlayerHubProgressionStore.StateKey(A)] =
			$"{{\"steamId\":\"{A}\",\"points\":2,\"ranks\":{{\"{SkillA}\":2}}}}";
		sourceIo.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		var source = NewFixture(sourceIo);
		_ = source.Progression.GetStateFor(A);

		var journalKey = LpPlayerHubProgressionStore.JournalKey(A);
		var malformed = RechecksumJson(
			sourceIo.Files[journalKey],
			root =>
			{
				var stateOperations = root["state"]!["operations"]!.AsArray();
				root["state"]!["pointBalance"] = 99;
				root["operationRecords"] = new System.Text.Json.Nodes.JsonArray(
					stateOperations[^1]!.DeepClone());
			});

		sourceIo.Files[journalKey] = malformed;
		var restart = NewFixture(sourceIo);
		var state = restart.Progression.GetStateFor(A)!;
		Eq(2, state.PointBalance);
		Eq(2, state.Ranks[SkillA]);
		True(state.Migration is not null);
		True(string.IsNullOrEmpty(sourceIo.Files[journalKey]));
	}

	private static void DualCorruptionFailsClosed()
	{
		var io = new MemoryFileIo();
		io.Files[LpPlayerHubProgressionStore.StateKey(A)] = "{bad-state";
		io.Files[LpPlayerHubProgressionStore.JournalKey(A)] = "{bad-journal";
		var fx = NewFixture(io);
		Eq<LpPlayerHubProgressionState?>(null, fx.Progression.GetStateFor(A));
		var result = Spend(fx);
		Eq(LpPlayerHubProgressionResultCode.StoreFailure, result.ResultCode);
		True(io.Files.Keys.Count(x => x.Contains(".corrupt.", StringComparison.Ordinal)) >= 2);
		True(fx.Log.Messages.Count >= 2);
	}

	private static void UnsupportedVersionPreservesOriginal()
	{
		var io = new MemoryFileIo();
		var key = LpPlayerHubProgressionStore.StateKey(A);
		var original = "{\"storeVersion\":2,\"future\":\"preserve\"}";
		io.Files[key] = original;
		var before = Sha(original);
		var fx = NewFixture(io);
		Eq<LpPlayerHubProgressionState?>(null, fx.Progression.GetStateFor(A));
		Eq(before, Sha(io.Files[key]));
		Eq(original, io.Files[key]);
		True(io.Files.Keys.Any(x => x.Contains(".unsupported.", StringComparison.Ordinal)));
	}

	private static void MigrationExactFoldAndGenesis()
	{
		var io = new MemoryFileIo();
		var key = LpPlayerHubProgressionStore.StateKey(A);
		var legacy = $"{{\"steamId\":\"{A}\",\"points\":2,\"ranks\":{{\"{SkillB}\":1,\"{SkillA}\":2}}}}";
		io.Files[key] = legacy;
		var fx = NewFixture(io);
		var state = fx.Progression.GetStateFor(A)!;
		Eq(2, state.PointBalance);
		Eq(2, state.Ranks[SkillA]);
		Eq(1, state.Ranks[SkillB]);
		Eq(4, state.Operations.Count);
		Eq(LpPlayerHubOperationKind.Earn, state.Operations[0].Kind);
		Eq(SkillB, state.Operations[1].SkillId);
		Eq(1, state.Operations[1].Tier);
		Eq(SkillA, state.Operations[2].SkillId);
		Eq(1, state.Operations[2].Tier);
		Eq(SkillA, state.Operations[3].SkillId);
		Eq(2, state.Operations[3].Tier);
		True(state.Operations.All(x => x.CatalogVersion == Version));
		True(state.Operations.All(x => x.Generation == 1));
		True(state.Operations.Select(x => x.Seq).SequenceEqual(new long[] { 1, 2, 3, 4 }));
		True(state.Operations.Skip(1).All(x => x.PointsDelta == 0 && x.PointBalanceAfter == 2));
		Eq(legacy, io.Files[LpPlayerHubProgressionStore.RetiredV0Key(A)]);
		Eq(0, state.Migration!.MigratedFromVersion);
	}

	private static void MigrationUuidV5KnownAnswer()
	{
		var actual = LpPlayerHubProgressionStore.CreateMigrationOperationId(A, 1);
		Eq("fe0aeb3e-681a-5681-9c17-6025f674f34b", actual);
	}

	private static void MigrationSteamIdMismatchFailsClosed()
	{
		var io = new MemoryFileIo();
		var key = LpPlayerHubProgressionStore.StateKey(A);
		io.Files[key] = $"{{\"steamId\":\"{B}\",\"points\":1,\"ranks\":{{}}}}";
		var fx = NewFixture(io);
		Eq<LpPlayerHubProgressionState?>(null, fx.Progression.GetStateFor(A));
		True(io.Files.Keys.Any(x => x.Contains(".identity-mismatch.", StringComparison.Ordinal)));
		Eq(LpPlayerHubProgressionResultCode.StoreFailure, Spend(fx).ResultCode);
	}

	private static void MigrationRetirementFailurePreservesV0()
	{
		var io = new MemoryFileIo();
		var key = LpPlayerHubProgressionStore.StateKey(A);
		var legacy = $"{{\"steamId\":\"{A}\",\"points\":1,\"ranks\":{{}}}}";
		io.Files[key] = legacy;
		io.AddFault(IoKind.Write, ".v0.retired.json", FaultMode.ThrowBefore);
		var fx = NewFixture(io);
		Eq<LpPlayerHubProgressionState?>(null, fx.Progression.GetStateFor(A));
		Eq(legacy, io.Files[key]);
		True(!io.Files.ContainsKey(LpPlayerHubProgressionStore.JournalKey(A)));
	}

	private static void MigrationPreverificationFailureRetriesAtomically()
	{
		var io = new MemoryFileIo();
		var stateKey = LpPlayerHubProgressionStore.StateKey(A);
		var legacy = $"{{\"steamId\":\"{A}\",\"points\":2,\"ranks\":{{\"{SkillA}\":2}}}}";
		io.Files[stateKey] = legacy;
		io.AddFault(IoKind.Write, ".journal.json", FaultMode.ThrowBefore);
		var first = NewFixture(io);
		Eq<LpPlayerHubProgressionState?>(null, first.Progression.GetStateFor(A));
		Eq(legacy, io.Files[stateKey]);
		var retry = NewFixture(io);
		var state = retry.Progression.GetStateFor(A)!;
		Eq(2, state.PointBalance);
		Eq(2, state.Ranks[SkillA]);
		Eq(3, state.Operations.Count);
	}

	private static void MigrationIndeterminateReadbackReconciles()
	{
		var io = new MemoryFileIo();
		io.Files[LpPlayerHubProgressionStore.StateKey(A)] =
			$"{{\"steamId\":\"{A}\",\"points\":1,\"ranks\":{{\"{SkillA}\":1}}}}";
		var clock = new MutableClock(new DateTime(2026, 7, 23, 2, 3, 4, DateTimeKind.Utc));
		io.AddFault(IoKind.Read, ".journal.json", FaultMode.ThrowBefore);
		var first = NewFixture(io, clock: clock);
		Eq<LpPlayerHubProgressionState?>(null, first.Progression.GetStateFor(A));
		var journal = io.Files[LpPlayerHubProgressionStore.JournalKey(A)];
		True(!string.IsNullOrEmpty(journal));
		clock.UtcNow = clock.UtcNow.AddDays(5);
		var retry = NewFixture(io, clock: clock);
		var state = retry.Progression.GetStateFor(A)!;
		Eq(new DateTime(2026, 7, 23, 2, 3, 4, DateTimeKind.Utc), state.Migration!.MigrationUtc);
		Eq(1, state.Ranks[SkillA]);
	}

	private static void MigrationTornStateRecovers()
	{
		var io = new MemoryFileIo();
		io.Files[LpPlayerHubProgressionStore.StateKey(A)] =
			$"{{\"steamId\":\"{A}\",\"points\":3,\"ranks\":{{\"{SkillA}\":1}}}}";
		io.AddFault(IoKind.Write, ".state.json", FaultMode.CorruptWrite);
		var first = NewFixture(io);
		var authoritative = first.Progression.GetStateFor(A)!;
		Eq(3, authoritative.PointBalance);
		var retry = NewFixture(io);
		var state = retry.Progression.GetStateFor(A)!;
		Eq(3, state.PointBalance);
		Eq(1, state.Ranks[SkillA]);
	}

	private static void MigrationPostStatePreclearRecovers()
	{
		var io = new MemoryFileIo();
		io.Files[LpPlayerHubProgressionStore.StateKey(A)] =
			$"{{\"steamId\":\"{A}\",\"points\":4,\"ranks\":{{\"{SkillA}\":1}}}}";
		io.AddFault(IoKind.Write, ".journal.json", FaultMode.ThrowBefore, matchingOccurrence: 2);
		var first = NewFixture(io);
		var state = first.Progression.GetStateFor(A)!;
		Eq(4, state.PointBalance);
		True(!string.IsNullOrEmpty(io.Files[LpPlayerHubProgressionStore.JournalKey(A)]));
		var retry = NewFixture(io);
		var recovered = retry.Progression.GetStateFor(A)!;
		Eq(4, recovered.PointBalance);
		True(string.IsNullOrEmpty(io.Files[LpPlayerHubProgressionStore.JournalKey(A)]));
	}

	private static void MigrationInterruptionMetadataStable()
	{
		var io = new MemoryFileIo();
		io.Files[LpPlayerHubProgressionStore.StateKey(A)] =
			$"{{\"steamId\":\"{A}\",\"points\":1,\"ranks\":{{\"{SkillA}\":1}}}}";
		var clock = new MutableClock(new DateTime(2026, 7, 23, 1, 2, 3, DateTimeKind.Utc));
		io.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		var first = NewFixture(io, clock: clock);
		var authoritative = first.Progression.GetStateFor(A)!;
		var migrationUtc = authoritative.Migration!.MigrationUtc;
		clock.UtcNow = clock.UtcNow.AddDays(10);
		var restart = NewFixture(io, clock: clock);
		var recovered = restart.Progression.GetStateFor(A)!;
		Eq(migrationUtc, recovered.Migration!.MigrationUtc);
		Eq("batch2-test", recovered.Migration.MigratorBuild);
	}

	private static void JournalCardinalityLiveOneMigrationAllGenesis()
	{
		var live = NewFixture();
		live.Io.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		Earn(live, 1);
		var liveRaw = live.Io.Files[LpPlayerHubProgressionStore.JournalKey(A)];
		Eq(1, CountCandidateRecords(liveRaw));

		var io = new MemoryFileIo();
		io.Files[LpPlayerHubProgressionStore.StateKey(A)] =
			$"{{\"steamId\":\"{A}\",\"points\":2,\"ranks\":{{\"{SkillA}\":2}}}}";
		io.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		var migration = NewFixture(io);
		var state = migration.Progression.GetStateFor(A)!;
		var migrationRaw = io.Files[LpPlayerHubProgressionStore.JournalKey(A)];
		Eq(state.Operations.Count, CountCandidateRecords(migrationRaw));
	}

	private static int CountCandidateRecords(string json)
	{
		using var doc = System.Text.Json.JsonDocument.Parse(json);
		return doc.RootElement.GetProperty("operationRecords").GetArrayLength();
	}

	private static void TwoPrincipalFileScopeIsolation()
	{
		var fx = NewFixture();
		Earn(fx, 1, A);
		fx.Io.AccessLog.Clear();
		_ = Spend(fx, steamId: A);
		var aToken = $"/{A}.";
		var bToken = $"/{B}.";
		True(fx.Io.AccessLog.Any(x => x.Contains(aToken, StringComparison.Ordinal)));
		True(fx.Io.AccessLog.All(x => !x.Contains(bToken, StringComparison.Ordinal)));
	}

	private static void CrossPlayerOperationsCompleteIndependently()
	{
		var fx = NewFixture();
		var results = Task.WhenAll(
			Task.Run(() => ExecuteTrustedEarn(fx.Progression, A, Op(), 1, "test:a")),
			Task.Run(() => ExecuteTrustedEarn(fx.Progression, B, Op(), 2, "test:b"))).GetAwaiter().GetResult();
		True(results.All(x => x.ResultCode == LpPlayerHubProgressionResultCode.Committed));
		Eq(1, fx.Progression.GetStateFor(A)!.PointBalance);
		Eq(2, fx.Progression.GetStateFor(B)!.PointBalance);
	}

	private static void DisconnectDuringCommitNeverPartial()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Write, ".journal.json", FaultMode.CorruptWrite);
		var id = Op();
		_ = Spend(fx, id);
		var rejoin = NewFixture(fx.Io);
		var beforeRetry = rejoin.Progression.GetStateFor(A)!;
		Eq(1, beforeRetry.PointBalance);
		True(!beforeRetry.Ranks.ContainsKey(SkillA));
		var retry = Spend(rejoin, id);
		Eq(LpPlayerHubProgressionResultCode.Committed, retry.ResultCode);
	}

	private static void DisconnectAfterCommitReplays()
	{
		var fx = NewFixture();
		Earn(fx, 1);
		fx.Io.AddFault(IoKind.Write, ".state.json", FaultMode.ThrowBefore);
		var id = Op();
		var dropped = Spend(fx, id);
		Eq(LpPlayerHubProgressionResultCode.Committed, dropped.ResultCode);
		var rejoin = NewFixture(fx.Io);
		var retry = Spend(rejoin, id);
		Eq(LpPlayerHubProgressionResultCode.Committed, retry.ResultCode);
		True(retry.Replayed);
	}

	private static void RestartRejoinAuthoritativeReadback()
	{
		var fx = NewFixture();
		Earn(fx, 2);
		var committed = Spend(fx);
		var restart = NewFixture(fx.Io);
		var state = restart.Progression.GetStateFor(A)!;
		Eq(committed.PointBalanceAfter, state.PointBalance);
		Eq(1, state.Ranks[SkillA]);
		Eq(committed.Seq, state.Seq);
	}

	private static string Sha(string value)
		=> Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(value)));

	private static string RechecksumJson(
		string raw,
		Action<System.Text.Json.Nodes.JsonObject> mutate)
	{
		var root = System.Text.Json.Nodes.JsonNode.Parse(raw)!.AsObject();
		mutate(root);
		root["checksum"] = string.Empty;
		var canonical = root.ToJsonString(new System.Text.Json.JsonSerializerOptions
		{
			WriteIndented = false,
		});
		root["checksum"] = Convert.ToHexString(
			SHA256.HashData(Encoding.UTF8.GetBytes(canonical))).ToLowerInvariant();
		return root.ToJsonString(new System.Text.Json.JsonSerializerOptions
		{
			WriteIndented = false,
		});
	}

	private static void True(bool condition, string? message = null)
	{
		if (!condition) throw new InvalidOperationException(message ?? "assertion was false");
	}

	private static void Eq<T>(T expected, T actual)
	{
		if (!EqualityComparer<T>.Default.Equals(expected, actual))
			throw new InvalidOperationException($"expected <{expected}> actual <{actual}>");
	}
}

internal sealed record Fixture(
	MemoryFileIo Io,
	MemoryLog Log,
	MutableClock Clock,
	LpPlayerHubProgression Progression)
{
	public Fixture WithClock(MutableClock clock)
		=> this with { Clock = clock };
}

internal sealed class FixtureCatalog : ILpPlayerHubProgressionCatalog
{
	private static readonly HashSet<string> Known = new(StringComparer.Ordinal)
	{
		"resilience-slot-1",
		"recovery-slot-1",
	};

	public string Version => "fixture-v0";
	public bool ContainsSkill(string skillId) => Known.Contains(skillId);
	public int MaxTier(string skillId) => Known.Contains(skillId) ? 5 : 0;
}

internal sealed class TestCostPolicy : ILpPlayerHubCostPolicy
{
	private readonly int _cost;
	public TestCostPolicy(int cost) => _cost = cost;
	public LpPlayerHubCostDecision Evaluate(string catalogVersion, string skillId, int tier)
		=> new(true, _cost);
}

internal sealed class MutableClock : ILpPlayerHubClock
{
	public MutableClock(DateTime utcNow) => UtcNow = utcNow;
	public DateTime UtcNow { get; set; }
	public DateTime GetUtcNow() => UtcNow;
}

internal sealed class MemoryLog : ILpPlayerHubProgressionLog
{
	public List<string> Messages { get; } = new();
	public void Error(string message) => Messages.Add(message);
}

internal enum IoKind
{
	Exists,
	Read,
	Write,
	Delete,
}

internal enum FaultMode
{
	ThrowBefore,
	ThrowAfter,
	CorruptWrite,
}

internal sealed class FaultRule
{
	public required IoKind Kind { get; init; }
	public required string PathContains { get; init; }
	public required FaultMode Mode { get; init; }
	public required int TargetOccurrence { get; init; }
	public int Matches { get; set; }
}

internal sealed class MemoryFileIo : IProgressionFileIo
{
	private readonly object _gate = new();
	private readonly List<FaultRule> _faults = new();
	public ConcurrentDictionary<string, string> Files { get; } = new(StringComparer.Ordinal);
	public List<string> AccessLog { get; } = new();

	public void AddFault(IoKind kind, string pathContains, FaultMode mode, int matchingOccurrence = 1)
	{
		lock (_gate)
		{
			_faults.Add(new FaultRule
			{
				Kind = kind,
				PathContains = pathContains,
				Mode = mode,
				TargetOccurrence = matchingOccurrence,
			});
		}
	}

	public bool FileExists(string path)
	{
		var fault = Before(IoKind.Exists, path);
		var value = Files.ContainsKey(path);
		After(fault, path);
		return value;
	}

	public string ReadAllText(string path)
	{
		var fault = Before(IoKind.Read, path);
		if (!Files.TryGetValue(path, out var value))
			throw new FileNotFoundException(path);
		After(fault, path);
		return value;
	}

	public void WriteAllText(string path, string contents)
	{
		var fault = Before(IoKind.Write, path);
		if (fault?.Mode == FaultMode.CorruptWrite)
		{
			Files[path] = contents[..Math.Max(1, contents.Length / 2)];
			return;
		}

		Files[path] = contents;
		After(fault, path);
	}

	public void DeleteFile(string path)
	{
		var fault = Before(IoKind.Delete, path);
		Files.TryRemove(path, out _);
		After(fault, path);
	}

	private FaultRule? Before(IoKind kind, string path)
	{
		lock (_gate)
		{
			AccessLog.Add($"{kind} {path}");
			var fault = _faults.FirstOrDefault(x =>
				x.Kind == kind &&
				path.Contains(x.PathContains, StringComparison.Ordinal) &&
				++x.Matches == x.TargetOccurrence);
			if (fault?.Mode == FaultMode.ThrowBefore)
			{
				_faults.Remove(fault);
				throw new IOException($"injected {kind} failure for {path}");
			}
			return fault;
		}
	}

	private void After(FaultRule? fault, string path)
	{
		if (fault is null) return;
		lock (_gate) _faults.Remove(fault);
		if (fault.Mode == FaultMode.ThrowAfter)
			throw new IOException($"injected post-effect failure for {path}");
	}
}
'@
	[IO.File]::WriteAllText((Join-Path $tempRoot 'Program.cs'), $program, [Text.UTF8Encoding]::new($false))

	& dotnet run --project (Join-Path $tempRoot 'Harness.csproj') --configuration Release --nologo
	if ($LASTEXITCODE -ne 0) {
		throw "Player Hub progression harness failed with exit code $LASTEXITCODE."
	}

	foreach ($path in $productionPaths) {
		$afterHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash
		if ($afterHash -ne $beforeHashes[$path]) {
			throw "Production source changed while under harness: $path"
		}
		Write-Host "PRODUCTION_SOURCE_SHA256 $afterHash $path"
	}

	Write-Host 'PASS: Player Hub Batch 2 progression behavioral contract.'
}
finally {
	if (-not $KeepTemp -and [IO.Directory]::Exists($tempRoot)) {
		Remove-Item -LiteralPath $tempRoot -Recurse -Force
	}
	elseif ($KeepTemp) {
		Write-Host "HARNESS_TEMP $tempRoot"
	}
}
