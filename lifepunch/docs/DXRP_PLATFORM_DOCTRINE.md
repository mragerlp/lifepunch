# DXRP PLATFORM DOCTRINE — ratified 2026-07-11
Sensor: Fable direct read + hands-on creation flows, dxrp.net
(docs, marketplace, all legal pages, authenticated LIFEPUNCH
portal: every tab, settings, store, backups), 2026-07-11.
Living doctrine (amendable in place per write-once law).

## 1. Platform model
DXRP = portal (control plane) + game code (execution plane). The
portal is the authoritative backend for network configuration;
servers pulse to it and pull from it. What canon previously called
"backend DTO fields" ARE portal data, editable in the portal UI.
Operating assumption, Bloodwave-ratified: apparent limitations
seen from the editor are usually already solved portal-side —
CHECK THE PORTAL before declaring a platform gap.

## 2. Consumption model
Fork-and-publish is Dimmer's intended model (his explicit fork
encouragement to contributors; GMod/Workshop lineage formalized).
Standalone game (lifepunch.rp), Parent Game UNSELECTED — package
parenting is NOT the model. DXRP consumed at the operational pin,
LP layer on top. The server launcher (dxrp-server.cs) pulls latest
game code from GitHub + the network's addons from the DXRP API on
every boot, verifies build, launches — the Blue lane operates this
exact loop.

## 3. Publish lanes & addon anatomy
LANE A — s&box package publish (the game itself).
LANE B — DXRP portal addon revisions (the LIFEPUNCH content layer;
this is where our addon work ships).
Addon = code (→ Code\Addons\<networkId>\<addonId>\, compiled into
the game project, services auto-register) + assets (→
Assets\addons\<networkId>\<addonId>\). Identifiers immutable,
lowercase-hyphen, platform-unique. Caps: code 50MB, assets 300MB.
Our networkId: lifepunch.
Addon manage page: Details (visibility · addon identifier ·
S&BOX IDENTIFIER — the explicit lane-A↔B bridge field) · Content
entries (UI or JSON) · CONFIG (addon-level JSON defaults that
gamemodes override) · Revisions (immutable snapshots; only latest
accepts uploads; SAVE DRAFT exists before Publish; optional s&box
version pin + changelog) · Listing (price, source visibility,
media) · OWNERS/Grant Access (per-network access grants — private
distribution + where buyers appear).
Public detail page: Claim for Free / price · "N servers using
this" adoption metric · <network>.<addon> tag · Code Explorer when
source is visible. lifepunchulx (Public, Rev 13, 5 servers) is the
reference implementation and the network's sole public addon.
Grant Access observed in the wild: Monnow's Printer Upgrades shows
"Your network LIFEPUNCH™ owns this addon" — entitlement in the
Transactions view, granted by the developer, no expiry.
Developer-to-network grants are the private-distribution rail.

## 4. THE PIPELINE (canonical, Bloodwave-stated, sensor-verified)
1. PUBLISH the addon revision (lane B; draft → publish).
2. INSTALL/UPDATE it in the target gamemode's Addons tab —
   gamemodes PIN a specific revision (installed vs latest, e.g.
   Base Content Rev 6 installed / Rev 9 available). The gamemode
   addon set + config IS the LIFEPUNCH layer, portal-controlled.
