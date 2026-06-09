# LIFEPUNCH — Trademark & IP Doctrine (Canonical)

This is the **source of truth** for the LIFEPUNCH brand architecture, trademark filings, and
proprietary-IP posture. The always-apply agent rule `.cursor/rules/lifepunch-trademark-ip.mdc`
is the short enforceable summary; this document holds the detail and the reasoning.

**Operating assumption:** LIFEPUNCH-branded, paid/distributed downloadable goods **will** ship, and
others **will** try to clone them for profit. Everything below is structured so the trademark is
*provable and defensible up front* — not duct-taped after a leak.

> Not legal advice. Trademark Engine's attorney/paralegal performs the final legal review and filing.
> This doc keeps our application data accurate and internally consistent so that review is clean.

---

## 1. Brand architecture — what we own vs. third parties

| Name | Owner | Our relationship |
|------|-------|------------------|
| **LIFEPUNCH** | **Peak Performance Products LLC** (ours) | Our brand / mark — the single source of our servers, community, and content. `lifepunch.co`, `assets.lifepunch.co`. |
| **DXRP** | **Dxura** (third party) | A roleplay gamemode/platform we *use* and publish LIFEPUNCH content for. **Not affiliated; not owned by us.** `dxrp.net`, repo `github.com/dxura/dxrp`. |
| **s&box** | **Facepunch** (third party) | The game engine DXRP runs on. Not ours. |

**LIFEPUNCH is the only mark we register.** We do **not** own and must **never** claim DXRP, Dxura,
s&box, or Facepunch. Our goods/services are LIFEPUNCH servers/community (Class 41) and LIFEPUNCH
downloadable content that *runs on* DXRP (Class 9).

For a LIFEPUNCH Class 9 registration to be provable, **LIFEPUNCH — not DXRP — must function as the
source identifier on the goods**:
- The download listing shows **"Published by LIFEPUNCH."**
- The mark appears in the addon (launcher / loading / credit) and in file metadata.
- DXRP may appear only **nominatively** ("a LIFEPUNCH addon for DXRP servers"), never as our brand.

> ⚠️ **Naming caution:** an addon currently titled **"DXRP Admin Menu"** (`addons.json` ident
> `adminmenu`, network id `dxrpadminmenu`) leads with a *third party's* mark. For trademark strength
> (LIFEPUNCH as the source) and to avoid implying affiliation with Dxura, our products should lead
> with **LIFEPUNCH** — e.g. "LIFEPUNCH Admin Menu for DXRP." See §7 open items.

---

## 2. Trademark register

| Order | Mark | Type | Classes & basis | Status |
|-------|------|------|-----------------|--------|
| **#402997** | LIFEPUNCH | Word mark | **041** services — §1(a) in use · **009** software — §1(b) intent-to-use | Intake corrected + applicant entity entered; saved (see §8) |
| **#397871** | LIFEPUNCH logo | Design mark | Match #402997 (owner, classes, dates) | Locked in processing — edit after TE support unlocks |

