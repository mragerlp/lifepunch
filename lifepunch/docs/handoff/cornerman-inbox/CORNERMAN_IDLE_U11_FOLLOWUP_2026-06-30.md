# CORNERMAN IDLE — U1.1 follow-up (read-only, no editor)

- **Route tag:** GREEN DEEP REQUIRED
- **Owner:** Bloodwave — not ready for flatgrass / editor yet
- **Mode:** Read-only · outbox drafts only · **no code · no commits · no push · eyes covered**
- **Assumes:** Tasks A–C from `CORNERMAN_IDLE_U11_PROOF_U2_CATALOG_2026-06-30.md` complete (3-bullet summary delivered)
- **HEAD:** pull latest `main` (expect `8f718a7` inbox brief or newer)

## Gate (unchanged)

No U2 implementation. No economy/RPC/persistence edits. No playtest claims.

---

## Task E — DECISION-0010 tier label diff matrix (U2 input)

**Output:** `C:\lifepunch\cornerman\outbox\U2_TIER_LABEL_RECONCILIATION_MATRIX_2026-06-30.md`

Side-by-side for **all 15 tracks × Tier I–V**:

| Column | Source |
|--------|--------|
| Track name | DECISION-0010 §Full Tier Display Names |
| Tier I–V (canon) | Same section |
| Tier I–V (code) | `LpHashdPanel.razor` — `TierOneLabel` + `HwTiers()` / `CosmeticTiers()` per track |
| Match? | Y / N / partial |
| U2 action | rename shell only / owner decision |

Include **GPU RACK Compute Profile** note: code uses OC vocabulary; canon uses "Tuned Clocks / Performance Profile / …" — flag explicitly.

Add **price stub column** (planning): Tier II $10k … Tier V $100k — display-only, no wiring.

---

## Task F — GO DOCS reconciliation manifest (post-U1.1)

**Output:** `C:\lifepunch\cornerman\outbox\GO_DOCS_U11_RECONCILIATION_MANIFEST_2026-06-30.md`

Grep + read; for each hit document:

1. Path + section heading
2. Stale claim (quote ≤2 lines)
3. Correct replacement (proposed wording — **draft in outbox only**)
4. Priority: P0 (misleading purchase path) / P1 (tier taxonomy) / P2 (historical brief)

**Seed list (expand via grep):**

- `lifepunchaddons/docs/BITCOIN_UPGRADE_TAXONOMY.md` — Servers purchase path
- `lifepunchaddons/Code/.../bitcoinmining/docs/BITCOINMINING_PLAYTEST.md` — `upgrade cpu/cores`
- `lifepunchaddons/Code/.../bitcoinmining/docs/BITCOINMINING_TERMINAL_DOCTRINE.md` — hub RPC upgrades
- `lifepunchaddons/docs/UPGRADE_TIER_STANDARD.md` — CRT upgrade commands
- `lifepunchaddons/docs/BITCOIN_DATA_FLOW.md` — Servers upgrade sub-view
- `lifepunchaddons/docs/reference/BITCOINMINING_REMOTE_RACK_SPEC.md`
- `lifepunchaddons/docs/briefs/BITCOINMINING_PHASE2_WIREFRAME.md`
- `lifepunch/docs/handoff/cornerman-outbox/LPBITCOIN_RESTART_PACKET_2026-06-29_1035.md` — pre-U1 state (mark historical)

**Do not edit repo files.** Bloodwave runs GO DOCS pass after U1.1 Codex PASS.

---

## Task G — Orphan backend disposition brief

**Output:** `C:\lifepunch\cornerman\outbox\U11_ORPHAN_BACKEND_DISPOSITION_2026-06-30.md`

Document live but unreachable paths:

- `LpBitcoinHubEntity.RequestUpgradeCpu/Cores`
- `LpBitcoinRackEntity.ApplyUpgradeCpu/Cores` + wallet charge
- Any dev ConCmd / RPC callers still referencing these (grep full monorepo)

For each, options table (no recommendation unless one is clearly safe):

| Option | Pros | Cons | When |
|--------|------|------|------|
| Leave dormant until U3 | … | … | … |
| `[Obsolete]` + no callers | … | … | … |
| Remove in U3 migration slice | … | … | … |
| Dev-only gate | … | … | … |

Note: Terminal `info` still **displays** `CpuUpgradeLevel` / `CoreUpgradeLevel` — classify as **read-only status**, not purchase.

Owner decision required before any code change.

---

## Task H — U2 catalog data model sketch (planning only)

**Output:** `C:\lifepunch\cornerman\outbox\U2_CATALOG_DATA_MODEL_SKETCH_2026-06-30.md`

No C# in repo. Propose:

1. Static catalog record shape (track id, surface, tier index, display label, price stub, icon key)
2. Where it should live (`LpHashdPanel` static vs shared `LpBitcoinUpgradeCatalog.cs` — recommend one with rationale)
3. How shell reads it (replace inline `UpgradeTrackShell[]` arrays in U2 slice)
4. What stays out of U2 (`[Sync]`, save migration, `TryCharge`, profile persistence)
5. Single **U2 slice definition of done** (display-only, Architect-reviewable)

Label: INFERRED FROM PATTERNS where not canon-locked.

---

## Task I — Optional (time permitting)

- Draft `ARCHITECT_CURRENT_STATE.md` **delta** (5–10 bullets): post-U1.1 Bitcoin upgrades UX — outbox only, do not overwrite repo handoff file
- Update-style draft for `BITCOIN_SHIP_ROADMAP.md`: U1/U1.1 ✅ code complete, blocked on flatgrass + Codex — outbox only

---

## Session end

- [ ] Primary outputs: E + F (minimum); G + H if time
- [ ] 3-bullet summary for Bloodwave (new findings only — do not repeat A–C bullets)
- [ ] No commit, no push

**Cornerman's eyes are covered.**
