# DXRP Audit Log Reference

> Source: `https://dxrp.net/portal/audit` (live, authenticated portal).
> Purpose: hand-off reference for the admin-menu agent on how audit actions are
> structured and how they should be grouped/filtered in-game, plus implications
> for the dev test-bot framework.
>
> Studied: the global feed plus two full player histories —
> **Ominous** `76561198149414975` (Community Manager / heavy staff) and
> **Young Sheldon** `76561198891825101` (regular player, no staff access).

© lifepunch.co — proprietary & confidential.

## 1. Table schema (5 columns)

| Column | Meaning |
|---|---|
| **WHEN** | Relative timestamp (`just now`, `5 minutes ago`, `1 week ago`, `1 month ago`). |
| **ACTION** | Enum tag, color-coded by category (Chat = purple, ModifyBalance = teal, Ban = red, etc.). |
| **PLAYER** | SteamID64 of the **actor** (clickable link). |
| **ENTITY** | Target context: `Player` or `Server`. Also filterable via an Entity ID box. |
| **DESCRIPTION** | Human-readable sentence; format depends on the action (see §3). |

**Filters:** Player ID (exact SteamID64), Actions (searchable **multi-select** chip list),
Entity ID, plus a server/network selector ("LifePunch"). Pagination is
First / Prev / Next / Last with a rows-per-page selector.

## 2. Full action taxonomy (~72 types) and proposed groupings

**Moderation / staff-on-player** (what staff care about most; rare vs total volume)
`Ban` · `Kick` · `Warn` · `Gag` · `Freeze` · `Sanction` · `Expire` · `Demote` ·
`CancelDemote` · `VoteDemote` · `Arrest` · `Unarrest` · `Warrant` · `Wanted` ·
`PoliticalPrisoner` · `Spectate` · `Teleport` · `Waypoint` · `SetHealth` ·
`JobForce` · `ForceRpName` · `ForceSellDoor` · `DispatchAction` · `StaffAnnounce`

> `Unarrest`, `Waypoint`, and `JobForce` were **not** in the portal's Actions
> dropdown chips but DO appear in real data — the exhaustive scan surfaced them.
> Treat the dropdown as incomplete; trust observed `action` values.

**Staff ticket lifecycle** (the `!report` / help workflow — its own swimlane)
`StaffRequest` · `StaffRequestCreated` · `StaffRequestUpdated` ·
`StaffTicketClaimed` · `StaffTicketResolved`

**Economy / money**
`ModifyBalance` · `SetBalance` · `MoneySpawn` · `WalletDeposit` · `WalletCharge` ·
`ATM` · `GenerateToken`

**Items / inventory**
`GiveItem` · `TakeItem` · `SpawnItem` · `BulkGiveItems` · `BulkRevokeItems` ·
`DropItem` · `PickupItem` · `PocketDrop` · `PocketPickup` · `UseItem` ·
`Recycler` · `MysteryBoxWin`

**Combat / life**
`Kill` · `Death` · `Hit` · `SetHealth`

**Government / world / RP**
`AddLaw` · `RemoveLaw` · `MayorAnnounce` · `MayorTown` · `Vote` · `VoteBet` ·
`CustomJob` · `Job` · `RpName` · `ForceRpName` · `ForceSellDoor` · `Create` ·
`Delete` · `Update` · `UpgradeLevel` · `TV` · `Status` · `Frame`

**Communication**
`Chat` · `PrivateMessage` · `Advert` · `Me`

**Minigames / gambling**
`CoinFlip` · `Minigame` (overlaps `VoteBet`, `MysteryBoxWin`)

## 3. DESCRIPTION format patterns (catalog, all verified from live data)

Two recurring shapes: **actor-first** sentences, and bracketed channel tags for chat.
All examples below are real rows pulled from the two studied players' full logs.

### Moderation / staff-on-player
```text
Ban             <staff> (<id>) banned <target> (<id>) permanently: <reason>
Ban             <staff> (<id>) banned <target> (<id>) for 2d: <reason>      // also 1d / 7d
Kick            <staff> (<id>) has kicked <target> (<id>) for <reason>
Warn            <staff> (<id>) warned <target> (<id>): <reason>
Freeze          <staff> (<id>) toggled freeze on <target> (<id>)
Arrest          <staff> (<id>) jailed <target> (<id>) for 10m: <reason>
Unarrest        <staff> (<id>) unarrested <target> (<id>) via staff command.
Teleport        <name> (<id>) teleported to <name> (<id>)
Waypoint        <name> (<id>) teleported to waypoint '<name>'
Spectate        <staff> (<id>) started spectating <target> (<id>)
SetHealth       <staff> (<id>) set <target> (<id>)'s health to 100
SetBalance      $111672 -> $121672
JobForce        <staff> (<id>) force-set <target> (<id>) to <job>
ForceSellDoor   <staff> (<id>) force sold door (previous owner steamId: <id>)
StaffAnnounce   <staff> (<id>): <message>
Warrant         <name> (<id>) requested a warrant for <target> (<id>): <reason>   // cop job, not only staff
```

