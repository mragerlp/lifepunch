# lpbitcoin HYBRID CONFIG SPEC v1.2 — tracked record

> **Class: SPEC (graduated 2026-07-12).** Drafted by Codex (`comms\codex\0003`), graded
> spec-ready by Fable, ratified by Bloodwave with micro-rulings **N** and **O** folded below.
> **IMPLEMENTATION IS POST-MERGE** — a lane-B ladder rung, NOT r3 scope.
>
> **RULING N —** schema 1 **REJECTS** the reserved multipliers (`miningRateMultiplier`,
> `upgradeCostMultiplier`) until consumers exist. *A portal value that does nothing is a lie.*
>
> **RULING O —** T3 ladders **MUST be monotonic non-decreasing** in both effect and cost.
> A non-monotonic candidate **REJECTS whole-object** with the loud sensor. Operator-authored
> weird ladders require a future canon change, never silent acceptance.
>
> Cross-ref: `LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md` (the ruled record this implements).

FROM: CODEX
SEQ: 0003
DATE: 2026-07-12
STATE BASIS: LIFEPUNCH develop @ 6c9e86acb43e350e028dad2336766d08c9aa14f7; DXRP fork origin/develop @ b9d6068f8d003ec625f8b9563e6772ff7e93a6a3
RE: Proposal-only lpbitcoin hybrid config extraction specification v1.2 / BLOCK-0 resolution

# PROPOSAL ONLY — LPBITCOIN HYBRID CONFIG EXTRACTION SPEC v1.2

This is advice-class data. Red is the canonical-tree implementer; Bloodwave is the only execution authority. If ratified, this comms payload must graduate through Red into a **new** tracked record, proposed path `lifepunch/docs/handoff/LPBITCOIN_HYBRID_CONFIG_EXTRACTION_SPEC_V1_2_2026-07-12.md`, citing rather than editing the frozen `LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md` record.

## 0. R7 STEP 0 / read basis

**CONFIRMED:** sanctioned non-forcing fetch exited 0. Local `develop`, `origin/develop`, and `HEAD` all resolve to `6c9e86acb43e350e028dad2336766d08c9aa14f7`. LIFEPUNCH claims below read Git object bytes at that SHA, never Red's dirty files. DXRP `origin/develop` was independently compared to the remote and both resolve to `b9d6068f8d003ec625f8b9563e6772ff7e93a6a3`.

Sensors: R7 authority `comms/fable/0003_FABLE_GREEN-GRADE-R7-NEXT_2026-07-12.md:19-22`; terminal ref capture 2026-07-12T22:26Z; `git ls-remote --heads origin develop` in the nested DXRP mirror.

**Editor Access Law absorbed:** Red has DRIVE authority; Codex is OBSERVE-only and may read status/logs/screenshots but never sync, hotload, issue side-effecting commands, or mutate play/scene state (`comms/STACK_ARCHITECTURE.md:17-30`, external transport law). No editor bridge call was made for this static specification.

## 1. Outcome

BLOCK-0 resolves as two deliberately different configuration lanes:

1. **T3 shipped balance shape** — a flat Monnow-style content config with defaults in C# initializers, read through `BaseEntity.GetConfig(fallback)`. It activates only after portal edit -> Save -> Sync -> fresh server restart.
2. **Store live economy dials** — one strict, versioned JSON document at `lifepunch:bitcoin:config:settings`, read by the existing `LpBitcoinPortalEconomySync` host service into a last-known-good cache and applied live as one atomic tuple.

The merged v1 implementation already establishes both lanes. v1.2 is a hardening/reconciliation delta; it does not reopen the passing v1 landing gate. Its governing invariant is:

> **one document -> one validated candidate -> one main-thread swap -> one local revision increment -> one reliable broadcast -> one audit.**

No per-field mixing, no silent zero/default collapse, and no client-authoritative configuration.

## 2. Pinned current-state reconciliation

### CONFIRMED present

