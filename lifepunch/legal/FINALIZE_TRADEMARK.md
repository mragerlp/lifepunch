# LIFEPUNCH — Trademark Finalization Runbook (START HERE)

**Purpose:** a single, action-ordered handoff so *any* agent or operator can finish the LIFEPUNCH
trademark filings the moment Trademark Engine (TE) support responds — without re-deriving context.

- **Canonical doctrine / reasoning:** `TRADEMARK_AND_IP.md` (source of truth)
- **Logo drawing assets + color claim:** `marks/MARK_DRAWINGS.md`
- **Specimens + capture guidance:** `specimens/SPECIMEN_NOTES.md`
- **Enforceable summary rule:** `../../.cursor/rules/lifepunch-trademark-ip.mdc`

> Not legal advice. TE's attorney/paralegal does the final legal review + filing. This runbook keeps
> our submitted data accurate and internally consistent so that review is clean and fast.

---

## 0. Status snapshot (update this whenever a step changes)

| Order | Mark | Type | Blocked on | Next action |
|-------|------|------|-----------|-------------|
| **#402997** | LIFEPUNCH | Word mark | TE support clearing "timeframe expired" banner | §2 wordmark steps |
| **#397871** | LIFEPUNCH logo | Design mark (color, claiming blue) | TE support unlocking it from paralegal review | §3 logo steps |

**Both orders are blocked on the same TE support contact.** Send the messages in §1, then execute
§2 and §3. When all boxes are checked, log it in `TRADEMARK_AND_IP.md` §8 and update this table.

**Constants that must be identical on BOTH orders** (a mismatch or wrong entity voids the filing):
- **Applicant/owner:** `PEAK PERFORMANCE PRODUCTS LLC` — NJ single-member LLC (sole member: Jared
  Zerillo). **Never** the individual, **never** "LifePunch." Confirm exact suffix/punctuation vs. the
  **NJ Certificate of Formation** before final submit.
- **Class 041** "Entertainment services, namely, providing online video games" → **§1(a) in use**;
  first use anywhere **04/26/2026**, first use in commerce **04/30/2026**.
- **Class 009** "Downloadable computer game software" → **§1(b) intent-to-use** (NO specimen).
- **Domicile/EIN:** required by USPTO but kept in **OneDrive only** — never type it into a repo file.

---

## 1. Messages to send TE support (copy-paste)

**Wordmark #402997 (clear the order so it can proceed):**
> "Order #402997 (LIFEPUNCH word mark) shows a banner that the timeframe to upgrade has expired and I
> can't proceed. All applicant/entity data, disclosures, and website are entered and saved. Please
> confirm whether this order can proceed as-is, or what's needed to move it to filing (or a new order).
> Two filing instructions for the paralegal: (a) **Class 041 = Section 1(a) in use** (first use
> 04/26/2026; in commerce 04/30/2026), specimen = lifepunch.co screenshot. (b) **Class 009 = Section
> 1(b) intent-to-use** — there is NO Class 9 specimen; the image currently in the Class 009 slot is a
> PLACEHOLDER only to pass form validation — please disregard/remove it and file Class 009 as 1(b)."

**Logo #397871 (unlock + align to the wordmark)** — verbatim from `marks/MARK_DRAWINGS.md`:
> "Order #397871 (LIFEPUNCH logo) is in paralegal review and I can't edit it. Before it's filed,
> please make these corrections so it matches my wordmark order #402997:
> 1. **Applicant/owner = PEAK PERFORMANCE PRODUCTS LLC** (NJ LLC), not an individual.
> 2. **Class 041 = Section 1(a) in use** (first use 04/26/2026; in commerce 04/30/2026), specimen =
>    lifepunch.co screenshot.
> 3. **Class 009 = Section 1(b) intent-to-use** — no specimen; do not file Class 9 as in use.
> 4. Logo drawing: file the logo **in COLOR, claiming blue.** Color claim statement: *'The color blue
>    is claimed as a feature of the mark.'* Mark description: *'The mark consists of a blue circle
>    containing a stylized "LP" monogram (the letters "L" and "P") appearing in white negative space
>    within the circle. The color white represents background and/or negative space and is not claimed
>    as a feature of the mark.'*
> Please confirm once updated."

---

## 2. Finalize the wordmark (#402997)

