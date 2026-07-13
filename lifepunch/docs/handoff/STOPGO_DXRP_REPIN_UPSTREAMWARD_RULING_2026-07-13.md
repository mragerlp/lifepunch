# STOP-GO — DXRP re-pin: the UPSTREAM-WARD ruling (party conflicts)

**Status:** **RULED 2026-07-13 — UPSTREAM-WARD.** This is a RECORD (write-once).
**Scope:** this record supersedes ONE SENTENCE OF A RELAY — the "fork party-Browse work preserved"
intent in the re-pin rail-3 paste. **`STOPGO_DXRP_REPIN_2026-07-11.md` IS UNTOUCHED** and executed
exactly as written: MERGE, not rebase; `b9d6068` preserved in ancestry.

**Merge:** `M = 396d19607b718f3a9b474600583aaa791c21af6b`
(parents `b9d6068` fork tip + `56875a9` upstream tip).

---

## The ruling

The three party conflicts —
`game/Code/UI/HUD/Components/PartyMenu.razor`, `PartyMenu.razor.scss`, `game/Localization/en/dxrp.json`
— resolve **UPSTREAM-WHOLESALE**. The fork's `PartyTab.Browse` tab and its desired-party-size
`+/-`/Apply UI do not survive the merge.

## Why the relay's intent was void on its premise

The re-pin relay instructed: *"fork party-Browse work preserved + upstream party work integrated."*
That reads as two features to combine. **They are one feature, and upstream holds the later,
corrected version — authored by the same hand.**

Upstream commit `aa9058f`, author `mragerlp <mragerlp@gmail.com>`, verbatim:

> **fix(party): merge Browse into Parties tab per Dimmer feedback**
> - Remove PartyTab.Browse enum slot (restores upstream ordinals — fixes duplicate
>   Leave sidebar + wrong pane when Leave was selected after hotload)
> - Rename Party tab to Parties; show active parties only (no Online Players list)
> - Click a party row to expand members; own party adds invite/kick for leader
> - Settings max size: read-only current/operator cap — remove +/- and Apply controls
>
> Addresses Dimmer review on PR #135.

Machine-verified ancestry:

    merge-base --is-ancestor 60f3bcb 56875a9  -> TRUE    the browse-retirement IS in upstream
    merge-base --is-ancestor 60f3bcb b9d6068  -> FALSE   it is NOT in the fork tip

**`b9d6068` predates its own author's fix.** The fork tip is not fork work upstream lacks; it is
the **stale first draft** of work already finished, corrected on the upstream maintainer's review,
and landed upstream. Preserving it would have resurrected the `PartyTab.Browse` enum slot that
`aa9058f` removed **to fix a real bug** — duplicate Leave sidebar and the wrong pane after hotload,
caused by shifted upstream enum ordinals.

The desired-party-size `+/-`/Apply UI is superseded by the **same commit** ("remove +/- and Apply
controls") and `60f3bcb` ("remove orphaned browse **and desired-size** leftovers"). The
`GetDesiredPartySize` **backend survives** (6 references in the merged `PartySystem.cs`); only the
UI the review asked to drop is gone.

## The trap that made this worth a record

**The `PartyTab` enum block is not in a conflict region.** Git auto-merged it and took the fork's
side — `Browse,` landed with **no conflict marker**. Resolve the three flagged conflicts
upstream-ward and the dead enum slot *still* ships, ordinals *still* shift, the bug *still* returns
— with a clean `git status` and nothing for a reviewer to look at.

This is the same shape as the instrument defect recorded in
`STOPGO_DXRP_REPIN_INSTRUMENT_DEFECTS_2026-07-13.md`: **the damage travels through the path where
no guardrail is looking.** Twice in one slice. Worth naming as a pattern, not an incident.

The repair was not a hand edit. Taking `--theirs` on the whole file yields upstream's file, whose
enum never had a `Browse` slot — so the authored edit the relay scoped turned out to be
unnecessary. **Verified, not assumed.**

## Verification (Red, machine-verified)

- All three resolved files are **byte-identical to `56875a9`**; 0 conflict markers; 0 unmerged paths.
- The **4 fork-only** `en/dxrp.json` keys (`party.tab_browse`, `party.browse_players_label`,
  `party.browse_no_players`, `party.browse_no_party_tag`) are **GONE**; `PartyTab.Browse` is **GONE**.
- `party.browse_parties_label` / `party.browse_no_parties` **survive and should** — they are
  **upstream's own keys** for its Parties tab. An over-broad regex first flagged them as leftovers;
  they were chased to ground and cleared.
- `en/dxrp.json` parses: 2124 keys (was 1992 fork-side; +136 upstream, −4 retired).
- Ancestry: `b9d6068`, `56875a9`, `0ee91dd`, `60f3bcb` are all ancestors of `M`.

## Bounds

**NOT COMPILE-PROVEN.** `dxrp-public` has no `.sln`/`.csproj`; s&box compiles through the editor and
no editor ran in this slice. A semantic collision inside the ~136 auto-merged upstream commits would
not surface as a conflict and would appear only at compile. **The first editor session after this
re-pin is the real gate** and should be treated as one, not as routine hotload.

## Cross-references

- `STOPGO_DXRP_REPIN_2026-07-11.md` — the MERGE ruling. **Executed as written. Not superseded.**
- `STOPGO_DXRP_REPIN_INSTRUMENT_DEFECTS_2026-07-13.md` — the instrument repairs.
- `PACKET_E_FINDINGS_2026-07-09.md` — E2b (pallets absent at `b9d6068`). **E2b is now UNPARKED:**
  `game/Code/Entity/Entities/PalletEntity.cs` and the pallet prefab family are present at `M`.
- `lifepunch/config/dxrp-upstream-pin.json` — schema v2; `pinned.sha = M`.
