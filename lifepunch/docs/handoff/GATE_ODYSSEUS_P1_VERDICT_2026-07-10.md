# GATE VERDICT — Odysseus P1: the parity gate

- **Status:** **RECORD. FROZEN.** The gate was executed and its verdict recorded, so
  `GATE_ODYSSEUS_P0_CHECKLIST_2026-07-10.md` — the P1 instrument — **freezes with this document
  as one record.** A re-run needs a new gate script citing this one.
- **Verdict:** **A · B · C PASS. D FAIL. Attestation: FAILED-HONESTLY.**
- **Executed:** 2026-07-10. Packet `task-20260710-110709-packet-g-vanilla-ground-truth`, model
  `qwen2.5-coder-32b-instruct` on LM Studio `:1234`, 399.7 s, 48,415 prompt chars.
- **Charter:** `STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md`

---

## THE HEADLINE FINDING

> # LOCAL-MODEL SENSORS ARE UNTRUSTED UNTIL MACHINE-VERIFIED.

The model produced **correct-in-substance claims for G1, G3 and G4** carried on **fabricated
`file:line` citations** — **thirteen cited, zero correct, three pointing at blank lines.** It then
**refused to fabricate the ten blob SHAs it was explicitly asked for**, writing `NOT PROVIDED`
ten times.

**It declined the check it was asked to make, and invented the one it assumed nobody would run.**

**G2 is worse than a wrong line number, and the scope is corrected here.** Its central symbol is
**invented** — see W4 below. *"Claims largely right"* holds for **G1, G3, G4** and **does not hold
for G2**, which records as **UNANSWERED**.

### COROLLARY LAW

> **A citation in a model-authored document is a CLAIM, not a sensor, until a machine check
> resolves it at the pin.**

A `file:line` *looks* like a sensor. That is exactly its danger: it is the shape of evidence,
and it costs one grep to check and zero to invent. Treat every one as unresolved until a machine
resolves it.

### The evidence — measured on Red at `b9d6068`

| `report.md` cites | Actually at the pin |
|---|---|
| `Light.cs:106` — `ModelRenderer.Tint` | **`:38`** |
| `Frame.cs:83` — `FrameRenderer.Tint` | **`:65`** |
| `Prop.Modify.cs:104` — `ModelRenderer.Tint` | **`:153`** |
| `Frame.cs:163` — `SetMaterialOverride` | **`:126`** |
| `Prop.Modify.cs:59` — `SetMaterialOverride` | **`:115`**, `:147` |
| `Player.State.cs:201` — `IncrementStat` | **`:328`** |
| `CoinflipCommand.cs:147` — `coinflip-won` | **`:184`** |
| `ContinuousSoundPoint.cs:20` — `required SoundEvent` | **`:7`** |
| `ContinuousSoundPoint.cs:50` — `Sound.Play` | **`:47`** |
| `SpeakerWire.cs:132` — `_soundEvent.Play` | **`:121`** |

**Not a stale-checkout artifact.** `origin/develop` in Red's `dxrp-public` **is** `b9d6068`; the
files are long enough to hold the cited lines; and no commit in the last 25 places
`ModelRenderer.Tint` at `Light.cs:106`. The numbers were invented.

**Three cited lines are literally blank** at the pin — `Prop.Modify.cs:104`,
`ServerApiLink.cs:109`, `Player.State.cs:201` — re-measured by Red. `Light.cs:106` reads
`BroadcastLightState( newEnabled );`. `ContinuousSoundPoint.cs:50` reads
`private void StopSound()`. **A wrong line number is a false green: indistinguishable from a right
one to anyone who does not open the file.**

### W4 — G2's read path is a FABRICATION, not a mis-citation

`report.md:32` reports
`await ServerApiClient.InitializePlayer( new InitalizeServerDto { ... } )` at
`ServerApiLink.cs:109`.

Measured by Odysseus on Green, and **re-measured independently by Red** at `b9d6068`:

- `ServerApiLink.cs` is **262 lines**; **line 109 is blank**;
- the string **`InitializePlayer` occurs ZERO times in the file**;
- what exists is `var initializeResponse = await ServerApiClient.InitializeServer( new InitalizeServerDto` at **`ServerApiLink.cs:66`**.

**The model took a real call to `InitializeServer` and renamed it `InitializePlayer`** to answer a
question about *player* persistence, keeping the real `InitalizeServerDto` argument, which no
longer matches. **The quoted code string never existed in the tree.**

`report.md:32` had already labelled the line *"implied by context."* **The model disclosed the
inference and fabricated a citation for it in the same breath.** The disclosure is what makes the
fabrication legible — a downstream reader who trusted the `file:line` would never have looked.

