# BRAND_DOCTRINE MONTSERRAT SUPERSESSION — the "zero hits" claim is FALSE in its own tree

**Ratified:** 2026-07-14, Bloodwave (dispatch: canon-sweep3, Fable relay author)
**Supersedes:** the factual assertion in `lifepunch/docs/BRAND_DOCTRINE.md:35-39` — **that section's
RULE stands; its FACT does not.**
**Class:** RECORD (write-once). Describes a discovered defect. Never edited — supersede by a new record
citing this one by filename.

---

## §1 THE FALSE CLAIM

`lifepunch/docs/BRAND_DOCTRINE.md:35-39`, verbatim at pin `e475f279`:

> ### MONTSERRAT IS **NEVER** DECLARED IN GAME SCSS.
> **It does not exist on this stack.** Exhaustive search — engine, DXRP game tree, and repo — returns
> **zero hits** (`red\0040`). A `font-family: Montserrat` in an s&box panel **does not fail. It falls
> back silently, renders a different typeface, and passes every check we own.**

**The "zero hits ... repo" clause is false.** At `e475f279`,
`grep -rn "Montserrat" --include=*.scss lifepunchaddons/` returns **FIVE** declarations in **TWO
tracked files** — re-verified by Red's own grep this dispatch, and independently by Green
(`green\0039`, T4):

```
lifepunchaddons/Code/Addons/lifepunch/LifePunchUiShell.scss:100    font-family: Montserrat, Arial, sans-serif;
lifepunchaddons/Code/Addons/lifepunch/LifePunchUiShell.scss:322    font-family: Montserrat, Arial, sans-serif;
lifepunchaddons/Code/Addons/lifepunch/LifePunchUiShell.scss:349    font-family: Montserrat, Arial, sans-serif;
lifepunchaddons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor.scss:1486   font-family: Montserrat, Arial, sans-serif;
lifepunchaddons/Code/Addons/lifepunch/lpbitcoin/bitcoinhub/code/ui/LpHashdPanel.razor.scss:3416   font-family: Montserrat, Arial, sans-serif;
```

Both files are tracked (`git ls-files` confirms). **They ship.**

## §2 TWO CLAIMS COLLAPSED INTO ONE SENTENCE

`red\0040` did not miss this — `red\0040` **found** it. The doctrine then cited `red\0040` for a "zero
hits" claim that reads across two different searches. Green (`green\0039`) named the exact fault:

| Claim | Truth |
|---|---|
| **"Montserrat does not exist on this stack"** — the font asset is not installed | **TRUE.** |
| **"Montserrat is never declared in game SCSS"** — nobody writes the declaration | **FALSE — five declarations ship.** |

**The first is precisely why the second is dangerous, and the sentence asserts the second while proving
the first.** "Hits for the font asset" is a different search from "hits for the declaration." A
`font-family: Montserrat` in an s&box panel does not fail — by the doctrine's own words it *falls back
silently, renders the wrong typeface, and passes every check we own.* `LifePunchUiShell.scss` is the
**shared UI shell**: the blast radius is not one panel.

## §3 WHAT THIS RECORD RULES

1. **The RULE survives.** Montserrat MUST NEVER be declared in game SCSS — Poppins is the ruled in-game
   heading font, Inter is body and ships with the engine. That prescription is unchanged and correct.
2. **The FACT is superseded.** The tree does NOT contain zero Montserrat declarations. It contains
   **five, in two tracked files**, at `e475f279`. Any seat grounding on `BRAND_DOCTRINE.md:35-39` reads
   the false fact; this record is the correction of record.
3. **`CLAUDE.md:295` carried the same false fact into every seat's grounding** and is corrected in the
   same dispatch that lands this record (canon-sweep3, commit 2), citing this file.

## §4 THE CODE FIX RIDES GROK'S PR — NOT THIS ONE

**This dispatch does NOT edit the SCSS.** The five declarations are Grok's surface tonight
(`cursor\`/Grok reskin lane). The doctrine defect and the code defect are **opposite halves**: this
record fixes the *doctrine's* false claim; the *code* fix (replace/scope the five declarations) lands on
**Grok's PR**, under the Green+Fable pass and Bloodwave's merge gate. Grok's earlier font rider (PR #102)
covered only the playerhub + Bitcoin Ops surfaces — **`LifePunchUiShell.scss` was in nobody's scope**
(`git log origin/main..HEAD -- LifePunchUiShell.scss` → empty). The shared shell still carries three.

## §5 SENSORS

- **Red grep, this dispatch** (pin `e475f279`): 5 hits, 2 files — the FRESH read.
- **Green outbox `0037`–`0041`** (`green\0039` T4 primary): independent hands, same 5 hits, same
  two-claims diagnosis. `0041` is the Packet T index.
- **`red\0040`**: the origin — it *found* the declarations; the doctrine miscited it for a "zero" claim.

---
FROM: Red
