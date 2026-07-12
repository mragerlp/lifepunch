# lpbitcoin HYBRID CONFIG PROPOSAL (T3 vs Store) — feeds the BLOCK-0 ruling

> **STATUS: APPROVED AS FILED — BLOODWAVE RULING 2026-07-12** (via Fable recommendation). Implementation unlocked. **Guard:** the host-RPC + local-cache plumbing is money-adjacent — TOCTOU debit-before-await law applies, every Store economy/state write carries an audit sensor.
> Spec v1 for BLOCK-0 config extraction. **T3** = shipped per-entity defaults (`LpBitcoinRackConfig`: hash ladder, tier costs 0.25/0.75/2/6/16, buffer cap, intervals, advanced ratio). **Store** = live dials + persistent state (BTC↔cash rate, payout percents, hub wallet, PIN hash, tier ledger, locked-transaction +TTL, cross-job persistence) via `ServerApiClient.Store` host-only API — UI routes through host RPCs + MainThread rechecks + local cache (no existing consumer to copy; lpbitcoin is first). Permissions: T3 = EditServer-class · Store economy writes = lpbitcoin-supplied Manage-Economy · Store state writes = host-only + ownership-gated. Implementation gates behind this ruling — **NOW OPEN.**

> **Class: RULED RECORD** — the ruling above (2026-07-12) froze this from instrument to record; the study below is the approved spec.
> Red read-only study 2026-07-12. Cross-ref: `lifepunch-config` skill,
> `LPBITCOIN_TUNABLES_EXPORT.md` (Packet H), `DXRP_PLATFORM_DOCTRINE.md §13 PORTAL STORE`.

