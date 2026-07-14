# ORCHESTRATOR-SEAT RULING — one window = one seat; subagents are tools

**RATIFIED 2026-07-14, Bloodwave.** Source record: `comms\fable\0072` (ruling authored by Fable #5 on
Bloodwave's word). **Write-once.** Landed verbatim by Red under a board-named DRIVE grant.

> **CLASS: RULED.** This record is never edited in place. A change of law supersedes it with a new
> record citing this one by filename.

---

## THE RULING

**1. ONE WINDOW = ONE SEAT.** An OpenCode (or equivalent) session that routes multiple models via
provider/agent blocks is **ONE seat on the board**, named by its window (**KEPLER** for the OpenCode
orchestrator). Its subagents — corner-review, deep-scan, codex-review, and any future additions — are
**TOOLS of that seat**: they inherit the seat's constraints, are permission-capped **under the seat's own
permission file**, and **gain no authority of any kind.**
*Precedents:* Green drives qwen as muscle; Red's subagents inherit Red's constraints
(`SUPERPOWERS_DOCTRINE.md`).

**2. SUBAGENT OUTPUT IS LEADS-GRADE to its own orchestrator.** The orchestrating model
**machine-verifies subagent cites before they enter any filing** — exactly as Odysseus verifies qwen.

**3. TRANSPORT LAW UNCHANGED between windows.** **Bloodwave remains the only transport between seats.**
A seat consulting its own subagents is **internal to the seat** and is **not inter-seat traffic.**

**4. THE ONE-CODEX LAW APPLIES INSIDE.** Codex reached via the orchestrator's ChatGPT Pro provider **IS
the one Codex** — *harness is transport, not identity* (ratified in PR #97, `CLAUDE.md` → AUTHORITY
FOLLOWS THE MODEL). **While the orchestrator window is live, no separate Codex chat window is consulted
for the same tree.** One Codex, one place at a time.

**5. DRIVE, merge gates, two-key, and editor law are ALL UNCHANGED.** The orchestrator seat holds DRIVE
**only when board-named**, same as any implementer. **Red retains the editor bridges and runtime truth;
the s&box editor surface does NOT move to OpenCode by this ruling.**

**6. INDEPENDENT REVIEW IS PRESERVED.** For merge-gate reviews where independence matters, a reviewer
**OUTSIDE the orchestrator window** (standalone Cursor, or Red) may be used at Bloodwave's discretion —
**a seat reviewing its own subagent's work is not independent review.**

---

## WHY THIS RULING EXISTS

An orchestrator window that fans out to N models looks, from the outside, like N seats. It is not. The
board's invariants — one seat per tree, one DRIVE, one Codex, Bloodwave as sole transport — are all
**seat-scoped**, and they silently break if a single window can mint seats by spawning subagents.

**The failure this forecloses:** a window consults its own subagent, the subagent's output is treated as
an independent second opinion, and the seat reviews itself while believing it has been reviewed. Clause 6
names that directly. Clause 2 stops the softer version — a subagent's unverified cite entering a filing as
though the orchestrator had observed it.

*A tool is capability. Only the board grants authority.*

---

## RELATED CANON

- `lifepunch/docs/cvl/CVL_AUTHORITY_LEVELS_2026-07-13.md` — **L4: tools are capability, never authority;
  a tool call inherits only its caller's grant.** This ruling is that principle applied to orchestrators.
- `lifepunch/docs/cvl/OPENCODE_HARNESS_ADOPTION_2026-07-14.md` — authority follows the model.
- `lifepunch/docs/cvl/EDITOR_ACCESS_LAW_V2_2026-07-13.md` — DRIVE is a board-named grant. Clause 5 leaves
  it untouched.
- `lifepunch/docs/cvl/SUPERPOWERS_DOCTRINE.md` — subagents inherit their seat's constraints.
- `comms\fable\0071` — the `comms\kepler\` lane (transport for this seat's advisory output; **narrower
  than implementer eligibility**).
- `CLAUDE.md` → **AUTHORITY FOLLOWS THE MODEL, NOT THE HARNESS** — the ONE-CODEX law clause 4 invokes.

## DISPOSITION (from the source record)

`opencode.json`'s agent block is live config. The **codex-review subagent joins when Bloodwave supplies
the ChatGPT Pro provider id.**
