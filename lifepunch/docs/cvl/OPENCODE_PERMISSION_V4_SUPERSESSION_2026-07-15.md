# SUPERSESSION — OpenCode permission graduation v3 → v4 → v4.1 → v4.2

**RATIFIED 2026-07-15, Bloodwave** (chat-carried; Fable #9 relay). `dispatch\red\0003` item 3, folding
`dispatch\cursor\0005` (the v3→v4 supersession task) and extending it to v4.2.

**This record supersedes, it does not edit.** It documents the permission graduation ruling and the
config's activation state; the `opencode.json` write itself is Fable #9's (see §4).

> **CLASS: RULED. Write-once.** Supersede with a new record citing this one by filename.

---

## 1. WHAT IS SUPERSEDED

- **`OPENCODE_HARNESS_ADOPTION_2026-07-14.md` permission gates** + the **T0-ACCEPTED reaffirmation**
  (`opencode.json` v3: `edit=ask`, `commit=ask`, push denied, skills `*=ask`).
- **`dispatch\cursor\0005`** — the v3→v4 supersession task. **SUPERSEDED-BY this slice** (it is folded
  and extended here through v4.2; the Cursor lane need not land a separate v4 record).

## 2. THE GRADUATION — EXACT DELTA, STEP BY STEP

**Ruling authority: Bloodwave, 2026-07-15.** The through-line at every step: **the deny wall is the
real authority boundary; the gate moves from per-keystroke to per-round** (`COMMS_PROTOCOL` Rule 25).

| Version | Change | Rationale |
|---|---|---|
| **v3 → v4** | `edit: allow`, `git commit: allow`; read/build allowlist widened (`git add`, `dotnet build`). | Rounds still land branch + diff + filing; Bloodwave holds the merge key. Per-keystroke prompting was noise, not a gate. |
| **v4 → v4.1** | `skill: "*": "allow"` (default graduated to allow). | Skills are read-only reference material — no mutation authority. **`lifepunch-editor-gate` and `cornerman-packets` stay `deny`** (wrong-surface / wrong-lane guards). |
| **v4.1 → v4.2** | `git push: allow` — **SUPERSEDES the deny** (`fable\0091` issue-centric workflow). | **Branch protection on `develop`+`main` is the authority gate** — agents push work branches freely but physically cannot merge a protected branch. **Same graduation logic as edit/commit: the real gate was always merge, not push.** |

## 3. THE DENY WALL — UNCHANGED THROUGHOUT

**`git merge` · `git tag` · `git reset` · `git clean` · `git stash` · `git checkout` · `git switch`
remain `deny` at every version.** These are the destructive / branch-swapping / merge verbs — the
authority boundary that graduation never crossed. `external_directory` stays `ask`; the seat-level
`*` stays `ask` (an unknown affordance prompts Bloodwave, never silently allows).

## 4. ACTIVATION + CONFIG STATE (verified, not asserted)

- **The config is Fable #9's write to `opencode.json`** (primary tree root), **startup-only — dormant
  until Bloodwave keys OpenCode's restart at its next stopping point.** OpenCode reads its local
  `opencode.json`, so the write is live-on-restart regardless of commit state.
- **Verified (per `cursor\0005`: "do not touch `opencode.json`; verify it reads v4 and cite it"):**
  the primary-tree `opencode.json` reads the v4.2 gates above — `edit:allow`, `git commit:allow`,
  `git add:allow`, `dotnet build:allow`, **`git push:allow`**, deny wall intact, `skill "*":allow`
  with editor-gate + packets denied. Cited, not modified.

> ⚠ **CANON-vs-LIVE DIVERGENCE — FLAGGED, held for a word.** The **canonical (`develop`)
> `opencode.json` is still pre-v4** (`edit:ask` / `commit:ask` / `push:deny`); the **v4.2 write lives
> only on the primary tree, uncommitted.** Per `cursor\0005` this record **verifies + cites** the
> config and **does not commit it** (config-to-canon is outside item 3's explicit scope). Landing
> Fable #9's v4.2 write into `develop` as canon is a **separate config-landing act** — recommend
> Fable/Bloodwave decide whether it rides a follow-up. Until then the ruling is recorded here; the
> committed config trails it.

## 5. OPENCODE_BOOT.md

Amended to reflect the v4.2 gates with a supersession pointer to this record (never a silent rewrite).

FROM: Red