- [ ] TE confirms the order can proceed (timeframe banner cleared) — or migrate to the new order they specify.
- [ ] Confirm `PEAK PERFORMANCE PRODUCTS LLC` exact suffix/punctuation vs. NJ Certificate of Formation.
- [ ] Confirm Class 041 first-use dates are the true earliest *provable* dates (use earlier if provable).
- [ ] **Class 041 specimen uploaded:** final `lifepunch.co` capture — re-grab at peak (players online,
      e.g. 37/70) with the **browser URL bar + date visible** (no mockups). File: `specimens/` (see
      `specimens/SPECIMEN_NOTES.md`). The staged JPG is `specimens/2026-06-09_lifepunch-co_class41-specimen.jpg`.
- [ ] **Class 009 confirmed §1(b)** on paralegal review and the **placeholder specimen removed**.
- [ ] Class fee paid.

## 3. Finalize the logo (#397871)

- [ ] TE unlocks #397871 from paralegal review (or applies the §1 corrections directly).
- [ ] Applicant = `PEAK PERFORMANCE PRODUCTS LLC` (mirror #402997 exactly).
- [ ] Classes + basis mirror #402997 (041 §1(a), 009 §1(b)); first-use dates 04/26/2026 / 04/30/2026.
- [ ] **Drawing = `marks/lifepunch-logo_drawing_color_900.jpg`** (COLOR, claiming blue).
- [ ] **Color claim statement** entered: *"The color blue is claimed as a feature of the mark."*
- [ ] **Mark description** entered (verbatim from `marks/MARK_DRAWINGS.md` §Decision).
- [ ] Class 041 specimen = same `lifepunch.co` screenshot as #402997; Class 009 = no specimen (§1(b)).
- [ ] Class fee paid.

## 4. Definition of done (verify on the paralegal review screen)

- [ ] Both orders show applicant `PEAK PERFORMANCE PRODUCTS LLC` (identical), not the individual.
- [ ] Both: Class 041 = §1(a) with the specimen attached; Class 009 = §1(b) with **no** specimen.
- [ ] Logo: color claim + mark description present; color drawing attached.
- [ ] No third-party marks (DXRP / Dxura / s&box / Facepunch) claimed or implied as ours anywhere.
- [ ] Filing receipts / serial numbers saved (to OneDrive; record serial numbers — not sensitive — in §6 below).

## 5. After filing — update the repo (don't let legal state drift)

- [ ] `TRADEMARK_AND_IP.md` — update §2 register statuses, tick §7 open items, add a §8 progress-log entry.
- [ ] `marks/MARK_DRAWINGS.md` — tick the #397871 alignment checklist.
- [ ] `specimens/SPECIMEN_NOTES.md` — note the final Class 041 specimen used; confirm Class 009 placeholder removed.
- [ ] This file — update the §0 status table (and §6 serial numbers).
- [ ] Separately tracked (not gating): rebrand "DXRP Admin Menu" → "LIFEPUNCH Admin Menu for DXRP"
      (`addons.json` title / `dxrpAddonIdentifier` / `sboxIdentifier`, portal listing, network id) so
      LIFEPUNCH leads as the source identifier. Confirm any Dxura marketplace name constraints first.

---

## 6. Filing record (fill in as we go)

| Field | #402997 (word) | #397871 (logo) |
|-------|----------------|----------------|
| USPTO serial no. | _pending_ | _pending_ |
| Filing date | _pending_ | _pending_ |
| Class 041 status | _pending_ | _pending_ |
| Class 009 status | _pending_ | _pending_ |
| Specimen on file (041) | _pending_ | _pending_ |

## 7. Asset inventory (paths)

- Logo source: `marks/lifepunch-logo_source_1006.png`
- Logo drawing (file this): `marks/lifepunch-logo_drawing_color_900.jpg` (color)
- Logo drawing (alt, unused): `marks/lifepunch-logo_drawing_bw_900.jpg` (no-color-claim option)
- Class 041 specimen (staged): `specimens/2026-06-09_lifepunch-co_class41-specimen.jpg`
- Class 041 specimen (draft PNG): `specimens/2026-06-09_lifepunch-co_class41-specimen-draft.png`
- Clearance / dormancy evidence: `clearance-evidence/`
