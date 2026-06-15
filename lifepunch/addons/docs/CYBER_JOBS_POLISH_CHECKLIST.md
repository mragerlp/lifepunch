# LifePunch cyber jobs — polish checklist (hub → terminal → rack)

**Production gate:** `ACTIVE_WORKSTREAM.md` — **all rows below are BLOCKED** until Bitcoin Phases A–C sign-off.  
**Law:** one item at a time → play proof → owner sign-off → check box → next.  
**Shared pattern:** **Hub / Server Rack** (power, PIN, linking, upgrades) → **Terminal** (typed CRT commands) → **Satellite entities** (racks, tellers, miners).

**Bitcoin lane (civilian):** `Code/Addons/lifepunch/bitcoinmining/docs/BITCOINMINING_POLISH_CHECKLIST.md` — **finish Phase A–C first**; other lanes compose from those patterns.

**Full job portfolio (all tiers):** `JOB_PORTFOLIO_ROADMAP.md` — owner priority after bitcoin (Drug Chemist, Security Guard, SWAT, Hitman, Casino, etc.).

**Brand canon:** `TERMINAL_BRAND_MATRIX.md` · `branding/OPS_CRT_TERMINAL_THEMES.md` · `PHYSICAL_TERMINAL_DOCTRINE.md`

---

## Build order (owner)

| Order | Lane | Addon ident | Status | Blocked on |
|-------|------|-------------|--------|------------|
| **0** | Civilian Bitcoin Miner | `bitcoinmining` | **Active** — Phase A in progress | — |
| **1** | Hacker (criminal) | `hackerjob` | **Blocked** | Bitcoin Phases A–C owner sign-off |
| **2** | Banker | `bankerjob` | Spec / scaffold only | Bitcoin + hacker Phase 1 playtest; Opus economy |
| **3** | Black Market Dealer | *(TBD ident)* | Theme SCSS only (`lp-ops-crt--blackmarket`) | Bitcoin BTC wallet + optional hub payment RPC |
| **4** | Drug Chemist | `advanceddrugprocessing` | Assets partial; economy not signed off | Hub pattern; **likely no terminal** |
| *(Phase F — after Hacker)* | Government / FBI (protagonist cyber) | `governmentdatacenter` + `government-server-rack` + `police-terminal` | Concept greenlit; **no deep dive until E-D done** | Hacker advanced terminal + govdb breach/response loop |

**Tier 2+ (not in this checklist yet):** Security Guard, SWAT, Secret Service, Hitman, Casino Manager — see `JOB_PORTFOLIO_ROADMAP.md`.

---

## Progress summary

| Lane | Hub / rack | Terminal | Sign-off |
|------|------------|----------|----------|
| **Hacker (criminal)** | Not started | Not started | — |
| **Gov / FBI (protagonist)** | Not started | Not started | — |
| **Banker** | Not started | Not started | — |
| **Black Market Dealer** | Not started | Not started | — |

**Last updated:** 2026-06-15 (FBI Phase F canon + bitcoin access law + hacker starter vs purchased tiers)

---

## Lane map (who is who)

| Role | Fiction machine | Program | Accent | Hub entity | Terminal entity |
|------|-----------------|---------|--------|------------|-----------------|
| **Civilian miner** | hashd | `rig0>` | Amber `#f0a500` (admin) / gray CRT | `bitcoin-miner` | `bitcoin-terminal` |
| **Hacker (standard)** | Cornerman | `cornerman.exe` | Green `#00FF7F` | `server-rack` | `hacker-terminal` |
| **Hacker (advanced)** | VENGEANCE | `vengeance.exe` | Red `#E4002B` | `advanced-server-rack` | `advanced-hacker-terminal` |
| **Police / FBI cyber** | lifepunchnet | `lifepunch-ops.exe` | Cyan `#00D4FF` | `government-server-rack` | `police-terminal` (Government Terminal) |
| **Gov treasury miner** | city rig | `treasuryd` (LCD) | Cyan `#00D4FF` | — *(map/server placed)* | `government-data-center` *(autonomous tax miner)* |
| **Bank manager** | vault branch | `vaultd` | Navy `#000080` + gold `#C9A227` | `bank-vault-hub` | `bank-teller-terminal` |
| **Bank security** | sentinel | `sentinel.exe` | Steel blue `#4A6FA5` | links to `bank-vault-hub` | `bank-security-terminal` |
| **Black market dealer** | underground shop | TBD | Black shell `#000000` | **BTC payment hub** *(reuse hashd hub pattern)* | dealer CRT + catalog |

