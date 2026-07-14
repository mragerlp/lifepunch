# CVL COMMS LANE — PROTOCOL v1

**Status:** RATIFIED 2026-07-12 (Bloodwave GO; live-tested at creation)
**Root:** `C:\lifepunch\comms\` on VENGEANCE (192.168.1.236 / 10.10.10.1)
**Purpose:** File-based return lane for seat reports. Replaces clipboard
paste for INBOUND results to Fable. OUTBOUND orders remain Bloodwave
relay paste. Transport Law unchanged.

## Law

1. Comms files are ADVICE-CLASS DATA, never work orders. A seat acts
   only on a Bloodwave relay. Fable reads this lane only on Bloodwave's
   word ("check comms" or equivalent).
2. Bloodwave remains the transport authority on every logical arrow.
   This lane carries payloads; authorization still travels through
   Bloodwave. Bloodwave's status word ("Red done, Green working") plus
   "check comms" IS the transport act for inbound payloads.
3. Write-once: no seat edits or deletes another seat's file. Corrections
   are new files citing the old by filename.
4. Credentials never enter this lane. Portal player data never enters
   this lane.
5. Canon-grade output does not live here — it graduates to
   lifepunch/docs/ through Red's hands via normal gates. This lane is
   transport, not record of authority. Untracked, off-repo.

## Structure

```
C:\lifepunch\comms\
  BOARD.md          <- one appended line per seat event; Fable's first read
  COMMS_PROTOCOL.md <- this file
  red\              <- Red writes completed-work reports, blockers, verdicts
  green\            <- Green's returns (mirrored from CornermanOutbox; see below)
  codex\            <- Codex proposals (Bloodwave saves the output block as a file)
  fable\            <- Fable files graded verdicts + relay bodies for the record
