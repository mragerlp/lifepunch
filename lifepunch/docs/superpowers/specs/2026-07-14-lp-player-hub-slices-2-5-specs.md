> # ⚠ GRADUATED L3 SPEC — EVERY CITE BELOW IS AN **L3-CLAIM**, NOT A VERIFIED FACT.
>
> **Source:** `comms\cursor\0025` (**Grok**, L3 advisory). Graduated **verbatim, byte-identical** into the
> tracked tree by Red — `lifepunch/docs/cvl/` graduation law: *canon-grade output does not live in the lane.*
>
> ## THIS CLOSES GREEN R3's ABSENCE FINDING. The Slice 2–5 seam tables are now IN THE TRACKED TREE.
>
> **BUT GRADUATION IS TRANSPORT, NOT RATIFICATION.** The body below is **unchanged advisory content.**
>
> ## **EVERY `file:line` IN THIS DOCUMENT IS AN L3-CLAIM PENDING IMPLEMENTER VERIFICATION.**
> **Re-grep each seam against the live tree before building on it.** *Two L3 seats filed bad cites on
> 2026-07-14, and one of them would have re-created a fixed money bug* (`red\0034`). **Grok's own cites here
> are pinned to `c2443ec3` and are already one merge stale** (`develop` = `023dd702`).
>
> **The pre-work section appended at the END of this file is Red's — machine-verified, and it is NOT
> advisory.**

---

# GROK 0025 — PLAYER HUB SLICES 2–5 DESIGN SPECS

