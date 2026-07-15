# SUPERSESSION — OpenCode gets the editor MCP block (the "Red keeps the bridges" clause is narrowed)

**RATIFIED 2026-07-15, Bloodwave** — BOARD `"BLOODWAVE | RULED | OPENCODE EDITOR TRIAL"` +
`comms\dispatch\opencode\0001` + `comms\dispatch\red\0002` Rider 4(a).

**This record supersedes two ruled statements. It edits neither** — per write-once law, a ruled
record is superseded by a new record citing it, never annotated in place.

> **CLASS: RULED. Write-once.** Supersede with a new record citing this one by filename.

---

## 1. WHAT IS SUPERSEDED (cited, not edited)

1. **`comms\fable\0074`** — the *"no editor MCP block: Red keeps the bridges"* clause of the
   `opencode.json` config-of-record (itself echoing `fable\0072` cl. 5 / `fable\0073`).
2. **`lifepunch/docs/cvl/WINDOW_TOPOLOGY_2026-07-14.md`** — specifically:
   - §2 table row *"NO `mcp` / editor block — absent by ruling — Red keeps the editor bridges"*;
   - §3 line *"The editor surface does NOT move to OpenCode"* **as it pertains to MCP wiring**;
   - §4 *"EDITOR EYES FOR THE ORCHESTRATOR — BANKED, NOT GRANTED"* **as it pertains to the two
     HTTP surfaces**.

## 2. THE NEW STATE

`opencode.json` (config of record) **carries the editor MCP block**:

```jsonc
"mcp": {
  "sbox-native": { "type": "remote", "url": "http://127.0.0.1:7269/mcp" },
  "chomnr":      { "type": "remote", "url": "http://127.0.0.1:9090/sbox-mcp" }
}
```

OpenCode wired this as its first boot act and **reachability-tested both surfaces** before this
landed (`opencode\0001` T0 PASS: native `list_toolsets` clean, chomnr `scene_get_status` clean,
zero mutations). Red committed OpenCode's tested config on this canon PR.

## 3. WHAT IS **NOT** CHANGED — the narrowing is exact

- **DRIVE ≠ MCP wiring.** An MCP cable is reachability, not authority. **Editor DRIVE remains an
  exclusive, board-named Bloodwave grant** (`EDITOR_ACCESS_LAW_V2_2026-07-13.md`), grantable to any
  implementer-eligible harness. OpenCode holds DRIVE **only for the trial slice**
  (`dispatch\opencode\0001`); on fail/close it releases and Red takes the editor per
  `dispatch\red\0002`. **This record wires a cable; it grants no standing DRIVE.**
- **TRIPLE_MCP law stands** (`TRIPLE_MCP_STACK_2026-07-13.md`): **three cables are not three
  drivers.** One board-named DRIVE holder at a time; OBSERVE seats are read-only on all three
  surfaces; **every mutation records which surface performed it.**
- **The Claude Bridge (file IPC) remains Red's surface** — not wirable to the OpenCode harness by
  design; OpenCode drives on the two HTTP surfaces only.
- **Ozmium / port 8098 remains a phantom** — barred, never wired, never probed
  (`WINDOW_TOPOLOGY §4`).
- **"Concurrent read-only eyes fine, concurrent mutating control never"** (`EDITOR_ACCESS_LAW_V2`)
  is untouched — a reachable cable does not license concurrent mutation.

## 4. DRIVE-ELIGIBILITY NOTE (Rider 4(d))

No law change is needed to let OpenCode hold DRIVE: **`EDITOR_ACCESS_LAW_V2_2026-07-13.md` already
grants DRIVE to any implementer-eligible harness**, and authority follows the model
(`OPENCODE_HARNESS_ADOPTION_2026-07-14.md`: cloud frontier = L2-eligible; CORNERMAN local =
advisory-only). This record only performs the two supersessions in §1; DRIVE eligibility was
already law.

## 5. FOLLOW-UP FLAGGED (out of this dispatch's scope, held for a word)

`CLAUDE.md`'s *Window topology* hard-rule bullet still reads *"no editor MCP block: Red keeps the
bridges … Editor-eyes-for-the-orchestrator is BANKED, not granted."* As living canon of record it
now carries a superseded clause (the same false-grounding class the Montserrat item corrected on
this PR). **Red held the CLAUDE.md edit as out of Rider 4's literal scope** and recommends a
one-line correction pointing at this record — Bloodwave's word.

FROM: Red
