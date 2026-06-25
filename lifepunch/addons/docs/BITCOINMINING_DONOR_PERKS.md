# LIFEPUNCH Bitcoin Miner — donor perks (VIP / EVIP)

**Status:** Design locked for cosmetics · **Not shipped in code yet**  
**Store ranks:** `VIP` ($10) · `EVIP` ($25) — migrating to **`VIP (OG)`** / **`EVIP (OG)`** at LPDXRP addon launch (`lifepunch/docs/LPDXRP_OG_SUPPORTERS.md`)  
**Pattern:** Same as Visible Pocket — rank grants **identity/QoL**, not earn multipliers.

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