- The Monnow precedent is one content entry reading one flat config object; in-game tier levels are state, not separate tier content entries. The supplied build has 29 fields, not the superseded ~48-field claim (`CODEX_LPBITCOIN_BLOCK0_CONFIG_STUDY_2026-07-12.md:10-13 @ 6c9e86a`; ruled correction `LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md:12`).
- `LpBitcoinRackEntity` reads `GetConfig(new LpBitcoinRackConfig())` and passes it to the global track latch (`LpBitcoinRackEntity.cs:283-290 @ 6c9e86a`).
- `LpBitcoinRackConfig` carries flat shipped defaults for `MaxTier`, five effect multipliers, and five integer-satoshi costs (`LpBitcoinRackConfig.cs:47-61 @ 6c9e86a`).
- `rack_compute` is process-global and one-shot: first config registers; later divergence is ignored and warned once (`LpBitcoinComputeTrack.cs:28-57,83-101 @ 6c9e86a`). This is the ratified v1.2-B behavior, not per-rack configuration (`LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md:7`).
- `LpBitcoinPortalEconomySync` already owns the Store bridge and atomic key constant (`LpBitcoinPortalEconomySync.cs:45,48-54 @ 6c9e86a`). Extend it; do not create a second service.
- The service correctly avoids `GetStoreJson<T>` and reads raw text with `GetStore` (`LpBitcoinPortalEconomySync.cs:263-269`). This avoids DXRP's silent JSON swallow (`ServerApiClient.Store.cs:136-142 @ b9d6068`).
- `Permission.ManageEconomy` already exists and is used by a host RPC (`Permission.cs:148-149`; `AdminSystem.cs:105-113 @ b9d6068`). `Permission.EditServer` already exists at `Permission.cs:17-18`. The addon cannot and must not extend this mirrored fork enum (`Permission.cs:7`).

### v1.2 hardening delta

- **PARTIAL LKG:** the service seeds from last-applied fields (`LpBitcoinPortalEconomySync.cs:52-54,252-257`), but a malformed present bundle returns `false` silently (`:617-681`) and then falls through to legacy/item sources (`:297-375`). A malformed authoritative document must hold LKG, not become “absent.”
- **REFUTED atomic-document semantics:** current parsing accepts fields independently (`:269-289,655-675`). A present bundle can therefore mix one new field with legacy or item values. v1.2 is all-or-nothing.
- **REFUTED atomic-apply semantics:** current refresh calls hub apply then redeem apply (`:385-386`), and each broadcasts independently (`:394-421`). Clients can observe an intermediate tuple and `PortalEconomyRevision` increments through separate methods.
- **ABSENT schema/revision enforcement:** `schemaVersion` and document `revision` have zero tokens in `LpBitcoinPortalEconomySync.cs @ 6c9e86a`, despite the ruled key contract requiring both (`LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md:3`).
- **PARTIAL host authority:** runtime guards exist (`LpBitcoinPortalEconomySync.cs:135-155,378-386`), but the required invariant assertion is absent. v1.2 adds an explicit host assertion at schedule/apply boundaries, derived from DXRP's `Assert.True(Networking.IsHost)` pattern (`BaseEntity.cs:117-123 @ b9d6068`).

## 3. Layer ownership and precedence

| Surface | Authority | Activation | v1.2 content |
|---|---|---|---|
| T1 server config | DXRP server config | next restart | None added by BLOCK-0. Check first; do not duplicate existing T1 knobs. |
| T2 content override | Gamemode content entry | Save + Sync + restart | Overrides the shipped rack config for that content entry. |
| T3 shipped defaults | Addon code/content defaults | addon revision + install/update + Sync + restart | COMPUTE effect and cost ladder only. |
| Store live settings | `lifepunch:bitcoin:config:settings` | successful reload/periodic refresh | cash/BTC base rate, cash multiplier, portal stack redeem cash. |
| Portal MARKET | market item binding | gamemode Save + Sync | Spawn price; never duplicated into T3/Store. |

Precedence inside each lane:

- T3 candidate = C# fallback initializers -> content BaseConfig -> content ConfigOverride, using DXRP's case-insensitive merge (`Config.GameMode.cs:8-46,71-124 @ b9d6068`).
- Live candidate = valid atomic Store document. Legacy scalar keys and inventory-item text are **cold-bootstrap migration fallback only** when no atomic document has ever been applied. Shipped defaults are the safe initial LKG.
- T3 never reads Store. Store never overwrites the T3 ladder. `/lpbitcoinreloadconfig` reloads Store live dials only; it does not relatch T3.

## 4. T3 COMPUTE schema

Normative shape, matching the current class and Monnow flat-field pattern:

```json
{
  "MaxTier": 5,
  "Tier1EffectMultiplier": 2,
  "Tier2EffectMultiplier": 4,
  "Tier3EffectMultiplier": 8,
  "Tier4EffectMultiplier": 16,
  "Tier5EffectMultiplier": 32,
  "Tier1CostSats": 25000000,
  "Tier2CostSats": 75000000,
  "Tier3CostSats": 200000000,
  "Tier4CostSats": 600000000,
  "Tier5CostSats": 1600000000
}
```

Rules:

1. `MaxTier` MUST be in `[1,5]`; do not silently clamp malformed portal input into a different operator intent.
2. All five effect values MUST be positive integers. All five costs MUST be positive `long` satoshi values. A zero/negative price can become a free persistent tier and is rejected before registration.
3. Quote multiplication by rack yield MUST be checked for finite/range-safe conversion before returning `long`; overflow rejects the purchase, never wraps or saturates silently.
4. Validation is whole-object. Any invalid field rejects the entire T3 candidate and latches the shipped default object with a loud `LP_CONFIG_T3_REJECTED` sensor naming content id and field; no per-field repair/clamp.
5. Base-rig scalars remain outside v1.2: `StartClockGhz`, `BaseSpeed`, `PayoutIntervalSeconds`, `BufferCapTicks`, standard/advanced yield constants remain canon in `LpBitcoinEconomy` (`LpBitcoinEconomy.cs:15-18,91-119`; v1.2-C ruling `LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md:8`). Their const->static extraction requires its own proposal and GO.

### One-shot latch contract

- `rack_compute` remains one global track. The first valid rack config seen by `EnsureRegistered` is latched.
- `EnsureRegistered` SHOULD receive the source content id/ident for diagnostics in addition to the validated config.
- Every later rack config is compared field-for-field to the latch. Exact match is a no-op. Divergence emits exactly one loud `LP_CONFIG_T3_MISMATCH` with latched source/fingerprint and rejected source/fingerprint, then keeps the original latch, matching the ratified first-wins rule.
- **Deployment precondition:** every standard and advanced rack content entry must carry byte-normalized/effective-value-equivalent ladder config. A mismatch warning is a deployment **HOLD**, not permission to ship spawn-order-dependent economics.
- T3 proof requires a fresh process. Hotload is not an activation sensor for a static one-shot latch.

**NEEDS-BLOODWAVE-CONFIRM — ladder ordering:** recommend rejecting a decreasing effect or cost ladder because later persistent tiers should not buy less capability or cost less than their prerequisites. Existing canon fixes shipped defaults but does not explicitly say whether operators may intentionally author non-monotonic ladders. Until ruled, v1.2 MUST at least reject non-positive values and MUST log non-monotonic values; it must not silently sort them.

## 5. Store live-settings schema

Single key only:

`lifepunch:bitcoin:config:settings`

Active v1.2 document:

```json
{
  "schemaVersion": 1,
  "revision": 1,
  "cashUsdPerBtc": 5000,
  "cashRateMultiplier": 1.0,
  "portalRedeemCashUsd": 5000
}
```

Required validation:

- `schemaVersion == 1` exactly. Unknown schema rejects and holds LKG.
- `revision >= 1`, represented as `long` in code.
- `cashUsdPerBtc > 0` and `portalRedeemCashUsd > 0`.
- `cashRateMultiplier > 0`, finite, not NaN/Infinity.
- Derived `cashUsdPerBtc * cashRateMultiplier` must be finite and within the payout conversion's supported numeric range. Validation failure holds LKG.
- Missing required fields, duplicate aliases, wrong JSON types, unknown active fields, or malformed JSON reject the **whole document**.
- Same revision + same normalized tuple = no-op. Same revision + different tuple = revision-collision rejection. Lower revision = stale rejection. Higher revision + valid tuple = candidate.
- Store contains gameplay numbers only. No API keys, tokens, webhooks, or credential-bearing URLs (`DXRP_PLATFORM_DOCTRINE.md:4,13,21 @ 6c9e86a`).

Use a sealed data class such as `LpBitcoinLiveSettingsDocument`; do not deserialize directly into mutable global economy state.

