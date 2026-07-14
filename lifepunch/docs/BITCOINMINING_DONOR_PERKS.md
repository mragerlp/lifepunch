# LIFEPUNCH Bitcoin Miner — donor perks (VIP / EVIP)

**Status:** Design locked for cosmetics · mined-BTC payout exception ratified and implemented
**Store ranks:** `VIP` ($10) · `EVIP` ($25) — migrating to **`VIP (OG)`** / **`EVIP (OG)`** at LPDXRP addon launch (`lifepunch/docs/LPDXRP_OG_SUPPORTERS.md`)  
**Pattern:** Same as Visible Pocket for general donor treatment — identity/QoL, with the one named mined-BTC payout exception below.

---

## Hard rule (owner canon)

| Category | Donor-only? | Earn impact |
|----------|-------------|-------------|
| **HASHD UI skin / panel theme** | **Yes — VIP/EVIP only** | **Zero** |
| **GPU fan RGB variant** (color palette / led pattern) | **Yes — VIP/EVIP only** | **Zero** |
| **Hub power sound variant** (startup / fan loop / spin-down) | **Yes — VIP/EVIP only** | **Zero** |
| CPU / core upgrades | No — cash for everyone | gameplay |
| Encryption tracks | No — cash for everyone | PvP defense |
| Hub/rack placement caps | TBD separate doc — **not** cosmetics | ceiling only |

**Cosmetic donor perks are NOT purchasable with in-game cash.** No market row, no hashd `upgrade` path. Rank check only (`VIP` / `EVIP` from store fulfillment).

**Never gate:** `BaseSpeed`, tick interval, `BitcoinValue`, CPU/core costs, or mining payout math behind donor rank.

> **NARROW SUPERSESSION (ruled 2026-07-14, Bloodwave; `comms\copilot\0006`).** The sentence above
> remains law except for one named mechanism: at mined-BTC bank cashout only, the **caller's** live
> VIP tier multiplies payout by **1.5x** and EVIP by **2x** (including the corresponding OG tiers).
> The donor rate composes multiplicatively with the global event rate and the result is floored once
> at the end. This does not change mining speed, BTC yield, upgrade costs, portal `$BTC` redemption,
> any other economy rail, or any other donor perk.
>
> **AUDIT CLAUSE (Ruling 4, `comms\copilot\0006` — recorded in doctrine 2026-07-14).** The multiplier is
> **only lawful while it is auditable.** Every multiplied payout MUST emit **both**: (a) an **enriched
> reason string** — the always-present breadcrumb on the ledger row — and (b) a **queryable addon-side
> Audit event**. Both MUST carry **the base AND the multiplied figures** so a payout can be re-derived
> from its own record: `btc` · `baseUsdPerBtc` · `eventMultiplier` · `donorTier` · `donorMultiplier` ·
> `preFloorUsd` · `finalUsd`. **A multiplied payout that records only its final number is a defect** — it
> is indistinguishable from a mint, and `fable\0068` (d) requires the audit trail to show base vs
> multiplied.
>
> *Implementation sensor (verified 2026-07-14):* `LpBitcoinDonorPayout.cs:62` (`BuildLedgerReason`) and
> `:65` (`BuildAuditDescription`) both satisfy this today. **The clause is written down so a refactor
> cannot quietly drop it** — the code was compliant before canon said it had to be, which is exactly how
> a requirement gets deleted by someone who never knew it was one.
>
> **Rank source (Ruling 2):** the **CALLER's** live portal rank — the player at the terminal, not the hub
> `Owner`. **Composition (Ruling 3):** multiplicative, **ONE floor at the end** (2× event + 2× EVIP = 4×).
> **Terminal display (Ruling 5):** DEFERRED — the terminal may show a pre-multiplier figure. **This is a
> known, documented lie with a follow-up slice owed.**

