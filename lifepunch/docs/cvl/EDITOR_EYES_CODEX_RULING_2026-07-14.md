# EDITOR EYES FOR CODEX / OPENCODE — READ-ONLY OBSERVE (ruled)

**RATIFIED 2026-07-14, Bloodwave.** Word: *"D6 GO AS PROPOSED. Your 0038 shape is the ruling."*
Source records: `comms\red\0038` (the proposed shape) → `comms\red\0039` (this landing).
Companion to `EDITOR_ACCESS_LAW_V2_2026-07-13.md` and `TRIPLE_MCP_STACK_2026-07-13.md`.

> **CLASS: RULED. Write-once.** Supersede with a new record citing this one by filename.

---

## THE RULING

**Codex / OpenCode gets EYES. It does not get HANDS.**

| | Grant |
|---|---|
| **Surfaces** | **Read-only OBSERVE on all three**: s&box native (`127.0.0.1:7269/mcp`) · Claude Bridge (file IPC) · chomnr (`127.0.0.1:9090/sbox-mcp`) |
| **Enforcement** | **Allowlist at CONFIG level**, scoped to the **inspection classes** of `lifepunch/docs/reports/BRIDGE_TOOL_CENSUS_2026-07-12.md` |
| **Mutation tools** | ## **ZERO. None. Not one.** |
| **DRIVE** | ## **EXPLICITLY NOT GRANTED.** |
| **A mutation attempt** | ## **AN INCIDENT.** |

**Purpose:** so a reviewing seat can read **real editor state** — scene, types, compile output, logs —
instead of reviewing a diff against nothing but static text. **A reviewer that cannot see the running
system reviews the code it can imagine, not the code that runs.**

---

## WHAT "EYES, NOT HANDS" MEANS CONCRETELY

**PERMITTED** (inspection classes only): editor/compile status · type + API queries · scene *reads* ·
asset + code *reads* · log reads · bridge status.

**FORBIDDEN — the whole class, not a list to be lawyered:**
`editor_play` / `stop` · any `scene_*` or `gameobject_*` or `component_*` **write** · `code_write_file` /
`code_edit_file` / `code_delete_file` · `asset_write_raw` / `asset_compile` · `execute_csharp` ·
`invoke_static` / `invoke_method` · ConCmd / `console_run` / `convar_set` · `trigger_hotload` ·
`restart_editor` · **any sync to the editor tree** · **any playtest or input simulation.**

> **If a tool changes anything the editor persists, renders, or executes — it is out of scope, whether or
> not it is named above.** *The list is illustrative. The rule is the rule.*

---

## THE INVARIANTS THIS DOES **NOT** TOUCH

- **DRIVE remains exclusive and board-named.** `EDITOR_ACCESS_LAW_V2`:
  ## **"Concurrent read-only eyes fine. Concurrent mutating control never."**
  **This ruling is the "eyes" half of that sentence, finally exercised.** It changes nothing about the
  "control" half.
- **THREE CABLES ARE NOT THREE DRIVERS** (`TRIPLE_MCP_STACK`). Granting OBSERVE on all three surfaces
  grants **one read-only seat**, not three of anything.
- **Absence of a grant is not a grant.** OBSERVE does not decay into DRIVE, and **it never silently
  upgrades.**
- **Every observation is LEADS-GRADE** until machine-verified against the tree — identical to any L3 cite.
  **`red\0034`: two advisory seats filed bad cites in one night, and one would have re-created a fixed
  money bug.** *Eyes on the editor do not exempt a seat from being checked.*
- **THERE IS EXACTLY ONE CODEX.** If OpenCode drives the Codex API, **that IS the Codex seat.** This grant
  attaches to the **seat**, not to a process — a second harness pointed at the same model does not get a
  second pair of eyes, **it creates a race for the same chair.**

## A MUTATION ATTEMPT IS AN INCIDENT — not a denied call

**Bloodwave's word.** The distinction is deliberate and load-bearing:

> A tool call that the config *blocks* is a **guardrail doing its job**. A seat that *tries* to mutate a
> surface it was granted read-only is a seat **acting outside its charter** — and the block is the only
> reason it failed. **The attempt is the finding, not the failure.**

**It is reported, not swallowed.** A config that silently denies and moves on is a
**GREEN-BY-OMISSION** check: it cannot distinguish *"nothing tried to mutate"* from *"something tried and
I quietly said no."* **Those are very different facts about a seat.**

---

## WHY RED DID NOT WRITE THIS RULING ITSELF (part of the record, per Bloodwave)

The dispatch ordered D6 to ride PR #101. **Red held it and refused to author it.**

Every other rider in that PR **graduated an existing Bloodwave ruling** into canon. **D6 had none to
graduate.** Writing it would have meant **authoring new law governing an editor surface — as the seat that
holds the editor.**

> ## **A SEAT THAT DRAFTS ITS OWN GRANT HAS GRANTED ITSELF SOMETHING.**
> `CVL_AUTHORITY_LEVELS` **L1**: *a request authored by a non-L0 seat is not authorization.* The seat
> proposed a shape and **stopped.** Bloodwave read it, ruled it, and **the ruling is his.**
>
> **Bloodwave's verdict on the refusal:** *"Your refusal to author your own grant was correct and is part
> of the record."* **It is now.**

FROM: Red
