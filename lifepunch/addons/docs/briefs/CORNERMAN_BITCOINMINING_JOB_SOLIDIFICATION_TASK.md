# Cornerman task — Bitcoin Miner job solidification (distill)

**Lane:** Tier-3 prep (distill) · **Priority:** **P1c** (owner brainstorming miner class — parallel P0 hacker)  
**Issued:** 2026-06-12 · **Red:** VENGEANCE ships C#, Market rows, ModelDoc scale  
**You do NOT:** open s&box, ModelDoc, compile, `git push`, or patch C#.

---

## Why this task

Owner locked the **miner as a roleplay class** (not a copy-paste ATM):

- **Bitcoin Miner hub** (`bitcoin-miner` / Ophion) = PIN gatekeeper + hashd + wallet + encryption
- **GPU Rack** + **Advanced GPU Rack** = passive compute linked by proximity + same spawner `Owner`
- **Hackers** crack PIN / breach hub — miners defend with encryption tiers

Red just shipped: owner-matched rack linking, ghost-console PIN veil, gatekeeper flow.  
Your job: **distill player-facing canon**, **audit doc drift**, **draft Market/portal copy**, **recommend purchase model** — so the job feels polished before portal ship.

---

## Read first (in order)

| # | Path | Why |
|---|------|-----|
| 1 | `addons/docs/BITCOINMINING_HUB_ARCH.md` | Hub + rack caps + link rules |
| 2 | `addons/docs/LIFEPUNCH_CYBER_ECOSYSTEM.md` | Miner ↔ hacker loop |
| 3 | `addons/Code/Addons/lifepunch/bitcoinmining/docs/BITCOINMINING_TERMINAL_DOCTRINE.md` | PIN gatekeeper + hashd only on hub |
| 4 | `addons/docs/PHYSICAL_TERMINAL_DOCTRINE.md` | USE entity, no dev console gameplay |
| 5 | `addons/docs/BITCOINMINING_UX_SPEC.md` | Economy + Phase 2 modules |
| 6 | `addons/docs/reference/BITCOINMINING_PORTAL_LISTING.md` | Portal copy starter |
| 7 | `addons/config/addons.json` → `bitcoinmining` contents | Three market entities |
| 8 | `addons/Code/Addons/lifepunch/bitcoinmining/BitcoinMiningAddon.cs` | Display names + paths |

**Skip as primary:** `bitcoin-terminal`, `BITCOINMINING_THREE_ENTITY_ARCH.md` terminal-as-hub rows — mark deprecated where cited.

---

## Task J-1 — Job roleplay one-pager

**Output:** `outbox/BITCOINMINING_JOB_ROLEPLAY_ONE_PAGER.md`

One page a new player / staff member understands:

1. **What you buy** (3 Market items — not one blob)
2. **Setup loop** (spawn hub → PIN → place racks within 8m → power → mine → sell)
3. **Defense loop** (encryption upgrades, PIN length future, hacker threat)
4. **What you never do** (USE a GPU Rack — it's hardware only)
5. **Caps** (2 hubs · 3 small · 1 large per hub)

Use player-facing names: **Bitcoin Miner**, **GPU Rack**, **Advanced GPU Rack** — not slug jargon in body text.

---

## Task J-2 — Purchase model recommendation

**Output:** `outbox/BITCOINMINING_PURCHASE_MODEL.md`

Compare two v1 options (recommend one):

| Model | Flow | Pros | Cons |
|-------|------|------|------|
| **A — Market placeables** | Buy hub + racks separately from DXRP Market | Matches printers/meth lab; physical base building | Three purchases to learn |
| **B — Hub deploy menu** | Buy hub only; hashd spawns racks for cash | One job UI; progression feel | More C#; spawn placement UX |

Owner lean (from Red session): **A for v1 ship**, **B as Phase 2 optional**.  
Document starter kit idea: *"Bitcoin Miner Starter"* market bundle (hub + 1 GPU Rack) — portal-only, no code.

---

## Task J-3 — Stale doc fixlist

**Output:** `outbox/STALE_BITCOINMINING_DOC_FIXLIST.md`

Grep repo `lifepunch/addons` for drift vs hub canon. Flag files that still say:

- `bitcoin-terminal` as control station
- `bitcoin-miner` = small gpu-rack mesh (wrong — Ophion hub)
- `hashd` / `mine` as **player** ConCmds (dev only now)
- `racks` without **GPU Rack** / **Advanced GPU Rack** labels
- Purchase "through terminal" or single entity

Per row: `path` · `line/issue` · `fix one-liner` · `priority P0/P1/P2`

---

## Task J-4 — Market listing draft (3 entities)

**Output:** `outbox/BITCOINMINING_MARKET_LISTINGS_DRAFT.md`

Paste-ready for DXRP portal / gamemode entity rows:

| Entity | Display name | Short description | Suggested price band | Limit per player |
|--------|--------------|-------------------|----------------------|------------------|
| `bitcoin-miner` | Bitcoin Miner | … | TBD | 2 |
| `gpu-rack` | GPU Rack | … | TBD | 3 per hub (note) |
| `advanced-gpu-rack` | Advanced GPU Rack | … | TBD | 1 per hub |

Include **job fantasy** one-liner each (not tech spec). Lead **LIFEPUNCH** per trademark rule.

---

## Task J-5 — Scale verification checklist (for Red ModelDoc)

**Output:** `outbox/BITCOINMINING_SCALE_CHECKLIST.md`

**Critical:** `BoxCollider` ≠ visual mesh. Hub collider Z≈48 can be **wrong** while Ophion reads as a desktop — visual hierarchy must be **Advanced GPU Rack >> GPU Rack >> hub**.

Table Red fills on `facepunch.flatgrass` with bridge bounds:

| Entity | Mesh bounds (visual) | BoxCollider | import_scale | Smallest→largest rank | Action |
|--------|----------------------|-------------|--------------|----------------------|--------|
| Bitcoin Miner hub (Ophion) | measure | 20×20×48 ⚠️ stale? | 1.0 | **3 — smallest** | Shrink collider to desk |
| GPU Rack | measure | ~8.6×12.9×21 | 1.0 | 2 | |
| Advanced GPU Rack | measure | ~52×27×47 | 1.0 | **1 — largest** | |

Law: `MODEL_SCALE_DOCTRINE.md` — prefab root `1,1,1` only; tune `import_scale` once from measured mesh.

Include link range: **8m / 4m** from hub.

---

## Task J-6 — Command naming audit (hashd UI copy)

**Output:** `outbox/BITCOINMINING_UI_NAMING_AUDIT.md`

Red renamed CLI `rigs` (alias `racks`). Audit `HashdTerminal.razor` + help strings for:

- Generic "rack" → prefer **GPU Rack** / **Advanced GPU Rack**
- Empty state copy (Market purchase hint)
- Rail **LINKED** summary format: `2× GPU Rack · 1× Advanced GPU Rack`

List any remaining generic "rack(s)" user-visible strings + suggested replacement.

---

## Deliverables summary

| File | Required |
|------|----------|
| `BITCOINMINING_JOB_ROLEPLAY_ONE_PAGER.md` | Yes |
| `BITCOINMINING_PURCHASE_MODEL.md` | Yes |
| `STALE_BITCOINMINING_DOC_FIXLIST.md` | Yes |
| `BITCOINMINING_MARKET_LISTINGS_DRAFT.md` | Yes |
| `BITCOINMINING_SCALE_CHECKLIST.md` | Yes |
| `BITCOINMINING_UI_NAMING_AUDIT.md` | Yes |

Commit to Green `outbox/` only. Ping Red one line: `OK cornerman bitcoinmining-job-solidification @<sha>`.

---

## Model

**WarmDistill** — no WarmCoder unless SCSS token pass requested later.

---

## References

- Red playtest: `lp_spawn_bitcoin_miner_hub` · `lp_hashd_pin_preview` · `rigs`
- `BITCOINMINING_PLAYTEST.md` §1 physical hub
