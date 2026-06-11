# Cornerman task — Bitminer three-entity architecture + remote rack UX

**Lane:** Tier-3 prep · **Priority:** **#2** (after AK47 study; bump Hacker Job if owner says so)  
**Issued:** 2026-06-11 · **Red:** implements prefabs + registry on VENGEANCE  
**Owner ask:** Three **separate** placeables — Terminal controls racks remotely; owner needs to **see** what hashd console looks like and how the system fits together.

**You do NOT:** edit ship C#, ModelDoc, or `git push`.

---

## Goal

Distill the **owner-canon** architecture (terminal + small miner + advanced miner) and spec how the **hashd console** manages multiple racks. Correct obsolete docs that put both racks on one `bitcoin-miner` prefab.

**Read first:** `docs/reference/BITMINER_THREE_ENTITY_ARCH.md`

---

## Task 1 — System map (1 page)

Append to `docs/reference/BITMINER_THREE_ENTITY_ARCH.md` or create `docs/reference/BITMINER_REMOTE_RACK_SPEC.md`:

1. **Entity table** — slug, mesh, `BitminerEntity` variant?, yield role.
2. **Placement rules** — e.g. terminal within 4–8 m of racks to register; multiple racks per terminal?
3. **Data flow** — terminal START → which RPC on which rig; balance stored per-rig vs pooled at terminal.

Mark uncertain values `TBD — Red playtest`.

---

## Task 2 — hashd console UX (remote racks)

Extend `BITMINER_UX_SPEC.md` or Phase 2 wireframe with:

### Telemetry rail (left column)

When multiple racks registered, show:

```text
RACKS   2 linked (1× SMALL · 1× ADVANCED)
ACTIVE  rig-0 SMALL · MINING
        rig-1 ADVANCED · IDLE
```

### New CLI commands (spec only)

| Command | Behavior |
|---------|----------|
| `racks` | List registered rigs + id + type + mining state |
| `select <id>` | Set active rig for upgrades / status |
| `mining start [id]` | Start one rack or all |
| `mining stop [id]` | Stop one rack or all |

### Upgrade panel

- CPU/CORES apply to **selected rig** or **terminal host CPU**? Propose one model; justify in 2 sentences.

---

## Task 3 — Advanced miner prefab wireframe

ASCII hierarchy for `entities/advanced-bitcoin-miner/advanced-bitcoin-miner.prefab`:

```text
advanced-bitcoin-miner
├── ModelRenderer  → gpu-rack-stacked.vmdl
├── BitminerEntity (or AdvancedBitminerEntity?)
└── fan placeholders → deprecate when stacked anim ships
```

Note ModelDoc steps for `gpu-rack-stacked.vmdl` (reuse `gpu-rack-*.vmat` remaps from `BITMINER_DUAL_RACK_SPEC.md`).

---

## Task 4 — Doc hygiene

Update these to **three-entity** language (no `computer_terminal` child on rack):

| File | Change |
|------|--------|
| `briefs/BITMINER_DUAL_RACK_BRIEF.md` | Strike §Prefab “both racks on bitcoin-miner”; point to three-entity arch |
| `reference/BITMINER_DUAL_RACK_SPEC.md` | §Prefab hierarchy → three prefabs |
| `ASSET_INVENTORY.md` | Add `advanced-bitcoin-miner` row; terminal “control station”, not “on rig” |

---

## Task 5 — Owner visibility cheat sheet

Add subsection **“What the player sees”** to arch doc:

1. **World:** CRT computer (when vmdl compiled) + 0–N GPU racks placed nearby.
2. **Overlay:** Green/amber hashd panel (`BitminerTerminal.razor`) — this is the real console.
3. **LCD:** Amber `TextRenderer` on monitor — summary only.
4. **Playtest:** `lp_hashd_preview` → instant console without fixing CRT mesh.

---

## Task 6 — RAG outbox

Copy completed spec to `C:\lifepunch\cornerman\outbox\`.

---

## Commit + ping

```text
docs(bitcoinmining): three-entity arch + remote rack hashd UX distill
```

Ping Red: `three-entity spec on Green — terminal hub, advanced miner prefab wireframe, racks CLI`
