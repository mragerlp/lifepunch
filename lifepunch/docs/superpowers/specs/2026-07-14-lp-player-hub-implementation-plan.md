# LIFEPUNCH Player Hub — Implementation Plan

**STATUS:** PLAN ONLY — no implementation in this PR.  
**Depends on:** `2026-07-14-lp-player-hub-design.md` (design wireframe APPROVED).  
**Also aligns:** `LIFEPUNCH_UI_STANDARD.md` token reconcile (website `:root`).  
**Currency:** `$LP` placeholder until final currency ruling.

## Constraints (non-negotiable)

| Constraint | Rule |
|---|---|
| Layout | CSS **`flex` only** — no `grid` (s&box SCSS) |
| Script | **No client JS** — C# / Razor handlers only |
| Purchases | **Debit-before-await** — host-authoritative debit; no optimistic `$LP` deduction |
| Skill spend | Skill points only — never `$LP` |
| Chrome | Tokens from design spec / UI standard; no branding footer, glow, glass |
| Hash | `BuildHash` includes every private UI flag that changes markup |
| Proof | Flatgrass / play proof before "done" on interactive slices |

## Package / path targets (proposed)

Exact addon package TBD at Shell slice kickoff; provisional layout:

```text
lifepunchaddons/Code/Addons/lifepunch/<ident>/UI/PlayerHub/
  LpPlayerHubRoot.razor (+ .razor.scss + .cs)
  Shell/LpPlayerHubShell.razor
  Overview/LpPlayerHubOverview.razor
  Skills/LpPlayerHubSkills.razor
  Store/LpPlayerHubStore.razor
  Stats/LpPlayerHubStats.razor
  Shared/LpPlayerHubConfirm.razor
  Shared/LpPlayerHubEmpty.razor
  Shared/LpPlayerHubError.razor
  Data/ILpPlayerHubData.cs
  Data/LpPlayerHubModels.cs
```

---

## Slice 1 — Shell

**Goal:** Branded hub chrome: header, sidebar nav, close, tab host, empty content region.

### Files
- `LpPlayerHubRoot.razor` / `.razor.scss` / code-behind
- `Shell/LpPlayerHubShell.razor`
- Token SCSS partial mirroring design tokens

### Component hierarchy
```text
LpPlayerHubRoot
  └─ LpPlayerHubShell
       ├─ Header (level, $LP read-only stub, close)
       ├─ Sidebar (avatar stub, nav: Overview / Skills / Store / Stats)
       └─ TabHost (active tab slot — empty placeholder)
```

### Data contracts
```csharp
enum LpPlayerHubTab { Overview, Skills, Store, Stats }
record LpPlayerHubShellVm(
  string PlayerName,
  string RankLabel,      // e.g. "Member"
  int Level,
  long LpBalance,        // display only this slice
  LpPlayerHubTab ActiveTab,
  int SkillsBadgeCount   // unread/available unlocks
);
```

### Dependencies
- None (stub VMs OK)

### Acceptance criteria
- [ ] Opens/closes as a panel; 1160×700 target scales within viewport
- [ ] Sidebar nav switches ActiveTab; selected wash + left indicator
- [ ] Tokens match `#017AEF` / `#000000` / surfaces; flex layout only
- [ ] No JS; `BuildHash` includes `ActiveTab` + open flag
- [ ] Screenshot proof of shell chrome

---

## Slice 2 — Overview

**Goal:** Summary cards + earn routes copy; deep-links to other tabs.

### Files
- `Overview/LpPlayerHubOverview.razor` (+ scss)
- Shell wires Overview into TabHost

### Component hierarchy
```text
LpPlayerHubOverview
  ├─ SummaryCardRow ($LP / XP / Skills available)
  ├─ EarnRoutesBlock ("How to earn $LP" — not real-money CTA)
  └─ DeepLinkButtons → Skills | Store | Stats
```

### Data contracts
```csharp
record LpOverviewVm(
  long LpBalance,
  int Level,
  int XpIntoLevel,
  int XpForNextLevel,
  int SkillPointsAvailable,
  IReadOnlyList<LpEarnRouteVm> EarnRoutes
);
record LpEarnRouteVm(string Title, string Body);
```

### Dependencies
- Slice 1 Shell

### Acceptance criteria
- [ ] Cards match design Overview section
- [ ] Deep-links change ActiveTab and match destination values (Law 16)
- [ ] Earn copy is play-earn, not IAP CTA
- [ ] Flex-only; screenshot proof

---

## Slice 3 — Stats

**Goal:** Personal stats tables / rows across systems (read-only).

### Files
- `Stats/LpPlayerHubStats.razor` (+ scss)

### Component hierarchy
```text
LpPlayerHubStats
  ├─ FilterChips (All / per-system) — optional if design requires
  └─ StatSection[] → StatRow[]
```

### Data contracts
```csharp
record LpStatsVm(IReadOnlyList<LpStatSectionVm> Sections);
record LpStatSectionVm(string Title, IReadOnlyList<LpStatRowVm> Rows);
record LpStatRowVm(string Label, string Value, string? Hint);
```

### Dependencies
- Slice 1 Shell (Overview deep-link optional)

### Acceptance criteria
- [ ] Sections/rows match Stats wireframe density
- [ ] Empty + error shared states work
- [ ] Read-only; no spend path
- [ ] Flex-only; screenshot proof

---

## Slice 4 — Skills

**Goal:** Skill tree navigation + node detail; spend skill points (not `$LP`).

### Files
- `Skills/LpPlayerHubSkills.razor` (+ scss)
- Shared node/tooltip primitives as needed

