# LPDXRP — glossary & OG supporters

**Status:** Owner policy (June 2026) · **Agents:** read before ship/copy that mentions donors, VIP, EVIP, or first addon launch.

---

## LPDXRP (abbreviation)

| Term | Meaning |
|------|---------|
| **LPDXRP** | **LifePunch DXRP** — LifePunch's DXRP server/community and its addon portfolio on Dxura's gamemode (s&box). |
| **LifePunch** | Brand / publisher (LIFEPUNCH™). |
| **DXRP** | Third-party gamemode (Dxura) — nominative reference only. |

Use **LPDXRP** in internal docs, handoffs, Discord changelogs, and agent chat when you mean
"LifePunch's DXRP operation" without repeating the full phrase.

**Not:** a separate trademark filing; a shorthand for ops and launch planning.

---

## OG supporter ranks (migration)

When **LIFEPUNCH addons** (Class 9 portfolio) ship on LPDXRP, **current store donors** receive
successor ranks — they are **not** left on legacy `VIP` / `EVIP` alone.

| Current rank (pre–addon launch) | Successor rank (at addon era) |
|--------------------------------|-------------------------------|
| **VIP** | **VIP (OG)** |
| **EVIP** | **EVIP (OG)** |

**OG** = early supporter who backed LifePunch **before / through the literal first launch** of
the LPDXRP addon line (not a pay-to-win tier).

### Agent rules

1. **Exact rank strings** in portal/DXRP when created: `VIP (OG)` and `EVIP (OG)` (parentheses, space).
2. Code that checks supporter rank should treat **OG as superset** of current tier:
   - `VIP (OG)` gets everything planned for VIP + OG extras.
   - `EVIP (OG)` gets everything planned for EVIP + OG extras.
3. **New purchasers after OG window** may get plain `VIP` / `EVIP` (or renamed store tiers) —
   policy TBD at store relaunch; do not assume OG perks on new SKUs without owner sign-off.
4. **Never** grant moderation, portal, or staff permissions via OG ranks (`players/ranks/README.md`,
   `economy/README.md`).

Fulfillment list / Steam-ID migration stays **off-repo** (Stripe, portal) — only rank *names* and
*policy* live here.

---

## Fair OG perks (design fence)

OG rewards must pass **all** of:

| Gate | Question |
|------|----------|
| **Zero earn** | Does it change mining payout, sell price, job pay, or market prices? → **No** |
| **No admin** | Does it grant kick/ban/portal/staff tools? → **No** |
| **Identity OK** | Cosmetics, nameplate flair, chat badge, title, early access *cosmetic* drops? → **Yes** |
| **Ceiling OK** | Slightly higher *placement cap* (e.g. +1 hub) if everyone can still compete with grind? → **Discuss** |
| **Not cash-buyable** | Can a non-donor buy the same perk in-game? → **No** for OG-exclusive cosmetics |

### Locked: donor-only cosmetics (zero earn)

See `lifepunch/docs/BITCOINMINING_DONOR_PERKS.md` — applies to **VIP / EVIP / VIP (OG) / EVIP (OG)** for cosmetic lanes:

- HASHD UI skin / panel theme  
- GPU fan RGB variant  
- Hub sound pack  

OG tiers should get **at least** the same cosmetic ladder as their tier, plus **OG-exclusive** variants (TBD art pass).

---

## OG perk menu (discussion — first LPDXRP addon launch)

**Status: brainstorm / owner review.** Check boxes when approved.

### Safe to discuss (likely fair)

| Perk | VIP (OG) | EVIP (OG) | Earn impact |
|------|----------|-----------|-------------|
| Exclusive HASHD / terminal **OG skin** | ✓ | ✓ (stronger variant) | Zero |
| Exclusive **fan RGB + hub sound** OG pack | ✓ | ✓ (EVIP-only palette) | Zero |
| **Nameplate / chat** OG badge or color | ✓ | ✓ | Zero |
| **`command.title` or cosmetic title** string | ✓ | ✓ | Zero |
| **Early access** to *cosmetic* addon rows (24–72h) | optional | ✓ | Zero if cosmetic-only |
| Visible Pocket slot floor (if not already VIP/EVIP) | align with `VISIBLE_POCKET_SPEC.md` | align | Ceiling only |

### Discuss carefully (cap, not multiplier)

| Perk | Notes |
|------|-------|
| +1 **bitcoin hub** placement cap | EVIP (OG) only; still must buy/upgrade in-game — see fleet cap math in donor economy notes |
| Encryption install **discount** (5% / 10%) | Cash sink relief only; same max tiers as everyone |

### Do not offer OG (unfair)

| Perk | Why |
|------|-----|
| Mining speed / BTC multiplier | Pay-to-win |
| Cheaper CPU/core upgrades globally | Pay-to-win |
| Higher `BitcoinValue` sell price | Pay-to-win |
| Staff / EVIP fallback powers on OG alone | Admin creep |
| Exclusive weapons or job income | P2W |

---

## Implementation notes (when coding)

- Central policy resolver (future): `LifePunchDonorPolicy` or per-addon `*DonorPolicy.cs` —
  pattern: `PocketSlotPolicy.ResolveMaxSlots`.
- Rank checks: `VIP`, `EVIP`, `VIP (OG)`, `EVIP (OG)` — case-insensitive; OG includes base tier benefits.
- Portal: create `VIP (OG)` / `EVIP (OG)` rank rows before addon marketing push; migrate existing donors.

---

## Related

- `lifepunch/economy/README.md` — store, VIP/EVIP, no admin on supporter ranks  
- `lifepunch/players/ranks/` — rank baselines (`vip-rank.json`, `evip-rank.json`)  
- `lifepunch/docs/BITCOINMINING_DONOR_PERKS.md` — bitcoinminer cosmetic donor lane  
- `lifepunchaddons/docs/VISIBLE_POCKET_SPEC.md` — VIP 8 / EVIP 12 slots  
- `lifepunch/legal/TRADEMARK_AND_IP.md` — LIFEPUNCH™ source identifier on shipped addons  

**Open items:** exact OG migration date, new-store SKU names, OG-exclusive art list — owner + Bloodwave before portal push.