3. Code-only addons: done at install. Addons with content/assets:
   entries appear in the gamemode CONTENT tab, attributed to
   addon+revision, and get configured per-entry: Primary Reference
   (asset/prefab path), NAME OVERRIDE (e.g. Monnow's "Tier 1
   Upgradable Printer" → "Monnowlith Printer T2"), grouping,
   limit-per-player, health, behavior toggles (disconnect/job
   cleanup, ownership transfer), and CONFIG JSON with Diff View
   against the addon's shipped defaults.
4. MARKET: add/bind market items (Cost + per-job Whitelist/
   Blacklist) so players can purchase/spawn — the marketItem
   contract's source of truth and Law 2's enforcement surface.
5. SAVE the gamemode.
6. SYNC SERVERS (gamemode action) — pushes to all servers running
   that gamemode.
7. TEST on a live server (Dev first, per protection doctrine).
LP ADDON CONFIG LAW: every LP addon ships tunable variables in its
config JSON (Monnow's pattern: print speed, tick rates, rate/tick)
— server owners, including future buyers, tune without code.
Reference schema (Monnow's Printer Upgrades, content-entry
Config → Full JSON, ~48 keys): per-level BankCost/BankPercent/
CoolingCost/PrintAmount/IntervalCost/StorageCost/Silencer
Cost-Radius-Volume, BaseMaxStorage, HeatDamagePerLevel, Beep/
Idle Radius+Volume. The complete upgrade economy is externalized
as config — tune in portal, diff vs shipped defaults, zero
republish. lpbitcoin's config MUST take this shape: hash rates,
tick intervals, buffer caps, tier costs, payout percents.
Buyer-side proof of the pattern: Monnow's public About page
advertises 6 upgrade tracks × 3 levels, 3 tiers, "fully
server-configurable via portal config." Configurability is a
SELLING POINT — lpbitcoin's future listing advertises the same.
· CLIENT-SYNC WARNING (third-party confirmed, SGR addon Config
  docs): gamemode config CAN BE SYNCED TO CLIENTS. Secrets (API
  keys, tokens) go in SERVER CONVARS, never addon/gamemode config.
  LP LAW: T2/T3 config carries gameplay numbers ONLY — no keys, no
  URLs-as-credentials, nothing secret. lpbitcoin's schema is bound
  by this.

## 5. Gamemodes
Create = name+description shell, then BLANK SLATE: no jobs, groups,
market, addons, default job/loadout — only platform-default
Starting Balance ($1,500). Nothing inherits: the 18-job LIFEPUNCH
config is entirely deliberate state. Tabs: General (default job,
starting balance, default loadout) · Addons (rev-pinned) · Content
· Jobs (groups + per-job salary/health/max-slots/loadout; live:
citizen 12, gundealer 20/3, hitman 8 + Fiber Wire/Pry Bar, mayor
128/1, hobo 0 + Can/Excrement) · Market · Minigames. Actions:
Sync Servers, Delete.
LIFEPUNCH runs 3: LIFEPUNCH™, LIFEPUNCH™ Dev (18 jobs / 4 addons:
Kevlar, Monnow's Printer Upgrades, Base Content, lifepunchulx),
Vanilla (clean) — 1:1 official-default mirror, our permanent A/B
control group. lpbitcoin is NOT yet installed in any gamemode.
Parallel-gamemode pattern: a future gamemode can be built complete
beside the live one and servers switched at a Sync (the launch
lever).

## 6. Server Status Page (per server)
Status: ACTIVE flag, engine version, last pulse, uptime, MAP,
RULESET, GAMEMODE — the server↔gamemode/map/ruleset binding lives
here (Edit to change). Players: current/max, rank-based WHITELIST
(Dev: Owner+Super Admin, 12 slots). Actions: BROADCAST · RESTART ·
Delete. Server Token (masked, regenerate; feeds launch command /
dxrp-server-config.json). SNAPSHOT: auto-saved world state used to
restore after restart/crash — "contains your permanent props";
Download / Upload / Clear (Clear = world reset lever). Host stats
(FPS, bandwidth). CONFIGURATION: per-server engine config as
before→after diffs vs defaults (Diff View toggle). Live-observed
knobs: cooldowns (Advert/NoCollide/FadingDoor/HitmanRequest),
DRUG ECONOMY (DrugDropMaxPrice 350→450, MinPrice 175→200,
PriceChangeCycle 1800→500 — Packet E's missing fields, found),
MysteryBoxRewards (references INVENTORY ITEM UUIDs), BreachDuration,
MaxHitPrice, DroppedMoneyDestroyTime, DropMoneyUsesBankForExcess,
SentinelTeleportReportingEnabled (SENTINEL = the platform's
automatic detection system, per-server opt-in), DiscordUrl,
RulesUrlOverride, TextWordBlacklist.

## 7. Economy spine
Global Balance is a portal-side network ledger ($60,928,433 at
study; 4,933 total players; 15s dashboard refresh) — The Gauntlet's
always-safe terminus, by construction. Per-player balances portal-
held (top ~$1.0-1.5M; sortable). AUDIT = platform-native Sensor
Law: every balance mutation is a ModifyBalance event with a reason
string — live: "$12 for Salary" streams, "$2500 for LIFEPUNCH
bitcoin sell", "$5000 for LIFEPUNCH hub BTC cashout". lpbitcoin's
Gauntlet exits already write portal evidence. Economy instruments
gain a second, portal-side sensor lane (game log + audit row).
Reason-string namespace law: every LP economy mutation carries
"LIFEPUNCH <verb>". BACKUPS: automatic hourly when active, 7-day
retention, manual create, per-snapshot Total Balance, download/
restore — player balances, levels, inventory, and store data are
restorable. Restore = destructive-class, Bloodwave's hands only.
Distinction: server SNAPSHOT = world/props state; portal BACKUP =
economy/inventory/store state.

## 8. Inventory item engine
Item Type enum: Weapon Skin, Emote, Currency, Clothing, Accessory,
Vehicle, Title, Consumable, Other. Rarity: Common/Epic/Legendary.
Per-item economy flags: Stackable(+max), Tradable, Marketable.
Create defaults: Common, stackable, tradable, NOT marketable, no
grant identifier. GRANT IDENTIFIER binds portal item → in-game
content (emote id, addon content id). Live: $BTC = Legendary
Currency, stackable max 10 (3 owners/41) — lpbitcoin's coin is
portal-native; $LP second Legendary Currency; Early Supporter
Legendary Title × 61 (May-launch cohort). EARNED-ONLY door is
mechanically enforceable (untradable+unmarketable). BULK INVENTORY:
Give/Take × items × qty with player filters (rank, online, playtime
min/max) + Preview — cohort grants in one gated op. Clothing/
Accessory = Cosmetics slice delivery rail; Consumable = Hospital
stim-war items; Vehicle = ownable entity class, all backup-covered,
all subject to the four acquisition doors + Law B.

## 9. Ranks & donor law
Ranks: order, inheritance, flags (Show On Nameplate/In Chat),
server restriction, grouped permissions (Portal/Moderation/
Commands/Ability/Building/Misc). Ladder: Owner, SA×2, Admin, Mod,
EVIP(OG), EVIP, VIP(OG), VIP, Members (11). DONOR LAW: donor ranks
grant ONLY social/QoL (nameplate/chat, RP Name, Use Title, Vote
Bets, Minigame Participate/Manage, Bypass Max Players) — ZERO
economy/combat advantage. Facepunch compliance AND LIFEPUNCH
identity: donors buy identity + convenience, never power.

## 10. Moderation & the Discord loop
Sanctions (2,290 records): manual (issuer-attributed, typed,
durations incl. Permanent), AUTOMATIC (Sentinel detections, e.g.
Teleport), AI-issued category ("Show AI" toggle). Flag/revoke/
history per row. Player profiles: editable balance/level,
inventory, staff notes (2000 chars), sanctions, full event log
(Kill/Death/Chat retained; 9,509 records on Owner). DISCORD
WEBHOOKS are portal-native and ALREADY CONFIGURED: Mod Log
(sanctions/bans/automated checks), Media, Chat Log. Webhook URLs
are CREDENTIALS — never in repos/docs/packets/pastes. The player-
report loop = Mod Log webhook + sanctions pipeline + (future)
scoped-key Discord bot.
Alt Inspector = clustered alt evidence, typed matches (IP Match /
Hardware Match; same primary may appear once per type), per-row
rank/balance/last-seen + inspect. Match type is surfaced;
confidence/recency is not — staff weigh Hardware > IP. Get Age =
per-row on-demand Steam account-age resolve. Invite = pre-login
network access grant (Steam64 + rank) via avatar-menu modal.
Data-hygiene note: two distinct rank entities share the label
"Super Admin".

## 11. API & keys
api.dxrp.net · X-Api-Key + X-Tenant headers · scoped permissions
(view/edit per domain), keys cannot exceed issuer's access,
revocable · rate limit 10 req/10s/key (429 + Retry-After).
Active: one wildcard-ALL key ("LifePunch", never-expires) —
reserved for the trusted internal integration that holds it.
KEY LAW: every new integration (Discord bot, donation automation,
lifepunchnet host link) gets its OWN minimum-scope, purpose-named,
independently-revocable key. Keys never in repos or client code.
Terms forbid API access beyond documented surface.

## 12. Monetisation rails
Payments process through DXRP only (Terms §4 EXCLUSIVITY: no
external donation links, personal handles, off-platform stores —
violation risks monetisation loss/server removal; competitor
violations observed in the public directory change nothing for
us). Stripe is the processor (card data never touches Dxura).
"Platform currency" is purchasable at platform level. Platform cut
15%; earnings accrue to a Payment Recipient ledger (Steam ID;
LIFEPUNCH unset = not selling yet, deliberate). WHITE LABELING:
operator's external store site allowed as post-purchase redirect
host (exact hostnames) — a branded shop.lifepunch.co is possible
within exclusivity. Refunds: all sales final (exceptions:
duplicate, non-delivery, fraud, law); chargebacks risk suspension
+ forfeiture; DXRP holds final refund authority over operator-sold
products — perk fulfillment must tolerate DXRP-initiated refunds.
Business doctrine: PRIVATE BY DEFAULT · AGNOSTIC BY DISCIPLINE
(portal-driven config, no LP hardcoding — lifepunchulx is the
model) · SELL LATER FROM STRENGTH (marketplace nascent: 12 public
addons, $2-13) · players > addon revenue.
THE DONATION LOOP (all on rails): DXRP product purchase → perk
delivery (rank assign / item grant / bulk op / scoped-key API) →
Discord webhook announce.
· PLATFORM CURRENCY: none exists today. "Currency" is a per-network
  inventory item TYPE; $BTC and $LP are LIFEPUNCH-defined instances.
  Privacy policy's "platform currency" language = dormant/planned
  rail; its arrival will land in the portal Changelog. Only live
  real-money rail: per-addon Stripe checkout. Marketable flag is
  0/17 network-wide, buyer-side meaning UNVERIFIED — do not design
  against it.
· Checkout anatomy (captured to hard-stop on a $2 addon): price +
  "small payment processing fee, added at checkout" · network
  selector (which network receives the addon) · Coupon Code + Apply
  · Confirm Purchase → Stripe redirect. Coupons exist platform-side
  — note for future promos.
· Paid addons hide source; free addons expose Code Explorer.
  Publisher landscape: 12 addons, 6 publishers (PikPak 6 of 12;
  Official, Monnow, LIFEPUNCH™, DXRP UK, CosmicRP). Marketplace is
  embryonic — sell-later doctrine reaffirmed.

## 13. Store (KV persistence)
Portal Store = hierarchical key-value persistence for server and
addons, per-entry expiry (live: lifepunchulx/settings,
staffmenu/settings, commands/waypoint/*). Official cross-restart
home for addon config/state — candidate target for lpbitcoin
config.

## 14. Legal corpus (Dimmer/Dxura, all read 2026-07-11)
TERMS: Facepunch policy precedence; operator responsibilities
(monetisation exclusivity; player data restricted to server
administration — portal player data NEVER leaves the portal into
repos, packets, or Cornerman); developer terms (IP warranty, no
malicious code, Dxura may inspect addon code anytime, buyers keep
distributed revisions, addon support is the developer's);
payouts (accrual, manual, discretionary, reserves, seller owns
taxes, fees changeable). PRIVACY: Steam identity + activity/audit
+ Stripe billing + technical data; no selling of personal info;
operator sharing limited to moderation-relevant; retention while
active + reasonable period; rights via legal@dxura.com. DMCA:
standard notice/counter-notice via legal@dxura.com; repeat
infringers risk termination. REFUNDS: as §12.

## 15. Public surfaces
dxrp.net/servers: all networks — name, network+gamemode tags,
description (ours carries lifepunch.co), live player count, rules,
connect. dxrp.net/marketplace/addons: the addon store (Dimmer's
Workshop/gmodstore successor — no Steam Workshop for DXRP).
Adoption metrics public.

## 16. Creation idiom & study artifacts
Portal idiom: CREATE-SHELL-THEN-EDIT (minimal dialog → full detail
page). Study artifacts pending Bloodwave's delete: addon "Fable
Test" (fable-test — identifier burned permanently), gamemode
"Fable Test Mode", items "Fable Test Item" + "Fable Study Title"
(both Vehicle/Common specimens).

## 17. Workflow integration (CVL)
· The portal is a first-class work surface beside the repo and the
  editor. Fable holds portal eyes (read + Bloodwave-authorized
  test writes); Bloodwave executes all destructive/production
  portal actions (restore, delete, Sync on live, sanctions).
· lpbitcoin route to production: lane-B revision (portal addon
  lpbitcoin, currently 0 revisions) → install into LIFEPUNCH™ Dev
  gamemode → content/config/market per §4 → Sync → live test —
  behind the existing code gates (chair → commit → PR → republish
  ruling decomposes into lane A and/or B at the sitting).
· Vanilla (clean) gamemode = canonical A/B control for economy
  disputes.
· THE LAUNCH PLAY (design-ready, unscheduled, own STOP-GO when
  real): portal backup (preserve pre-launch economy) → economy
  reset at final-package launch (mechanism = its own gated ruling;
  restore-class = Bloodwave's hands) → seed via gamemode Starting
  Balance + Bulk Inventory loyalty grants (Early Supporter
  pattern) → webhook announce.
· Cornerman: distilled, account-data-free doctrine packets only;
  never raw portal data.
· QUEUED NEXT: lifepunch.co study + Cloudflare — separate arc,
  separate record.

## 21. THE CONFIG LAYER MODEL (read in full 2026-07-11)
Three config tiers, each with its own scope and activation:
T1 SERVER ENGINE CONFIG — per-server, Edit → Editor, one JSON
  document (519 lines live on Dev). Activation: NEXT SERVER
  RESTART. Views: Diff rows ↔ override JSON ↔ full editor.
  Contains: all gameplay cooldowns (jobs/votes/arrest/lockdown/
  doors/hitman) · institutional economies (PD upgrades Overheal
  8000→M4 32000 + durations/decay, BankRaidVanishPercent 0.125,
  TaxResetTreasuryOnMayorDeath/Elect, TownNameCost, hitman price
  ladder, drug drop min/max/cycle, Recycler drop tables,
  garbage) · SENTINEL anticheat suite (Teleport/NetSpam/MassKill:
  reporting, punishment, thresholds, grace, decay — per server)
  · master switches (SalaryPaymentEnabled, MoneyEnabled,
  JobsEnabled, MinigamesEnabled, EventsEnabled, AutoUpdateEnabled
  + 120s check, SnapshotEnabled + 300s interval/600s grace) ·
  FactionsEnabled:false + FactionCreateCost:500000 (engine-ready,
  deliberately off; pairs with portal Factions WIP) · anti-
  exploit (ForcerExcludeTags:["money"], PrinterDestroyAfter
  DisconnectTime) · build governance (prop/text/frame/door/light
  limits, ~20 wire component limits, MaterialWhitelist ~55) ·
  chat (ChatMaxLength 150, distance, TTS, emojis, automessages)
  · nameplates, RpNameMaxLength, AFK-demote, armor/fall/revive,
  radio URLs, MysteryBox (win % + inventory-item UUID rewards),
  weapon spread model, medkit tuning, DupeWorkshopType "dxdupe".
T2 GAMEMODE CONFIG — per-gamemode: jobs/market/content entries +
  per-entry config JSON overriding addon defaults (name override,
  limits, health, behaviors). Activation: Save + SYNC SERVERS.
T3 ADDON SHIPPED DEFAULTS — the addon's Config tab JSON,
  inherited by every installing gamemode until overridden.
Sensor implication: "is X tunable?" is answered by checking T1
→ T2 → T3 before writing code. Most apparent engine limitations
are T1 knobs.
PARITY LAW: Dev and Official T1 configs are kept identical
except where a test explicitly requires divergence; any
divergence is temporary, named, and reverted when the test
closes. Verified identical by full-text diff 2026-07-11
(sensor: Fable, chat paste vs official.txt). Verbatim
reference: docs/reference/SERVER_CONFIG_T1_2026-07-11.json —
T1 engine config, LIFEPUNCH Official, captured 2026-07-11,
restart-activated, secret-scanned clean (no tokens/webhooks;
Discord invite, rules URL, radio streams are public).

## 22. PORTAL SCAN ADDENDA + RULINGS (2026-07-11)
· CHANGELOG LAW: dxrp.net portal Changelog is the platform drift
  sensor — dated, versioned, audience-tagged (P/O/D). Practice
  began 2026-07-08 (v0.1.0 Boiler → v0.1.3 = portal stamp
  2026.07.10-81e8e1f). LIFEPUNCH reads it WEEKLY; platform-currency
  arrival and breaking changes land there first.
· MINIGAMES: portal tab "Coming Soon" while T1 carries
  MinigamesEnabled + audit type + rank permission. Pattern: T1 runs
  ahead of portal UI — check T1 before calling a feature absent.
· RULESETS: Markdown editor (name/description/content, preview).
  PUBLIC EMBED: dxrp.net/embed/ruleset/<id> — rules embeddable into
  lifepunch.co (site-arc dependency).
· MAPS: Parent Map inheritance — prefabs layer from parent maps;
  children inherit and extend fittings. Per-map prefab upload/
  Replace/Remove/Download. LIFEPUNCH current: 2 maps, both
  thieves.rpdowntown3t, no parent set. This is the prefab rail's
  management surface.
· AUDIT ACTION-TYPE ENUM (partial, 44 captured, tail pending):
  AddLaw, Advert, Arrest, ATM, Ban, BulkGiveItems, BulkRevokeItems,
  CancelDemote, Chat, CoinFlip, Create, CustomJob, Death, Delete,
  Demote, DispatchAction, DropItem, Expire, ForceSellDoor,
  ForceRpName, Frame, Freeze, Gag, GenerateToken, GiveItem, Hit,
  Kick, Kill, MayorAnnounce, MayorTown, Me, Minigame, ModifyBalance,
  MoneySpawn, MysteryBoxWin, PickupItem, PocketDrop, PocketPickup,
  PoliticalPrisoner, PrivateMessage, Recycler, RemoveLaw, RpName,
  Sanction, [tail pending]. Every entry is a sensor lane: economy
  instruments cite ModifyBalance, moderation cites Sanction/Ban,
  item flows cite Give/Drop/Pickup.
· TAX BAND RULING (Bloodwave, 2026-07-11): Mayor band 0-30% is
  DESIGN CANON. T1 TaxRateMax raised 0.2→0.3, Dev + Official, Parity
  Law, restart-activated (Bloodwave's portal edit). Packet G rows
  1-3 dispositioned: config-below-intent, knob corrected; doctrine
  numbers stand.
· MYSTERYBOX RULING: cosmetic lootbox — rewards are inventory item
  UUIDs; WinPercentage is an open-rate, not a gambling edge. Inside
  the Cosmetic Firewall. (Packet F casino flag = false positive,
  dismissed with portal sensor.)
· Repo note: PR #60 merged as 790c43e (+534 −1, checks passed;
  GitHub sensor 2026-07-11).
· T1 SNAPSHOT SUPERSESSION: after Bloodwave's TaxRateMax edit +
  restarts, SERVER_CONFIG_T1_2026-07-11.json is stale on one field
  — next re-export lands as a NEW dated file; dated snapshots exist
  for exactly this.
· GAMEMODE EDIT SURFACE (deep-dived): jobs fully portal-authorable
  — name/model/clothes chips, group, PREREQUISITE CHAINS,
  salary/health/max-count, EQUIPMENT LOADOUT (multi-select over
  installed content equipment), vote/election flags. JSON-only job
  fields: interaction (code hook, e.g. hit.request), demotable,
  playTime (playtime-minute unlock gates — hitman=20). JOB TAGS are
  the permission + code-hook mechanism (pool: Citizen,
  PoliticalPrisoner, Mayoral, Police, Chief, Medic, Government,
  Hitman); market entries gate on whitelist/blacklist of job IDs AND
  tags; blacklists override whitelists; both empty = all jobs. Live
  Law 2 surface: printers blacklistJobTags ["Government"].
· GAMEMODE JSON MODEL (2,342 lines harvested): top-level
  {defaultJobId, startingBalance, defaultEquipmentIds, addons (with
  per-addon globalConfigOverride — addon-wide config lane),
  equipments (nameOverride/limit), entities (+healthEnabled/
  healthAmount/destroyOnDisconnect/destroyOnJobChange/
  allowOwnershipTransfer — entity HP + lifecycle are portal knobs),
  marketItems (cost/quantity — qty>1 = shipment/whitelists/
  blacklists), jobs, jobGroups}. UI|JSON toggle = bulk-edit lane.
  Export/Import/Reset-to-Vanilla exist on the gamemode (T2
  backup/restore/nuclear).
· WEAPON ROADBLOCK — CLOSED: Base Content weapons ship baseConfig
  "{}" (stats NOT portal-tunable in r6). Kevlar proves the
  mechanism: ships {ArmorAmount:25, EquipDuration:3}, carries LIVE
  gamemode configOverride {ArmorAmount:100}. THE PATH: LIFEPUNCH
  ships its own weapon addon with config'd prefabs (damage/ammo/
  spread as T3 keys) — then every weapon number is a portal knob.
  Same pattern as lpbitcoin extraction.
· EDITOR STAGING LAW: staging is PER-MODAL (Add Job stages on
  close; Add Market Item doesn't). Invariant ritual: View Changes →
  verify → page-level Cancel is the only true abort. Every modal
  open is a staged write until proven otherwise.
· Minigames: no config surface in view OR edit — placeholder
  confirmed both modes. General edit = exactly 3 fields (Default
  Job, Starting Balance stepper, Default Loadout multi-select).
· Audit enum tail: 25 further entries, SetBalance→Warrant [full
  list held in scan-seat bank — fold verbatim if couriered]. New
  audit signatures known: "$1 for Printer Bank Auto-Deposit"
  (Monnow auto-bank writes the audit lane) and MoneySpawn "$576
  spawned: Player disconnect" — FLAG: Monnow disconnect decay pays
  through a faucet-tagged action; Law A accounting review at chair
  time.
· Public /servers rows: name, tags (gamemode label shows VANILLA
  for all rows incl. ours — public label does not reflect custom
  gamemodes), description, player count, public Rules modal,
  connect. No IP/config/addon list exposed.
· Base Content observed installed (r6) while marketplace shows "not
  claimed" — install and claim are separate ledgers; meaning
  unverified. Rev 9 published ~19h before capture: review-before-
  accept gate is LIVE business.
