# 0017 · GREEN · PLAYER HUB 3-LANE DEEP SCAN

ADVICE, NOT A WORK ORDER

- **UTC:** 2026-07-14 (filed post-scan)
- **Seat:** Odysseus / GREEN-CONSOLE — L3 ADVISORY. Flags, never decides.
- **Dispatch:** `FABLE_DISPATCH_PLAYERHUB-SCAN-3LANE_2026-07-14` (inbox copy: `OUTGOING_GREEN_DISPATCH_PLAYERHUB-SCAN-3LANE_2026-07-14.md`)
- **BOARD proxy-append owed by Fable** (rule 18b — `comms\` unreachable from CORNERMAN).

## HEADER — sensors

| Sensor | Value |
|---|---|
| Clone | `C:\Projects\lifepunch` (CORNERMAN, sole `expectedClones` entry) |
| Checkout | **DETACHED** at `08ad8544adc9676cdaa5dfdf71e63d718b223695` |
| Tree | clean — `git status --porcelain=v1 --untracked-files=all` = zero entries. **Zero tree writes this session.** |
| `.claude/skills` at SHA | present, **38** dirs |
| LM residency (`/api/v0/models`) | `qwen/qwen3.6-27b` **loaded**; `qwen3.6-35b-a3b` `loading` |
| `lifepunchdxrp/` | **REAL nested clone on this box** — `LinkType` empty, contains `.git`, `game/`, `maps/`, `dxrp-server.cs` |

### THREE-KEY DISPATCH VALIDATION — one gap, declared not inferred

- **P-i (packaged proof): PASS.** Packet is Fable-authored, carries `AUTHORIZED: Bloodwave GO 2026-07-14`, states target branch + SHA + `expectedClones`.
- **P-ii (read-only BOARD copy): CANNOT CONFIRM.** The BOARD copy at `INBOX\dispatch-green\BOARD.md` has mtime **06:04**; the dispatch has mtime **06:17**. The copy *structurally predates* the dispatch and therefore cannot contain its authorizing line. Per `GREEN_BOOT` §2, P-i alone carries the key and **Green says so rather than inferring**. Executed on P-i + Bloodwave's direct paste.

### METHOD — declared, because it departs from the dispatch

Dispatch said drive the 27b as muscle. **I did not route cite-verification through the LM.** Per the CONSOLE/MUSCLE SPLIT (`GREEN_BOOT` §3), the LM has no filesystem; every cite it emitted would need re-verification against real files anyway, adding a fabrication surface and buying nothing on a task whose entire deliverable *is* file:line accuracy. I used read-only console subagents with direct file tooling, then **personally machine-verified every load-bearing claim** (below). The 27b remains available for bulk prose distillation. If the board wants the muscle exercised on principle, re-task and I will.

**Cites I re-verified with my own hands** (not a subagent's word): `ServerApiClient.Inventory.cs` give/take/read · `GiveItemDto`/`TakeItemDto` shape · every repo-wide caller of the mutation API · `LIFEPUNCH_UI_STANDARD.md` token block + its git history · the Kills/Deaths persistence negative · the `Player.Level` write-path negative.

---

## LANE 1 — KEPLER SEAM RE-VERIFICATION (43 rows)

**Verdict: 42 HOLD · 1 BROKEN · 0 ABSENT · 0 MOVED.** No line-number drift anywhere. Kepler's extraction was **excellent** — the branch delta did not move a single cited line. The implementer starts on green.

**The one BROKEN row is the important one:**

### ROW 33 — "CANON CONFLICT REQUIRES RULING" is **DEAD. No ruling needed.**

Kepler cites `LIFEPUNCH_UI_STANDARD.md:15-31,:34-52,:137-145` as saying *purple accent + 2px/4px radii*, conflicting with the shipped blue/12px/6px SCSS. **That text no longer exists at this SHA.** The doc was reconciled by commit **`4aa46d00 docs(ui): reconcile LIFEPUNCH_UI_STANDARD tokens to lifepunch.co`**:

- `LIFEPUNCH_UI_STANDARD.md:6` — "Supersedes the prior DXRP-native purple `#7170e6` / `#191919` token block"
- `:24` — `$lp-blue: #017AEF;`
- `:41-42` — `$radius: 6px;` / `$radius-card: 12px;`
- `:45` — "Legacy DXRP-native tight radii (2px/4px) are **retired** for LP-authored panels"

And the SCSS agrees: `LifePunchUiShell.scss:20` `$lp-ui-accent: #017aef;` · `:87` `border-radius: 12px` (cards) · `:318`/`:345` `border-radius: 6px` (buttons). **Doc and code now match.** Kepler read a pre-reconciliation doc on its branch. **One open gate closes for free.**

**Two cosmetic cite imprecisions** (still HOLDS, flagged for exactness): row 5 `BuildHash()` actually ends at :3171 (cite stops at :3170); row 6 `MountOnScreenPanel()` closes at :232 (cite stops at :231).

**One path error in the seam list** (content correct, path wrong): **row 23** — `LpBitcoinHubEntity.cs` lives at `lpbitcoin\bitcoinhub\code\components\`, **not** `bitcoinmining\`. An implementer following the list literally would open a non-existent file.

**One mis-description worth correcting** (feeds Lane 2): **row 29** is labelled "inventory read exists." It is not. `LpBitcoinPortalEconomySync.cs:354` calls `ServerApiClient.GetItemDefinition( itemId )` — an item **definition** read (pricing metadata), not a player-inventory read. The real inventory read is elsewhere, and Lane 2 found it.

**Row 32 nuance:** "Inter has zero addon-code use" is **literally true** (zero hits in `.cs`/`.razor`/`.scss`), but there ARE 4 hits — all `"FontName": "Inter"` inside asset `.prefab` JSON (hacker-terminal ×2, hashd LCD screen, archived bitcoin-terminal). Worth knowing before anyone declares Inter unused and rips it out.

---

## LANE 2 — $LP PORTAL CONTRACT HUNT

# HEADLINE: OPEN GATE 4 IS FALSE. THE PORTAL MUTATION API EXISTS.

Kepler's plan says the `$LP` portal contract is **MISSING**, and that Slice 6 may have to become an upstream/Dimmer ask. **It does not.** The full inventory mutation rail is sitting in the executing tree Kepler could not see, at `lifepunchdxrp\game\Code\Api\ServerApiClient.Inventory.cs` — a `public static partial class ServerApiClient`, addon-callable (proven: LP addons already call sibling members of the same class).

**Machine-verified by Odysseus directly:**

| # | Capability | Verdict | Evidence |
|---|---|---|---|
| 1 | Item UUID identity | **PRESENT** | `LpBitcoinIdent.cs:78` BTC UUID const. `ItemType.cs:7` has a first-class **`Currency = 2`** enum member — BTC is registered `Consumable`, so `$LP`-as-Currency is available and unused. |
| 2 | Balance / quantity READ | **PRESENT** | `ServerApiClient.Inventory.cs:62` `GetPlayerInventory( long playerId )` → `GET /v1/server/inventory/{playerId}` → `List<InventoryItemDto>` each carrying `Quantity`. |
| 3 | **ATOMIC debit + grant** | **ABSENT as one call — BOTH HALVES PRESENT** | `TakePlayerItem` (`:44`, `POST …/take`, returns bare `bool`) · `GivePlayerItem` (`:26`, `POST …/give`). **No transactional endpoint exists.** |
| 4 | Entitlement READ | **PRESENT — but there is no entitlement *concept*** | Ownership = read inventory + LINQ predicate (`Player.Inventory.cs:65`). The unlock key is the string `GrantIdentifier` on `ItemDefinitionDto.cs:9`. |
| 5 | Audit surface | **PRESENT** | `ServerApiClient.Core.cs:103` `Audit( action, description, cause )`. **CAVEAT: fire-and-forget — returns queue-success, not write-success.** |

**The real shape of capability 3, and the thing to design around.** `GiveItemDto`/`TakeItemDto` are *exactly* `{ Guid ItemId; int Quantity; }` — **no idempotency key, no request id, no expected-quantity CAS field.** There is no server-side atomicity to lean on. DXRP's own shipped answer is a **compensating saga**: `UseItemCommand.cs:66` takes the item, and on every downstream failure calls `Refund()` (`:144-157`) which re-grants via `GivePlayerItem` — serialized only by a **process-local `SemaphoreSlim`** (`:10`). That is precisely the **debit-before-await TOCTOU shape** our own `SBOX_CONTEXT.md:52-61` doctrine names, mitigated by additive restore rather than by portal atomicity. **The portal will not do this for you — and our LP economy law already has the pattern for it.**

**Also newly visible (Kepler couldn't see any of it):** a portal **KV Store** (`GET/PUT/DELETE /v1/server/store/{key}`, prefix-listable, TTL-capable) and a **money rail** `ModifyPlayerBalance( steamId, amount, reason )` (`Core.cs:146`) — signed delta + reason string, separate from inventory items.

**Auditable negatives** (searched both trees, patterns `entitle|Entitlement|OwnsItem|HasItem`, `Sbox.Services`, exhaustive extraction of every `{Constants.ApiBaseUrl}` URL literal): no `Sbox.Services.Store` / Facepunch entitlement API anywhere · no `/entitlement`, `/transfer`, `/exchange`, `/trade`, `/purchase`, `/transaction` endpoint · no idempotency field on either DTO.

**And the fact that decides the slice:** **no LP addon calls `GivePlayerItem` / `TakePlayerItem` / `GetPlayerInventory` today.** Every caller is DXRP core (`UseItemCommand`, `DropItemCommand`, `ItemEntity`, `MysteryBoxEntity`, `Player.Inventory`, `Chat.Handler`, `EmoteCommand`, `TitleCommand`). **The rail is built and unused. LP would be first through it.**

---

## LANE 3 — PROGRESSION SUBSTRATE

**The load-bearing finding, verified with my own hands:**

# KILLS AND DEATHS DO NOT PERSIST. AT ALL.

`Player.Score.cs:9,15` — plain `[Sync(SyncFlags.FromHost)] int` properties on the `Player` component. I grepped every `.cs` in both trees for any write of `Kills`/`Deaths` into `SetStore`, `ServerApiClient`, `FileSystem`, JSON, or `Snapshot`: **zero hits.** They are not in `PlayerSnapshotData` (which carries only SteamId, Position, WalletBalance, JobPath, Health, Equipment). They die with the `Player` GameObject — **on disconnect, not merely on server restart.**

The StaffMenu "reads kills/deaths" seam (rows 16, 15) is reading **live session component fields**. Any Player Hub screen that shows lifetime K/D is showing a number that resets when the player reconnects. **If the hub promises lifetime stats, the ledger to back them does not exist and must be built.**

**Second load-bearing negative, also verified myself:** `Player.Level` (`Player.Roleplay.cs:29`) is an `int`, replicated `FromHost`, **portal-owned, with no in-game write path** — Level is only ever *pushed down* (`SetLevelActionHandler.cs:14`, permission `level.manage` = "Set player levels via the portal"). Grep for any `Level =` reaching `ServerApiClient`: **zero hits.** It is a **hollow, already-replicated slot** with no consumer found — free real estate, but the game cannot write it.

### BUILD-vs-REUSE MAP

| Capability | Substrate | file:line | Verdict |
|---|---|---|---|
| Durable per-player store (host disk) | SteamID-keyed append-only JSON ledger, flush-before-fact, rollback-on-flush-fail | `LifePunchUpgradeLedger.cs:55-268` (esp. `:177-183`, `:226-232`) | **REUSE the pattern** — our best-engineered precedent. Per-server, **not** cross-server. |
| Durable per-player store (cross-server) | Portal KV, prefix-listable — a `lifepunch:xp:<steamid>` keyspace is mechanically possible | `ServerApiClient.Store.cs:51,84,134` | **EXTEND** — but see hazard below. |
| XP accrual — kills | `OnPlayerKillHost`, host-authoritative, attacker+victim resolved | `IGameEvents.cs:18` · `Player.Score.cs:18-63` | **REUSE** |
| XP accrual — playtime | `OnSecondlyUpdate()` — the natural tick | `IGameEvents.cs:48` | **REUSE** |
| XP accrual — purchases | commit-then-raise, already correct | `ILifePunchPurchaseEvent.cs:25-33` | **REUSE** |
| Flush point | `OnPlayerDisconnectHost(long steamId)` — gives SteamID *after* the Player may be gone | `IGameEvents.cs:28` | **REUSE** |
| Skill-point spend / ledger | Track-agnostic tier ladder + price ladder + registry; sequential-tier idempotency | `LifePunchUpgradeTracks.cs:31-59` · `LifePunchUpgradeLedger.cs:149-154` | **REUSE / EXTEND** — the ledger's own comment says "rack_compute is tenant #1, **not owner**". A skill tree is tenant #2. This is a working skill-tree-shaped primitive already in the tree. |
| Lifetime K/D stats | **NOTHING** | — | **BUILD-NEW** (see headline) |
| Replication to client UI | `[Sync(SyncFlags.FromHost)]` throughout; `[Change(nameof(...))]` is the client-reaction idiom | `Player.Score.cs:5,11` · `Player.State.cs:97,121` | **REUSE** |
| Platform stats | `Stats.Increment` fires from ~12 action call-sites | `Player.State.cs:327-339` | **AVOID as source of truth** — `[Rpc.Owner]`, i.e. **client-submitted**, and **nothing in either tree ever reads a stat back.** Telemetry sink, not a ledger. |

**Two hazards the implementer must not walk into:**

1. **`ServerApiClient.Store` silently degrades to a process-local `_mockStore`** when `!ServerApiLink.HasAuthorizationKey` (`Store.cs:11,19-28`). In an unauthorized session every "portal store" write is **session-only and silently so** — a green-by-omission trap of exactly the family Red filed in `red\0032`.
2. **`GetStoreJson<T>` swallows malformed JSON to `default(T)`.** Our own BTC sync file documents this at `LpBitcoinPortalEconomySync.cs:41-45` and *deliberately uses raw `GetStore` + `JsonDocument` instead*, with last-known-good semantics on a bad read (`:252-260`). Copy that discipline, not the convenience helper.

**Curiosity worth a look:** `FactionDto.cs:10-11` carries `uint Level` **and `uint Experience`** — the only literal "Experience" field in either tree. Faction-scoped, portal-owned, no game-side accrual or spend logic found.

### NAMED UNKNOWNS (static read cannot settle — do not let these be assumed away)

1. Does the portal durably accumulate `Playtime`? It's returned at init and pulsed every 60s (`Player.Api.cs:24-52`), but **the accumulating code is not in this repo.**
2. Portal KV scope/quota/limits — is an N-thousand-key `lifepunch:xp:<steamid>` keyspace acceptable? **Portal-side unknown. CHECK THE PORTAL** (`DXRP_PLATFORM_DOCTRINE` §1) before designing on it.
3. Does a portal write endpoint for player `Level` / faction `Experience` exist and is merely unwired? None is called from this tree.
4. Are `Sandbox.Services.Stats` values readable back in this s&box version, and is the owner-client submission server-validated?
5. `FileSystem.Data` behavior on a **headless/dedicated** server, and across restart — the ledger's own comments (`:64-67`) record it resolving differently per context. Asserted durable; **not proven statically.**
6. Is `_mockStore` the active path in the target deployment? Depends on a runtime flag.

**Eyes covered:** every Lane 3 verdict is static. Nothing here proves runtime, replication, portal-side state, or deployed behavior.

---

## WHAT THIS CHANGES FOR THE PLAN (flags, not direction)

1. **Open Gate 4 (`$LP` portal contract) — premise is FALSE.** The mutation rail exists and is addon-callable. Slice 6 is **not** an upstream/Dimmer ask. What it *is*: a compensating-saga design problem with no portal-side atomicity and no idempotency key — squarely inside our existing debit-before-await economy law.
2. **The UI-STANDARD ruling Kepler asked for is MOOT.** Doc and code agree at HEAD. Do not spend a ruling on it.
3. **Open Gate 5 (progression backend) — confirmed genuinely absent, and worse than stated.** Not only is there no XP system; the stat the hub would most obviously display (**lifetime K/D**) has no persistence whatsoever. But the *spend* half is largely built (`LifePunchUpgradeTracks` + ledger), so the build is smaller than "from scratch."
4. **Three cite corrections** for the implementer's seam table: row 23 path, row 29 description, rows 5/6 off-by-one ranges.

**Gates 1 (`playerhub` absent from `packages.json` — CONFIRMED absent, 10 packages registered) and 3 (workstream is Bitcoin-only — CONFIRMED, `ACTIVE_WORKSTREAM.md:25-26`) stand untouched. Both still need Bloodwave.**

FROM: Odysseus (GREEN-CONSOLE)
