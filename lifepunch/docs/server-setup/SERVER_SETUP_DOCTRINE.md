# LIFEPUNCH SERVER SETUP DOCTRINE

Ratified: 2026-07-12. Drafted by Codex; **landed by Red with three byte-verified corrections**
(§5 TaxRateMax, §2.10 severity, `RefundEntities` demotion — each marked below).

This document is the operator route for standing up or restoring a LIFEPUNCH server. It
inventories the required portal/server surfaces and orders their restoration. It does **not**
replace the platform model, config-layer model, or canonical deployment sequence in
[`DXRP_PLATFORM_DOCTRINE.md`](../DXRP_PLATFORM_DOCTRINE.md) — consult that doctrine, especially
§4, §5, §6, §10 and §21, before operating these surfaces.

## 1. Canonical setup sensors

The dated files below are **verbatim exports**. They are sensors of portal/server state **at the
date in their filename**, not live-state assertions. All five were SHA256-verified byte-identical
to the OneDrive drop zone at landing, and secret-scanned (clean: no tokens, no webhooks; the only
URLs are public radio streams; the long strings are addon GUIDs).

- [`config/SERVER_CONFIG_T1_2026-07-12.json`](config/SERVER_CONFIG_T1_2026-07-12.json) — fresh T1
  server-engine export.
- [`config/GAMEMODE_CONFIG_T2_2026-07-12.json`](config/GAMEMODE_CONFIG_T2_2026-07-12.json) — T2
  gamemode export: addon pins, content entries, market items, jobs, job groups, `configOverride`.
- [`motd/MOTD_2026-07-12.md`](motd/MOTD_2026-07-12.md) — the eight-category player-facing ruleset.
- [`motd/ANNOUNCEMENTS_2026-07-12.txt`](motd/ANNOUNCEMENTS_2026-07-12.txt) — in-game announcement panel.
- [`snapshots/WORLD_SNAPSHOT_EMPTY_2026-07-12.json`](snapshots/WORLD_SNAPSHOT_EMPTY_2026-07-12.json)
  — clean world-snapshot format exemplar (verified: **zero `MoneyEntity` occurrences**).

The earlier `../reference/SERVER_CONFIG_T1_2026-07-11.json` remains untouched as a historical T1
sensor. **A dated export is never automatically the current portal value.**

## 2. Operator surface census

Standing up a server requires deliberate configuration of **every** surface below. A newly created
gamemode is a **blank slate** apart from platform defaults — do not assume jobs, groups, equipment,
addon pins, content, or market bindings were inherited.

**2.1 Server identity/binding** — gamemode, map, ruleset; server name; capacity; rank whitelist;
restart/sync controls used only at the stages below. **The server token is a credential and must
never enter this repository.**

**2.2 Gamemode general** — name, description, starting balance, default job, default loadout.

**2.3 Jobs and job groups** — create groups, then jobs. Verify group, salary, health, max players,
model/clothing, loadout, prerequisites, playtime gates, election/vote settings, tags. **Job IDs and
tags feed market access control — settle them before binding market items.**

**2.4 Addon revision pins** — install each addon and pin the **intended** revision. "Latest
available" is not proof the intended revision is installed. The revision must already have been
published through Lane B.

**2.5 Content entries + config JSON** — per installed addon: confirm attribution to the intended
addon **and revision**; set primary reference, name override, grouping, limit, health, cleanup,
ownership-transfer; apply per-entry config JSON / `configOverride`; **inspect the portal diff
against the addon's shipped defaults.** These per-gamemode values are **T2**; the addon's shipped
defaults are **T3**.

**2.6 Market bindings** — bind a market item per purchasable content entry: content entry, cash
cost, job-ID and job-tag whitelists **and** blacklists. This is the portal enforcement surface for
**Law 2**. Blacklists take precedence over whitelists; **empty access lists mean available to all
jobs.** Re-review after any job/tag/content change.