## A. Reference 1 — T3 shipped-defaults pattern (Monnow's Printer, sensored)
Files under `…\Monnow's Printer Addon\LifePunch\code\monnowprinterlp\`.
- **Read call:** `GetConfig( new MonnowPrinterConfig() )` on DXRP `BaseEntity` — `MonnowPrinterEntity.cs:131` (OnStart) & `:82` (lazy getter). Reads the entity **content-entry's portal "Config Override JSON"**, deserialized onto the fallback type.
- **Config class:** `sealed class MonnowPrinterConfig` — `MonnowPrinterConfig.cs:7`. Flat `{ get; init; }` fields; **defaults live in the field initializers** (`BasePrintAmount = 8`, `L1PrintCost`, …) = the shipped T3 layer. No separate defaults JSON.
- **Per-tier mapping:** each **tier is a separate content entry/prefab** with its own Config Override JSON → one config object (`DisplayName` names the tier). Within a tier, flat `L1/L2/L3` fields → runtime arrays in `MonnowPrinterUpgrades` ctor (`:40-71`); level selected by a synced `int`, 1-based count-clamped lookup (`GetPrintAmount` `:82-86`).
- **Activation:** portal Config Override JSON edit → gamemode Save + **Sync** (NOT live; restart/sync-gated).

## B. Reference 2 — Store live/persistence layer (DXRP fork, sensored)
- **Client:** `static partial class ServerApiClient` — Store surface in `game/Code/Api/ServerApiClient.Store.cs:9`. **SERVER/HOST-ONLY** static `async` HTTP to the portal REST API (`/v1/server/store…`); offline in-memory `_mockStore` fallback (`:11`). **Not `[Rpc.Host]`, not client-callable.**
- **Read:** `GetStore(key)→string?` `:51` · `GetStoreJson<T>(key)→T?` `:136`. **Write/upsert:** `SetStore(key,value,expiresAt?)` `:84` · `SetStoreJson<T>(…)` `:145`. **Delete:** `DeleteStore(key)` `:106`. **Namespace scan:** `ListStore(prefix?)→List<StoreEntryDto>` `:13`. DTO = `{Key, Value, ExpiresAt}` (`StoreEntryDto.cs:3`).
- **Keys:** `NormalizeKey` forces **lowercase + trim** (`:134`); `namespace:sub:key` is a **caller convention**, not enforced (exemplar `WaypointCommand.cs:8` `"commands:waypoint:"`).
- **TTL:** per-key via `expiresAt` (no independent touch/refresh). **No reload/cache** — every call is a live HTTP round-trip.
- **Permission:** **NONE built in** — the Store methods have no scope/gate. Caller gates (waypoint checks `Permission.CommandWaypointEdit` in `ExecuteHost`, `WaypointCommand.cs:30,45`). Host-context only; a client must route through host code.
- **Exemplar (only one in-tree):** `WaypointCommand` — full CRUD + `GameTask.MainThread()` + `IsValid()` recheck after every await (`:86-87`). **No `:config:` / economy consumer exists yet — lpbitcoin would be the first.**

## C. The hybrid split for lpbitcoin
Rule of thumb: **T3 = shipped balance SHAPE** (per-entity, edit→Save→Sync, not live) · **Store = live economy DIALS + persistent per-instance/player STATE** (host-only, live HTTP).

| Knob | Layer | Rationale |
|------|-------|-----------|
| Hash-rate ladder (COMPUTE ×1/2/4/8/16/32) | **T3** | shipped per-entity balance; Monnow per-tier pattern |
| Tier cost ladder (0.25/0.75/2/6/16 BTC) | **T3** | shipped economy shape |
| Buffer cap (`K=4 × tickYield`) | **T3** | shipped derived-world default |
| Tick intervals | **T3** | shipped timing default |
| Advanced-rack yield multiplier (2.0) | **T3** | shipped per-entity ratio (the ratio-watch knob) |
| Market spawn costs ($2500/$1500/$5000/$10000) | **Gamemode MARKET** (not addon config) | portal marketItem `Cost` per §4; server-owner tunable |
| BTC↔cash rate (`CashUsdPerBtc`) | **Store** | LIVE-tunable economy; changes without republish; already portal-fed |
| Payout percents | **Store** | live economy dial |
| Hub wallet balance (per hub) | **Store** | persistent per-instance state; survives restart (**G2**) |
| Hub PIN hash (per hub) | **Store** | persistent per-instance state |
| Rack tier ledger (per rack) | **Store** | persistent upgrade state, survives restart |
| Locked-transaction state | **Store** | persistent + **TTL** (`expiresAt` auto-expire) |
| Tablet cross-job persistence (Medic upgrades…) | **Store** | the tablet-persistence backend (`TABLET_DOCTRINE` D3) |

## D. Packet H mapping (`LPBITCOIN_TUNABLES_EXPORT.md`)
Packet H tunables split: **hash rates · tick intervals · buffer caps · tier costs → T3** (a Monnow-shaped `LpBitcoinRackConfig` per content entry). **payout percents · cash-per-BTC rate → Store** (live economy lane).

## E. Permission model (FLAG)
- **T3 edits** (Config Override JSON on content entries) → portal gamemode-edit = **EditServer-class → Bloodwave-only + delegated super-admins.**
- **Store ECONOMY writes** (live rate/payout) → a dedicated **Manage-Economy permission → Bloodwave-only + delegated super-admins**, routed through a **host command** (WaypointCommand pattern: `ExecuteHost` + `RankSystem.HasPermission`). There is **no generic `store.manage` in-game** — lpbitcoin must supply its own `Permission.LpBitcoin*` and gate every write.
- **Store STATE writes** (wallet, ledger, PIN, tablet) → **host-only + ownership-gated** (hub owner / host authority), NOT a manage permission — gameplay mutations, not admin dials.

## F. BLOCK-0 caveats the ruling must weigh
1. Store is **host-only / not RPC** → tablet/hub UI must route reads+writes through **host RPCs** (extra layer).
2. Store is **off-thread HTTP** → `GameTask.MainThread()` + `IsValid()` after every await; **never read per-frame** — cache locally, refresh on a cadence.
3. **No client cache / reload** in the API → build a local cache + explicit refresh.
4. **Per-key TTL** (`expiresAt`) fits locked-transaction auto-expire natively.
5. **Offline mock** → editor/dev works without portal auth.
6. lpbitcoin is the **first** economy/state Store consumer — no in-tree pattern beyond waypoints; build carefully, and this is the **same backend** as the tablet-persistence + G2 question.

## G. What this un-blocks
**BLOCK-0** ("LP reads the addon config surface ZERO times") is un-gated by RULING this split: T3 `GetConfig<LpBitcoinRackConfig>` per-entity (Monnow pattern) for shipped ladders + a host-gated Store lane for live economy + persistent state. **The ruling decides the split + permission model; config-extraction implementation is gated behind it.** No code until then.
