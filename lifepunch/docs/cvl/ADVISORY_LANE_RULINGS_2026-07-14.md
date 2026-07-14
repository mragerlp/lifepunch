# ADVISORY COMMS LANE RULINGS — `copilot\` · `cursor\` · `kepler\`

**RATIFIED 2026-07-14, Bloodwave.** Source records: **`comms\fable\0070`** (Copilot + Cursor) and
**`comms\fable\0071`** (Kepler). Landed by Red under a board-named DRIVE grant.

> **CLASS: RULED. Write-once.** The lane *mechanics* also live in `COMMS_PROTOCOL.md` v1.5 §18. **This
> file is the RULING RECORD** — it exists because a rule whose ruling is unreachable from canon is a rule
> the next seat cannot check. *(`comms\red\0031`: not one grounding file mentioned these lanes — including
> `FABLE_BOOT.md`, so Fable's own boot file did not know about the lanes Fable ruled on.)*

---

## THE CORE CLAUSE — read this one twice

> ## **A COMMS FOLDER IS A TRANSPORT PRIVILEGE, NOT AN AUTHORITY GRANT.**

Filing to an advisory lane confers **no DRIVE, no commit, no push, no merge, and no canon right.**
Classification is **UNCHANGED**: all three remain **L3-equivalent** per `CVL_AUTHORITY_LEVELS`.

## THE THREE LANES

| Lane | Seat | Ruling |
|---|---|---|
| `comms\copilot\` | **COPILOT** | `fable\0070` |
| `comms\cursor\` | **CURSOR** | `fable\0070` |
| `comms\kepler\` | **KEPLER** (the OpenCode orchestrator window) | `fable\0071` |

## THE SEVEN BINDINGS (identical across all three)

1. **CLASSIFICATION UNCHANGED — L3.** A folder is transport. It is not a seat promotion.
2. **CONVENTIONS UNCHANGED** — `<SEQ>_<FROM>_<SUBJECT>_<DATE>.md`, per-seat monotonic from `0001`.
3. **BOARD APPEND RIGHT, LIMITED** — **one line per filing.** State words **`FILED` / `PROPOSED` / `HELD`
   ONLY.** **Never `DONE`, never `DRIVE-ACCEPTED`, never any word implying execution.**
   **`RULED` / `WORD` / `OVERRIDE-RULED` remain BLOODWAVE-ONLY.**
4. **READ ACCESS** — all of `comms\` (BOARD + every seat folder). Already true in practice; now explicit.
5. **WRITE-ONCE, ADVICE-CLASS.** **No seat — including L2 — treats an advisory filing as a work order.**
   If code is proposed, the implementer **machine-verifies every cite against the live tree before use.**
6. **NO DISPATCH FOLDER.** `dispatch\copilot\`, `dispatch\cursor\`, `dispatch\kepler\` **do not exist.**
   The **dispatch class stays reserved to the four ratified seats.** These lanes **never receive a work
   order** — they receive Bloodwave's direct paste.
7. **ABSENCE IS NOT STATUS.** An empty advisory folder is evidence of **nothing.**

## KEPLER — the narrowing clause (`fable\0071`)

**The lane grant is INDEPENDENT OF, and NARROWER THAN, implementer eligibility.**

`copilot\0010` (authority-follows-the-model) makes **OpenCode-with-a-frontier-model implementer-*eligible*
under the relief clause.** **This lane grant does not seat it.** The lane is transport for the seat's
**advisory / design output**.

When Kepler **is** seated as implementer under an **explicit relief handoff**, it files as an implementer
does. **Outside that, its lane states remain `FILED` / `PROPOSED` / `HELD`.**

See **`ORCHESTRATOR_SEAT_RULING_2026-07-14.md`**: **one window = one seat; its subagents are tools and
gain no authority.**

## WHY BINDING 5 IS THE LOAD-BEARING ONE

**It was tested the night it was written, and it held.**

`comms\cursor\0019` filed three skill drafts. **12 file:line cites — 5 clean.** Two named TOCTOU bugs
**already fixed** (the cited range now pointed at *innocent* code), one described a restore idiom that,
**followed literally, would have re-created the exact bug the rails were repaired to close.** A second L3
seat filed a **phantom cite** the same night (`copilot\0005`'s `:83`).

**The drafts were worth landing. Their cites were not.** The implementer verified first; the defects died
at the gate. **That is binding 5 working exactly as designed.**

> ## **L3 CITES REQUIRE MACHINE VERIFICATION. EVERY TIME.**

Verification record: **`comms\red\0034`.**

## RELATED CANON

`COMMS_PROTOCOL.md` v1.5 §18–19 (mechanics + FILE-FIRST) · `CVL_AUTHORITY_LEVELS_2026-07-13.md` (L3) ·
`OPENCODE_HARNESS_ADOPTION_2026-07-14.md` (authority follows the model) ·
`ORCHESTRATOR_SEAT_RULING_2026-07-14.md` · `WINDOW_TOPOLOGY_2026-07-14.md`
