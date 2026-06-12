# Cornerman — Physical terminal alignment (P0 distill)

**Issued:** 2026-06-12  
**Lane:** Cornerman (Green) → **outbox notes only** — Red (VENGEANCE) implements C#  
**Model:** `WarmDistill` (`qwen/qwen3.6-35b-a3b`) unless Red assigns `WarmCoder` for scss draft  
**Parent canon:** `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md`

---

## Owner decision (locked)

Players **never** use the s&box developer console for job gameplay. No `cornerman`, `vengeance`, `hashd`, `mine`, `scan`, `hack`, or economy verbs in the `>` bar for normal play.

| Job | **Terminal** (USE → program UI) | **Hub** (passive) |
|-----|----------------------------------|-------------------|
| Bitcoin | **Bitcoin Miner** — wallet, upgrades, start/stop, sell | **GPU Rack** — compute; credits hub |
| Hacker | **Hacker Terminal** / **Advanced** — cornerman / vengeance ops console | **Server Rack** — power + link |

**Ops console** = in-fiction prompt inside Razor UI (`rig0>`, `cornerman@terminal:~$`).  
**Developer console** = staff/editor spawn (`lp_spawn_*`) and admin only.

---

## Red already shipped (VENGEANCE — verify on `main`)

Bitcoinmining alignment (this session):

| Change | File(s) |
|--------|---------|
| Hub-only USE open | `BitcoinMinerHubEntity.cs` |
| GPU rack not pressable | `GpuRackEntity.cs` — removed `IPressable` |
| Wallet on hub | `BitcoinMinerHubEntity.BitcoinAmount`; racks call `CreditMiningPayout` |
| Sell from hub | `Hub.RequestSellBitcoin()`; UI reads hub balance |
| No player ConCmds in DXRP | `HashdCommandHost.cs` — `hashd`/`mine` only `#if LIFEPUNCH_LOCAL` |
| Hacker ConCmds dev-only | `HackerCommandHost.cs` — `cornerman`/`vengeance` only `#if LIFEPUNCH_LOCAL` |
| Doctrine | `PHYSICAL_TERMINAL_DOCTRINE.md`, updated terminal doctrines + brand matrix |

**Playtest path:** `lp_spawn_bitcoin_miner_hub` → link racks → **USE hub** → `rig0>` commands.

---

## Your job (Cornerman) — audit + distill, not C#

Produce **outbox/** artifacts Red uses for hacker fixes + doc cleanup.

### Deliverable 1 — `PHYSICAL_TERMINAL_GAP_AUDIT.md`

Read repo (after `Cornerman (Sync from Red)`). Table per addon:

| Check | Bitcoin | Hacker |
|-------|---------|--------|
| Only terminal entity is `IPressable` for UI open? | | |
| Hub entity passive (no job ConCmd open)? | | |
| Player ConCmds absent in non-LOCAL build? | | |
| Economy/wallet on terminal or hub (not compute prop)? | | |
| Playtest docs say USE not dev console? | | |
| Stale `cornerman`/`hashd` player paths in briefs? | | |

List **file:line** gaps. Flag `RED_HACKER_JOB_BUILD.md` H1 still using `lp_cornerman_ui` as pass criteria.

### Deliverable 2 — `HACKER_SERVER_RACK_TERMINAL_PARITY.md`

Mirror bitcoin hub/rack split for hacker:

- **Server Rack** = power, link range, fan/hum — same role as GPU rack  
- **Hacker Terminal** = sole USE target; `HackerTerminalEntity.Press` → ops UI  
- Confirm `HackerServerRackEntity` is **not** opening UI on USE (audit current code)  
- Session close on walk-away: distance anchor = **terminal** or **rack**? Recommend one.

### Deliverable 3 — `STALE_TERMINAL_DOC_FIXLIST.md`

Bullet list of docs to update on Red (do not edit on Green):

- `CORNERMAN_HACKER_JOB_TERMINAL_TASK.md` — remove `cornerman`/`hack` as player commands table  
- `RED_HACKER_JOB_BUILD.md` — H1 pass = USE CRT after `lp_hacker_kit_preview`, not `lp_cornerman_ui`  
- `BITCOINMINING_PLAYTEST.md` — remove `hashd`/`mine` player table  
- `HACKER_JOB_PLAYTEST.md` — same  
- Any brief still saying “open via hashd on rig”

### Deliverable 4 — `HACKER_UI_PARITY_NOTES.md` (optional)

Compare `HackerTerminal.razor` vs `HashdTerminal.razor` for:

- Bottom-right dock, branding trim, settings cog vs expand  
- Footer version string pattern (`lifepunch.hackerjob v1.0.0 - lifepunch.co`)  
- Rail telemetry vs module panes per `HACKER_OPS_CONSOLE_SPEC.md`

Distill only — screenshots optional if owner sends.

---

## Red implementation queue (after your outbox)

Red executes from `to-vengeance-physical-terminal-red.txt`:

1. Hacker: remove `HackerServerRackEntity` UI open if present; terminal-only USE  
2. Hacker: align playtest runbooks to USE CRT  
3. Docs sweep per your fixlist  
4. Phase 2 economy stays Opus on Red

---

## Warm + sync

```powershell
powershell -File lifepunch\scripts\Send-CornermanWorkflow.ps1 -Action WarmDistill
# Green: Cornerman (Sync from Red).cmd
```

## Ping Red when done

```text
OK physical-terminal distill — outbox/PHYSICAL_TERMINAL_GAP_AUDIT.md + parity + fixlist ready
```

## Do NOT

- Commit C# on Green  
- ModelDoc / prefab edits  
- Claim eyes on game — Cornerman is repo + distill only unless owner screenshots