**NEEDS-BLOODWAVE-CONFIRM — reserved multipliers:** the v1.1 header names optional `miningRateMultiplier` and `upgradeCostMultiplier`, while v1.2-C says only the three cash dials shipped and base-rig extraction is deferred (`LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md:3,8`). Recommended ruling: schema 1 rejects these fields while they have no consumer, rather than accepting a portal value that does nothing. Add them in schema 2 or an amended schema 1 only with their consumers and gates.

## 6. Read/validate/LKG state machine

`LpBitcoinPortalEconomySync` remains the sole service. Required flow:

1. Entry guard: `Networking.IsHost`, service valid, authorization key present, no refresh in flight. At the internal schedule/apply boundary, assert host authority as an invariant as well as returning safely from public commands.
2. Set `_refreshInFlight` before the first await. Concurrent periodic/reload requests coalesce; they never race two candidates.
3. Read the atomic key with raw `ServerApiClient.GetStore`, never `GetStoreJson<T>`.
4. Parse into a discriminated outcome: `Absent`, `Valid(candidate)`, or `Invalid(reason)`. The parse catch MUST log the exception/reason; bare `catch { return false; }` is forbidden.
5. If raw text is present but invalid: emit `LP_CONFIG_PARSE_REJECT`, then `LP_CONFIG_LKG_HOLD`; do not consult legacy keys or item text.
6. If raw text is absent/blank:
   - before any external config has been applied in this process, attempt the three legacy scalar keys/item source as a one-time migration bootstrap, validate the resulting full tuple, and tag source `LegacyBootstrap` with synthetic document revision `0`;
   - after any external tuple is LKG, treat null as “no new authoritative document,” hold LKG, and log once. Do not change live economics from legacy sources during an ambiguous Store failure.
7. Hop to `GameTask.MainThread()`. Re-check service validity and assert host authority. Validate candidate again only if validation depends on current state; otherwise carry the immutable validated candidate.
8. Compare revision/tuple. Rejections retain LKG. A valid change performs the single atomic apply in section 7.
9. `finally` clears `_refreshInFlight`; every exceptional path emits a loud log and leaves the previous tuple untouched.

LKG initializes to shipped nonzero defaults:

- schema `0`, document revision `0`, source `ShippedDefault`
- cash/USD per BTC `5000`
- cash multiplier `1.0`
- portal redeem cash `5000`

No failed read may turn any of these into zero.

**NEEDS-DXRP-API-CONFIRM:** `ServerApiClient.GetStore` returns `null` for both not-found and transport/API failure because `SafeApiCall` logs and returns `default` (`ServerApiClient.Store.cs:51-80`; `ApiClientBase.cs:13-61 @ b9d6068`). The LKG policy above is safe despite that ambiguity, but exact absence-vs-failure telemetry requires a future typed `TryGetStore` result from DXRP. BLOCK-0 must not fork its own HTTP client to fake this distinction.

## 7. Atomic main-thread apply and replication

Replace split hub/redeem apply with one synchronous method, conceptually:

```text
ApplyLiveSettingsHost(validatedCandidate, source, reason)
  assert host
  compare tuple/revision
  LpBitcoinEconomy.ApplyPortalSettings(cash, multiplier, redeem)  // all fields; one repaint revision
  _lastKnownGood = candidate                                     // one immutable reference
  BroadcastPortalEconomyClient(schema, documentRevision, cash, multiplier, redeem) // once
  log + audit once
```

Requirements:

- `LpBitcoinEconomy.ApplyPortalSettings` sets all three values synchronously and increments `PortalEconomyRevision` exactly once per changed tuple. Existing split methods may become private wrappers only if they cannot be used to create a torn tuple.
- Add `PortalConfigRevision` (the Store document's `long`) separately from `PortalEconomyRevision` (the local UI/repaint counter). Do not overload one field with both meanings.
- The broadcast remains `[Rpc.Broadcast(NetFlags.HostOnly | NetFlags.Reliable)]`, using primitive arguments already exemplared in the current service (`LpBitcoinPortalEconomySync.cs:433-444`). The receiver applies the full tuple through the same atomic economy method.
- A client rejects an older document revision. Replication remains **NEEDS SBOX RUNTIME PROOF** until a non-owner client sees the full tuple update live without rejoin; declarations alone prove intent only.
- `RequestPortalEconomyHost` returns the single current LKG tuple; it does not trigger a Store read.
- Dev overrides must pass through the same validation and atomic-apply path, source-tagged `DevOverride`; they never write Store.

Audit/log contract on successful changed apply:

- `LP_CONFIG_APPLY source=<...> schema=<...> revision=<...> cash=<old->new> multiplier=<old->new> redeem=<old->new>`
- `ServerApiClient.Audit("LpBitcoinConfig", "LIFEPUNCH config reload ...")`; server-console invocation may omit cause because `Audit` accepts nullable cause (`ServerApiClient.Core.cs:103-123 @ b9d6068`).

Failure/no-op sensors:

- `LP_CONFIG_READ_FAIL`
- `LP_CONFIG_PARSE_REJECT`
- `LP_CONFIG_LKG_HOLD`
- `LP_CONFIG_STALE_REVISION`
- `LP_CONFIG_REVISION_COLLISION`
- `LP_CONFIG_NOOP`

## 8. Permission and authority contract

The corrected permission model is normative:

1. **No new enum member.** The addon cannot extend `Permission`; it is backend-mirrored (`Permission.cs:7-18,148-149 @ b9d6068`).
2. **Current `[ConCmd("lpbitcoinreloadconfig")]`:** server-console/operator trust is the permission boundary. It MUST also guard and internally assert host authority. There is no caller SteamId to pass to `RankSystem`; do not claim a rank check that the command cannot perform (`LpBitcoinPortalEconomySync.cs:126-156 @ 6c9e86a`).
3. **Future player/in-game reload dispatch:** host RPC/command path with a real caller; allow `ManageEconomy || EditServer`. Either suffices. It invokes the same read-only reload service method.
4. **Future Store set/write command:** `ManageEconomy` only, host-gated, separately proposal-gated. BLOCK-0 v1.2 ships no Store writer.
5. T3 portal edits remain portal `EditServer`-class authority and follow Save + Sync + restart.

`lpbitcoinreloadconfig` reads and applies config; it never persists player/hub state and never writes a Store key.

## 9. File-by-file implementation map

| File | Required v1.2 responsibility |
|---|---|
| `LpBitcoinRackConfig.cs` | Keep flat defaults; add whole-object validation/result formatting or a dedicated adjacent validator. |
| `LpBitcoinRackEntity.cs` | Read content config once at reconcile/latch point; pass validated candidate plus source content identity. No per-frame config reads. |
| `LpBitcoinComputeTrack.cs` | One global latch; validate before register; exact later comparison; one mismatch sensor; checked quote range. |
| `LpBitcoinLiveSettings.cs` (new proposed file) | Sealed immutable-ish DTO/candidate, schema/revision/source, strict validation and normalized tuple equality. No DXRP dependency if avoidable. |
| `LpBitcoinPortalEconomySync.cs` | Sole Store reader; raw read; discriminated parse; LKG; host assertions; one atomic apply/broadcast/audit; legacy cold bootstrap. |
| `LpBitcoinEconomy.cs` | One tuple apply method; separate document revision from local repaint revision; all consumers continue reading the same static getters. |
| DXRP `Permission.cs` | **No change.** Use `ManageEconomy` and `EditServer` already present. |
| DXRP `ServerApiClient.Store.cs` | **No BLOCK-0 change required.** Typed absence/failure result is a future DXRP API improvement, not an addon-local fork. |

## 10. Explicit non-goals

- No Store migration for BTC balances, hub wallet, PIN, purchased tiers, or ledger state. Reserved namespaces remain unused until durable IDs + versioned transactional state exist.
- No Store write command.
- No base-rig const->static extraction.
- No new permissions.
- No market price changes.
- No secrets in T2/T3/Store.
- No per-rack or standard-vs-advanced independent `rack_compute` ladder.
- No runtime/editor proof claim from this static proposal.

## 11. Rollout and migration

1. Red re-resolves all files at its live HEAD and reports branch/HEAD/dirty/intended/forbidden paths before implementation.
2. Land code plus a **new** tracked v1.2 record in the same PR if Bloodwave ratifies this spec; do not annotate the frozen prior record.
3. Portal owner creates the atomic key with schema 1/revision 1 and all three active fields. Credentials never enter the value.
4. Keep legacy scalar reads for cold bootstrap during one migration window. Service never auto-writes/consolidates keys because Store writes are blind PUT.
5. Publish addon revision -> install/pin -> configure content entries -> Save -> Sync servers -> fresh restart for T3.
6. Store live settings may then change by writing a higher valid revision and invoking the reload; no server restart for Store dials.
7. Retire legacy scalar/item fallback only in a later record after portal evidence shows the atomic key deployed everywhere.

Deletion behavior is fail-safe: deleting the atomic key during a running process holds current LKG. A deliberate reset to shipped defaults must be an explicit valid higher-revision document, not key deletion.

## 12. Red verification gate

### Static/compile sensor

- Compile/parser log postdates every write and contains positive IDs: `LP_CONFIG_T3_REJECTED`, `LP_CONFIG_T3_MISMATCH`, `LP_CONFIG_PARSE_REJECT`, `LP_CONFIG_LKG_HOLD`, `LP_CONFIG_APPLY`.
- Confirm zero new `Permission` enum entries and zero Store write calls in BLOCK-0.
- Confirm config consumers do not read per-frame.

### T3 cases — fresh process each time

1. No override -> exact shipped ladder 2/4/8/16/32 and 25M/75M/200M/600M/1.6B sats.
2. Valid override -> first rack latches override; quote/effect both use it.
3. Invalid zero/negative/wrong-range field -> entire candidate rejected; shipped defaults latch; no free tier.
4. Standard and advanced effective configs identical -> no mismatch regardless spawn order.
5. Divergent configs -> first latch holds, exactly one mismatch sensor, deployment verdict HOLD.
6. Portal edit without fresh restart -> no T3 activation claim; restart -> positive override ID proves new bytes/config were read.

### Store/LKG cases

1. Valid revision 1 -> one apply, one local repaint revision increment, one broadcast, one audit.
2. Same rev/same tuple -> no-op.
3. Same rev/different tuple -> collision reject, LKG unchanged.
4. Lower rev -> stale reject, LKG unchanged.
5. Malformed JSON, missing field, zero/negative, NaN/Infinity, unsupported schema, unknown field -> loud reject, no legacy fallback, no value changes.
6. Simulated Store/API failure after a good apply -> LKG unchanged; no `$0` cashout/redeem value.
7. Atomic key absent on cold start -> validated legacy/item bootstrap or shipped defaults; migration sensor names source.
8. Atomic key deleted after good apply -> LKG holds until explicit higher-revision document.
9. Two rapid reload requests -> one in flight; no out-of-order apply.

### Runtime/replication/economy

- Scene: `scenes/blank.scene` (map-independent config/economy proof).
- Identity: host plus one non-owner client for replication; portal-backed payout proof uses a real portal identity, never a bot.
- Non-owner client observes one coherent tuple update live without rejoin. **NEEDS SBOX RUNTIME PROOF.**
- Hub display and payout read the same effective cash rate; portal stack redeem reads the same applied tuple's redeem field.
- One controlled payout verifies the audit reason remains `LIFEPUNCH ...`; no double apply or zero payout.
- Portal Config/Store values and Save/Sync/restart activation are **NEEDS PORTAL PROOF** from the executing environment.

Under the Editor Access Law, Red drives every sync, restart, ConCmd, and play-state change. Codex may only observe relayed status/logs/screenshots and file review findings.

## 13. Honest flags / verdict

- **NEEDS-BLOODWAVE-CONFIRM:** whether schema 1 rejects the currently named-but-unimplemented optional mining/upgrade-cost multipliers (recommended) or carries them as accepted no-ops (not recommended).
- **NEEDS-BLOODWAVE-CONFIRM:** whether non-monotonic T3 effect/cost ladders are operator-legal. Minimum positive/range validation is non-negotiable; silent sorting is forbidden.
- **NEEDS-DXRP-API-CONFIRM:** typed not-found versus transport failure for Store reads. v1.2's LKG rule is safe without it but telemetry remains ambiguous.
- **NEEDS SBOX RUNTIME PROOF:** ConCmd execution boundary, one-broadcast client coherence, hot/reload behavior.
- **NEEDS PORTAL PROOF:** actual atomic key, T2/T3 content overrides, rank grants, Save/Sync/restart activation.

**VERDICT: SPEC READY, TWO BLOODWAVE MICRO-RULINGS OPEN.** The two-layer architecture is confirmed and the full v1.2 implementation contract is complete without moving persistent state into blind-PUT Store or inventing a permission.

FROM: Codex · CVL Review + Proposal Seat