**Visual doctrine (see `CYBER_VISUAL_IDENTITY_DOCTRINE.md`):**  
Donor themes on HASHD / Bitcoin surfaces must never apply full Cornerman green, VENGEANCE red, or lifepunchnet cyan-blue. These are role identities for other lanes. HASHD donor range is limited to amber/gold/warm white/bronze/dark graphite + controlled metallic/scanline accents. Reserved state colors (Warning / Error / Hacked / etc.) always override cosmetics.

Terminal defense tracks (DECISION-0010) are gameplay (firewall, alerts, etc.) purchased via the universal Upgrades home. They are not donor cosmetics. Cosmetic donor rules remain amber-only on Bitcoin surfaces.

---

## Cosmetic catalog (proposed)

### HASHD skins (hub UI — `HashdTerminal.razor`)

| Skin | Rank | Notes |
|------|------|-------|
| **Amber HASHD** (default) | Everyone | Shipped Phase 1 canon |
| **VIP HASHD** | VIP+ | Accent trim + title-bar badge — same layout, no extra commands |
| **EVIP HASHD** | EVIP only | Exclusive rail/chrome variant |

Settings → theme picker only lists skins the player’s rank unlocks.

### Fan RGB variants (rack — `g_flLedActive` / vmat params)

| Variant | Rank | Notes |
|---------|------|-------|
| **Stock amber pulse** | Everyone | Baseline when BITCOINMINING-03 shader ships |
| **VIP spectrum** | VIP+ | e.g. gold/cyan alternate `g_vLedColor` preset |
| **EVIP signature** | EVIP only | Exclusive palette (one approved look — no player-custom hex) |

Non-donors: default LED behavior only; donor variants hidden in hashd settings.

### Hub sounds (`BitcoinMiningAddon` sound paths)

| Sound slot | Rank | Notes |
|------------|------|-------|
| Default startup / fan loop / spin-down | Everyone | CC0 baseline |
| VIP pack | VIP+ | Alternate `.sound` resources, same volume rules |
| EVIP pack | EVIP only | Third pack — exclusive |

Sounds are **swap asset path only** — no duration/volume buffs.

---

## Implementation seam (when built)

Mirror `visiblepocket/PocketSlotPolicy.cs`:

```text
BitcoinMinerDonorPolicy.cs
  - ResolveHashdSkin(rankName) → skin id
  - ResolveFanRgbPreset(rankName, selectedPreset) → allow / deny
  - ResolveHubSoundPack(rankName) → sound path suffix
  - Rank names: VIP, EVIP, VIP (OG), EVIP (OG) — OG includes base tier + exclusive variants (TBD)
```

**Gate in:**

- `HashdTerminal.razor` — theme list + SCSS class
- `BitcoinMinerHubEntity` — startup/fan sound selection on power on/off
- `GpuRackEntity` — RGB attribute preset (after BITCOINMINING-03 shader live)

**Do not gate in:** `MineBitcoin()`, `CreditMiningPayout()`, `PurchaseUpgradeHost()`, sell RPCs.

> **NARROW SUPERSESSION:** sell RPC authorization and debit/restore behavior remain ungated. The
> two mined-BTC sell rails may pass `Rpc.CallerId` into `LpBitcoinEconomy.BtcToCashPayout` solely to
> apply and audit the named VIP/EVIP payout-rate exception above.

---

## Portal / market copy

- List donor cosmetics under **VIP/EVIP store benefits**, not as separate bitcoinmining market items.
- In-product `about`: LIFEPUNCH proprietary notice only — no third-party credits.
- Nominative: “VIP/EVIP supporter themes for LIFEPUNCH Bitcoin Miner” — not pay-to-win language.

---

## Related

- `BITCOINMINING_HUB_ARCH.md` — RGB fans row (cosmetic; donor-gated when implemented)
- `BITCOINMINING_ENCRYPTION_SPEC.md` — encryption stays cash-paid for all ranks
- `TECH_DEBT.md` — `BTC-DONOR-01`
- `lifepunch/docs/LPDXRP_OG_SUPPORTERS.md` — LPDXRP shorthand, VIP (OG) / EVIP (OG) migration
