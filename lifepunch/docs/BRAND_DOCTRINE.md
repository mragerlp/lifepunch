# LIFEPUNCH BRAND DOCTRINE — `lifepunch.co` IS THE BRAND SOURCE OF TRUTH

**RATIFIED 2026-07-14, Bloodwave.** The website is **LIVE** and is a **Bloodwave proof-of-concept**;
screenshots chat-carried to Fable 2026-07-14. Records: `comms\red\0040` (the font inversion),
Bloodwave's two-surface font relay, and the reskin answer sheet (`RESKIN_SHEET_RULING_2026-07-14.md`).

> **CLASS: RULED. Write-once.** Supersede with a new record citing this one by filename.

---

## 1. THE OFFICIAL MARK

**The official LIFEPUNCH mark is the blue LP roundel.**

**Source file — RULED OFFICIAL:** `lifepunch/legal/marks/lifepunch-logo_source_1006.png`
*(662 204 bytes. Companions: `MARK_DRAWINGS.md`, `lifepunch-logo_drawing_bw_900.jpg`,
`lifepunch-logo_drawing_color_900.jpg`.)*

**This is the file. Not a lookalike, not a re-export, not a regenerated roundel.** When a surface needs the
mark, it uses **this source** — and it ships it as an **image asset**, never as an SCSS `url()`.

> **WHY THAT LAST CLAUSE IS LAW AND NOT STYLE:** substituting real `Image` elements for `url()`
> backgrounds does not merely fix a bug — **it removes the entire SCSS-`url()` failure class.**
> *Killing a class beats killing an instance.* (Reskin ruling **A/R2**.)

---

## 2. ## TWO-SURFACE FONT CANON — **READ BOTH LINES OR YOU WILL "FIX" THE RIGHT ANSWER INTO THE WRONG ONE**

| Surface | Heading font | Body font | Status |
|---|---|---|---|
| **WEBSITE** (`lifepunch.co`) | **Montserrat-class heavy geometric** | web stack | **BRAND IDENTITY. Untouched by this doctrine.** Fonts cost nothing on the web; they live there natively. |
| **IN-GAME** (s&box, **code-only**) | ## **POPPINS** | ## **INTER** | **RULED.** Poppins is the **in-game equivalent** of the brand heading font. |

### ## MONTSERRAT IS **NEVER** DECLARED IN GAME SCSS.

**It does not exist on this stack.** Exhaustive search — engine, DXRP game tree, and repo — returns
**zero hits** (`red\0040`). A `font-family: Montserrat` in an s&box panel **does not fail. It falls back
silently, renders a different typeface, and passes every check we own.**

### The two facts that make this ruling free

- **`Inter` SHIPS WITH THE ENGINE** — `sbox/addons/base/Assets/fonts/Inter-*.ttf`. It resolves with
  **zero addon assets.** *This is what discharged `PLAYERHUB_GATES_RULING` Gate 1: the `code-only` manifest
  kind was **conditional** on the Inter proof, and **the condition is met.***
- **`Poppins` ALSO SHIPS** — and is **already precedent in our own tree**
  (`adminmenu/StaffMenu.razor.scss:49`). It costs **one token line** and **preserves `code-only`.**

### ⚠ THE TRAP THIS SECTION EXISTS TO PREVENT

> ## A FUTURE SEAT WILL COMPARE THE GAME TO THE WEBSITE, SEE POPPINS, AND "FIX" IT BACK TO MONTSERRAT.
> **They will be chasing the brand and they will be right about the brand and wrong about the engine.**
> The font will fall back, nothing will error, and the bug will look like a rendering nit forever.
>
> **BOTH LINES ARE LOAD-BEARING. The brand font and the in-game font are DIFFERENT ON PURPOSE, and the
> difference is a platform constraint, not a compromise.**

**The `lifepunch-design-tokens` skill Type row carries both lines.** *(Amended in the reskin slice — that
skill previously named a font that does not exist, and therefore instructed every seat to write a silent
fallback.)*

---

## 3. WEBSITE DESIGN GRAMMAR — the Player Hub family follows it

Observed on the live site and adopted as the in-game panel grammar:

- **Nav pill buttons.**
- **Blue eyebrow over title** headings.
- **Card panels on near-black.**

**The Player Hub shell already matches this grammar** (Slice 1, `023dd702`) — *the convergence was
independent, which is the useful part: the grammar is real, not retrofitted.*

### ⚠ LAW 17 DOES **NOT** CROSS THE SURFACE BOUNDARY

**The website's green `CLAIMED` / referral accents are WEBSITE grammar.**
**In-game Law 17 is UNCHANGED: no green on status / BTC-adjacent readouts.** Green in-game is reserved for
**cash and success**.

> **A seat porting the site's green into a game panel would be importing the brand and breaking the money
> grammar in the same commit.** *The site and the game share an identity. They do not share a colour law.*

---

## 4. ⚠ THE WEBSITE STORE SELLS `$LP` DIRECTLY — **FLAGGED, NOT RULED**

**The live site sells `$LP` for money** (WIP-tagged on the site).

**This is recorded here because it is a fact about the brand surface, and it is NOT ruled.** It collides
head-on with an open question and with the Player Hub's own shipped copy:

| Open | Why it matters |
|---|---|
| **`$LP` currency identity** | Sign and colour still **PENDING-RATIFICATION** (blue is temporary). |
| ## **PURCHASED vs PLAY-EARNED** | ## **OPEN. NOT RULED.** |

**The Player Hub design says `$LP` is *"earned through play — not a real-money storefront CTA"*, and Slice 1
ships that copy.** **The website sells it.** *Both can be true only if the ruling says so — and there is
no ruling.*

> ## THIS IS A DOCTRINE-LEVEL QUESTION, NOT A COPY QUESTION.
> It decides whether the Store tab is a **play-economy sink** or a **monetisation surface**, and that answer
> changes **Slice 5, Slice 6, the economy law's faucet analysis, and every "no combat advantage" claim we
> make.** **Do not resolve it in UI copy. Do not resolve it in a slice. It needs a Bloodwave ruling.**

---

## 5. VIP / EVIP PERKS — as shipped, verified inside Donor Law

**Builder+ · prop limit · queue skip · minigame starts.**

**Verified as consistent with the Donor Law** — these are **convenience and expression**, not combat power.
This is the line that keeps the perk list shippable, and **it is the line to check any new perk against.**

## CANON POINTERS

`lifepunch/docs/cvl/PLAYERHUB_GATES_RULING_2026-07-14.md` (Gate 1, now discharged) ·
`lifepunch/docs/cvl/RESKIN_SHEET_RULING_2026-07-14.md` (A–E) ·
`.claude/skills/lifepunch-design-tokens` (the Type row) · `comms\red\0040` (the font inversion, with sensors).

FROM: Red