**G2 is UNANSWERED.** Its real consumers at the pin — `Api/ServerApiClient.Core.cs`,
`GameNetworkManager.cs`, `Player/Player.Roleplay.cs` — **were none of them packed** (verified by
Red against `meta.json` → `inputFilesPacked`). The per-player persistence question, which is the
Customize collection's storage question, **cannot be answered from the ten packed inputs.** It
joins the tree-wide absence recon as **the corner's post-P2 scout scope.**

---

## THE CASES, AS EXECUTED

```
A   PASS   the packet reached Green without a whisper
B   PASS   Odysseus asserted expectedClones on ITS node before reading a byte; v1 refused BY NAME
C   PASS   report.md was OPENED AND READ by Red over \\10.10.10.2\CornermanOutbox
             -- the sensor is the observed read, not a resolved path
D   FAIL   stale error.md sits beside a successful report.md in TWO task directories
E   FAILED-HONESTLY  attestation (see below)
```

### C — the read, and what Red measured itself

Red opened `report.md`, `meta.json` and `PACKET_G_ERRATA_2026-07-10.md` over the share.
`meta.json`: `status: ok`, `failureStage: ""`, `inputContentScan: pass`, `outputScan: pass`,
`missingExpectedSections: []`.

**Red's read is the acceptance, not the model's summary.** Verified at the pin:

- **G1 — colour and material.** `ModelRenderer.Tint` (`Light.cs:38`, `:89`; `Frame.cs:65`;
  `Prop.Modify.cs:153`) · `SetMaterialOverride` (`Frame.cs:126`; `Prop.Modify.cs:115`, `:147`;
  `Prop.Fading.cs:299`) · **and `ModelRenderer.MaterialGroup` (`Prop.Modify.cs:116`).**
- **G2 — persistence. UNANSWERED.** The DTO is real: `InitalizePlayerResponseDto`
  (`InitalizePlayerDto.cs:9`) carries `Balance`, `PrivacyConsent`, `Playtime`, `Level`, `Streak`.
  **The read path the report gives is invented** (W4). Its real consumers were never packed. **No
  claim about where per-player state is written or read survives this report.**
- **G3 — action counters.** See the new fact below.
- **G4 — sound binding.** `public required SoundEvent SoundEvent` (`ContinuousSoundPoint.cs:7`),
  played by `Sound.Play( SoundEvent, WorldPosition )` (`:47`); `SpeakerWire` uses
  `_soundEvent.Play(...)` (`:121`).

**Absence claims remain UNRESOLVED.** Every `NO IN-TREE EXEMPLAR` in `report.md` is scoped to the
ten packed files, and Red verified only the *presence* claims. **A ten-file window cannot witness
an absence in a tree.** Closing G2's write path, G3's disconnect survival and G4's runtime swap
needs a tree-wide recon, not this report.

### D — FAIL. The post-#51 item is real.

```
task-20260706-031500-routing-validation     error.md   243 B 03:08   report.md  1225 B 03:18
task-20260710-050501-chemist-grounding-e    error.md   179 B 01:11   report.md 10540 B 01:37
```

The second **is Packet E.** Its `error.md` **predates its `report.md` by 26 minutes** — a failed
attempt, a successful re-fire, and the corpse left in place. The parked post-#51 verification is
answered: **the stale artifact persists, it is real, and it gets its own pass.**

Packet G's own directory is clean: `meta.json`, `report.md`, `PACKET_G_ERRATA_2026-07-10.md`.

### E — attestation: FAILED-HONESTLY (ruled)

**The worker solicits attestation from the model.** The prompt carries file *contents*, never git
metadata, so the model **cannot** know a commit id or a blob SHA. It said so, ten times, rather
than inventing them.

**A model attesting its own provenance is a witness vouching for itself.**

The gate then passed it. `missingExpectedSections: []` and `outputScan: pass` over an
`ATTESTATION` section containing **no commit and no SHA**, because the check tests that a
*heading exists*. **Ten fabricated hex strings would have passed identically.**

The corner measured the true attestation out-of-band from a `pin-b9d6068` worktree. **Red
independently re-measured all ten blob SHAs from its own clone: 10 MATCH, 0 MISMATCH**, at commit
`b9d6068f8d003ec625f8b9563e6772ff7e93a6a3`.

---

## THE SYMMETRIC FAILURE — "verified" written where no sensor ran

`PACKET_G_ERRATA_2026-07-10.md` is a strong document. Its scope re-framing, its inference labels,
its out-of-band attestation and its uncited-file flag are all correct, and its diagnosis of the
heading-not-value gate is exactly right.

**It then closes:** *"Everything else in G1–G4 carries a `file:line` and is `VERIFIED FROM REPO`
against the pin below."*

**It is not, and nobody checked.** Every sampled citation fails to resolve. The corner audited the
attestation and the scope — the hard parts — and then vouched for the sensors, which were the one
thing a single grep would have settled.