**Owner / applicant:** **PEAK PERFORMANCE PRODUCTS LLC** — a New Jersey **single-member LLC** (sole
member: Jared Zerillo). This LLC is the legal entity that owns the **LIFEPUNCH** mark (DXRP is
Dxura's, not ours); LIFEPUNCH is a *brand* of the LLC, not the entity name. The applicant on every filing must be this
LLC — **not** "Jared Zerillo" as an individual, and **not** "LifePunch." Keep the applicant
**identical** on #402997 and #397871; a wrong-entity filing is *void ab initio* — unfixable later.

- Confirm the exact suffix/punctuation against the **NJ Certificate of Formation** — the IRS CP-575
  prints the name without the "LLC" suffix (name control "PEAK"); the registered name is almost
  certainly `PEAK PERFORMANCE PRODUCTS LLC`.
- **Sensitive identifiers (EIN, domicile street address) are NOT stored in this repo** — they live in
  OneDrive. USPTO requires a domicile address on the filing (it can be kept off the public record),
  but it is not committed here.

### Applicant vs. DBA — and the umbrella structure (do not let this leak)

- **A DBA / trade name cannot own a trademark — only the legal entity can.** The applicant is always
  **Peak Performance Products LLC**, never a DBA, never "LIFEPUNCH," never the individual.
- **The applicant name need not match the mark.** `Peak Performance Products LLC` owning the mark
  `LIFEPUNCH` is normal and correct (cf. Apple Inc. → "iPhone"). **No DBA is required to file** — a
  federal registration is *stronger* than a DBA (nationwide rights a DBA never confers).
- **Umbrella structure:** one LLC (Peak Performance Products LLC) → many brands/marks **it owns**
  (**LIFEPUNCH** and future LIFEPUNCH-owned brands), each filed as its own trademark **owned by the
  one LLC**, each optionally transacting under its own DBA. **DXRP is NOT one of our brands — it is
  Dxura's;** we publish to it but do not own it.
- **DBA is operational, on a parallel track — it must not gate the filing.** In NJ an LLC registers an
  **"Alternate Name"** with the Division of Revenue (Form **C-150G**, ~$50, 5-yr renewable) to bank,
  contract, and take payment as "LIFEPUNCH." Recommended for clean ops and to tie the use-in-commerce
  chain (storefront/invoices = LIFEPUNCH ⟷ entity = Peak Performance Products LLC), but file the
  trademark now regardless. *(Verify the current NJ form/fee before submitting.)*

**First-use dates (Class 041):** first use anywhere **04/26/2026**; first use in commerce
**04/30/2026**. (Anywhere ≤ in-commerce — consistent.) If LIFEPUNCH was genuinely in use earlier and
it is provable, use the true earliest date for stronger priority.

**Goods/services wording (USPTO ID-Manual compliant):**
- Class 041: *"Entertainment services, namely, providing online video games"*
- Class 009: *"Downloadable computer game software"*

Avoid naming third parties (the prior draft referenced "the 's&box' game owned by Valve" — removed)
and avoid "including but not limited to / like / such as / etc." (those phrasings delay examination).

---

## 3. Filing basis — why mixed, and how Class 9 converts

- **Class 041 (services) = §1(a) in use.** Public LIFEPUNCH game servers are live, so the service is
  actually rendered in commerce. Specimen = a screenshot of the site / server browser / in-game UI
  showing LIFEPUNCH offering the gameplay service. Working specimens + capture guidance live in
  `lifepunch/legal/specimens/` (`SPECIMEN_NOTES.md`); draft = a live `lifepunch.co` screenshot showing
  the LIFEPUNCH mark + joinable server list.
- **Class 009 (software) = §1(b) intent-to-use.** No LIFEPUNCH-branded, distributed download exists in
  commerce *yet* (the addons page is live but DXRP-branded and "price locked to 0 / paid not available
  yet"). Intent-to-use **locks the priority date today**, needs **no specimen now**, and gives ~3 years
  (with extensions) to ship and prove use. Claiming Class 9 use prematurely would draw a **specimen
  refusal**.

### Class 9 conversion checklist (do before filing the Statement of Use)
1. A LIFEPUNCH-branded download is publicly available on `dxrp.net/addons` (free or paid — either works).
2. The listing shows **"Published by LIFEPUNCH"** next to the download/buy control.
3. Capture that listing as the **specimen** (mark + product + download/price visible together).
4. Record the true **first-use** and **first-use-in-commerce** dates for the software.

---

## 4. "Use in commerce" — facts, so we never conflate them

- **Use in commerce** = WE distribute the branded goods/services in commerce **and** a specimen shows
  the mark as the source. **Charging money is not required** — a free download can qualify as
  "transport in commerce" if genuinely distributed under the mark with a valid specimen (a price just
  makes it bulletproof).
- **Resale rights are a different body of law.** Whether server owners may resell is governed by our
  **copyright license / EULA**, not trademark use. Our rule — *"use our content on your own server; no
  copying, redistribution, or resale"* — does **not** weaken the trademark. It *reinforces*
  single-source identity and supports the anti-clone posture. Keep it.

---

## 5. Proprietary-IP enforcement stack (uniform across the repo)

1. **Ownership notice.** Original LIFEPUNCH content is proprietary IP of the owner — not for resale,
   redistribution, sublicensing, or reuse by any party (including DXRP and LifePunch
   staff/contributors/community) except the owner. Canonical wording mirrors the `ownership` field in
   `lifepunch/addons/config/addons.json`; apply it to every new addon.
2. **EULA / license terms.** Server owners receive a limited license to *use* content on their own
   servers; copying, redistribution, and resale are prohibited.
3. **Website TOS + DMCA.** Enforced through TOS **§5 (Intellectual Property)** and **§6 (DMCA)** in
   `lifepunch/website/deployments/cloudflare-worker.mjs`.
4. **Brand integrity.** Spell **LIFEPUNCH** consistently and use it as a source identifier so the mark
   does not become generic or diluted.
5. **Exception:** explicitly flagged third-party work (e.g. evo's bitminer) is **not** LIFEPUNCH IP and
   must never be published as LIFEPUNCH content (see `.cursor/rules/lifepunch-operating-context.mdc`).

---

## 6. Clearance — results (searched 2026-06-08)

### Federal register — CLEAR
Official USPTO Trademark Search (`tmsearch.uspto.gov`), all statuses (Registered/Pending/Cancelled/
Abandoned) checked:
- **`LIFEPUNCH`** → **0 records** (0 live, 0 dead).
- **`LIFE PUNCH`** → **0 records** (0 live, 0 dead).

No registered or pending federal mark blocks LIFEPUNCH. An examiner likelihood-of-confusion refusal
on prior-mark grounds is unlikely. (This was a literal word search; a phonetic/design/by-class
knockout can still be run, but the exact mark and the obvious spaced variant are both clear.)

### Common-law — one watch item, low-to-moderate risk
- **lifepunch.net** — a Garry's Mod community ("LifePunch" / "Life Punch") since **2011**, hosting
  GMod servers (Jailbreak, Deathrun, Bunny Hop, Cinema, GunGame); Steam group ~399 members. A senior
  user (2011 ≫ our 2026) of a near-identical mark in a *related* field (online gaming community).
- **Mitigating factors:**
  1. **No federal registration** — they cannot block our application administratively; an examiner
     will not cite an unregistered common-law user.
  2. **Non-commercial** — their own notice: *"There is no premium store. We don't want your money."*
     Weak/possibly no protectable *commercial* trademark rights; weak damages exposure.
  3. **Apparently dormant** — `lifepunch.net` currently returns a Cloudflare **522 (origin down)**;
     public activity tapered after ~2020. 3+ years of non-use is *prima facie* abandonment.
- **Net:** practical risk is **low-to-moderate and mostly private** (a possible opposition or
  cancellation by the senior user / a successor), not an examination bar.

### Recommendations
- **Proceed** with the federal filing — the register is clear.
- **Preserve evidence** of the senior user's dormancy/non-use (the 522 page; Steam group last-activity
  dates) in case of a future challenge.
- We are the **commercial** actor (LLC, planned paid goods) building real brand equity — that
  strengthens our position; distinguishing facts: different platform/game (s&box DXRP RP vs GMod
  minigames), commercial vs free, and design-mark differences.
- Optional: an attorney clearance opinion before heavy spend; TE's attorney can advise on the
  common-law angle.

---

## 7. Open confirmations

- [x] **Applicant entity = PEAK PERFORMANCE PRODUCTS LLC** (NJ single-member LLC) — **now entered &
      saved on #402997** (Organization owner, LLC, NJ; sole member Jared Zerillo). Still: confirm exact
      suffix/punctuation vs. the NJ Certificate of Formation, and mirror onto #397871 once unlocked.
- [ ] Confirm Class 041 first-use dates are the true earliest provable dates.
- [ ] Instruct Trademark Engine paralegal/attorney that **Class 009 must be filed §1(b) intent-to-use**
      (the intake's single in-use toggle can't express the per-class split). **Confirmed needed:** the
      intake's specimen step demanded an upload for *both* Class 041 and Class 009 — do **not** supply a
      Class 9 specimen now.
- [ ] **Order status:** #402997 shows a "timeframe to upgrade has expired" banner; have TE confirm it
      can proceed (or what a new order requires) — all intake data is entered/saved regardless.
- [ ] **Upload Class 041 specimen** on TE: live `lifepunch.co` capture (re-grab at peak with players
      online + URL bar/date visible). Description + "webpage screenshot = Yes" already staged.
- [x] LIFEPUNCH clearance search (2026-06-08): federal register CLEAR (`LIFEPUNCH` and `LIFE PUNCH`
      both 0 records); sole watch item is the dormant, non-commercial lifepunch.net GMod community —
      low-to-moderate private risk, not an examination bar. Preserve dormancy evidence.
- [ ] After TE unlocks **#397871**, align owner, classes, and dates with the wordmark.
- [ ] **Product naming:** rebrand "DXRP Admin Menu" → a LIFEPUNCH-led name (e.g. "LIFEPUNCH Admin
      Menu for DXRP") so LIFEPUNCH is the source identifier and we don't lead with Dxura's mark.
      Touches `addons.json` (title / `dxrpAddonIdentifier` / `sboxIdentifier`), portal listing, and
      network identifier — confirm whether the Dxura marketplace constrains the name before renaming.

---

## 8. Filing progress log

### 2026-06-09 — #402997 intake corrected & applicant set (browser session)
Completed and **saved** ("Save for later") on Trademark Engine order #402997:
- **Applicant corrected** from individual "Jared Zerilo" → **Organization: PEAK PERFORMANCE PRODUCTS
  LLC** (org type LLC; country US; **state of formation NJ**; position Member; business address per
  EIN letter — entity address is public USPTO record, kept by choice).
- **Owner of the LLC**: Jared Zerillo (corrected spelling — prior individual entry had one "L").
- **Company info**: DBA = No, affiliates/children = No, domicile = mailing (Yes) — using the real
  physical address avoids an Office Action per TE's own note.
- **Disclosures**: "aware of a similar mark" = **Yes**, disclosed *"LifePunch (lifepunch.net) — dormant
  Garry's Mod community, apparently abandoned (last activity ~2020)"* so TE's attorney can pre-empt it
  with our abandonment evidence. All other disclosures (other regs / prior attempts / litigation /
  adverse parties) = No.
- **Language other than English** = No; **person's name/likeness** = No; **industry/geographic
  meaning** = No (keeps LIFEPUNCH a coined/suggestive mark, no disclaimer).
- **Website**: `lifepunch.co` added.
- **Specimen (Class 041)**: description + "webpage screenshot = Yes" staged; file upload is manual
  (automation can't attach files) → do on the TE call. Draft capture saved at
  `lifepunch/legal/specimens/`.

**Discovered:** the specimen step requests an upload for **both** 041 and 009 → reinforces the §1(a)/
§1(b) split must be set by TE's paralegal. **Pending:** order-expiry status, class-basis split,
Class 41 specimen upload, #397871 alignment, LLC-name-suffix confirmation. See §7.
