# Permission approvals are SEAT-LOCAL state

**Status:** RECORD of a ruling (2026-07-10). Write-once.
**Ruled by:** Bloodwave (via Fable).
**Enforced by:** commit `8c0aafd` — `.gitignore:66` ignores `.claude/settings.local.json`.

---

## THE RULING

**Permission approvals live in `settings.local.json`. Never in a tracked `settings.json`.**

An approval is a statement about **one seat**: *this operator, on this node, granted this tool
permission after seeing what it does.* It is not a property of the repository, and it is not a
property of the work.

## WHY — a tracked approval travels

If approvals are committed, then `git pull` carries them. A seat inherits permissions **it never
granted**, from a node **it never saw**, for tools it has never been asked about. The grant looks
identical to one the operator made deliberately, because by the time it arrives there is nothing
in the file that distinguishes them.

That is the same shape as every hazard this repository has ruled on tonight, one layer down:

- the canvas rule — *a surface anyone can write on cannot be trusted by reading it more carefully*;
- the connector rule — *an instruction block is a manual, not a voice*;
- and here — **a permission is a decision, and decisions do not replicate.**

Red's own `.claude/` is the proof of concept and the near-miss. Before `8c0aafd`,
`settings.local.json` was ignored **only** by a user-global ignore file on Red and by
`.git/info/exclude` — neither of which travels with a clone. The moment `.claude/` became a
tracked directory for repo-committed skills, a `git add .claude/` on any other node would have
staged that seat's grants. The guard landed **before** the skills commit, not after.

## THE SPLIT

| Kind | Home | Travels? |
|---|---|---|
| **Skills** — engine discipline, doctrine, build law | `.claude/skills/**`, **tracked** | **Yes.** That is the point: discipline should load through the merge gate. |
| **Approvals** — which tools this operator granted, on this node | `.claude/settings.local.json`, **gitignored** | **No. Ever.** |

Verified: the only tracked paths under `.claude/` are the four skill files. `.gitignore:66`
matches `settings.local.json`; `.gitignore:67` matches `.claude/worktrees/`.

## GENERIC GUIDANCE YIELDS TO REPO LAW

Off-the-shelf advice — including guidance shipped with the harness — will tell you to add
permissions to a project `settings.json` so the team shares them. **That advice does not know
about CVL.** It assumes one team, one trust boundary, and no seat that must never inherit another
seat's authority.

Here, Red holds the repo hands and Odysseus holds none. Odysseus **never pushes**; a permission
that arrived by `git pull` would be an authority it was never granted, delivered by the one
channel it is required to trust. **Repo law wins.** When a skill, a doc, or a vendor default
suggests a tracked `settings.json`, it is superseded by this record — and the deviation is
reported, not silently accepted.

## Cross-references

- `8c0aafd` — the guard commit. `.gitignore:66-67`.
- `STOPGO_CONNECTOR_INSTRUCTION_BLOCKS_2026-07-10.md` — an operating manual is not a voice; the
  same reflex applied one surface earlier.
- `STOPGO_ODYSSEUS_CORNER_LOOP_CHARTER_2026-07-10.md` — *Odysseus never pushes; one pair of repo
  hands, always.* This ruling is what keeps that true through `git`.