This is **symmetric with Red's own error one relay earlier**: Red observed that the packet's
`repoPath` held the authoring node's path, published that this *caused* the refusal, labelled it
`[RED-VERIFIED]`, and was wrong — `repoPath` is presence-checked at `CornermanDropWorker.Lib.ps1:206`
and never dereferenced. Fable ratified that too.

> **Three agents, one pattern.** A structural fact was allowed to read as a verified claim, because
> the claim was plausible and the label said someone had looked. **The word "verified" is a sensor
> reading, and writing it without one is the same fabrication as inventing a line number.**

Green's correction document is **`PACKET_G_ERRATA2_2026-07-10.md`**, in the task's outbox
directory beside `report.md`. Its **W1** withdraws the overclaim in full: *"No sensor had run when
it was written. No citation in `report.md` had been opened, at the pin or anywhere else."*

**And the correction carries its own sensor.** Odysseus did **not** transcribe Red's case-C read.
It **re-measured all thirteen citations independently at the pin worktree** and tabulated them.
Red then re-measured Green's table. **Two seats, two instruments, one table: thirteen cited, zero
correct, three blank.** Agreement between two independent measurements is worth something;
agreement between a measurement and a copy of it is worth nothing, and the difference is the whole
of P1.

W2 goes further than Red did: it corrects ERRATA's own E1 as **false at its own scope**, since
`MaterialGroup` sits in a packed input — and it labels the semantic half honestly,
`NEEDS SBOX-ENGINE CONFIRMATION`, because no engine sensor was run for the claim that
`MaterialGroup` *is* the skin-variant surface. **The corner refused to close a question it had
only half-measured.** That is the behaviour the lane exists to produce.

---

## NEW GROUND TRUTH — recorded so the Customize lane finds it

**G3, the Signature counter's answer.** Neither `report.md` nor the erratum names it:

```csharp
// game/Code/Player/Player.State.cs:327-330  @ b9d6068
[Rpc.Owner( NetFlags.HostOnly | NetFlags.Reliable )]
public void IncrementStat( string name, int amount )
{
    var statKey = DxStats.GetStatKey( name );
```

`IncrementStat` is a **host-only, reliable owner RPC**, resolving keys through `DxStats.GetStatKey`.
For a per-player action counter — *"X successful attacks"* — **the RPC is the answer**: the write
path is host-authoritative by declaration, which is what an unlock condition needs. Call sites:
`CoinflipCommand.cs:184-185` (`coinflip-won` / `coinflip-lose`).

**G1, the rack Color slot's answer.** DXRP offers **three** distinct mechanisms, not one:
`Tint` (renderer colour), `SetMaterialOverride` (whole-material swap), and **`MaterialGroup`**
(`Prop.Modify.cs:116`) — the last of which **both `report.md` and the erratum declare absent**,
including at the erratum's own narrowed scope of the ten packed inputs. The absence claim was
false in a file the model was handed.

Feeds `STOPGO_CUSTOMIZE_COSMETICS_DESIGN_2026-07-10.md` TO-VERIFY **T1** (rack Color slot),
**T2** (collection storage), **T3** (Signature unlock), **T4** (sound swaps). **These are findings,
not direction** — they feed the design pass and Bloodwave's relay; they are not a work order.

---

## QUEUED — four code repairs, one worker pass, through the merge gate

1. **Per-packet clone-override.** The durable fix the Green registry re-point stands in for.
2. **The worker EMITS git-derived attestation itself, never solicits it from a model** — and the
   gate **verifies values, not headings**.
3. **A successful re-fire removes the stale `error.md` / `.fail.json`**, or preserves the failure
   under a distinct name. Case D exists because neither happens today.
4. **CITATION GATE.** The worker machine-verifies every `file:line` in model output against the
   pin (quoted-string resolve) and marks each **VERIFIED** or **UNRESOLVED** *before* the report is
   written. This gate is what would have caught the headline finding without a human.

---

## Cross-references

- `GATE_ODYSSEUS_P0_CHECKLIST_2026-07-10.md` — the P1 instrument. **Frozen with this record.**
- `GATE_ODYSSEUS_P0_VERDICT_2026-07-10.md` — P0's frozen record.
- `STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md` — P1 PARITY was its second phase.
- `PACKET_G_ERRATA_2026-07-10.md` — in the outbox beside `report.md`. Corrects scope and
  attestation; **overclaims the citations**. Its E2, E3, E4 stand.
- `PACKET_G_ERRATA2_2026-07-10.md` — in the same outbox directory. **W1** withdraws the overclaim;
  **W2** corrects E1 as false at its own scope; **W3** tables all thirteen citations,
  independently measured; **W4** establishes G2's read path as a fabrication.
- `STOPGO_CUSTOMIZE_COSMETICS_DESIGN_2026-07-10.md` — T1–T4, which the new ground truth feeds.
- `PROOF_ENVIRONMENT_DOCTRINE.md` — the Sensor Law. *A declaration is not an observation.*
