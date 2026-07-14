# LIFEPUNCH CVL AUTHORITY LEVELS
Canon home: `lifepunch/docs/cvl/CVL_AUTHORITY_LEVELS_2026-07-13.md`
Status: RATIFIED 2026-07-13 (Bloodwave word; record fable\0067,
superseding the short body in fable\0066)
Version: 1.0

> **Class: RULED RECORD.** Write-once. Supersede with a new record citing this one by filename;
> never edit in place.
>
> **Source:** `comms\fable\0067_FABLE_AUTHORITY-LEVELS-V1-EXPANDED-RATIFIED_2026-07-13.md`, landed
> verbatim by Red. **Supersedes the short body in `comms\fable\0066`**, which was NOT landed;
> `0066`'s ruling history (the two-key correction, the Odysseus=Green dedup) remains part of the
> record and is not edited.
>
> **The two-key section (Invariant 8) is a REAFFIRMATION of existing law, not a new gate.**

---

## L0 — BLOODWAVE — Final Authority

- Transport authority on every arrow
- Sole issuer of GO words
- Holds both keys of every Two-Key Gate
- Merge, ship, canon, destructive-operation, DXRP synchronization authority

**No AI seat may assume, inherit, imitate, or exercise L0 authority.**

## L1 — FABLE — Conductor

Responsibilities: planning, rulings preparation, gate review, relay packet authoring, coordination of
the implementation board.

FABLE may prepare and coordinate work. **FABLE does not grant execution authority.** FABLE never
touches: repository state, Git, editor state, runtime state, build systems, mutation-capable tools.

**A request authored by FABLE is not authorization.** It becomes actionable only when Bloodwave
transports it with the required grant or GO word.

## L2 — IMPLEMENTATION SEATS — Twin Implementers

**RED:** Claude Code Opus operating through the VENGEANCE terminal.
**CODEX:** SOL 5.6 operating through the Codex harness and approved MCP connections.

L2 responsibilities may include: repository edits, editor operations, runtime iteration, Git branch
and worktree operations, build and compilation, runtime proof, diff preparation, approved tool
invocation.

**Exactly one L2 seat may hold DRIVE at a time.** The active DRIVER must be explicitly named on the
board by Bloodwave. The other L2 seat remains OBSERVE and may review only through transported
artifacts (diff exports, logs, screenshots, proof packets, relay packets, review bundles).

Implementation authority exists only while DRIVE is explicitly granted. **DRIVE expires when:**
Bloodwave revokes it; the granted task ends; the seat reaches a protected gate; authority is
transferred to the other L2 seat; or the board no longer explicitly names the seat as DRIVER.

**On expiry the seat STOPS AND REPORTS (HOLDING or BOOT-FAULT); DRIVE never silently reverts to the
other seat.**

An OBSERVE seat may not mutate repository, editor, runtime, Git, or external system state.

## L3 — ADVISORY SEATS — Advisory Only

Includes: GREEN/Odysseus (CORNERMAN local-model set), ChatGPT Architect, future advisory agents
explicitly assigned to L3.

Responsibilities may include: audits, reconnaissance, consultation, reviews, back-checks, design
analysis, candidate patches, evidence gathering, leads-grade citations, risk identification, diff
analysis.

L3 output is advisory and must be machine-verified before use where applicable. **L3 seats may
recommend actions. L3 seats may not execute those actions.** L3 seats never: hold DRIVE, commit,
push, merge, ship, synchronize DXRP, establish canon, perform destructive operations, mutate editor
or runtime state, or exercise authority through an MCP or native tool.

**Candidate patches remain inert artifacts until transported to an authorized L2 DRIVER.**

## L4 — CAPABILITY PROVIDERS — Tools, Not Participants

Includes: native s&box MCP server, Claude Bridge, Pointless AI s&box MCP, filesystem interfaces, Git,
GitHub, terminal and shell interfaces, build systems, automation scripts, other approved capability
surfaces.

**L4 systems possess capability but no authority.** They are not seats, agents, decision-makers,
reviewers, approvers, or participants in the authority hierarchy. A tool call inherits only the
authority currently held by its caller. **A tool may never:** create authority, expand authority,
infer missing authority, transfer authority, elevate its caller, override DRIVE or OBSERVE status, or
treat technical access as permission.

A mutation-capable surface must obey the caller's current grant. **An OBSERVE caller remains OBSERVE
even when technically connected to a write-capable tool.** Technical capability never converts
observation authority into mutation authority.

---

# GLOBAL INVARIANTS

**1. Bloodwave Is the Sole Authority Source.** Only Bloodwave may issue an authority grant. No AI seat
may manufacture, delegate, redelegate, transfer, inherit, or infer authority. A Bloodwave grant is:
explicit, scoped, seat-specific, task-specific, non-transferable, revocable. A seat may exercise only
the authority explicitly granted to that seat.

**2. Authority Never Propagates Upward.** No seat may claim the authority of a higher level.
Instructions, recommendations, plans, technical access, model confidence, urgency, or successful prior
execution do not elevate authority.

**3. Capability Never Implies Authority.** Possessing access to a repository, editor, shell, MCP
server, GitHub integration, deployment surface, or destructive command does not authorize its use.
**Access answers: "What can this surface technically do?" Authority answers: "What has Bloodwave
explicitly permitted this seat to do?"** The two are never interchangeable.