### Staff ticket lifecycle
```text
StaffTicketClaimed   <staff> (<id>) claimed <target> (<id>)
StaffTicketResolved  <staff> (<id>) resolved <target> (<id>)
StaffRequestCreated  <name> (<id>): <ticket text>      // player files the ticket
StaffRequestUpdated  <name> (<id>): <ticket text>
```

### Economy
```text
ModifyBalance   $19 for Salary   |   $-4200 for Purchase #entity.shipment.m4a1.name
WalletDeposit   <name> (<id>) received $36 into wallet: Withdrew money from printer
WalletCharge    <name> (<id>) charged $1442 from wallet: ATM Deposit
ATM             <name> (<id>) has deposited 1442 (tax: 0) into their bank account, total balance: 1055625
CoinFlip        <name> (<id>) won $20,000 in a coinflip against <name> (<id>)
UpgradeLevel    Upgraded to Level 1 for 75000
```

### Items / inventory / world
```text
PocketPickup    <name> (<id>) pocketed <item>
PocketDrop      <name> (<id>) dropped from pocket <item>
Recycler        Garbage recycled. Refund: Random roll by <name> (<id>)
MysteryBoxWin   <name> (<id>) won <item> (<guid>) from mystery box
Frame           <name> (<id>) <image-url>
TV              <name> (<id>) <youtube-url>
```

### Combat / life
```text
Kill            <killer> KILLED <victim> WITH <weapon>   |   <killer> KILLED <victim>
Death           <victim> (<id>) was killed by <killer> (<id>)   |   <name> died by suicide
Hit             <name> (<id>) accepted a $1000 hit from <name> (<id>) on <target> (<id>) for <reason>
```

### Communication / RP / government
```text
Chat            [GlobalChat] <name> (<id>): <message>   // also [LocalChat]
PrivateMessage  <name> (<id>) -> <target> (<id>): <message>
Advert          Player <name> (<id>) sent advert: <message>
Me              Player <name> (<id>) used ME: <action text>
Job             <name> (<id>) changed job to <job>
RpName          <name> (<id>) set their RP name to <newname>
Vote            DemotePlayer started by <name> (<id>)
VoteDemote      Passed | Initiator: <name> (<id>) | Target: <name> (<id>) | Votes: 15 Yes / 1 No
```

> **Gotcha:** staff moderation rows tag `ENTITY = Server` (not the victim), and the
> `PLAYER` column is the **actor**. So "actions taken *against* player X" cannot be
> found by the Player filter alone — the target SteamID must be parsed out of the
> DESCRIPTION if the menu wants a "received sanctions" view per player.

## 3a. Backend API (the data source — use this, not DOM scraping)

The portal page is an Angular SPA backed by a clean REST endpoint:

```text
GET https://api.dxrp.net/v1/audit/events
    ?filterPlayerId=<steamid64>      (optional)
    &filterEntityId=<entityId>       (optional)
    &filterActions=<Action>          (optional, repeatable for multi-select)
    &pageIndex=<n>                   (0-based)
    &pageSize=<n>                    (200 works well)

Headers:  Authorization: Bearer <jwt>     // from localStorage 'token'
          X-Tenant: <tenant-guid>         // from localStorage 'tenant'
```

Response shape:
```json
{
  "items": [{
    "timestamp": "2026-05-18T20:43:43.166695+00:00",
    "playerId": "76561198891825101",
    "userId": null,
    "action": "ModifyBalance",
    "entityName": "Player",
    "entityId": "76561198891825101",
    "description": "$12 for Salary",
    "additionalData": null
  }],
  "pageNumber": 1, "pageSize": 200, "totalPages": 145,
  "totalCount": 28984, "hasPreviousPage": false, "hasNextPage": true
}
```

The API exposes full ISO `timestamp`, an `entityId` (GUID for server-context rows), and an
`additionalData` slot — all richer than the rendered table. If the in-game menu mirrors a
portal-style audit view, this is the contract to model against.

## 4. Most important insight: signal vs. noise

Both a top staff member and a regular player have logs **overwhelmingly dominated by
automatic gameplay/economy events** — `ModifyBalance` (salary every ~30s),
`PocketPickup`/`PocketDrop`, `WalletDeposit`, `ATM`, `Chat`. Ominous's actual
*moderation* actions over ~2 weeks were a tiny fraction of his total rows.

**Implications for the admin menu:**

- Default the per-player view to **moderation + tickets + combat**; make
  economy/gameplay spam an opt-in or collapsed group. A raw chronological dump is
  unusable.
