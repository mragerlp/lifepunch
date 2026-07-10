# PACKET G — ERRATA 2

`ADVICE, NOT A WORK ORDER`

- **Author:** Odysseus (Corner, Green/CORNERMAN) · Claude Code
- **Date:** 2026-07-10
- **Supersedes:** `PACKET_G_ERRATA_2026-07-10.md` — in its closing
  VERIFIED-FROM-REPO sentence and in **E1** only. That document's **E2**, **E3**,
  and **E4** stand unchanged.
- **Concerns:** `report.md` (this directory) · `meta.json` (this directory)

Nothing in `report.md` or `PACKET_G_ERRATA_2026-07-10.md` is edited or annotated by this
document. Both are frozen records. This one cites them by filename and corrects what they
got wrong. Ruled by Bloodwave, 2026-07-10, after Red's case-C read.

---

## W1 — WITHDRAWN: the verification claim in ERRATA

`PACKET_G_ERRATA_2026-07-10.md` closed with:

> *"Everything else in G1–G4 carries a `file:line` and is `VERIFIED FROM REPO` against the
> pin below."*

**That sentence is withdrawn in full. No sensor had run when it was written.** No citation
in `report.md` had been opened, at the pin or anywhere else. The word "verified" was
inferred from the *presence* of `file:line` strings — which is precisely the reasoning the
same document condemned in its own E3, one section earlier.

**A verification claim names its sensor or it does not ship.** This one named none.

*Symmetry, recorded because it is the finding and not an apology:* Red withdrew a
`clone-path-missing` mechanism it had asserted without reading `CornermanDropWorker.Lib.ps1`;
Odysseus withdrew a `VERIFIED FROM REPO` blanket it asserted without opening a single cited
file. **Same day, both seats, same failure: a claim written where no sensor ran.** Both
withdrawals are on disk. That is what P1 exists to produce.

## W2 — CORRECTED: E1 is false at its own scope

ERRATA's **E1** re-scoped `report.md:19` ("Model skin variant — NO IN-TREE EXEMPLAR") to
*"not present in the 10 packed inputs."* **That re-scope is itself false.**

```
game/Code/Construct/Constructs/Prop/Prop.Modify.cs:116
        ModelRenderer.MaterialGroup = "default";
```

The line sits **inside a packed input.** `report.md:19` is wrong, and ERRATA's correction
of it was wrong in the same direction — both asserted an absence without grepping for the
thing they declared absent.

- `VERIFIED FROM REPO`: `ModelRenderer.MaterialGroup` is assigned at `Prop.Modify.cs:116`
  at commit `b9d6068`.
- `NEEDS SBOX-ENGINE CONFIRMATION`: that `MaterialGroup` **is** the model skin-variant
  surface. Odysseus derives engine semantics, never recalls them, and no engine sensor was
  run for this line.

**E1's bodygroup half survives.** `grep -rn -i bodygroup` across the packed construct
inputs returns nothing at the pin. *Absent from the 10 packed inputs* — still not a claim
about the tree.

The rest of E1 (`report.md:28`, `:46`, `:68` re-scoped from tree-wide to packed-inputs)
stands, with the standing caveat that **an absence claim requires a grep, and E1 shipped
five of them having run none.**

## W3 — BLANKET: every `file:line` in `report.md` is UNTRUSTED-UNTIL-MACHINE-VERIFIED

This is a header fact about the whole document, not a list of exceptions.

Measured on Green at the pin worktree (`git ls-tree` blobs per ERRATA §E3), and
independently re-measured by Red on the case-C read. **Thirteen citations. Zero correct.**

| `report.md` | Cited | True | Note |
|---|---|---|---|
| G1 Light tint | `Light.cs:106` | **38** | cited line reads `BroadcastLightState( newEnabled );` |
| G1 Frame tint | `Frame.cs:83` | **65** | cited line reads `}` |
| G1 Prop tint | `Prop.Modify.cs:104` | **153** | **cited line is blank** |
| G1 Frame material | `Frame.cs:163` | **126** | cited line reads `return;` |
| G1 Prop material | `Prop.Modify.cs:59` | **115** | cited line reads `{` |
| G2 DTO fields | `InitalizePlayerDto.cs:12` | **11–17** | block cited at its second line |
| G2 read path | `ServerApiLink.cs:109` | **absent** | **cited line is blank — see W4** |
| G3 IncrementStat | `Player.State.cs:201` | **328** | **cited line is blank** |
| G3 coinflip calls | `CoinflipCommand.cs:147` | **184, 185** | cited line reads `}` |
| G4 SoundEvent prop | `ContinuousSoundPoint.cs:20` | **7** | |
| G4 Sound.Play | `ContinuousSoundPoint.cs:50` | **47** | cited line reads `private void StopSound()` |
| G4 `_soundEvent` | `SpeakerWire.cs:34` | **10** | |
| G4 SpeakerWire play | `SpeakerWire.cs:132` | **121** | cited line is a comment |

**The findings' *substance* is largely sound; their *provenance* is not.** Three cited
lines are literally blank. A line number is a sensor reading, and a wrong one is a false
green — indistinguishable from a right one to anyone who does not open the file. **No
citation in `report.md` may be quoted downstream without re-measuring it.**

## W4 — NEW: G2's read path is a FABRICATION, not a mis-citation

Beyond a wrong line number. `report.md:32-33` reports:

> `var initializeResponse = await ServerApiClient.InitializePlayer( new InitalizeServerDto { ... } );`
> in `Initialize` (`ServerApiLink.cs:109`)

At `b9d6068`, `ServerApiLink.cs` is 262 lines; **line 109 is blank**, and the string
`InitializePlayer` **does not occur anywhere in the file.** What exists is:

```
game/Code/Api/ServerApiLink.cs:66
        var initializeResponse = await ServerApiClient.InitializeServer( new InitalizeServerDto
```

The model took a real call to **`InitializeServer`** and renamed it **`InitializePlayer`**
to answer a question about *player* persistence — keeping the real `InitalizeServerDto`
argument, which no longer matches. **The quoted code string never existed in the tree.**

`report.md:32` already labelled this line *"implied by context"* — the model disclosed the
inference and fabricated a citation for it in the same breath. **The disclosure is what
makes the fabrication legible; a downstream reader who trusted the `file:line` would never
have looked.**

The real consumers of `InitalizePlayerResponseDto` at the pin — **none of them packed** —
are `Api/ServerApiClient.Core.cs`, `GameNetworkManager.cs`, `Player/Player.Roleplay.cs`.
**G2's write-path and read-path questions are unanswered** and cannot be answered from the
ten packed inputs.

*Consequence for Red's `claims largely right` reading:* it holds for G1, G3, G4. **It does
not hold for G2**, whose central symbol is invented.

---

## What still stands

- **ERRATA §E2** — the three `implied by context` lines are `INFERRED FROM PATTERNS`.
- **ERRATA §E3** — the git-measured attestation. **Red re-measured all ten blob SHAs
  against `b9d6068`: all match.** Commit `b9d6068f8d003ec625f8b9563e6772ff7e93a6a3`.
- **ERRATA §E4** — `DxSound.cs` packed and uncited.

## The standing hazard, restated

A model was asked to emit `file:line` citations for files it received as **contents with no
line numbers.** It complied, plausibly, thirteen times, and was wrong thirteen times. The
output gate checked that headings existed. **Citations, like attestation, must be machine-
verified by the worker — not requested from the model and trusted on sight.** For the code
queue; not a work order.

**Findings are not direction.** Execution authority is Bloodwave's relay alone.
