# CLAUDE CODE BRIEF — SKILLS S1–S6 + OWED D-BODIES (verbatim re-drop)

> **Class: RECORD (write-once).** Verbatim capture of Bloodwave's relay,
> 2026-07-12. Records freeze; supersede by a new record, never edit.
> Transport Law: filed to repo so the spec survives session handoff.

## Rulings on the two immediates
- **R1.** Razor gotchas → fold into `lifepunch-razor-ui` NOW (living canon;
  the `EDITOR_LAUNCH_LAW` filing stands, the skill mirrors it per the
  skills-are-living-canon rule below).
- **R2.** D-bodies: verbatim below — write as given, no reconstruction.
  D3/D7 already filed; this drop covers D1, D2-as-LAW-17, D4, D5, D6.

## Skills reconciliation ruling
S1–S6 **EXTENDS** the three existing skills, never duplicates. Mapping:
- S3 content → merge into `lifepunch-razor-ui`
- S4 content → merge into `lifepunch-editor-gate`
- S1/S2/S5/S6 = new skills
- `sbox-engine-truth` untouched unless a gotcha naturally belongs there.

Report final skill list.

## S1–S6 SPEC (skills PR, own PR)
Location `.claude/skills/<name>/SKILL.md`. Each: description block with
precise triggers + body grounded in ratified canon with file:line cites —
**repo cites only, no chat-memory content.**

- **S1 `lifepunch-grounding`** — STEP 0 skill: read order (CLAUDE.md →
  DXRP_PLATFORM_DOCTRINE §1-22 → OPUS_USAGE_LAW → task-relevant doctrine),
  tree-state verification ritual, sensor discipline (FRESH definition,
  positive code-string ID), "unverified" usage, structured CVL HANDOFF
  schema.
- **S2 `lifepunch-economy`** — Law A/B application: currency-of-act/purchase
  tests ("does it exist after I die"), Gauntlet flow map, PayoutTarget enum,
  `marketItem?.Cost ?? 0` contract, TOCTOU debit-before-await + additive
  restore, faucet-audit checklist. Cite doctrine files + reference
  implementations.
- **S3 (→ `lifepunch-razor-ui`)** — UI_STANDARD Laws 9-17 (incl. new 17
  Currency Identity), Separator Law, Signal/Style split, Cosmetic Firewall,
  badge/chip baseline, popup/tooltip/backdrop conventions from the HASHD
  set, SCSS token usage, adjacent-@() law, @code-ASCII, cascade-debug
  (first gen-file error).
- **S4 (→ `lifepunch-editor-gate`)** — EDITOR_LAUNCH_LAW incl. launch-set
  rule (never lone-addon sync — flood precedent), hotload limits (razor
  handler binding, modified-scss-rule caching, orphaned static hooks),
  fresh-boot-before-commit gate, watch re-arm patterns, blank.scene
  fast-proof.
- **S5 `lifepunch-config`** — T1/T2/T3 layer model, check-order before code,
  Monnow ~48-key schema shape, Packet H spec pointer, secrets law (server
  convars only, never T2/T3), derived-values-never-keys. NOTE: flag BLOCK-0
  inside the skill — LP code currently reads the addon config surface ZERO
  times (Odysseus L2 finding); extraction work re-scopes at next regroup
  before any implementation.
- **S6 `cornerman-packets`** — packet envelope anatomy, ff-only sync
  precondition, findings-only discipline, output naming (FABLE_PACKET_*),
  corner-note format, BLOCKED-skip-continue, coverage self-gate (351/351),
  outbox-only writes.

**LIVING-CANON RULE (add one line to CLAUDE.md):** "Repo skills in
.claude/skills/ are canon-grade; sessions load relevant skills at grounding;
any ratified rule updates its skill in the same PR that lands the doctrine."

## D1 · CLAUDE.md append, top-level law
```
## CANON PERSISTENCE LAW (ratified 2026-07-12, Bloodwave)
Chat is volatile storage; the repo is the only durable canon store. Any
ruling, law, doctrine amendment, or design decision ratified in a seat
conversation MUST land in a tracked repo file before that arc's closing PR
merges. No session closes holding unwritten canon. The conducting seat
(Fable) maintains a running UNWRITTEN-CANON ledger during every arc and
converts it to file bodies at each PR gate — the gate review includes the
question "does this PR carry all canon ratified since the last merge?"
Precedent: Packet J's ratified body survived only because Bloodwave held the
paste; a closed session is an erased one.
```

## D2 · LIFEPUNCH_UI_STANDARD append as LAW 17
```
## LAW 17 — CURRENCY IDENTITY (ratified 2026-07-12, Bloodwave)
Every menu, panel, readout, or log line that displays currency displays its
identity through the SIGN: ฿ + gold/bitcoin-orange = BTC · $ + green = cash.
The colored sign is the invariant; bare "BTC"/cash text without sign+color
is a violation. Amount text is white by default on LP-authored surfaces;
full-colored amounts are PERMITTED where they match DXRP-native convention
(ULX, upstream menus) or where emphasis warrants — per-surface style
latitude at Bloodwave's eye, not a violation. Icon and container furniture
use theme colors and are not currency signals. Units and separators around
amounts are white ("/min", "/", "(100%)"). Labels following amounts are
white ("invested"). The two identities never share a color and never touch
without a separator (min 8px gap or divider — see Law 15 Separator Law).
DUAL-PRICE TOKEN: where both prices show, format is ฿4 | $20,000 — white
divider bar, tight gaps, each currency full-colored (sign AND amount;
dual-price warrants emphasis). Green is reserved for cash and success states
— never power, status, or BTC-adjacent controls. Applies to all current and
future LP surfaces that hold, move, or price currency. Reference
implementation: lpbitcoin HASHD set, Currency Standard v1.
```

## D4 · DXRP_PLATFORM_DOCTRINE (where Holdable-Hub Law lives)
Amend to ratified state-conditional form: hub is hands_interact only while
unplaced; on settle/power it converts to a fixed world machine and drops
hands_interact. Racks unchanged (no menu, fully holdable). Mark the trigger
line "trigger form under review, code currently settle-OR-power" (finding A
verdict pending).

## D5 · EDITOR_LAUNCH_LAW append (no-op if the root-cause filing already covers it)
"Sync the full launch set (lpbitcoin,adminmenu), never a lone addon — a
lone-addon sync purges siblings and orphans their static hooks (2026-07-12
flood precedent)."

## D6 · Capsule spec
The amended CHAIR_EVIDENCE instruction stands as the standing instruction —
additionally write it verbatim into the capsule's MANIFEST.md header when it
fires: CHAIR_EVIDENCE_<date>/ = CONSOLE_LOG (verbatim, session-spanning) +
LAUNCH_REPORT.md (formal 8-item, debt fold) + DRIVE_VERDICTS.md
(hub-interact proof, findings A/B, dead-purchase defect w/ diagnosis) +
TERMINAL_SET.md (branding, overlay, Currency Standard v1, punch batches,
final diffstat) + MANIFEST.md (what each file proves, screenshot
descriptions inline). Fires at terminal-set commit+PR. Destination
cornerman-inbox. Feeds J6.

## SEQUENCE
Brief file save → R1 fold → skills build (own PR) → D1/D2/D4/D5/D6 writes →
close report → Bloodwave verify sweep + A-verdict → fresh boot (✓/✗ click +
toggle prove) → commit → PR → capsule fire.
