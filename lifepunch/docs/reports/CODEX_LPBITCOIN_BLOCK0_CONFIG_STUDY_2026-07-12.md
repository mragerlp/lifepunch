# CODEX — lpbitcoin BLOCK-0 config study (verbatim, 2026-07-12)

> **Provenance:** Codex (CVL Review + Proposal Seat) blind study, relayed by Bloodwave, filed **VERBATIM** by Red (Codex is read-only — Red is its hands). Red machine-verified Codex's V1–V3 claims against the live tree; the ruled synthesis is `handoff/LPBITCOIN_HYBRID_CONFIG_PROPOSAL_2026-07-12.md` (spec v1.1). Full evidence report per the `docs/reports/` convention (`docs/handoff/` stays short relays). Body below is Codex's, unchanged.

---

FROM: Codex · CVL Review + Proposal Seat
TO: Fable / Claude (via Bloodwave)
SUBJECT: lpbitcoin BLOCK-0 ruling summary
CONFIRMED — T3 precedent: Monnow reads entity content config with GetConfig(new MonnowPrinterConfig()), then maps flat JSON fields into runtime upgrade behavior. It uses one content entry, not separate tier prefabs. The supplied build has 29 fields, not ~48, and no cooling/heat/silencer fields.
Sensors: MonnowPrinterEntity.cs:73-84,125-133; MonnowPrinterConfig.cs:3-62; MonnowPrinterUpgrades.cs:40-110; lifepunch/gamemode/config/lpmonnowsprinterupgrade-portal.json:55-102.

CONFIRMED — Store API: DXRP exposes ListStore, GetStore, SetStore, DeleteStore, GetStoreJson, and SetStoreJson. “Reload” simply rereads the key. Store methods have no built-in host or permission guard, and writes are blind PUTs with no CAS/transaction result.
Sensors: lifepunchdxrp/game/Code/Api/ServerApiClient.Store.cs:13-148; WaypointCommand.cs:14-94,177-195.

PARTIAL — BLOCK-0: lpbitcoin has no T3 content-config read path, but it already has a Store-backed host service. LpBitcoinPortalEconomySync polls three exchange-rate keys every 300 seconds, supports forced sync, applies on the main thread, and broadcasts to clients. Extend this service; do not create another Store bridge.
Sensors: LpBitcoinPortalEconomySync.cs:32-41,58-118,198-301,309-358.

PROPOSED HYBRID:
T3 shipped defaults: mining base speed, 90-second interval, base clock/cores, buffer-cap ticks, standard/advanced yields, COMPUTE ×1–×32 effects, and 0.25/0.75/2/6/16 BTC ladder. Keep one canonical ladder because rack_compute is a single global registry entry.
Sensors: LpBitcoinEconomy.cs:17-18,97-119; LpBitcoinComputeTrack.cs:30-78; LifePunchUpgradeTracks.cs:45-60.

Store live settings: one atomic JSON key, lifepunch:bitcoin:config:settings, containing schemaVersion, revision, cashUsdPerBtc, cashRateMultiplier, portalRedeemCashUsd, plus optional miningRateMultiplier and upgradeCostMultiplier.

Reserve lifepunch:bitcoin:player:{steamid} and lifepunch:bitcoin:hub:{persistentId} for versioned state, but do not migrate BTC balances or purchased tiers during BLOCK-0. Store lacks transactions/write acknowledgement, and current hub identity uses scene GameObject.Id, not a proven durable ID.
Sensors: ServerApiClient.Store.cs:84-104; LpBitcoinHubEntity.cs:455-468; LifePunchUpgradeLedger.cs:47-60,97-186.


Permissions proposal: Bloodwave retains generic ManageStore and T3 publishing. Delegated near-devs receive allowlisted ManageEconomy; reload-only operators use EditServer. Every in-game command must also be host-gated. Fishing’s exact permission split remains UNVERIFIED because its source was not present.
Sensor: Permission.cs:17-18,74-75,98-99,148-149.

Live reload: add /lpbitcoinreloadconfig over the existing sync service: permission check → reread one JSON document → validate → retain last-known-good on failure → main-thread atomic swap → one revision/broadcast/audit. No portal revision or restart required.

Static review only; runtime behavior remains unverified pending playtest. DXRP files cited above were compared read-only against b9d6068 and were byte-identical; deployed-server revision remains unverified.
— Codex · CVL Review + Proposal Seat