**RP triangle:** Civilians bank · hackers steal **wallet only** · bank security + FBI trace/respond · dealers accept **BTC** for contraband.

---

## Cross-job laws (owner)

### lifepunchbitcoin entity access

| Rule | Detail |
|------|--------|
| **Who may spawn / USE** | **Every job** may spawn and operate **lifepunchbitcoin** entities (hub, terminal, GPU racks) — civilian miners, hackers, bankers, dealers, chemists, etc. |
| **Exception** | **Government / Law Enforcement jobs** may **not** spawn or USE player bitcoin entities. Gov treasury uses **Government Data Center** only (Phase F). |
| **Why** | Keeps city treasury separate from personal mining; FBI counters breaches on **other people's** miners, not by running hashd rigs. |

### Hacker entity tiers (starter vs purchased)

| Tier | Entities | Cost / security | Commands |
|------|----------|-----------------|----------|
| **Starter** | `server-rack` + `hacker-terminal` (Cornerman green) | **Low price**, **less secure** (higher fail-alert risk; lower upgrade ceilings) | Wallet `scan` / `hack` — entry criminal cyber |
| **Purchased upgrade** | `advanced-server-rack` + `advanced-hacker-terminal` (VENGEANCE red) | **Much more expensive**, higher-end hardware, harder to operate | Higher-reward targets: player **bitcoin miners**, **bank**, **gov datacenter** / city funds — more complex puzzles |

Hackers **buy** the advanced rack + terminal in-world (DXRP economy). Standard kit is the job's starting footprint; red tier is the prestige breach tool that pairs against **Phase F** protagonist cyber.

### Criminal vs protagonist cyber

| Side | Job | Hub | Terminal | Opposes |
|------|-----|-----|----------|---------|
| **Criminal** | Hacker | `server-rack` / `advanced-server-rack` | Cornerman green / Vengeance red | FBI, bank security |
| **Protagonist** | FBI / gov cyber (Phase F) | `government-server-rack` | **lifepunchnet** `police-terminal` (`lifepunch-ops.exe`) | Advanced hacker (red) |

**Phase F gate:** finish **Hacker Job** (Phase E, especially E-D advanced terminal) before deep-diving FBI counter-intrusion design.

---

# Phase E — Hacker Job (criminal lane)

**Addon:** `hackerjob` · **s&box:** `lifepunch.hacker` · **Portal:** `019e448c-4958-77d1-84b7-c7ec3f1bc328`  
**Order:** Server Rack (basic **starter**) → Hacker Terminal → **Purchasable** Advanced Server Rack → **Purchasable** Advanced Hacker Terminal  
**Tier law:** green kit = job starter (cheap, less secure, wallet hacks only). Red kit = expensive upgrade (complex commands, higher rewards — miners, bank, govdb).  
**Canon:** `HACKER_JOB_SPEC.md` · `HACKER_SERVER_RACK_SPEC.md` · `hackerjob/docs/HACKER_JOB_PLAYTEST.md`

### Session setup

```powershell
powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon hackerjob,adminmenu
```

```text
game.scene → Play → lifepunch_spawn_testbot Greg
lp_hacker_kit_preview          # both racks + both terminals (powered)
lp_spawn_server_rack             # basic rack only
lp_spawn_advanced_server_rack  # advanced rack only
```

---