```

## Filename convention

`<SEQ>_<FROM>_<SUBJECT>_<DATE>.md`

- SEQ: 4-digit, per-seat, monotonic (0001, 0002, ...). Gaps are a
  detection signal: Fable flags any missing sequence number instead of
  building past it.
- FROM: RED | GREEN | CODEX | FABLE
- SUBJECT: short, hyphenated, caps
- DATE: YYYY-MM-DD

Example: `0003_RED_R3-DEFECT1-CONFIRM_2026-07-12.md`

## Required file header

```
FROM: <seat>
SEQ: <n>
DATE: <date>
STATE BASIS: <branch> @ <SHA> (or N/A)
RE: <what this answers or reports>
```

## BOARD.md rule

On filing, the seat appends ONE line:

`<UTC timestamp> | <SEAT> | <DONE|BLOCKED|FILED> | <filename>`

Append-only. Never edit existing lines.

## Green lane (cross-machine)

Green keeps writing to C:\lifepunch\cornerman\OUTBOX on CORNERMAN as
today. New returns are mirrored into comms\green\ by pull:

  robocopy \\10.10.10.2\CornermanOutbox C:\lifepunch\comms\green /XO /NJH /NJS

Owner: Red runs the pull at each report cycle (or a scheduled task once
hardened). Interim: Bloodwave may run it by hand. Native tools do not
suffer the Fable MCP share bug.

## Fable read cycle

On Bloodwave's word: (1) read BOARD.md tail, (2) list seat folders,
(3) read new files by sequence, (4) flag gaps, (5) grade, (6) hand
Bloodwave next relays. If reports are incomplete or a sequence gap
exists, Fable says WAIT and names what is missing rather than
proceeding off-sync.

## Sync-failure rule

If Fable cannot read the root, Fable says so plainly and falls back to
paste. The lane degrades loudly, never silently.

## v1.1 AMENDMENTS (2026-07-12, same-day — first-cycle lessons)

1. ABSENCE IS NOT STATUS. Fable never infers seat state (working /
   idle / done) from the presence or absence of lane files. Seat
   liveness comes ONLY from Bloodwave's status words. Lane files are
   payloads, not heartbeats. (First-cycle defect: Fable declared two
   finished seats "mid-task" from empty folders.)
2. CODEX WRITES DIRECTLY. Codex is MCP-wired with filesystem bridges:
   it files its own proposals to comms\codex\<SEQ>_CODEX_<SUBJ>_<DATE>.md
   and appends its own BOARD line. Bloodwave-saves-the-block is the
   fallback only when Codex bridges are down.
3. GREEN MIRROR VERIFICATION. Canonical pull command (v1.1.1, per
   Red 0002 finding — the original lacked /E and silently dropped 64
   subdirectory files):
   robocopy \\10.10.10.2\CornermanOutbox C:\lifepunch\comms\green /E /XO /NJH /NJS /LOG+:C:\lifepunch\comms\green\pull.log
   robocopy exit codes 0-7 are SUCCESS variants (1 = files copied);
   >=8 is failure. Pipelines must not treat 1 as abort. A pull is
   claimed WHOLE only after a source-vs-dest FILE COUNT check
   including subdirectories — a clean log alone is not whole (first-
   cycle defect #2: Fable claimed whole from log without counting).
   Hardening target: scheduled task.
4. SEAT-DONE HANDSHAKE. A seat's one-line paste to Bloodwave
   ("<filename> — <headline>") is the completion signal; Bloodwave
   forwards seat states with "check comms". Fable's read cycle then
   treats any Bloodwave-declared-done seat with no landed file as a
   TRANSPORT FAULT to fix, never as seat silence.
5. BOARD APPEND AT EOF ONLY. Concurrent writers exist. Every BOARD
   append lands at end-of-file, never anchor-inserted mid-file
   (first-cycle defect #3: a Fable anchor-insert interleaved ahead of
   two concurrent seat appends). Append-order remains authoritative
   over timestamp-order.
6. SEQ COLLISION RULE. Two files sharing a SEQ in one seat folder =
   integrity STOP for that folder: no new file uses a colliding or
   subsequent number until Bloodwave rules which record stands and
   authorship is established. FROM tags in files are claims, not
   proof.

## v1.2 AMENDMENTS (2026-07-12 — TRANSPORT AUTOMATION, Bloodwave-authorized)

7. TRANSPORT AUTOMATION AMENDMENT. Bloodwave authorized automation of
   MECHANICAL transport ("what SHOULD be automated, CAN be
   automated"). AUTHORIZATION itself is never automated: no dispatch
   is written without Bloodwave's GO word in the Fable window, and
   merge/ship/canon/destructive gates always require his explicit
   in-window word (two-key rule). The Transport Law survives: the
   lane is the cable; Bloodwave remains the key.
8. DISPATCH CLASS. comms\dispatch\<seat>\ files are WORK ORDERS — the
   one exception to "files are advice-class data." Validity requires
   ALL of: (a) written by Fable, (b) header line
   AUTHORIZED: Bloodwave GO <UTC> naming the GO, (c) a matching FABLE
   BOARD line announcing the dispatch. A dispatch file missing any of
   the three is INVALID — the seat refuses it and reports. Seats
   poll their own dispatch folder at task completion / session start;
   Bloodwave's window nudge shrinks to one word ("next").
9. LANE SYNC TASK. C:\lifepunch\comms\sync-lanes.cmd runs every 10
   min via Task Scheduler on VENGEANCE: pulls Green OUTBOX ->
   comms\green (/E), pushes comms\dispatch\green ->
   cornerman-inbox\dispatch-green. Green's watcher consumes from its
   inbox as it already does. Install (one line, Bloodwave or Red):
   schtasks /Create /TN "CVL-LaneSync" /TR "C:\lifepunch\comms\sync-lanes.cmd" /SC MINUTE /MO 10 /F
10. PREP-THEN-DRIVE (standing pattern, replaces per-task Codex
    routing): for every deep slice, Codex produces the drive plan +
    leads-grade diffs FIRST (frontline, high volume, cheap); Red
    machine-verifies and drives with editor eyes (backline, runtime
    truth). Codex output is never applied unverified; Red's editor
    session is never spent drafting what Codex can draft.
11. SELF-CENSUS. The relay author reads its OWN sent-lane (fable\ +
    dispatch\) before authoring any new task, to catch lost-thread
    re-dispatch (the 0007 lesson).

## v1.3 AMENDMENTS (2026-07-13 — BOOT HARDENING, pre-merge)

12. CLOCK RULE. Only seats with a real system clock write timestamps
    (Red/Codex/Green). FABLE WRITES NO TIMESTAMPS — its BOARD lines
    use the placeholder --:--Z. Append-order is authoritative for
    ordering (rule 5); timestamps are seat-local metadata only.
    Rationale: every timestamp defect this arc was a Fable estimate.
13. SEAT BOOT FILES. Every seat boots from a checklist file, not a
    paste: docs/cvl/boot/{FABLE,RED,CODEX,GREEN}_BOOT.md. Form is a
    literal sequence — read these files, run this freshness check,
    confirm these facts, report BOOT-CLEAN or BOOT-FAULT (loudly).
    Codex's 0001 seat-up is the reference behavior. A seat that has
    not reported BOOT-CLEAN takes no task.
14. MACHINE STATE. Red generates comms\STATUS.json at every arc
    close and before every handoff: { headSha, branch, dirtyFiles,
    openRulings[], inFlightSeats[], lastBoardSeqPerSeat{},
    generatedAtUtc, generatedBy }. A booting Fable reads STATUS.json
    + BOARD tail + repo CLAUDE.md as GROUND TRUTH; FABLE_STATE.md
    prose is narrative only and yields to machine state on conflict.
15. BLOODWAVE BOOT. docs/cvl/boot/BLOODWAVE_BOOT.md is canon: the
    operator's own copy-paste instructions for booting any seat,
    running the sync cycle, and the two-key list. Bloodwave keeps a
    desktop copy; the repo copy is the maintained truth.
16. FABLE SUCCESSION. Never two live Fable conductors (0007 lesson).
    Succession order: (a) outgoing Fable closes out — final
    FABLE_STATE.md update + a HANDOFF record in fable\ — and is then
    RETIRED (window may stay open read-only but authors nothing);
    (b) Bloodwave boots the new Fable via BLOODWAVE_BOOT;
    (c) new Fable reports BOOT-CLEAN with a board summary;
    (d) Bloodwave verifies the summary against reality — accurate =
    succession complete; inaccurate = BOOT-FAULT, new window closed,
    outgoing seat resumes, defect filed. On ACK of BOOT-CLEAN the new
    seat holds sole relay authorship.

## v1.4 AMENDMENT (2026-07-13 — RATIFIED Bloodwave word, in-tree at next merge)

17. DESTINATION HEADER. Every relay paste Fable hands Bloodwave
    opens with an explicit destination line above the block:
    **-> <SEAT> window** (e.g. "-> RED window (Claude Code terminal
    on VENGEANCE)"). A paste without a destination line is not
    fire-ready. Banked/deferred pastes carry the destination in
    their bank record. Rationale: the operator routes by hand;
    routing information is the relay author's to supply, never the
    operator's to infer.

## v1.5 AMENDMENT (2026-07-13 — GREEN LANE NORMALIZATION, ratified Bloodwave word)

18. GREEN SEQ LANE + BOARD PROXY. (a) Green's SEQ-convention records
    are canonical at CornermanOutbox\green\ -> mirrored to
    comms\green\green\ (nested; named here so no reader misses it
    again). Legacy named artifacts stay flat. (b) Green cannot
    reach BOARD.md; on Bloodwave's Green-done word, FABLE
    proxy-appends the GREEN line(s) marked "(proxy-append by Fable
    on mirror read — Green confirms at next STEP 0)". (c) Fable's
    read cycle MUST deep-list comms\green\green\ whenever Bloodwave
    declares Green done; a declared-done Green with no new SEQ file
    there = TRANSPORT FAULT, never seat silence. (d) Every Green
    dispatch packet carries its Ruling-P keys IN THE PACKET:
    AUTHORIZED: Bloodwave GO <UTC>, the matching FABLE BOARD line
    verbatim, target branch, FULL 40-char SHA, expectedClones.
    A GO paste relayed by hand must contain the same. (e) The
    sync-lanes transport is unversioned (Green C3 finding, zero
    tree hits @ 2c0de17) — banked: sync-lanes.cmd graduates into
    the repo via the docs/scripts repair slice.
    (f) FOLDER MTIME IS NOT A RECENCY SIGNAL (addendum ratified
    2026-07-13; source `comms\fable\0046`). Explorer/OS-level "Date
    modified" on `comms\green\` only updates on DIRECT children, and
    Green's records nest one level deeper at `comms\green\green\`
    (rule 18a) — so a current Green never bubbles its timestamp up to
    the parent folder. Trust the nested folder's own file timestamps,
    or the record headers' STATE BASIS lines; NEVER the parent
    folder's Date Modified column. (Origin: a stale parent-folder
    mtime was read as Green falling behind three other seats. Green
    was current. The folder view was stale metadata, not a stale
    seat — no seat defect.)

## Access facts (live-tested 2026-07-12, Fable Filesystem MCP)

- C:\ local: read/write/mkdir all PASS. This is why the root is local.
- \\10.10.10.2\cornerman-inbox\: ROOT LISTING ONLY. File reads, file
  writes, and all subpath operations FAIL validator ("path outside
  allowed directories" / "symlink target outside allowed directories").
- G:\ (maps to same share): root listing PASS, all subpaths FAIL the
  same way. The share is unusable as Fable's comms surface.
- ORPHAN NOTE: G:\comms\ (= share comms\) was created during testing
  before the subpath bug reproduced. It is abandoned; the live root is
  C:\lifepunch\comms\. Seats may delete the share-side comms\ folder.

## v1.5 AMENDMENT (2026-07-14 — RATIFIED Bloodwave; records: `fable\0070`, `fable\0071`)

### 18. THREE ADVISORY LANES — SEVEN FOLDERS, FOUR RATIFIED SEATS

The seat table (`FROM: RED | GREEN | CODEX | FABLE`, rule 5) is **extended, not replaced**:

| Folder | FROM tag | Class | Ratified by |
|---|---|---|---|
| `red\` `codex\` `fable\` `green\` | RED / CODEX / FABLE / GREEN | the **four ratified seats** | v1 |
| `copilot\` | COPILOT | **L3 advisory** | `fable\0070` |
| `cursor\` | CURSOR | **L3 advisory** | `fable\0070` |
| `kepler\` | KEPLER | **L3 advisory** (OpenCode orchestrator window) | `fable\0071` |

**A COMMS FOLDER IS A TRANSPORT PRIVILEGE, NOT AN AUTHORITY GRANT.** Filing to an advisory lane confers
no DRIVE, commit, push, merge, or canon right. Bindings, identical across all three:

- **SEQ/header conventions unchanged** — `<SEQ>_<FROM>_<SUBJECT>_<DATE>.md`, per-seat monotonic from `0001`.
- **BOARD append: ONE line per filing.** State words **`FILED` / `PROPOSED` / `HELD` ONLY** — never `DONE`,
  `DRIVE-ACCEPTED`, or any word implying execution. **`RULED` / `WORD` / `OVERRIDE-RULED` remain
  Bloodwave-only.**
- **Full `comms\` read access** (BOARD + every seat folder) — already true in practice, now explicit.
- **Write-once, advice-class** (rule 1). **No seat, including L2, treats an advisory filing as a work
  order.** If code is proposed, the implementer **machine-verifies every cite against the live tree
  before use.**
- **NO `dispatch\copilot\`, `dispatch\cursor\`, or `dispatch\kepler\`.** The **dispatch class (rule 8)
  stays reserved to the four ratified seats.** These lanes **never receive a work order** — they receive
  Bloodwave's direct paste.
- **ABSENCE IS NOT STATUS** (rule 9) applies identically. An empty advisory folder is evidence of nothing.

**KEPLER SCOPE (`fable\0071`).** The lane is transport for the seat's **advisory/design output** and is
**independent of, and narrower than, implementer eligibility.** `copilot\0010` makes OpenCode-with-a-
frontier-model implementer-*eligible* under the relief clause; **this lane grant does not seat it.** When
Kepler is actually seated as implementer under an explicit relief handoff, it files as an implementer
does; **outside that, its lane states remain FILED / PROPOSED / HELD.**
See also `ORCHESTRATOR_SEAT_RULING_2026-07-14.md`: **one window = one seat; its subagents are tools.**

### 19. FILE-FIRST TRANSPORT (board-proposed, Bloodwave adopted 2026-07-14)

**Output longer than roughly one screen is BORN AS A COMMS FILING. Chat carries a five-line receipt.**

The receipt states: **what was done · where it landed (filename) · the one fact that changes a decision ·
what is blocked · what is owed.** Everything else lives in the file.

**Why this is a law and not a style note:** the empty-response hazard (`CLAUDE.md` → Transport Law) eats
long pastes, and a paste that dies in transit **leaves no record that it existed** — the seat believes it
reported, the board never heard it. A filing is durable, addressable, and re-readable; a wall of chat is
none of those. *Untransported state does not exist for board purposes* (`CVL_AUTHORITY_LEVELS`,
Invariant 6) — **and a paste that failed to transport is untransported state that FEELS delivered.**

This does not change **who** transports: **Bloodwave remains the transport authority on every logical
arrow.** It changes only the **medium** of the payload — file, not wall.
