# PACKET G — ERRATA

`ADVICE, NOT A WORK ORDER`

- **Author:** Odysseus (Corner, Green/CORNERMAN) · Claude Code
- **Date:** 2026-07-10
- **Errata for:** `report.md` (this directory), produced by
  `Invoke-CornermanDropWorker.ps1`, model `qwen2.5-coder-32b-instruct`
- **Companion:** `meta.json` (this directory)

`report.md` is the frozen record of what the model produced. **This document does not
edit, annotate, or supersede it** — it corrects scope and supplies the attestation the
model was structurally unable to produce. Read them together. Ruled by Bloodwave,
2026-07-10.

---

## E1 — "NO IN-TREE EXEMPLAR" over-claims. Read it as "not present in the 10 packed inputs."

The model saw **exactly ten files** (`meta.json` → `inputFilesPacked`). It never saw the
tree. Every absence claim in `report.md` is therefore scoped to those ten files and to
nothing else.

Re-scope these lines verbatim:

| `report.md` | Claim as written | Correct scope |
|---|---|---|
| :19 | Model skin variant — `NO IN-TREE EXEMPLAR` | not present in the 10 packed inputs |
| :20 | Bodygroup — `NO IN-TREE EXEMPLAR` | not present in the 10 packed inputs |
| :28 | G2 write path — `NO IN-TREE EXEMPLAR` | not present in the 10 packed inputs |
| :46 | G3 survive-a-disconnect — `NO IN-TREE EXEMPLAR` | not present in the 10 packed inputs |
| :68 | G4 runtime sound swap — `NO IN-TREE EXEMPLAR` | not present in the 10 packed inputs |

**Read as written, `report.md:19-20` says DXRP has no skin or bodygroup support.**
Nobody measured that. It is the line most likely to be believed and repeated, and it is
the reason this erratum exists. A ten-file window cannot witness an absence in a tree.

**Sensor:** `meta.json` → `inputFilesPacked` (10 entries); `globExpandedFiles` empty.

## E2 — Three lines are INFERENCE, not ground truth. Label them.

Per the claim-labelling law, these carry `INFERRED FROM PATTERNS`, not
`VERIFIED FROM REPO`. All three say so in their own words and none is labelled.

| `report.md` | Line | Label |
|---|---|---|
| :32 | G2 read path — `ServerApiClient.InitializePlayer` *"(not shown in provided files, but implied by context)"* | **INFERRED FROM PATTERNS** |
| :44 | G3 — counts held in `Stats`, *"not explicitly shown in provided files but implied by context"* | **INFERRED FROM PATTERNS** |
| :73 | ATTESTATION commit — *"`expectedClones` (not explicitly provided, but implied by context)"* | **INFERRED** — and wrong; see E3 |

Everything else in G1–G4 carries a `file:line` and is `VERIFIED FROM REPO` against the
pin below.

## E3 — The true attestation, measured from git

`report.md:73-84` reports the commit as "implied by context" and all ten blob SHAs as
`NOT PROVIDED`. That is the honest answer to an impossible question: the prompt carried
file **contents**, never git metadata. The model could not have known these values.

Measured on Green from the pinned worktree — **not asked of any model**:

```
commit read: b9d6068f8d003ec625f8b9563e6772ff7e93a6a3

0e49cc9c19e9  game/Code/Api/Dtos/InitalizePlayerDto.cs
ec8adec895a4  game/Code/Api/ServerApiLink.cs
2ab5e3938ddf  game/Code/Chat/Commands/CoinflipCommand.cs
aa409887aa28  game/Code/Construct/Constructs/Frame/Frame.cs
c76d7ed09658  game/Code/Construct/Constructs/Light/Light.cs
2aff3f9dbaef  game/Code/Construct/Constructs/Prop/Prop.Modify.cs
021bfc6307e9  game/Code/Construct/Constructs/Wire/SpeakerWire/SpeakerWire.cs
723bc8588155  game/Code/Player/Player.State.cs
d080a846332b  game/Code/Utilities/Components/ContinuousSoundPoint.cs
44c8e56fc3b1  game/Code/Utilities/Dx/DxSound.cs
```

**Sensor:** `git -C C:\Projects\dxrp-public-worktrees\pin-b9d6068 ls-tree -r b9d6068 -- <paths>`,
run on Green, 2026-07-10. Worktree HEAD equalled `b9d6068` by name; tree clean (0 porcelain
entries) at read time.

**The standing hazard, for the code queue, not for this record:** the output gate checks
that an `ATTESTATION` heading *exists*
(`CornermanDropWorker.Lib.ps1:1417-1430`, "best-effort (missing = warning)"). It never
checks that the section contains a SHA, or that a SHA is correct. `meta.json` reported
`outputScan: pass` and `missingExpectedSections: []` over an attestation containing none.
**Ten fabricated hex strings would have passed identically.** A model attesting its own
provenance is a witness vouching for itself; attestation belongs to the worker, emitted
from git.

## E4 — One packed file is uncited

`game/Code/Utilities/Dx/DxSound.cs` was packed (`meta.json` → `inputFilesPacked`) and
appears in no G1–G4 finding. Whether it was irrelevant to the four questions or skimmed
is **unknown**; the run produces no per-file evidence to distinguish the two.

---

## What is NOT corrected here

The G1–G4 findings that carry a `file:line` are not re-verified by this document. Odysseus's
eyes are covered: no visual, playtest, scale, material, collider, or animation fact is
asserted anywhere above. Runtime and editor truth remain Red's.

**Findings are not direction.** Nothing here is a work order. Execution authority is
Bloodwave's relay alone.
