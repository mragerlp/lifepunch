# Fab model manifest — owner template (Jun 2026)

Paste this table into chat (or fill in OneDrive) when your Fab list is ready. **Links + intended role** are enough — agent maps each row to repo entity + intake script.

**Law:** game **code stays intact**. Only `models/.../source/`, vmdl import, vmats, and optional `lcd_screen` nudge change. Prefab keeps entity components, Rigidbody, BoxCollider, networking.

---

## Manifest (copy and fill)

| # | Fab URL | Intended entity / role | New or replace? | Notes |
|---|---------|------------------------|-----------------|-------|
| 1 | https://fab.com/... | bitcoin-terminal | replace | CRT ops console |
| 2 | https://fab.com/... | bitcoin-miner hub | replace | hashd control station |
| 3 | https://fab.com/... | hacker-terminal | replace | |
| 4 | https://fab.com/... | advanced-hacker-terminal | replace | |
| 5 | https://fab.com/... | server-rack | replace | |
| 6 | https://fab.com/... | advanced-server-rack | replace | |
| 7 | https://fab.com/... | government-server-rack | replace | FBI lane |
| 8 | https://fab.com/... | police-terminal | replace | |
| 9 | https://fab.com/... | black-market-hub | replace | |
| 10 | https://fab.com/... | *(new — describe)* | **new** | agent says possible / not / defer |
| … | | | | |

**GPU racks:** leave blank unless you find a replacement — current art gets **collision-only** fix (no Fab row required).

---

## Per row after download

When files are on disk, add:

```text
Row #: 3
Local path: C:\Users\...\OneDrive\Desktop\lifepunchaddons\lifepunchhacker\hacker\hackerterminal
FBX: source/Whatever.fbx
```

Agent responds with: entity slug → prefab path → **code unchanged** confirmation → Phase 1 plan.

---

## What stays intact (never replaced in a model swap)

| Layer | Location | Swap? |
|-------|----------|-------|
| Entity logic | `Code/Addons/lifepunch/<addon>/` | **No** |
| Razor UI | `*.razor`, `*.scss` | **No** |
| Economy / sync / RPC | `LpBitcoin*`, `Hacker*`, etc. | **No** |
| Prefab GUIDs + components | `HealthComponent`, `Rigidbody`, `BoxCollider`, entity script, `lcd_screen` | **Keep** — tune transforms only |
| `addons.json` slugs | `config/addons.json` | **No** (unless **new** entity you approve) |
| Portal / ident paths | `LpBitcoinIdent`, `HackerJob` constants | **No** |

## What changes (prop layer only)

| Layer | Swap? |
|-------|-------|
| `models/.../source/*.fbx` | **Yes** |
| `.vmdl` import scale / rotation / origin | **Yes** (ModelDoc) |
| `materials/*.vmat` + textures | **Yes** |
| `ModelRenderer.Model` on prefab | **Yes** (path usually unchanged) |
| `BoxCollider` Center/Scale | **Re-baked** from `model.Bounds` (all axes) |
| Fan child GOs / anim | **Phase 2 only** after Phase 1 sign-off |

---

## Fab-specific rules (LifePunch ship)

- **Self-contained:** textures + materials in addon `Assets/` — no Fab cloud mount at runtime (`RestrictCloudOrg = facepunch`).
- **Export:** FBX binary preferred; note if rigged / animated (we default to **static body + code spin** for fans unless you want otherwise).
- **Scale:** prefab root always `1,1,1`; tune `import_scale` once per vmdl (see `MODEL_SCALE_DOCTRINE.md`).
- **Duplicates:** if Fab asset ≈ mesh already in repo, still re-run Phase 1 on fresh export — do not skip collision.

---

## New entities (your “might be cool / complicated” rows)

Agent will reply per row before building:

| Question | Outcome |
|----------|---------|
| Same pattern as existing terminal/rack? | Wire to existing entity template + new prefab slug |
| Needs new gameplay systems? | **Possible** — scoped Opus pass; not same-day as mesh swap |
| Animated rig / destructible / vehicle? | Feasibility + TECH_DEBT entry before commit |
| Cloud-only / no FBX export? | **Not shippable** on DXRP — pick different Fab asset |

---

## Phase order (every asset, no exceptions)

1. **Phase 1** — white wireframe = BoxCollider on **X, Y, Z**; feet on floor; no walk-through  
2. **Phase 2** — fans, LEDs, screen text alignment  
3. **Phase 3** — polish, donor skins, sounds  

Cross-ref: `MODEL_INTAKE_DROP_MAP.md`, `BITCOINMINING_PROP_BASELINE.md`, `ASSET_INTAKE_CYBER_ECOSYSTEM.md`.

---

## Agent ack when list arrives

For each Fab row the agent will:

1. Confirm **entity slug** + **code file** that stays attached  
2. Flag **new vs replace** and **possible / defer**  
3. Intake FBX → compile → Phase 1 → ask you to sign off prefab wireframes  
4. Never delete or rewrite entity/UI code unless you explicitly ask for a **new feature**