## E-A — Server Rack (basic hub)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **E-A1** | ☐ | **Mesh compile** — `server-rack.vmdl` + vmats; prefab root `1,1,1` | No missing `_c` spam; scale vs citizen sane | ModelDoc + flatgrass spawn |
| **E-A2** | ☐ | **Scale + ground contact** — import law per `MODEL_SCALE_DOCTRINE.md` | Feet on ground; collider matches mesh | Orbit screenshot + bounds log |
| **E-A3** | ☐ | **Collider + perf** — tuned `BoxCollider`; rigidbody asleep | No FPS tank on spawn | `lp_spawn_server_rack` |
| **E-A4** | ☐ | **Power state** — `HackerServerRackEntity` POWER ON/OFF unmistakable | Linked terminals offline when rack off | Toggle power in rack menu |
| **E-A5** | ☐ | **Rack menu UI** — `HackerServerRackMenu` green ops; upgrades readable | Detection / puzzle / yield / cooldown tiers show costs | USE powered rack |
| **E-A6** | ☐ | **Link radius** — terminals within 8m H / 4m V register to rack | `cornerman` CRT shows `[ STANDBY ]` when powered | Kit preview layout |
| **E-A7** | ☐ | **Basic rack sign-off** | Owner OK on silhouette + power + menu | Screenshot |

---

## E-B — Hacker Terminal (standard / Cornerman green)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **E-B1** | ☐ | **World mesh** — `hacker-terminal.vmdl` compiles; green accent materials | CRT readable at USE range | Spawn next to powered rack |
| **E-B2** | ☐ | **CRT UI migration** — `lp-ops-crt--hacker` shell (from `LpOpsCrtTerminal.scss`) | Green `#00FF7F`; prompt `cornerman@terminal:~$` | `lp_cornerman_ui` or USE CRT |
| **E-B3** | ☐ | **Session flow** — boot → scan list → puzzle prompt | No typing in s&box `>` console for gameplay | `scan` → `hack <steamid>` |
| **E-B4** | ☐ | **Bot playtest** — Greg appears in scan with wallet | Puzzle completes (Phase 1 stub OK) | `lifepunch_spawn_testbot` + kit |
| **E-B5** | ☐ | **Rack dependency** — terminal denied when rack off | `[ OFFLINE ]` on CRT | Power off rack |
| **E-B6** | ☐ | **Standard terminal sign-off** | Owner OK green CRT + scan/hack stub | 30s capture |

**Out of scope E-B:** Phase 2 wallet transfer (`HackerEconomySecurity` host debit) — Opus gate.

---

## E-C — Advanced Server Rack

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **E-C1** | ☐ | **Mesh compile** — `advanced-server-rack.vmdl` | Clean compile; distinct read vs basic rack | Side-by-side spawn |
| **E-C2** | ☐ | **Scale + collider** — same law as E-A | Ground contact; perf OK | Bounds audit |
| **E-C3** | ☐ | **Tier caps** — higher detection/puzzle upgrade ceilings than basic | Menu shows advanced-tier costs | `HACKER_SERVER_RACK_SPEC.md` |
| **E-C4** | ☐ | **Vengeance terminal pairing** — advanced rack powers red CRT only | Registry tier match works | `lp_hacker_kit_preview` right side |
| **E-C5** | ☐ | **Advanced rack sign-off** | Owner OK | Screenshot |

---

## E-D — Advanced Hacker Terminal (VENGEANCE red)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **E-D1** | ☐ | **World mesh** — `advanced-hacker-terminal.vmdl`; red `#E4002B` accents | Distinct from green terminal | Powered advanced rack |
| **E-D2** | ☐ | **CRT UI** — `lp-ops-crt--vengeance`; prompt `vengeance@terminal:~$` | Red shell; no amber/cyan bleed | `lp_vengeance_ui` or USE |
| **E-D3** | ☐ | **Govdb commands** — `govdb`, `infil`, `govdb_breach` stub loop | Terminal accepts typed commands | Playtest § advanced |
| **E-D4** | ☐ | **Target policy** — `HackerHackTargetPolicy`: wallets + miners + govdb on advanced only | Standard tier cannot `govdb` | Policy table verified |
| **E-D5** | ☐ | **Advanced terminal sign-off** | Owner OK red CRT + govdb stub | Capture |