- Lead with the multi-select Action filter (mirror the portal's chip UI).
  Filter presets like "Moderation", "Economy", "Combat", "Chat" map directly to §2.

## 5. Staff vs. player profile (also informs the test bots)

- **Staff (Ominous):** same gameplay noise as anyone, **plus** `Ban`/`Kick` (structured
  reasons + durations). Moderation actions are the differentiator.
- **Player (Young Sheldon):** zero staff/moderation actions; only `Chat`, `Advert`,
  `PrivateMessage`, `Job` changes, `Kill`/`Death`, `ModifyBalance`, `Wallet*`, `ATM`,
  `Pocket*`, and `StaffRequestCreated` (he *files* tickets, never claims/resolves them).

**For the test bots:** to look realistic, bots should emit a believable mix of `Chat`
(Global/Local), `Job` change, `ModifyBalance` salary, `PocketPickup`, and occasional
`Kill`/`Death`. To exercise the staff workflow, bots must be valid **targets** of
`Ban`/`Kick`/`Warn`/`Gag`/`Freeze`/`Sanction`/`Teleport`. A "no staff access" player
profile = a bot that only ever appears as actor of gameplay events and as the *subject*
(not author) of moderation rows.

## 6. Observed-action coverage (exhaustive full-log scan)

Both players' **entire** histories were paged end-to-end via the API (not sampled).

### Young Sheldon `76561198891825101` — player, no staff access
**28,984 total events** across 145 pages · **22 distinct actions**.

| Action | Count | | Action | Count |
|---|--:|---|---|--:|
| WalletDeposit | 13,254 | | Job | 80 |
| ModifyBalance | 8,549 | | StaffRequestCreated | 74 |
| PocketPickup | 1,888 | | Advert | 64 |
| PocketDrop | 1,830 | | TV | 57 |
| Chat | 691 | | PrivateMessage | 56 |
| WalletCharge | 688 | | StaffRequestUpdated | 24 |
| Kill | 537 | | Vote | 9 |
| Death | 506 | | Hit | 4 |
| ATM | 501 | | VoteDemote | 2 |
| Frame | 166 | | CoinFlip | 2 |
| | | | Warrant | 1 |
| | | | UpgradeLevel | 1 |

Zero moderation/ticket-handling actions. He *files* tickets (`StaffRequestCreated/Updated`)
but never claims/resolves. `Warrant` here is a cop-job mechanic (player requested a warrant),
not staff power. Economy events (`WalletDeposit` + `ModifyBalance` + `Pocket*`) = **~88%** of
his entire footprint.

### Ominous `76561198149414975` — Community Manager / heavy staff
**36,508 total events** across 183 pages · **40 distinct actions**.

| Action | Count | | Action | Count | | Action | Count |
|---|--:|---|---|--:|---|---|--:|
| WalletDeposit | 14,329 | | Death | 200 | | Recycler | 17 |
| ModifyBalance | 10,391 | | PrivateMessage | 122 | | Ban | 15 |
| Chat | 5,603 | | Job | 84 | | Warn | 15 |
| Teleport | 1,159 | | Arrest | 79 | | Advert | 14 |
| PocketPickup | 1,155 | | Spectate | 73 | | CoinFlip | 12 |
| PocketDrop | 1,142 | | Freeze | 71 | | Waypoint | 9 |
| WalletCharge | 498 | | SetHealth | 64 | | StaffAnnounce | 9 |
| ATM | 385 | | JobForce | 35 | | Kick | 4 |
| StaffTicketClaimed | 314 | | ForceSellDoor | 33 | | StaffRequestCreated | 4 |
| StaffTicketResolved | 293 | | Hit | 32 | | Unarrest | 3 |
| Kill | 248 | | TV | 24 | | MysteryBoxWin | 3 |
| Frame | 22 | | Vote | 21 | | RpName | 2 |
| SetBalance | 19 | | | | | UpgradeLevel | 2 |
| | | | | | | Me | 2 |
| | | | | | | Warrant | 1 |

**The differentiator is real:** moderation + ticket actions (`Teleport`, `Arrest`, `Freeze`,
`Spectate`, `SetHealth`, `Ban`, `Warn`, `Kick`, `Unarrest`, `JobForce`, `ForceSellDoor`,
`StaffTicketClaimed/Resolved`, `StaffAnnounce`, `Waypoint`) total only **~3,800 of 36,508
(~10%)**. The other ~90% is the same gameplay/economy noise any player generates.
`StaffTicketClaimed`(314)/`StaffTicketResolved`(293) confirm the ticket workflow is high-volume
and deserves a dedicated menu surface.

### Net takeaway for the menu
- The action *vocabulary* a normal player ever produces (~22 types) is a strict subset of a
  staff member's (~40). Build the per-player view to show all, but **default-filter to the
  staff/moderation/ticket groups** so the 88–90% economy noise doesn't bury the signal.
- `StaffTicketClaimed/Resolved` volume implies "tickets" should likely be a first-class tab,
  not buried under a generic audit list.