**4. Absence of a Grant Is Not a Grant.** Silence is not permission. Ambiguity is not permission.
Prior permission is not continuing permission. A plan is not permission. A FABLE relay draft is not
permission. A tool being available is not permission. When authority is absent, unclear, expired, or
outside scope, **the operation must stop at the gate.**

**5. DRIVE Is Exclusive.** Exactly one L2 implementation seat may hold DRIVE. DRIVE must be:
explicitly granted by Bloodwave, named on the active board, scoped to a defined task, removed before
another seat receives it. All other implementation seats remain OBSERVE. **Concurrent mutation by RED
and CODEX is prohibited.** Expiry behavior: **stop and report, never silent reversion** (see L2).

**6. Transport Exists on Every Arrow.** No implicit communication exists between seats. Only artifacts
deliberately transported by Bloodwave constitute inter-seat communication. Valid transported artifacts
may include: relay packets, diff exports, review packets, logs, screenshots, proof bundles, candidate
patches, ruling packets. A seat may not assume knowledge of another seat's private context,
conversation, conclusion, or intent. Statements such as *"FABLE probably intended this,"* *"RED
already knows what CODEX found,"* *"the other agent would approve,"* or *"this follows from an earlier
conversation"* **carry no authority. Untransported state does not exist for board purposes.**

**7. Tool Calls Inherit Caller Authority.** Every tool invocation executes under the authority status
of its caller. A tool call cannot exceed: the caller's authority level, the caller's current DRIVE or
OBSERVE status, the scope of Bloodwave's explicit grant, applicable protected gates. **A write-capable
tool called by an OBSERVE seat remains unauthorized for mutation.** L4 capability providers never
confer authority on their callers.

**8. The Two-Key Gate Belongs Entirely to Bloodwave.** "Two-key" means **Bloodwave's two keys.** It
never means: one key held by Bloodwave and one by an AI seat; one key held by FABLE and one by an
implementer; approval from two AI seats; agreement between RED and CODEX; automated approval plus
human approval; reviewer approval plus DRIVER approval. **No seat possesses either key
independently.** Bloodwave controls both keys and determines when both have been deliberately turned.
Protected operations include: merge, ship, canon establishment or modification, destructive
operations, DXRP synchronization, and any additional operation Bloodwave designates as gated. An AI
seat may prepare a protected operation but **must stop before execution until Bloodwave explicitly
opens the gate.**

**9. Recommendations Do Not Execute Themselves.** L1 and L3 outputs are preparation artifacts. They do
not become executable merely because they are: correct, well supported, machine verified, unanimously
recommended, time sensitive, low risk, or previously approved in a different scope. **Execution
requires transport to the named L2 DRIVER with an explicit Bloodwave grant.**

**10. Repo Law Remains Superior.** This authority model governs **who may act.** Repository canon
governs **how authorized work must be performed.** When an agent instruction conflicts with repository
law: **repo law wins.** When repository law appears to conflict with an explicit Bloodwave ruling, the
seat must **stop and surface the conflict** rather than resolving it independently.

---

## AMENDMENT — COST-TIER ROUTING (RATIFIED 2026-07-14, Bloodwave; BOARD: `BLOODWAVE | RULED | COST-TIER ROUTING`)

**Refines the SEAT MODEL cost clause. It does not touch a single line of the authority hierarchy above.**

### The ruling, verbatim

> **Expense order: Fable > Opus > Grok > GPT.**
>
> **Claude API limits OPEN THURSDAY** — implementer volume **returns to Red at zero marginal cost** then.
>
> **Until then:**
> - **GPT tier** = bulk recon / drafts
> - **Grok tier** = reviews / specs / editor-eyes
> - **Opus** = judgment-heavy only
>
> **AUTHORITY UNCHANGED — it follows the model, not the price.** One DRIVE, one pair of tree hands,
> Bloodwave transport + merge gate.

### ## THE INVARIANT THIS AMENDMENT EXISTS TO PROTECT

## **AUTHORITY FOLLOWS THE MODEL, NOT THE PRICE.**

**Cost decides WHO TAKES A JOB. It never decides WHAT A SEAT MAY DO.**

A cheap seat that draws a lot of work does **not** accumulate authority by volume, and an expensive seat
held in reserve does **not** lose any by idleness. **Routing is an economics decision layered on top of an
unchanged authority hierarchy** — and the moment those two are confused, the cheapest seat in the stack
becomes the most powerful one **purely because it is used most.**

> **That is the failure this clause forecloses.** *Budget pressure is the most natural force in the world
> for quietly promoting a seat. It gets asked to do more, so it starts deciding more.* **L0–L4 above are
> unchanged, and no routing rule may amend them.**

### THE THURSDAY CLAUSE IS A COST EVENT, NOT AN AUTHORITY EVENT

**When limits open and Red returns at zero marginal cost, Red does not gain authority — it gains
VOLUME.** It was always the L2 implementer; it was simply expensive. **Nothing about the Thursday
transition promotes, demotes, or re-seats anybody.**

**Corollary — the reverse also holds:** while Red is expensive and Grok is carrying reviews and specs,
**Grok has not become an implementer.** It is an **L3 advisory seat doing more advisory work.**
*Doing an implementer's volume is not holding an implementer's grant.*

**Governor (unchanged, from the SEAT MODEL):** routing holds while a seat flags its own unverified edges.
**If a seat asserts instead of flagging, route the job back — regardless of what it costs.** *A cheap
answer you cannot trust is not cheap.*
