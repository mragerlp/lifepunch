# LifePunch job portfolio — post-bitcoin roadmap

**Owner law (2026-06-15):** finish **lifepunchbitcoin** polish (hub → terminal → GPU rack) before promoting any lane below.  
**Work law:** one item at a time → play proof → owner sign-off → next.

**Related:** `config/portfolio.json` · `CYBER_JOBS_POLISH_CHECKLIST.md` · `BITCOINMINING_POLISH_CHECKLIST.md` · `TERMINAL_BRAND_MATRIX.md`

---

## Gate — active now

| Order | Job | Package / repo | Status |
|-------|-----|----------------|--------|
| **0** | Civilian Bitcoin Miner | `lifepunchbitcoin` / `bitcoinmining` | **Active** — Phase A hub polish in progress |

Nothing in Tier 1–3 starts until Bitcoin Phase A–C hub/terminal/rack patterns are proven on flatgrass.

---

## Tier 1 — priority (build order after bitcoin)

| Order | Job | Package / repo | UI pattern | Status | Notes |
|-------|-----|----------------|------------|--------|-------|
| **1** | **Hacker** | `lifepunchhacker` / `hackerjob` | Hub + terminal (Cornerman + VENGEANCE tiers) | **In progress** | Criminal cyber lane; quarantined on bitcoin-only DXRP until promoted. Checklist: `CYBER_JOBS_POLISH_CHECKLIST.md` Phase E. |
| **2** | **Banker** | `lifepunchbanker` / `bankerjob` | Hub (`bank-vault-hub`) + teller terminal | Idea / concept | Spec: `BANKER_JOB_SPEC.md`, `bankerjob/docs/BANK_VAULT_HUB.md`. Blocked on bitcoin economy + Opus economy sign-off. |
| **3** | **Black Market Dealer** | *TBD* (e.g. `blackmarketdealer`) | Hub for **optional BTC** payments; dealer CRT catalog | Idea / concept | Gadgets + weapons; BTC via Ophion hub pattern when buyer chooses crypto. Theme: `lp-ops-crt--blackmarket`. Checklist: Phase H. |
| **4** | **Drug Chemist** | `lifepunchdrugprocessing` / `advanceddrugprocessing` | **Hub likely; terminal probably not** | Idea / concept | Processing stations exist in repo; economy not signed off. Coke/meth canon: `COKE_DRUG_RESKIN_SPEC.md`, `advanceddrugprocessing/docs/`. |

**Supporting cyber (Phase F — after Hacker Job):** Government / FBI **protagonist hacker** — `government-server-rack` (hub) + lifepunchnet **Government Terminal** + **Government Data Center** (autonomous tax miner, 0–30% mayor rate → city funds). Counters **advanced hacker (red)** breaches on miners, bank, city funds. **Not Tier 1** — finish Hacker Phase E first. See `CYBER_JOBS_POLISH_CHECKLIST.md` Phase F.

### lifepunchbitcoin access (all jobs)

| Allowed | Blocked |
|---------|---------|
| Civilians, Hacker, Banker, Black Market, Drug Chemist, Security Guard, Hitman, Casino, etc. | **Government / Law Enforcement** jobs |

Gov treasury uses **Government Data Center** only — not player hashd hubs.

---

## Tier 2 — for later

| Order | Job | Package / repo | UI pattern | Status | Notes |
|-------|-----|----------------|------------|--------|-------|
| **5** | **Security Guard** | *TBD* | **No hub / terminal** — new **freelance hire UI** | Not started | Private security; hireable by any job **except** Government / Law Enforcement. Can live in bases with civilians and criminals. |
| **6** | **S.W.A.T.** | `lifepunchswat` | Simple job kit (gear + weapons) | Not started | Stub: `SWAT_JOB_SPEC.md`. CS2 study → own meshes (`CS2_CHARACTER_HARVEST.md`). |
| **7** | **Secret Service** | *TBD* | Simple job | Not started | Protect government VIPs; lightweight kit lane after SWAT gear pipeline exists. |

---

## Tier 3 — in DXRP today; LifePunch must innovate

| Order | Job | Package / repo | UI pattern | Status | Notes |
|-------|-----|----------------|------------|--------|-------|
| **8** | **Hitman** | *TBD* | **Candidate for hub + terminal** — replace Dxura “place a hit” | DXRP baseline is weak | Goal: interactive, playable contract loop (post, accept, intel, raid rules) — a standout LifePunch system. Rules today: `website/rules/current-rules.md` (Hitman section). |
| **9** | **Casino Manager** | *TBD* | **Hub + terminal if table/slot entities persist** | Does not exist yet | Popular RP job; magenta CRT theme reserved: `lp-ops-crt--casino`. Depends on whether casino entities can persist across restarts. |

---

## UI pattern key

| Pattern | Used by |
|---------|---------|
| **Hub → terminal → satellite** | Bitcoin, Hacker, Banker, Black Market (hub), Hitman (candidate), Casino (candidate) |
| **Hub only (no typed terminal)** | Drug Chemist (likely) |
| **Freelance / hire UI (new)** | Security Guard |
| **Simple job kit** | SWAT, Secret Service |

---

## Agent routing

| Task | Start here |
|------|------------|
| Bitcoin hub/terminal/rack | `bitcoinmining/docs/BITCOINMINING_POLISH_CHECKLIST.md` |
| Hacker, banker, black market, gov cyber | `CYBER_JOBS_POLISH_CHECKLIST.md` |
| Full portfolio priority | **this file** |
| Active vs quarantine | `config/portfolio.json` |
| Package slugs | `config/packages.json` · `PACKAGE_NAMING_STANDARD.md` |

---

## Progress log

| Date | Change |
|------|--------|
| 2026-06-15 | FBI Phase F canon: gov server rack hub, lifepunchnet terminal, gov data center tax miner; hacker starter vs purchased red tier; gov/LE blocked from lifepunchbitcoin entities. |