**2.7 T1 server-engine config** — apply from the dated export. **T1 activates on the next server
restart, not when saved.** The 07-11 file is a comparison sensor only; never overwrite it.

**2.8 MOTD + announcements** — install both dated files. Verify the live surfaces preserve ordering
and formatting. **Repository presence does not prove player-visible rendering.**

**2.9 Discord webhooks** — configure portal-side. **Webhook URLs are credentials.** Never place them
in repository files, docs, screenshots, packets, console output, or handoffs. The repo records only
that the fields must be populated and verified.

### 2.10 World snapshots

Live intended configuration on 2026-07-12 (byte-verified in the T1 export): `SnapshotEnabled: true`
(`:331`), `SnapshotSaveInterval: 300` (`:333`), and `SnapshotInitialSaveGrace: 600` (`:332` — a
field no proposal named; recorded here so it is not lost).

**CRITICAL — every-boot restore, NOT crash-gated.** *(Red correction: the earlier MEDIUM grade was
argued from a crash-only premise the code disproves.)*

> **Sensor:** `lifepunchdxrp/game/Code/System/Recovery/SnapshotSystem.cs`, `OnSecondlyUpdate`:
> `if ( _pendingSnapshot != null && Time.Now > 5f ) → LoadSnapshot( file )`
>
> The condition is **snapshot-exists + 5 s elapsed**. **There is no crash gate.** The restore fires
> on **every boot** where `SnapshotSystem` runs with a snapshot present.

**CRITICAL — MoneyEntity snapshot duplication.** The snapshot path can duplicate snapshotted money
entities, and because restore fires on *every* boot, **every restart mints**. Treat any snapshot
containing `MoneyEntity` state as **unsafe** until the money-repair slice lands and is proven. The
repair must cite the clean exemplar above and must separately prove capture, restore, **and
repeated restore**. See [`../slices/MONEY_REPAIR_SLICE.md`](../slices/MONEY_REPAIR_SLICE.md).

**`RefundEntities` — PORTAL-SURFACE CLAIM, not witnessed by these sensors.** *(Red correction.)* The
claim that a portal control labelled `RefundEntities` is mis-wired into a snapshot parameter
**cannot be evidenced from these exports**: the string appears in **neither** the T1 nor the T2
export. Record its displayed and exported values when observed **in the portal**, and do not rely on
the toggle as proof of refund behaviour. Correction is deferred to its own scoped repair.

## 3. Config-layer placement

Authoritative layer definitions live in `DXRP_PLATFORM_DOCTRINE.md` §21. Placement of this set:

| File / surface | Layer | Scope + activation |
|---|---|---|
| `config/SERVER_CONFIG_T1_2026-07-12.json` | **T1** | Per-server engine config; activates on **restart**. |
| `config/GAMEMODE_CONFIG_T2_2026-07-12.json` | **T2** | Gamemode, pins, content, jobs, groups, market, per-entry overrides; activates on **Save + Sync Servers**. |
| Addon Config defaults referenced by T2 entries | **T3** | Shipped addon defaults, inherited until a T2 override replaces them; changing them requires the addon revision pipeline. |
| `motd/*` | Portal/operator surface | Publish + verify player-facing presentation. |
| `snapshots/*` | World-state sensor | Upload/restore **only** under an explicitly authorized destructive operation. |
| Discord webhook fields | Portal-side **credential** surface | Activate + verify in the portal; **never** export URLs into the repo. |

**T2 and T3 carry gameplay values only.** Credentials, tokens, API keys and credential-bearing URLs
are **forbidden in both** — gamemode config can sync to clients.

## 4. Restore from zero

The publish/install/content/market/save/sync/test stages are the canonical pipeline from
`DXRP_PLATFORM_DOCTRINE.md` §4.

