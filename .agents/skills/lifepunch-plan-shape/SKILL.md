---
name: lifepunch-plan-shape
description: "House template for LIFEPUNCH design and implementation plans. Canonizes the Player Hub plan FORMAT: verified-seams-before-design, explicit non-goals, target-file tables, data contracts as tables, per-slice acceptance checkboxes, hard integration gates, the execution gate, and the closing contract law. Use before authoring or reviewing any multi-slice UI or systems plan."
---

# LIFEPUNCH plan shape — the house template

**A plan without seams is fiction.** This skill fixes the *format* that stops a plan from inventing the
world it needs.

**Exemplar (read one before writing your first plan):**
- `comms\kepler\0001_KEPLER_PLAYERHUB-8SLICE-IMPLEMENTATION-PLAN_2026-07-14.md` — the lane filing.
- **`lifepunch/docs/superpowers/specs/2026-07-14-lp-player-hub-implementation-plan.md`** — the **tracked**
  mirror, and its design sibling `2026-07-14-lp-player-hub-design.md`.

> **The lane copy and the tracked copy are BOTH exemplars, and the tracked one is the durable reference.**
> A lane filing is transport; canon-grade output **graduates** into `lifepunch/docs/` under the normal
> gates (`COMMS_PROTOCOL` — *canon-grade output does not live in the lane*).

## When to apply

- Multi-slice feature plans (Player Hub class).
- Any plan that **invents files, RPCs, or data contracts**.
- Reviews asking *"is this shippable as a brief?"*

**Skip:** one-line bugfixes · doc typos · seat boot reports.

## Standing

**A plan is ADVICE-CLASS until Bloodwave GO** — even a beautiful one, even one an implementer wrote.
**A missing required section is a defect**, not a style note.

---

## Required sections, in order

| # | Section | Why |
|---|---|---|
| 1 | **Header / state basis** | Who · DATE · **HEAD + branch** · advice-vs-work-order · revalidate note. **Stops a build against a tree that has moved.** |
| 2 | **Goal + target assumption** | One paragraph. **Name the package/path assumption AS an assumption, not a fact.** |
| 3 | **Architecture + explicit NON-GOALS** | Non-goals are **first-class**. They forbid inventing portal APIs, client authority, JS/Grid/`@media`, combat `$LP`, and edits to `lifepunchdxrp/`. |
| 4 | **VERIFIED-SEAMS TABLE** | **file:line evidence BEFORE any design claim.** See below — this is the load-bearing section. |
| 5 | **Locked visual / constraint contract** | Tokens + engine constraints **up front** (`lifepunch-design-tokens`). Prevents purple/grid drift mid-plan. |
| 6 | **Target-files table** | **Create now** / **Create only when ruled** / **Modify after GO** / **FORBIDDEN**. Keeps exemplars read-only; blocks drive-by edits. |
| 7 | **Data contracts as TABLES** | `Field \| Type \| Source`. **Not prose.** Transaction results carry `RequestId` · `OperationId` · `ResultCode` · `AuthoritativeBalance`. |
| 8 | **Network / authority surface** | `[Sync]` vs private RPC · caller filter · **never a client SteamId** (`lifepunch-economy` P4). |
| 9 | **Per-slice blocks** | Goal · files · component hierarchy · dependencies · **acceptance criteria as CHECKBOXES**. |
| 10 | **Hard integration gates** | **Numbered HOLDs that BLOCK named slices.** A gate is not a to-do. |
| 11 | **Execution gate** | Validators · `Sync -WhatIf` · proof scene · **positive code-string ID** · screenshots · transaction cases. |
| 12 | **Closing law (verbatim)** | See the last line of this skill. |

*Optional but recommended:* screen contracts per tab · slice-close rule · preview-vs-production split.

---

## Section 4 — the VERIFIED-SEAMS TABLE. **This is the one that matters.**

```text
| Seam | Repository evidence (path:line) | Classification |
|------|----------------------------------|----------------|
| ...  | ...                              | VERIFIED FROM REPO / VERIFIED ABSENCE / OWNER CONTRACT REQUIRED |
```

**`VERIFIED ABSENCE` is a first-class result.** "I looked and it is not there" is a finding, and it is the
one that most often changes a plan — an absent seam becomes a **gate**, not a silent local substitute.

**Why the exemplar earns this:** the Player Hub plan listed **40+ seams before a single slice recipe.**
That ordering is what forced the UI-STANDARD token conflict and the missing `$LP` portal contracts to
**surface as gates instead of being quietly invented.**

> **A cite is a claim and it needs a sensor.** Seams **drift** — re-grep every one against the live tree
> before you build on it. *(2026-07-14: an L3 skill draft carried a TOCTOU cite that had been fixed weeks
> earlier; the cited line now pointed at innocent code. Verify: `comms\red\0034`.)*

---

## Per-slice block

```text
## Slice N — Name
Goal: ...
Files: ...
Component hierarchy: (tree)
Data contracts: (or pointer)
Dependencies: prior slices / gates
Acceptance criteria:
- [ ] ...
- [ ] ...
```

**Checkboxes, not vibes.** A reviewer grades **evidence**.

## Execution gate

Static validators · `Sync-LifePunchAddonsToDxrp -WhatIf` **first, every time** · the proof scene ·
**a positive code-string ID** · the screenshot set · transaction cases.

> **`dotnet build` IS NOT A COMPILE SENSOR** for addon code. The editor compiles a **hand-synced copy**
> (`lifepunch-editor-gate`). Editing the repo and hotloading gives a **FALSE ALL-CLEAR**.

## Plan anti-patterns

| Anti-pattern | Why it kills the plan |
|---|---|
| **Design claims before the seams table** | The plan invents the codebase it wishes it had. |
| **Prose data contracts** | Slice-6-class money work cannot ship on a DTO nobody pinned down. |
| **A gate written as a to-do** | A gate **blocks**; a to-do gets skipped under deadline. |
| **Acceptance criteria with no checkbox** | Unfalsifiable. Nothing to grade. |
| **Inventing a local substitute for a missing contract** | See the closing law. **This is the big one.** |

---

## CLOSING LAW — the required last line of every plan, verbatim

> **absence of a contract is a blocker, not permission to invent local substitutes.**

**Why:** the exemplar's Open Gate 4 (`$LP` portal) and Gate 5 (progression) exist **because** the plan
refused to fake them. **Inventing a local balance or a fake catalog to "unblock" a slice is a skill-miss
and an economy defect** — it manufactures the appearance of progress and hides a missing ruling.

*It is the same law as `absence of a grant is not a grant` (`CVL_AUTHORITY_LEVELS`), pointed at design
instead of authority. **Absence is a finding. It is never a license.***