### Component hierarchy
```text
LpPlayerHubSkills
  ├─ TreeNav / category list
  ├─ NodeGraph (flex-wrapped nodes — not CSS grid)
  └─ NodeDetail (rank, cost in skill points, unlock CTA)
```

### Data contracts
```csharp
record LpSkillsVm(
  int SkillPointsAvailable,
  IReadOnlyList<LpSkillNodeVm> Nodes,
  string? SelectedNodeId
);
record LpSkillNodeVm(
  string Id,
  string Title,
  int Rank,
  int MaxRank,
  int PointCost,
  bool CanUnlock,
  string State // Locked | Available | Unlocked | Maxed
);
```

### Dependencies
- Slice 1 Shell
- Skill progression service (stub → live in Slice 7)

### Acceptance criteria
- [ ] Node states match design (Locked / Available / Unlocked / Maxed)
- [ ] Unlock spends **skill points only**
- [ ] Confirm pattern for unlock (Slice 7 may harden)
- [ ] Flex node layout; no JS; screenshot proof

---

## Slice 5 — Store (browse)

**Goal:** `$LP` catalog browse + detail; purchase CTA disabled or confirm-gated without debit yet.

### Files
- `Store/LpPlayerHubStore.razor` (+ scss)

### Component hierarchy
```text
LpPlayerHubStore
  ├─ CatalogList / filters
  ├─ ItemCard[]
  └─ ItemDetail (price `$LP`, owned flag, Purchase opens confirm)
```

### Data contracts
```csharp
record LpStoreVm(
  long LpBalance,
  IReadOnlyList<LpStoreItemVm> Items,
  string? SelectedItemId
);
record LpStoreItemVm(
  string Id,
  string Title,
  string Description,
  long PriceLp,
  bool Owned,
  bool Affordable
);
```

### Dependencies
- Slice 1 Shell
- Catalog config source (stub OK)

### Acceptance criteria
- [ ] Catalog matches Store wireframe
- [ ] Price shows `$LP` brand grammar
- [ ] No balance mutation in this slice
- [ ] Flex-only; screenshot proof

---

## Slice 6 — Purchase (debit-before-await)

**Goal:** Host-authoritative `$LP` purchase path with confirm/deny primitive.

### Files
- `Shared/LpPlayerHubConfirm.razor`
- Store purchase handler / host RPC or service method
- Economy debit integration (existing LP economy path — no new money type)

### Component hierarchy
```text
LpPlayerHubConfirm
  └─ Affirm | Deny pair (Law 14 order: affirm LEFT, deny RIGHT)

Store.Purchase flow:
  Client → request confirm
  Host → debit-before-await → grant entitlement → sync balance
```

### Data contracts
```csharp
record LpPurchaseRequest(string ItemId, long ExpectedPriceLp, long ClientObservedBalance);
record LpPurchaseResult(bool Ok, string Code, long NewBalance, string? Message);
// Codes: Ok | InsufficientFunds | AlreadyOwned | StalePrice | HostRejected | TransientError
```

### Dependencies
- Slice 5 Store
- Economy / wallet service (LAW: debit before await / no optimistic UI)

### Acceptance criteria
- [ ] Debit commits on host before grant await completes
- [ ] UI never subtracts `$LP` optimistically
- [ ] Insufficient / owned / error states match Shared States
- [ ] Confirm-deny order + colors per UI standard
- [ ] Flatgrass proof: buy once, balance + entitlement match

---

## Slice 7 — Unlock (skills spend finalize)

**Goal:** Skill-point unlock transaction with same confirm discipline as purchase (points, not `$LP`).

### Files
- Skills unlock handler / host path
- Reuse `LpPlayerHubConfirm`

### Component hierarchy
```text
Skills.Unlock → Confirm → Host.TrySpendSkillPoints → Rank++
```

### Data contracts
```csharp
record LpSkillUnlockRequest(string NodeId, int ExpectedRank, int ExpectedCost);
record LpSkillUnlockResult(bool Ok, string Code, int RemainingPoints, int NewRank);
```

### Dependencies
- Slice 4 Skills
- Slice 6 confirm primitive (reuse)

### Acceptance criteria
- [ ] Cannot spend `$LP` on skills
- [ ] Host rejects stale rank/cost
- [ ] Badge count on sidebar updates
- [ ] Flatgrass proof: unlock one node

---

## Slice 8 — Live data

**Goal:** Replace stubs with live player progress, wallet, catalog, and skill graph; harden empty/error/loading.

### Files
- `Data/ILpPlayerHubData.cs` implementations
- Binding from gamemode / addon services
- Shared Empty / Error / Loading panels

### Component hierarchy
```text
ILpPlayerHubData
  ├─ GetShellAsync / Subscribe
  ├─ GetOverview / GetStats / GetSkills / GetStore
  └─ Purchase / Unlock commands (Slices 6–7)
```

### Data contracts
- All prior VMs become live projections
- Loading / Error envelopes:
```csharp
record LpHubLoadState(bool Loading, string? ErrorCode, string? ErrorMessage);
```

### Dependencies
- Slices 1–7
- Pending Inputs from design spec must be ruled or explicitly stub-labeled

### Acceptance criteria
- [ ] No stub constants in play path
- [ ] Shared States: loading, empty, error, offline-ish host reject
- [ ] Deep-links still match destination (Law 16)
- [ ] Full hub flatgrass smoke: open → each tab → one purchase → one unlock
- [ ] `Validate-SboxRazorScss.ps1` clean on touched panels

---

## Sequencing / stop points

```text
1 Shell → 2 Overview → 3 Stats → 4 Skills → 5 Store → 6 Purchase → 7 Unlock → 8 Live data
```

Each slice: implement → compile → play proof → owner GO before next.  
Parking: anything outside these eight slices → `BACKLOG_PARKING_LOT.md`.