---

# Phase F — Government / FBI (protagonist cyber)

**Addons:** `governmentdatacenter` · `hackerjob` (advanced red terminal = **opposing breach tool**) · police terminal assets  
**Fantasy:** **Government hacker** — counter-intrusion, trace, audit, intercept **large-scale** breaches against **bitcoin miners**, **the bank**, and **city funds**. Not wallet theft; lawful protagonist cyber.  
**Hub / terminal / miner:**
- **Government Server Rack** — hub (power, linking, upgrades) for gov cyber kit
- **Government Terminal** (`police-terminal`) — **lifepunchnet** cyan CRT · `lifepunch-ops.exe`
- **Government Data Center** — autonomous BTC miner on map; always mining; every 30m deposits **0%–30%** of accumulated BTC (mayor tax rate) as **cash → city funds**; no player withdraw

**Gate:** **Do not deep-dive Phase F until Hacker Job Phase E is finished** (especially E-D advanced terminal + target policy). Advanced Hacker (red) must exist as a real antagonist before FBI response loops are designed.  
**Canon:** `GOVERNMENT_DATABASE_SPEC.md` · `GOV_DATACENTER_ROLEPLAY.md` · `TERMINAL_BRAND_MATRIX.md`

### Session setup (when entities compile)

```text
# TBD — gov tax miner + police terminal spawn cmds
# Advanced hacker breaches: lp_hacker_kit_preview → vengeance → govdb
```

---

## F-A — Government Data Center (autonomous tax miner)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **F-A1** | ☐ | **Mesh + blue LCD** — `government-data-center` (or `government-tax-miner`) compiles | Cyan console read; always-mining fiction | Map or dev spawn |
| **F-A2** | ☐ | **Server mining loop** — accrual + 30m tax tick → city cash | No player withdraw; cap enforced | Host log / HUD |
| **F-A3** | ☐ | **Tax rate** — mayor sets 0–30% (host RPC) | Rate changes affect next tick | Mayor playtest |
| **F-A4** | ☐ | **Job gate** — gov jobs cannot USE player `bitcoin-miner` / hashd entities | Civilian + criminal jobs still can | Job swap test |
| **F-A5** | ☐ | **Data center sign-off** | Owner OK blue datacenter read | Screenshot |

---

## F-B — Government Server Rack (protagonist hub)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **F-B1** | ☐ | **Mesh compile** — `government-server-rack.vmdl` | Cyan lifepunchnet read; distinct from hacker racks | Spawn + compile |
| **F-B2** | ☐ | **Hub menu** — power, link radius, upgrade slots for gov terminal | Powers `police-terminal` when ON | USE hub |
| **F-B3** | ☐ | **Job gate** — police / FBI / mayor / gov jobs only | Civilians + hackers denied hub USE | Job swap test |
| **F-B4** | ☐ | **Gov rack sign-off** | Owner OK hub silhouette + power | Screenshot |

---

## F-C — Government Terminal (lifepunchnet / FBI desk)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **F-C1** | ☐ | **World mesh** — `police-terminal.vmdl` (govdatacenter intake) | Compile clean | Spawn near gov rack |
| **F-C2** | ☐ | **CRT UI** — `lp-ops-crt--government`; `lifepunch@lifepunch.net:~$` | Cyan `#00D4FF`; not hacker green/red | USE terminal |
| **F-C3** | ☐ | **Counter-hack tools** — trace / audit / alert on advanced hacker activity (Phase 2) | Intercepts breaches on miners, bank, city funds | Alert when red-tier hack fails nearby |
| **F-C4** | ☐ | **Job gate** — police / FBI / gov jobs only | Civilians denied USE | Job swap test |
| **F-C5** | ☐ | **FBI desk sign-off** | Owner OK protagonist cyber read | Capture |