1. **Server shell** — create/select; identity, gamemode/map/ruleset, capacity, whitelist. Token stays out of the repo.
2. **Gamemode shell** — name + description. **Treat as blank.**
3. **T2 general state** — starting balance, default job, default loadout, job groups, jobs. Settle IDs and tags **before** market work.
4. **Publish addon revisions** — each required Lane B revision. Precedes installation.
5. **Install + pin addons** — pin the exact intended revision.
6. **Content entries + T2 overrides** — recreate each; compare every override against its T3 default.
7. **Market bindings** — bind items, then costs and job whitelists/blacklists. Recheck Law 2 after the bindings exist.
8. **Save the gamemode** — before any sync.
9. **Apply T1** — load the dated export; review the portal diff.
10. **MOTD + announcements** — from their dated copies.
11. **Webhooks** — portal-only; URLs never leave the portal.
12. **Snapshots** — verify `SnapshotEnabled: true`, interval 300. Treat `MoneyEntity` snapshot state as **CRITICAL** until its repair gates. Do not restore a world snapshot as part of ordinary setup.
13. **Restart** — T1 activates here. **A saved T1 document without a restart is not an activated configuration.**
14. **Sync Servers** — T2 activates here. Preserve the order: **Save, then Sync.**
15. **Test on Dev first** — revisions, content, overrides, market cost/access, jobs, starting state, MOTD, announcements, webhook delivery, T1 activation, snapshot settings. **Static repo copies never prove deployed behaviour.**

## 5. TaxRateMax supersession — 2026-07-12

**RULED (Bloodwave, 2026-07-12): canonical `TaxRateMax` is `0.25`.** This supersedes the prior `0.3`
design value in `DXRP_PLATFORM_DOCTRINE.md` §21.

**BYTE-VERIFIED (Red correction — this overturns the draft's claim).** The draft stated the fresh
07-12 export reads `"TaxRateMax": 0.2`. **It does not.**

- Landed `config/SERVER_CONFIG_T1_2026-07-12.json` **`:182` → `"TaxRateMax": 0.25`**
- `../reference/SERVER_CONFIG_T1_2026-07-11.json` **`:182` → `"TaxRateMax": 0.2`**

Same line number in both files — the draft read the **07-11** file and attributed it to the fresh
export. **The bytes win.** The portal edit to `0.25` is **DONE**; only **restart activation** is
pending (T1 activates next restart).

**Never edit a dated export to make it appear compliant.** It is a verbatim sensor of exported state.
Record interpretation and supersession in doctrine, not by rewriting the sensor.

## 6. Export discipline

The OneDrive server-setup folder is the operational drop zone; repository copies are dated, verbatim
sensors of the bytes exported from it.

1. Copy bytes **verbatim** — no normalizing, reordering, or in-place redaction.
2. A new export creates a **new dated file**.
3. **Never overwrite** an earlier dated export.
4. Preserve historical exports even when a later ruling supersedes one of their values.
5. Record interpretation and supersession **in doctrine**, not by rewriting the sensor.
6. **Machine-verify** copied bytes against the drop-zone source before landing (SHA256).
7. **JSON-validate** without rewriting bytes.
8. **Secret-scan** every candidate before it enters the repo. If a secret is found: **stop.** Do not
   commit a "sanitized export" under the same sensor claim.

## 7. Proof required before declaring a restore complete

Exact installed pins · saved+synced T2 · content references and config diffs · market costs and job
access lists · T1 portal diff **plus a restart that postdates the save** · `TaxRateMax` reading
`0.25` in the next dated export · player-visible MOTD/announcement rendering · portal-side webhook
delivery **without exposing its URL** · snapshot toggle + 300 s interval · explicit acknowledgement
that `RefundEntities` remains an **unwitnessed portal-surface claim** · explicit acknowledgement that
`MoneyEntity` snapshot duplication remains **CRITICAL** until its repair slice passes.

**Without those sensors, the corresponding live, visual, portal, or deployed claim is UNVERIFIED.**
