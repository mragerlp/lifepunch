# CORNERMAN IDLE — U1.1 proof prep + U2 catalog audit (read-only)

- **Route tag:** GREEN DEEP REQUIRED (distill / audit only)
- **Owner:** Bloodwave — away 1–2h on full-time job work
- **Mode:** Read-only prep · **no code · no commits · no push · eyes covered**
- **Monorepo HEAD (VENGEANCE):** `3d273af` — `bitcoin(ui): U1.1 Servers legacy hardware X/4 readout, remove fake track levels`
- **Prior:** `fe5457c` — U1 Servers read-only + hub overview SCSS + hub logs bootstrap

## Gate (do not cross)

| Allowed | Blocked |
|---------|---------|
| Read repo, distill, audit, draft docs in `outbox/` | U2 implementation |
| Pre-fill Codex proof packet (code evidence) | Prices, purchases, RPCs, persistence |
| Flag stale canon vs code | CPU/Core migration |
| CRT `upgrade cpu/cores` reachability audit (read-only) | Touch `LpBitcoinEconomy.cs`, rack/hub entities, Terminal gameplay |
| Recommend doc reconciliation targets | `git push origin main` |

**U2 fully blocked** until Bloodwave flatgrass proof + Codex PASS + owner acceptance.

---

## Step 0 — Sync (Green clone)

```powershell
cd C:\Projects\lifepunch
git fetch
git pull --rebase
git log -1 --oneline
git status -short
```

If dirty or cannot fast-forward: **stop and report** in outbox only.

---

## Task A — Pre-fill Codex U1.1 proof packet (code evidence)

**Output:** `C:\lifepunch\cornerman\outbox\U11_PROOF_PACKET_PREFILLED_2026-06-30.md`

Use Architect response format (14 sections). Pre-fill from repo at `3d273af`:

1. Implementation status — **COMMITTED** at `3d273af`
2. Files changed — `LpHashdPanel.razor`, `LpHashdPanel.razor.scss` only for U1.1
3. Removed — `server-detail-tracks` + `@foreach GpuRackUpgradeTracks` + `ServerTrackTierLabel()`
4. Added — `server-detail-legacy` intro, `RackLegacyCpuClockLabel`, `RackLegacyCoreCountLabel`, CPU Clock / Core Count X/4
5. Grep proof — no `OpenRackUpgrades`, `UpgradeCpu`, `GetUpgradeRack` in razor
6. Leave **§7–10 blank** — mark `NEEDS BLOODWAVE STOP → PLAY` for runtime, screenshots, console log

Include exact line citations (file + line range) for removed/added blocks.

---

## Task B — U2 Catalog / Profile Model read-only audit

**Output:** `C:\lifepunch\cornerman\outbox\U2_CATALOG_PROFILE_MODEL_AUDIT_2026-06-30.md`

**Read first:**

- `lifepunch/addons/docs/BITCOIN_UPGRADE_TAXONOMY.md`
- `lifepunch/addons/docs/DECISIONS/DECISION-0010-Universal-Upgrades-Home.md` (if present)
- `lifepunch/addons/docs/CYBER_VISUAL_IDENTITY_DOCTRINE.md`
- `LpHashdPanel.razor` — `HubUpgradeTracks`, `TerminalUpgradeTracks`, `GpuRackUpgradeTracks`, tier shell helpers

**Owner tier semantics (record, do not implement):**

- T0 = Base (player-facing: **Base**, never "Tier 0")
- Purchased ladder: Tier I … Tier V
- Future prices: $10k / $25k / $50k / $75k / $100k (U2 planning only)

**Deliver in audit:**

1. Table: each track × surface (Hub / Terminal / GPU Rack) × current UI shell label × TierOneLabel × HwTiers[0..3] names
2. Gap list: what exists as UI shell only vs what would need `[Sync]` / economy / persistence in U3+
3. Legacy mapping note: `CpuUpgradeLevel` / `CoreUpgradeLevel` on rack today → future **Compute Profile** single track (migration = U3, not U2)
4. Stale canon flags — e.g. `BITCOIN_UPGRADE_TAXONOMY.md` §Rack still says "Purchased from Servers"
5. **ONE** recommended U2 slice scope (data model + display only, no purchases) — for Architect review, not implementation

Label every finding: VERIFIED FROM REPO | VERIFIED FROM CANON | INFERRED | NEEDS RUNTIME | OWNER DECISION.

---

## Task C — Residual purchase path audit (read-only)

**Output:** section inside Task A or separate `C:\lifepunch\cornerman\outbox\U11_RESIDUAL_PURCHASE_PATHS_2026-06-30.md`

Grep monorepo (lpbitcoin + bitcoinmining):

- UI: `UpgradeCpu`, `UpgradeCores`, `OpenRackUpgrades`, `RequestUpgradeCpu`
- Terminal CRT commands: `upgrade cpu`, `upgrade cores`
- Document each path: **UI removed** vs **backend/CRT still live** vs **dead code**

No fixes — report only.

---

## Task D — Optional (time permitting)

- Draft 5-line **Bloodwave flatgrass proof checklist** (checkbox markdown) for paste after play
- List `BITCOIN_UPGRADE_TAXONOMY.md` + `BITCOIN_REFERENCE_IMPLEMENTATION.md` sections needing GO DOCS reconciliation post-U1.1 (no edits)

---

## Session end

- [ ] Both primary outbox files written
- [ ] `git status` clean on Green clone
- [ ] **No commit, no push**
- [ ] Ping VENGEANCE: outbox paths + 3-bullet summary for Bloodwave return

**Cornerman's eyes are covered** — no playtest claims.