**Note:** **Advanced Hacker (red)** is the **antagonist** tool against F-A/F-C. Polish **E-D** before **F-C** for a meaningful breach/response loop.

**Future:** **Cybersecurity Officer** job — separate owner build; not in matrix yet.

---

# Phase G — Banker Job

**Addon:** `bankerjob` · **s&box:** `lifepunch.banker` *(planned)* · **Status:** spec-only / quarantine WIP  
**Order:** Bank Vault Hub → Teller Terminal → Security Terminal → Bank-owned miners  
**Canon:** `BANKER_JOB_SPEC.md` · `bankerjob/docs/BANK_VAULT_HUB.md` · `INTEGRATION_MAP.md`

**Hard rule:** Hackers steal **wallet only** — vault never drains via `hack` (see `HACKER_PHASE2_ECONOMY_PREP.md`).

### Session setup (when greenlit)

```powershell
# TBD: Sync-LifePunchAddonsToDxrp.ps1 -Addon bankerjob
# TBD: lp_bank_spawn_branch_kit
```

---

## G-A — Bank Vault Hub (institution hub)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **G-A1** | ☐ | **Art pass** — `bank-vault-hub` reskin or child of Ophion/bank mesh | Reads as **institution**, not criminal hashd | Flatgrass + citizen scale |
| **G-A2** | ☐ | **Entity shell** — `BankVaultHubEntity`: PIN, power, owner/job bind | Mirrors `LpBitcoinHubEntity` patterns | USE hub |
| **G-A3** | ☐ | **Vault panel** — `vaultd` admin rail: deposits summary, linked tellers, miners | Navy/gold chrome; no mine/sell on hub | Manager job USE |
| **G-A4** | ☐ | **Ledger service** — `BankVaultLedgerService` host-only deposit/withdraw | Server validates amounts; audit log | Deposit/withdraw test |
| **G-A5** | ☐ | **Interest accrual** — periodic tick with caps (anti-AFK) | No client-triggered interest | Timed playtest |
| **G-A6** | ☐ | **Branch alerts** — publish `HackerScanInRange` etc. for security/FBI hooks | Events fire on test stimuli | Log lines |
| **G-A7** | ☐ | **Vault hub sign-off** | Owner OK | Screenshot |

---

## G-B — Bank Teller Terminal

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **G-B1** | ☐ | **Mesh + prefab** — `bank-teller-terminal` | 4m link to vault hub | Spawn in branch kit |
| **G-B2** | ☐ | **CRT UI** — `lp-ops-crt--banker`; `vaultd` deposit/balance commands | Navy `#000080` + gold accents | USE teller |
| **G-B3** | ☐ | **Wallet → vault RPC** — host moves cash; job-gated | Cannot overdraft wallet | Teller job playtest |
| **G-B4** | ☐ | **Teller sign-off** | Owner OK | Capture |

---

## G-C — Bank Security Terminal (sentinel)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **G-C1** | ☐ | **Mesh + prefab** — `bank-security-terminal` | Links to same branch hub | Branch layout |
| **G-C2** | ☐ | **CRT UI** — `sentinel.exe`; steel blue `#4A6FA5` | Defense-only commands; no `hack` | USE security desk |
| **G-C3** | ☐ | **Alerts Phase 1** — read-only hacker proximity / failed PIN feed | Security staff sees alerts | Trigger hack nearby |
| **G-C4** | ☐ | **Lockdown stubs** — `LOCKDOWN` / `FREEZE` host RPCs documented | Phase 2+ if not wired | Spec + log |
| **G-C5** | ☐ | **Security terminal sign-off** | Owner OK | Capture |

---

