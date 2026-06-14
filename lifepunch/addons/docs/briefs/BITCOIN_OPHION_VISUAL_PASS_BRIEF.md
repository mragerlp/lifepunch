# VISUAL PASS BRIEF — lifepunch.bitcoin (Ophion P0)

**Source:** ChatGPT LIFEPUNCH™ Step 1b · **Verdicts:** Bloodwave June 2026 · **Package:** `lifepunchbitcoin` / `lifepunch.bitcoin`

---

## Product

| Field | Value |
|-------|-------|
| Product | Bitcoin Miner |
| Addon ident (s&box) | `lifepunch.bitcoin` |
| Priority | P1 — Ophion hub visual pass (criminal-lane centerpiece) |

**Reference mood:** Industrial crypto warehouse — the player’s **trophy operations center**. Black steel, cable clutter as earned scale, blue-white rack LEDs when live, amber HASHD when USE opens the hub. Same world as green `cornerman.exe`, red `vengeance.exe`, cyan `lifepunch-ops.exe` — **bitcoin keeps HASHD amber only**.

---

## Visual hierarchy (law)

The **room tells the story before USE**. Read order:

```text
Hub silhouette → rack wall → amber HASHD (on USE) → cable clutter → LEDs/fans
```

**Not:** UI panel → terminal screen → menus first.

---

## MUST READ IN-GAME (P0)

- Hub scale vs citizen on `facepunch.flatgrass` (~30″ class hub vs ~77″ citizen; not dollhouse, not building).
- Ophion silhouette at 10m — glass/acrylic sides, GPU face, cable mass.
- Material truth — GPU, wire weave, plates, acrylic; no single flat chassis.
- Powered vs off unmistakable (emissive + audio OK; fan/LED vmdl anim = Phase 2).
- Rack family — small + large GPU racks; emissive when mining; `complex.shader` baseline.
- HASHD `#f0a500` / `#12100c` on USE — no green/red/cyan contamination.
- Criminal-infra read — not hacker CRT, not police treasury.

---

## SPAWN / MAP PROOF

| Purpose | Command |
|---------|---------|
| Map | `lp_map_flatgrass` from **`scenes/game.scene`** play mode |
| **Hero composition (P0 sign-off)** | `lp_spawn_bitcoin_miner_hub` — hub + 3 small + 1 large rack |
| Scale documentation only | `lp_spawn_bitcoin_miner_hub_only` |
| Power skip (staging) | `lp_hub_power 1` |

**Never** proof from prefab tabs or saved test scenes.

---

## Owner verdicts (open questions closed)

| # | Verdict |
|---|---------|
| Hero composition | **Full kit** sells criminal-infrastructure fantasy. Hub-only = scale doc only. |
| Rack LEDs / shader | **`complex.shader` baseline** for P0 — reliability over RGB experiment. |
| Hub animation | **Emissive + audio** sufficient for P0 if power state is unmistakable. Fan/LED vmdl anim → Phase 2. |
| Integrated monitor mesh | Nice if it reinforces HASHD **without** material/remap risk. **Canonical UX:** USE → full-screen HASHD. |
| Scale | `0.77` / Z `26.6` internally consistent. **Top risk:** regressing to dollhouse `0.385` pass — not fine-tuning 0.77 vs 0.80. |

---

## Highest-risk P0 failures (Cursor review gate)

1. Material slot collapse → Ophion renders as one uniform chassis.
2. Acrylic side panels read opaque.
3. Wrong color family (hacker green, gov cyan, vengeance red on bitcoin surfaces).
4. Hub appears permanently powered regardless of state.
5. Proof captured from prefab/editor context instead of flatgrass play spawn.

---

## MATERIAL / MODEL NOTES

- Hub: `bitcoin-miner.vmdl` / `Ophion.fbx` — see `MODEL_BUILD.md` (import scale `0.77`, Z `26.6`).
- Remap chain: FBX slot → vmdl → vmat → textures; unmapped = P0 fail.
- Glass: `Side Panels` → acrylic, not chassis.
- Racks: `gpu-rack.vmdl`, `gpu-rack-stacked.vmdl` — emissive baseline; no long-term placeholder child-fan spin.

---

## OUT OF SCOPE (this pass)

- Shippable C# / economy / RPC changes.
- Hacker, government, banker meshes.
- Phase 2 module menu redesign.
- Hardware shop, generators, multi-room tiers, portal publish.
- `lifepunch_rgb_fan_led.shader` until post–P0 sign-off.

---

## MCP ROUTING

| Step | MCP | Deliverable |
|------|-----|-------------|
| 1 | `sbox-editor` | Hub + rack compile clean; remap audit; pull `_c` |
| 2 | `sbox` | Play `game.scene` → `lp_map_flatgrass` → `lp_spawn_bitcoin_miner_hub` |
| 3 | `sbox` | Orbit screenshot — **full kit** hero + citizen scale |
| 4 | `sbox` | `lp_spawn_bitcoin_miner_hub_only` — scale doc screenshot |
| 5 | `sbox` | Power on/off + mining — state unmistakable (LED/emissive/audio) |
| 6 | `sbox` | USE hub — HASHD amber UI (secondary to room story) |

---

## Related

- `BITCOIN_OPHION_CURSOR_BRIEF.md` — product + loop
- `LIFEPUNCH_BITCOIN_START.md` — session kickoff
- `LIFEPUNCH_CYBER_ECOSYSTEM.md` — criminal lane context
- `bitcoin-miner/MODEL_BUILD.md` — import law