DATE: 2026-07-14
FROM: Grok
SEQ: 0025
CLASS: ADVICE — FILED design (FILED / PROPOSED / HELD only)
REF: Bloodwave · GROK TASK: PLAYER HUB SLICES 2-5 DESIGN SPECS (Fable #6 relay)
TREE WRITES: NONE (product tree). Comms-lane file only.
DRIVE: none. Commits: none. Merge: Bloodwave only.

ADVICE, NOT A WORK ORDER.

Every `path:line` below is a **CLAIM** until a DRIVE implementer machine-verifies it
against the live tip they build on. Green R3 already proved the Kepler 43-row seam
table is **not in the tracked tree** (`comms\green\0026`). This filing builds a
**slice-local seam table from observed objects**, not a reconstruction of the missing
43 rows.

---

## 0. STATE BASIS

| Sensor | Value |
|--------|-------|
| Advisory worktree branch | `grokplayerhub-slice2-5-design-2026-07-14` |
| Worktree HEAD (develop pin) | `f60874ffa965d8310f778aa5e9f6f7a2b57ab916` |
| Worktree clean/dirty | clean at open (no product mutations this session) |
| Slice 1 shell tip (read-only ref) | `red/playerhub-slice1-2026-07-14` → `c2443ec35b0355ecca987f56cc9cff01579aeef5` (PR #101, 13 commits, **unmerged** at filing) |
| Player Hub code at `f60874ff` | **ABSENT** (only docs/rulings) |
| Skills read | `lifepunch-grounding`, `lifepunch-plan-shape`, `lifepunch-razor-ui`, `lifepunch-economy`, `lifepunch-design-tokens` |
| SCSS 4+ nesting claim | **DISPROVEN** (`red\0039` / commit `3eadcd48`). Flatten for **readability only**, not engine law. |
| Kepler 43-row table | Present only as lane transport `comms\kepler\0001` (reachable here); **not graduated**. Green `0026` = ABSENCE FINDING for tracked seams. |

**Intended consumer:** DRIVE implementer building slices 2–5 **after** PR #101 lands (or on a worktree that already contains the shell).

**Forbidden for this seat:** tree edits, inventing live progression/catalog backends, inventing lifetime ledgers, opening debit rails.

---

## 1. SHARED CONTRACT (all of 2–5)

### 1.1 Shell integration (Slice 1 — CLAIM cites @ `c2443ec3`)

| Seam | Evidence (CLAIM) | Class |
|------|------------------|-------|
| Root panel | `…/playerhub/code/ui/LpPlayerHubRoot.razor` (single-file shell; no `Shell/` subfolder) | HOLD @ S1 tip |
| Models + fixture | `…/playerhub/code/data/LpPlayerHubModels.cs` | HOLD @ S1 tip |
| Tab enum | `LpPlayerHubTab` Overview/Skills/Store/Stats (`Models.cs` ~:15–21) | HOLD |
| Fixture honesty | `LpPlayerHubFixture.Shell` + `IsFixture: true` (`Models.cs` ~:58–67) | HOLD |
| PREVIEW tag bound to flag | `Vm.IsFixture` → `.hub-preview-tag` (`Root.razor` ~:24–27) | HOLD |
| Law 17 TEMPORARY in **user-visible** tooltip | `LpTooltip` contains `TEMPORARY` (`Root.razor` ~:126–128) | HOLD (post-REVISE) |
| Tab host empty by design | `.hub-tabhost` + placeholder (`Root.razor` ~:84–90) | HOLD — **this is the fill region for 2–5** |
| Tab switch | `SetTab` (`Root.razor` ~:154–160) | HOLD |
| `BuildHash` | `_activeTab` + `_open` only (`Root.razor` ~:174–179) | HOLD — **must grow** as tab-local state lands |
| SCSS tabhost | `.hub-tabhost` / `.hub-placeholder*` (scss ~:308+) | HOLD |
| Package path vs plan | Plan assumed `UI/PlayerHub/Overview/…`; S1 shipped `playerhub/code/ui` + `code/data` | DRIFT (plan path) — **follow shipped layout** |
| Shell VMs for Overview/Stats/Skills/Store | **not present** on S1 tip | ABSENT (expected) |
| `ILpPlayerHubData` | **not present** | ABSENT until Slice 8 |

### 1.2 Fixture honesty (non-negotiable)

- Extend `LpPlayerHubFixture` (or sibling fixture factories on the same class) for each tab VM.
- Keep `IsFixture: true` and the PREVIEW tag until Slice 8 live swap.
- **No invented "live-looking" numbers without the PREVIEW tag.** Prefer design-wireframe values already used by the shell fixture (`Level 24`, `LpBalance 1280`, badge `2`) so Law 16 deep-links match header ↔ tab.
- Name methods `Overview()`, `Stats()`, `Skills()`, `Store()` — never `Default` / `Sample`.

### 1.3 Law 17 / tokens

| Item | Rule |
|------|------|
| `$LP` sign | blue `#017AEF` (token `$lp-blue`) — **TEMPORARY** until currency ruling |
| `$LP` amount | white (`$text-main`) |
| TEMPORARY label | user-visible (tooltip and/or page copy) — not a code comment only |
| BTC / cash | out of Player Hub scope for 2–5; if any BTC-adjacent copy appears, **green banned** on power/status |
| Layout | flex only; no grid / `@media` / gradients / raw hex in components |
| Nesting | deep nesting OK per engine experiment; **prefer shallow BEM for readability** |

### 1.4 Content region contract

Replace **only** the placeholder block inside `.hub-tabhost`:

```text
LpPlayerHubRoot
  hub-shell
    hub-header (owned by Slice 1 — do not re-layout)
    hub-body
      hub-sidebar (Slice 1)
      hub-content
        hub-page-head (Slice 1 owns eyebrow/title/blurb via LpPlayerHubTabInfo)
        hub-tabhost  ← SLICES 2–5 FILL HERE, switched on ActiveTab
```

**PROPOSED mount pattern** (implementer chooses one; both valid):

1. **Inline `@if (ActiveTab == …)` bodies** in `Root.razor` (matches S1 single-file reality; risk: file bloat).
2. **Child partials** `LpPlayerHubOverview.razor` etc. under `code/ui/` invoked from tabhost (cleaner; needs partial/component pattern used elsewhere in LP — verify against HASHD before inventing).

Plan's nested `Overview/` folders are **optional** once path DRIFT is acknowledged; **do not invent a second package root**.

### 1.5 Shared empty / error (minimal for 2–5)

| State | Slice 2–5 treatment |
|-------|---------------------|
| Fixture mode | PREVIEW tag on; all values fixture |
| Empty list | one plain line + optional deep-link (no fake zeros for unavailable stats) |
| Unavailable lifetime data | render `--`, never `0` pretending confirmation (design Stats law) |
| Spend | **closed** until Slice 6 / 7 gates open |

---

## 2. SLICE 2 — OVERVIEW

### 2a. SEAM TABLE

| # | Seam | Evidence (CLAIM) | Class |
|---|------|------------------|-------|
| 2.1 | Tab host fill point | `LpPlayerHubRoot.razor` ~:84–90 `.hub-tabhost` | HOLD @ S1 tip |
| 2.2 | Active tab Overview | enum + default `_activeTab = Overview` ~:111 | HOLD |
| 2.3 | Shell LP + level (header) | `Vm.Level`, `Vm.LpBalance` via fixture | HOLD — deep-link Law 16 must match cards |
| 2.4 | Skills badge | `SkillsBadgeCount` fixture `2` | HOLD — Overview "skill points available" must match badge |
| 2.5 | Overview page copy | `LpPlayerHubTabInfo` blurb/eyebrow | HOLD — keep; do not rewrite chrome |
| 2.6 | `LpOverviewVm` / `LpEarnRouteVm` | plan only (`implementation-plan.md` ~:102–110) | ABSENT in code |
| 2.7 | XP / level write path | Green `0017`: `Player.Level` portal-owned, no in-game write | ABSENT live source — **fixture only** |
| 2.8 | Stat ledger / recent XP events | Green `0017` lifetime ledger nonexistent | ABSENT — Recent Progress = fixture rows **or** honest empty |
| 2.9 | Deep-link to tabs | `SetTab` ~:154 | HOLD — Overview CTAs call this |
| 2.10 | Cross-surface: HASHD Overview pane | `LpHashdPanel` OpsTab.Overview (Green `0028` A5) | HOLD as **pattern ref only** — different product surface; do not share chrome classes |

### 2b. DESIGN SPEC

**Goal:** Fill Overview tab with summary cards + play-earn routes + deep-links. Fixture-backed.

**Content region:** `.hub-tabhost` when `ActiveTab == Overview`.

**Component structure (flex):**

```text
LpPlayerHubOverview (body)
  ├─ SummaryRow (flex row, wrap)
  │    ├─ ProgressionCard   (anchor — level, bar, XP into/next, remaining)
  │    ├─ LpBalanceCard     ($LP blue mark + white amount; "Earned through play"; CTA → Store)
  │    └─ SkillPointsCard   (available + unlocked counts; CTA → Skills)
  ├─ SecondaryRow
  │    ├─ RecentProgress    (fixture events OR empty "No activity recorded")
  │    └─ StatSnapshot      (playtime/sessions/$LP earned/events — `--` if no source)
  └─ EarnRoutesBlock        (title + body list; NOT IAP CTA)
```

**Data source:** `LpPlayerHubFixture.Overview()` → `LpOverviewVm`  
Align numbers with shell fixture: Level 24, LP 1280, SkillPointsAvailable 2.

**Data contract (plan, ship as records in Models.cs):**

| Field | Type | Source (2–5) |
|-------|------|----------------|
| LpBalance | long | Fixture (= shell) |
| Level | int | Fixture (= shell) |
| XpIntoLevel | int | Fixture only |
| XpForNextLevel | int | Fixture only |
| SkillPointsAvailable | int | Fixture (= badge) |
| SkillsUnlocked | int | Fixture (display only) |
| EarnRoutes | list Title/Body | Fixture copy (play-earn) |
| RecentEvents | optional list | Fixture **labeled** OR empty |

**Law 16:** header LEVEL / $LP / Skills badge must equal Overview card values when both fixture.

**Acceptance (checkboxes for implementer):**

- [ ] Cards match design Overview density (design.md Overview wireframe)
- [ ] Deep-links call `SetTab` for Skills / Store / Stats
- [ ] Earn copy is play-earn only
- [ ] PREVIEW tag still visible
- [ ] Flex-only; `BuildHash` includes any Overview-local selection if added
- [ ] Screenshot proof (Red editor gate)

### 2c. DEPENDENCIES

- **Hard:** Slice 1 shell merged or branched from S1 tip.
- **Soft:** Slice 3/4/5 not required (deep-links may land on placeholders until those slices fill).
- **External:** none for fixture Overview.

### 2d. FLAGS

| Flag | Severity | Note |
|------|----------|------|
| Recent Progress without ledger | HELD | Do not invent a lifetime event store. Fixture or empty. |
| XP curve / next unlock reward | PENDING INPUT (design.md) | Fixture labels only |
| Inter font / code-only package | OPEN | Gate 1 conditional (STATUS note) |

---

## 3. SLICE 3 — STATS

### 3a. SEAM TABLE

| # | Seam | Evidence (CLAIM) | Class |
|---|------|------------------|-------|
| 3.1 | Tab host Stats | same tabhost + `LpPlayerHubTab.Stats` | HOLD |
| 3.2 | `LpStatsVm` / sections/rows | plan only (~:140–143) | ABSENT |
| 3.3 | Lifetime K/D ledger | Green `0017` + STATUS: kills/deaths die on disconnect | **ABSENT** — gate for lifetime claims |
| 3.4 | Session K/D fields | StaffMenu reads `player.Kills`/`Deaths` (session) | HOLD as **session-only** — must not be labeled Lifetime |
| 3.5 | PlayTime | DXRP `Player.PlayTime` / StaffMenu minutes conversion | HOLD as possible **live later**; Slice 3 fixture OK |
| 3.6 | Period filters (Lifetime / 30d / 7d) | design wireframe only | ABSENT backend — **hide unsupported periods** |
| 3.7 | HASHD Logs pane (read-only feed pattern) | Green `0028` A9 | Pattern ref only |

### 3b. DESIGN SPEC

**Goal:** Read-only personal stats tables. Fixture-backed. Honest `--` for unknown.

**Content region:** `.hub-tabhost` when `ActiveTab == Stats`.

**Component structure:**

```text
LpPlayerHubStats
  ├─ FilterRow (optional) — only periods/sources that fixture declares
  ├─ HeroPlates (4): Playtime | Total XP | Skills unlocked | $LP earned
  ├─ ActivityTrend (flex bars + text summary) — fixture geometry only
  ├─ Highlights (no ranks/leaderboards)
  └─ StatSection[] → StatRow[] (label | period value | lifetime value)
```

**Data source:** `LpPlayerHubFixture.Stats()`  
If a row has no confirmed source, value = `"--"` (design law). **Never show session K/D as Lifetime.**

**Data contract:**

| Field | Type | Source |
|-------|------|--------|
| Sections[].Title | string | Fixture taxonomy labels |
| Rows[].Label | string | Fixture |
| Rows[].Value | string | Fixture or `"--"` |
| Rows[].Hint | string? | e.g. "session only" / "no ledger" |

**Non-goals:** leaderboards, percentiles, inventing a persistence ledger (Slice 7–8 / ruling).

### 3c. DEPENDENCIES

- Slice 1 hard.
- Slice 2 optional (Overview snapshot deep-link).
- **Lifetime ledger:** external gate — Slice 8 / progression ruling; Slice 3 must not pretend it exists.

### 3d. FLAGS

| Flag | Severity | Note |
|------|----------|------|
| Lifetime stats promise | **BLOCKER for live** | Fixture UI OK; live = inventing ledger without ruling = skill-miss |
| Period chips | HELD | Hide periods with no backend |
| Combat stats in hub | HELD | Session vs lifetime labeling is a product ruling |

---

## 4. SLICE 4 — SKILLS

### 4a. SEAM TABLE

| # | Seam | Evidence (CLAIM) | Class |
|---|------|------------------|-------|
| 4.1 | Tab + badge | Skills tab + `SkillsBadgeCount` | HOLD |
| 4.2 | `LpSkillsVm` / `LpSkillNodeVm` | plan (~:174–187) | ABSENT |
| 4.3 | Skill taxonomy / tracks | design: "unnamed until progression design" | ABSENT — fixture tracks only |
| 4.4 | Spend path skill points | STATUS: tenant #2 of `LifePunchUpgradeTracks` | **PROPOSED reuse** — not built as hub tenant yet |
| 4.5 | `LifePunchUpgradeTracks` registry | `LifePunchUpgradeTracks.cs:46` Register/Get | HOLD — BTC-priced tiers today (`PriceLadderSats`) |
| 4.6 | Upgrade ledger | `LifePunchUpgradeLedger.cs` (exists) | HOLD as pattern; **skill-points currency ≠ sats** |
| 4.7 | Slice 7 unlock finalize | STATUS GATED | external gate |
| 4.8 | HASHD entity detail + stepper confirm | Green `0028` A6 RackDetail confirm chips | Pattern for confirm UX (Slice 7), not for skill economy |

**Tension (plan vs STATUS vs Kepler lane):**

| Source | Slice 4 spend |
|--------|----------------|
| Tracked plan | Unlock CTA spends skill points (may harden in 7) |
| Kepler `0001` | "Slice 4 is read-only" |
| STATUS 1–5 | Fixture-backed, read-only |

**PROPOSED resolution (this filing):** Slice 4 ships **full browse + node detail + Unlock button chrome**, but:

- Unlock either **disabled** with reason `"Progression contract pending"` **or**
- Confirm opens a **non-mutating** dialog that states fixture mode / no spend  
- **No host debit of skill points in Slice 4.** That is Slice 7.

### 4b. DESIGN SPEC

**Goal:** Skill tree navigation + node detail; **points currency only in copy**; no real spend.

**Content region:** Skills tabhost.

**Component structure (flex, no grid):**

```text
LpPlayerHubSkills
  ├─ PointsHeader ("N available skill points" — match badge)
  ├─ TrackFilterChips (All / Track A/B/C — fixture names clearly fake OR neutral Track 1/2/3)
  ├─ Body (flex row)
  │    ├─ TrackList (progress X/Y)
  │    ├─ NodeGraph (tier rows of flex-wrapped nodes + connector lines if cheap)
  │    └─ NodeDetail (rank, cost in points, requirements, Unlock CTA)
```

**Node states (visual):** Locked / Available / Selected / Unlocked / Maxed — per design.md table.

**Data source:** `LpPlayerHubFixture.Skills()`  
Structural placeholders only; titles may be `Track A` style **if** UI copy marks PREVIEW (already global).

**Data contract:** plan records; `PointCost` int; `State` string enum; **no `$LP` fields**.

**Cosmetic Firewall N/A** unless a skill effect references economy — skill **definitions must not** carry `YieldMultiplier` / `ComputeTier`.

### 4c. DEPENDENCIES

- Slice 1 hard.
- Slice 2 soft (Spend Points deep-link).
- **Slice 7** for real unlock transaction + `LifePunchUpgradeTracks` tenant #2 design ruling.
- Confirm primitive may land in Slice 6 shared control — Slice 4 can stub local disabled button.

### 4d. FLAGS

| Flag | Severity | Note |
|------|----------|------|
| Skill-point track as tenant #2 | **RULING** | Reuse tracks/ledger; do not fork a second upgrade system |
| Tracks priced in sats today | DRIFT risk | Skill points ≠ `PriceLadderSats` — new subject/currency mapping needed in 7 |
| Taxonomy names | PENDING INPUT | Fixture labels only |
| Unlock in 4 vs read-only | PROPOSED | Prefer chrome without mutation (align STATUS) |

---

## 5. SLICE 5 — STORE (BROWSE)

### 5a. SEAM TABLE

| # | Seam | Evidence (CLAIM) | Class |
|---|------|------------------|-------|
| 5.1 | Store tab + `$LP Store` label | `LpPlayerHubTabInfo` | HOLD |
| 5.2 | `LpStoreVm` / items | plan (~:219–231) | ABSENT |
| 5.3 | Catalog config | none in playerhub | ABSENT — fixture catalog |
| 5.4 | Inventory rail (give/take/read) | Green `0017`: `ServerApiClient.Inventory` in **dxrp** tree | **UNVERIFIED this worktree** (dxrp clone ABSENT here); Green CLAIM: rail exists, atomicity ABSENT |
| 5.5 | LP addon callers of inventory mutations | Green: zero LP callers | HOLD as CLAIM |
| 5.6 | Slice 6 purchase / idempotency | STATUS reclassified design slice | external gate |
| 5.7 | Confirm primitive Law 14 | plan Slice 6 + design confirm wireframe | ABSENT in hub; HASHD has confirm chips (pattern) |
| 5.8 | Combat impact copy | design: every non-cosmetic shows `Combat impact: None` | product rule |

### 5b. DESIGN SPEC

**Goal:** `$LP` catalog browse + detail. **No balance mutation.** Purchase CTA disabled or confirm UI that does not debit.

**Content region:** Store tabhost.

**Component structure:**

```text
LpPlayerHubStore
  ├─ BalanceStrip ($LP mark blue + amount white; matches header)
  ├─ FilterChips (All / Cosmetics / QoL / Timed) — fixture categories
  ├─ Body (flex)
  │    ├─ Catalog (flex-wrap ItemCards)
  │    └─ ItemDetail (preview stub, description, duration, combat impact, price, after-balance math display-only)
  └─ Footer note: How to earn $LP + "Direct purchase is not promoted."
```

**Purchase control (Slice 5):**

| Option | When |
|--------|------|
| **A (preferred)** | Button label `Review purchase` **disabled** with tooltip `Purchases open in a later slice` |
| **B** | Opens confirm chrome with Affirm disabled / or Affirm no-ops while `IsFixture` |

**Never** call inventory take/give in Slice 5.

**Data source:** `LpPlayerHubFixture.Store()`  
Prices are fixture integers for layout (e.g. 250/400/500) — **not** a real catalog.

**Law 17:** price rows use blue `$LP` mark + white amount; dual-currency BTC/$ not used here.

**No-P2W:** listings non-combat; combat impact line mandatory for non-cosmetics.

### 5c. DEPENDENCIES

- Slice 1 hard.
- Slice 2 soft (Open Store deep-link).
- **Slice 6** for real debit-before-await + idempotency + confirm enablement.
- Portal/inventory atomicity ruling before any live spend.

### 5d. FLAGS

| Flag | Severity | Note |
|------|----------|------|
| Atomic debit+grant | **Slice 6 content** | Both halves may exist; one transactional call ABSENT (Green) |
| Catalog ownership | RULING | Who authors fixture→live catalog (config vs portal items) |
| Timed boost activation | PENDING INPUT | immediate vs inventory-held |
| `$LP` final identity | PENDING-RATIFICATION | keep TEMPORARY labeling |
| After-balance display | OK in 5 | Display-only math; must not mutate |

---

## 6. DEPENDENCY MAP (2–5 + external)

```text
                    ┌─────────────┐
                    │ Slice 1     │  PR #101 shell (unmerged at this filing)
                    │ Shell       │
                    └──────┬──────┘
           ┌───────────────┼───────────────┬──────────────┐
           v               v               v              v
      ┌────────┐     ┌────────┐     ┌────────┐     ┌────────┐
      │ 2 Over │     │ 3 Stats│     │ 4 Skill│     │ 5 Store│
      │ view   │     │        │     │ s      │     │ browse │
      └───┬────┘     └───┬────┘     └───┬────┘     └───┬────┘
          │              │              │              │
          │              │              │              v
          │              │              │         ┌────────┐
          │              │              │         │ 6 Buy  │  atomicity/idempotency
          │              │              │         │ DESIGN │  economy law P1/P4/P10
          │              │              │         └───┬────┘
          │              │              v             │
          │              │         ┌────────┐         │
          │              │         │ 7 Unlock│◄────────┘  (confirm reuse)
          │              │         │ GATED  │  progression tenant #2
          │              │         └────┬───┘
          │              │              │
          v              v              v
      ┌────────────────────────────────────┐
      │ 8 Live data GATED                  │
      │ wallet + catalog + skill graph     │
      │ + lifetime ledger if ever promised │
      └────────────────────────────────────┘
```

**Parallelism:** After Slice 1, **2 / 3 / 4 / 5 may proceed in parallel** (only soft deep-link coupling).  
**Serial hard gates:** 5 → 6 → (7 uses confirm) → 8.

| External gate | Blocks |
|---------------|--------|
| PR #101 merge (or branch-from-S1) | all of 2–5 on develop |
| Lifetime stats ledger ruling | live Stats (3→8) |
| Skill progression contract / tenant #2 | live Skills spend (4→7) |
| Slice 6 atomicity design + GO | live Store purchase |
| `$LP` currency identity ruling | final glyph/color (not blocking 2–5 if TEMPORARY labeled) |
| Inter / package kind | ship packaging, not layout |

---

## 7. TARGET FILES (PROPOSED — implementer after GO)

| Action | Path (follow S1 layout) |
|--------|-------------------------|
| Modify | `playerhub/code/ui/LpPlayerHubRoot.razor` — tabhost mount + `BuildHash` growth |
| Modify | `playerhub/code/ui/LpPlayerHubRoot.razor.scss` — tab body tokens only; no raw hex |
| Modify | `playerhub/code/data/LpPlayerHubModels.cs` — VMs + fixture factories |
| Create (optional split) | `code/ui/LpPlayerHubOverview.razor` (+ scss) |
| Create (optional) | `…Stats.razor`, `…Skills.razor`, `…Store.razor` (+ scss) |
| Create only when ruled | live `ILpPlayerHubData`, purchase RPC, skill tenant registration |
| FORBIDDEN | `lifepunchdxrp/**` edits · inventing portal APIs · client SteamId · optimistic LP debit · green on BTC/power status · second upgrade stack |

---

## 8. CROSS-SURFACE INTEGRATION (Green R5 → hub)

Use HASHD **as pattern library**, not as shared CSS:

| HASHD pane (Green `0028`) | Player Hub analogue | Copy? |
|---------------------------|---------------------|-------|
| A2 sidebar + A3 header | Slice 1 shell (already website family) | Structure only |
| A5 Overview command center | Slice 2 cards | Card density / checklist **ideas** — not classes |
| A6 entity chips / plates | Slice 3 hero plates | Entity Detail Contract discipline |
| A6 confirm chips | Slice 6/7 confirm | Affirm left / deny right, scrim |
| A7 wallet cashout | **out of scope** for hub 2–5 | Do not import BTC cashout |
| A9 logs empty/feed | Slice 3 empty | Empty copy tone |
| B* CRT | **EXEMPT** | Never restyle CRT into hub tokens |

Bloodwave UI direction (BOARD): Player Hub keeps website feel; Bitcoin Ops gets terminal-crypto reskin **separately** (Codex task). Slices 2–5 stay website family.

---

## 9. EXECUTION GATE (for implementer — not this seat)

1. Branch not `develop`/`main`; assert at commit.
2. `Validate-SboxRazorScss.ps1` on touched panels.
3. `Sync-LifePunchAddonsToDxrp.ps1 -WhatIf` first; launch set only.
4. Editor proof: cold compile 0 CS/0 RZ; positive code-string ID per slice mark.
5. PREVIEW tag visible in every screenshot for 2–5.
6. Law 17 pixel check: blue sign, white amount, TEMPORARY visible.
7. No inventory take/give; no skill ledger write; no optimistic balance.

---

## 10. CLOSING LAW

> **absence of a contract is a blocker, not permission to invent local substitutes.**

Slices 2–5 are **honest fixture UI on the Slice 1 shell**. They do not unlock Slice 6 atomicity, do not create a lifetime ledger, and do not register skill-point tenant #2. Those remain gates.

---

## 11. VERDICT

| Deliverable | Status |
|-------------|--------|
| (a) Seam tables 2–5 | FILED — HOLD/DRIFT/ABSENT labeled; S1 cites are CLAIMs @ `c2443ec3` |
| (b) Design specs 2–5 | FILED — content region, components, fixture sources |
| (c) Dependency map | FILED — parallel 2–5 after 1; 6/7/8 external gates |
| (d) Flags | FILED — rulings + portal/atomicity + progression |

**PROPOSED next implementer step:** merge or branch-from PR #101, then Slice 2 Overview first (deep-link hub for the rest), unless Bloodwave sequences differently.

FROM: Grok

---

# SLICE 2 PRE-WORK — S1 FIXTURE-TRAP CORRECTIONS

**AUTHOR: Red. MACHINE-VERIFIED against `develop` @ `023dd702` (merged Slice 1).**
**This section is NOT advisory and NOT an L3 claim. Every item below was greped, and two of them are
defects in shipped code.**

## ⚠ C4 — **THE HUB IS UNREACHABLE IN GAME. NOTHING MOUNTS IT.** *(BLOCKER)*

**Sensor:** `grep -rn "LpPlayerHubRoot"` across **every** `.cs` / `.scene` / `.prefab` / `.razor` in the
repo → **the only hit is its own definition.** **Zero mounts. No scene, no prefab, no component adds it.**

> ## MERGED SLICE 1 RENDERS FOR NOBODY. IT IS DEAD CODE IN THE TREE.

### HOW THIS PASSED AN EDITOR PROOF — read this before trusting the next screenshot

**I mounted the panel BY HAND** — created a `GameObject`, added `ScreenPanel` + `LpPlayerHubRoot`,
screenshotted it, **deleted the GameObject, and did not save the scene.**

> ## THE SCREENSHOT PROVED THE PANEL **CAN** RENDER. IT NEVER PROVED THE PANEL **DOES** RENDER.
> **The mount was the one thing I did with my own hands and then never shipped** — and because I did it
> myself, **the sensor I trusted most was the one thing standing between the code and the truth.**
>
> **Nothing else could catch it:** the compiler cannot (**dead code compiles**), a cold reviewer cannot
> (**there is nothing wrong with the file**), and the screenshot cannot (**I built the thing it was
> photographing**).

**GREEN-BY-OMISSION #12.** *An editor proof that requires the prover to hand-build the mount is a proof of
the COMPONENT, not of the FEATURE.*

**SLICE 2 CANNOT PROCEED WITHOUT A MOUNT. It is pre-work, not follow-up.** The mount **enters the repo** —
a tracked scene entry, prefab, or a component that adds the panel — **and the proof is that a player can
OPEN it, not that Red can spawn it.**

## ⚠ C3 — `_open` NEVER RESETS. **THE HUB CLOSES FOREVER.** *(BLOCKER)*

**Sensor:** `LpPlayerHubRoot.razor` — `:112` `_open = true` (init) · `:165` `_open = false` (`Close()`) ·
**and nothing anywhere sets it back to `true`.**

**Once closed, the panel cannot reopen.** There is **no open path in the code at all** — which is the same
hole as C4 seen from the other side: **I never shipped a way in, so I never noticed there was no way back
in.**

**Slice 2 lands `Open()` / toggle alongside the mount. C3 and C4 are one fix.**

## C1 — `BuildHash` MUST GROW WITH THE VIEW-MODEL

**Sensor:** `:174-179` hashes **`_activeTab` + `_open` only.**

**Correct today** — `Vm` is a pure function of `_activeTab` over a **static** fixture, so nothing else can
change. **It becomes WRONG the moment `Vm` carries live or tab-local state**, because the panel would stop
re-rendering when its data changes and **there would be no error — just a frozen readout.**

> **Every private flag that changes markup goes in the hash.** When Slice 2 adds Overview-local selection,
> or Slice 8 makes `Vm` live, **`BuildHash` grows in the same commit.** *A stale-render bug is invisible
> until someone notices a number that never moves.*

## C2 — THE PREVIEW TAG MUST SCOPE TO **ANY** FIXTURE ON SCREEN

**Sensor:** the tag is bound to `Vm.IsFixture` — a **shell-level** flag.

**A tab whose own content is fixture-backed while the shell has gone live would render live-looking numbers
with NO PREVIEW TAG.** The honesty guarantee **must widen to "any fixture visible anywhere in the hub,"**
not "the shell's fixture flag."

> **The tag's whole purpose is that a screenshot cannot lie.** *A tag that only watches the shell stops
> being that guarantee the instant one tab goes live before the others* — which is **exactly** what
> Slices 2–8 do, one at a time.

---

## ORDER OF WORK FOR SLICE 2

1. ## **MOUNT + OPEN/CLOSE (C4 + C3) — BLOCKING. Nothing else matters until a player can open the hub.**
2. Widen the PREVIEW tag (C2).
3. Overview content per the spec above — **re-greping every L3 cite first.**
4. `BuildHash` grows with whatever state Overview adds (C1).

> ## **DO NOT BUILD OVERVIEW CONTENT INTO A PANEL NOBODY CAN OPEN.**
> *That is how a slice ships "done" twice.*