## G-D — Bank-owned crypto miners

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **G-D1** | ☐ | **Prefabs** — `bank-gpu-rack` composes bitcoin rack art | Credits **branch pool**, not player wallet | Miner + hub link |
| **G-D2** | ☐ | **Job gate** — only bank roles manage bank miners | Civilians cannot upgrade bank racks | Job test |
| **G-D3** | ☐ | **Bank miners sign-off** | Owner OK branch mining read | Screenshot |

---

# Phase H — Black Market Dealer

**Addon ident:** *TBD* (e.g. `blackmarketdealer`) — **not in `addons.json` yet**  
**Payment:** accepts **BTC** from player wallets for gadgets/weapons — reuses **civilian bitcoin hub + terminal payment RPC** pattern, not a fork.  
**Canon:** `branding/OPS_CRT_TERMINAL_THEMES.md` (`lp-ops-crt--blackmarket`) · compose from `LIFEPUNCH_HUB_PATTERN.md`

**Blocked on:** Bitcoin Phase A–C + terminal `sell`/wallet flow proven.

### Session setup (when greenlit)

```text
# TBD: lp_blackmarket_spawn_shop
# Player pays BTC via terminal after civilian mining loop
```

---

## H-A — Dealer hub (BTC payment hub)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **H-A1** | ☐ | **Entity design** — dealer hub owns shop catalog + BTC price list (host) | Spec signed; no DXRP cash duplication | Design review |
| **H-A2** | ☐ | **World prop** — underground shop hub mesh (owned art) | Criminal read; not banker/gov | Flatgrass spawn |
| **H-A3** | ☐ | **Hub admin panel** — modern clickable: stock, prices, power, linked terminal | Black/gold chrome; no police cyan | USE hub |
| **H-A4** | ☐ | **BTC settlement** — debit player BTC balance server-side on purchase | Client cannot set price | Buy flow test |
| **H-A5** | ☐ | **Dealer hub sign-off** | Owner OK | Screenshot |

---

## H-B — Dealer terminal (shop CRT)

| ID | Done | Task | Done when | Proof |
|----|:----:|------|-----------|-------|
| **H-B1** | ☐ | **Mesh** — dealer CRT / counter terminal | Compile clean | USE range |
| **H-B2** | ☐ | **CRT UI** — `lp-ops-crt--blackmarket`; typed `list` / `buy <sku>` | Black shell; sidebar command ref | Terminal preview |
| **H-B3** | ☐ | **Catalog** — gadgets/weapons rows tie to DXRP shipment or inventory grant | Host grants item after BTC debit | Buy AK/gadget test |
| **H-B4** | ☐ | **Job gate** — dealer job or public shop rules (owner decision) | Documented abuse limits | Multi-player test |
| **H-B5** | ☐ | **Dealer terminal sign-off** | Owner OK underground shop loop | Capture |

---

## Cross-lane sign-off log

| Date | Lane | ID | Owner | Notes |
|------|------|-----|-------|-------|
| — | bitcoin | H1 | — | See `BITCOINMINING_POLISH_CHECKLIST.md` |
| — | hacker | — | — | Not started |
| — | gov/FBI | — | — | Not started |
| — | banker | — | — | Not started |
| — | black market | — | — | Not started |

---

## Related docs

| Doc | Purpose |
|-----|---------|
| `BITCOINMINING_POLISH_CHECKLIST.md` | Civilian hashd lane (active) |
| `HACKER_JOB_KICKOFF.md` | Hacker session kickoff |
| `RED_HACKER_JOB_BUILD.md` | VENGEANCE build runbook |
| `BANKER_JOB_SPEC.md` | Banker design spec |
| `LIFEPUNCH_HUB_PATTERN.md` | Shared hub USE flow |
| `QUARANTINE_REGISTER.md` | What is not mounted on bitcoin-only DXRP |

---

## How to use

1. Finish **bitcoin** checklist through Phase C (or explicit defer per item).
2. Pick next lane (**E** hacker recommended).
3. Say the ID (e.g. **E-A1**, **G-B2**).
4. One item → play proof → owner OK → check box → update **Cross-lane sign-off log**.
