# LifePunch Weapon Program — Vision & Strategy

The "why" and "in what order" layer. Pair this with `WEAPON_CLASS_SPEC.md` (the "how to
build one" mechanical layer). **Platform law:** `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md`. Read this first.

Verified against DXRP source 2026-06-04 (`ShipmentEntity.cs`, `GameModeMarketItems.cs`,
the `w_*`/`vm_*` weapon prefabs).

---

## 1. The goal

DXRP has a **Gun Dealer** job. Its exclusive market items are **shipments** — a crate of
**5 guns** of one kind. DXRP ships 5 base weapons, one per class:

| Class | DXRP base weapon |
|-------|------------------|
| Handgun | USP |
| Sub Machine Gun | MP5 |
| Sniper Rifle | M700 |
| Semi-Auto Shotgun | Spaghelli *(no pump-shotgun exists in DXRP)* |
| Assault Rifle | M4A1 |

**The program: ship 5 LifePunch weapons — one mirroring each class — with our own models
and sounds.** The AK-47 is the **Assault Rifle** entry (mirrors M4A1) and is weapon #1.

It is **not 1+1**. "Paste a model/sound over the existing one" undersells it: 47 revisions
and a week went into the AK. The point of this doc is to make sure that cost was **discovery
paid once**, not the per-weapon price.

---

## 2. The reframe that makes this tractable

**The shipment / Gun-Dealer pipeline is generic and reused for free.** We do NOT build a
shipment, a dropped-pickup, or a buy-menu per weapon. Proven in source:

- `shipment.prefab` is **one class-agnostic crate**. At runtime `ShipmentEntity` calls
  `equipment.GetWorldModel()` and renders *whatever* weapon you point it at (bob + rotate).
- On use it spawns `DroppedEquipment` of that equipment. Dropped pickup = world model again.
- Appearing in the Gun Dealer menu is **pure config**: `Config.GameMode.MarketItems` — each
  entry has `ReferenceId` → an equipment, `Quantity` (5 = shipment), and
  `WhitelistJobIds`/`WhitelistJobTags` (the Gun-Dealer-only gate).

### So the true per-weapon unit of work (the "class kit")

| # | Piece | Where | Notes |
|---|-------|-------|-------|
| 1 | **World model** `w_*.vmdl` (static) | repo | 3rd person. Tune grip offset vs class reference. |
| 2 | **Viewmodel** `vm_*`/`v_*` | repo | 1st person. **BLOCKED** (FP source not shipped) → clean class placeholder now. |
| 3 | **Functions** | repo | ammo/shoot/reload/recoil/sounds — copy from class, retune values. |
| 4 | **Addon content row** | repo (`addons.json`) → **publish** | `PrimaryReference` (prefab), `WorldModelPath`, `Name`/identifier, `Grouping`, `IconPath`. |
| 5 | **Equipment** | **DXRP.net portal** | points at the content row; optional name/desc override. |
| 6 | **Market item / shipment** | **DXRP.net portal** | `Type=Equipment`, `ReferenceId`→equipment, **`Quantity=5`** (=shipment), `Cost`, `Grouping`, **`WhitelistJobIds=[Gun Dealer]`**. |

> **Confirmed in source:** the gamemode config (`Equipments`, `MarketItems`, `Jobs`, `Addons`)
> is produced by the portal backend (`GameModeDto.FromEntity` under `#if ASPNETCORE`,
> `ToEntity` → DB) and pulled into `Config.Current.GameMode` at runtime. So **steps 5–6 are
> portal clicks, not code or repo edits.** The repo only publishes the assets + content row
> (step 4); the portal turns it into an Equipment and a Gun-Dealer shipment.

| Reused for free (build **zero** times) |
|----------------------------------------|
| shipment crate · dropped pickup · bobbing preview · buy menu · job/cooldown gating |

**The shipment is `Quantity` on a market item** — `Quantity=1` is a single gun, `Quantity=5`
is the 5-pack crate. Same generic `shipment.prefab`, driven entirely by portal config.

### Why the AK took a week and #2–5 won't

The week was **discovery**, not the kit: the first-person-rig truth, the cloud/third-party-IP
detour, and a publish-to-iterate loop. None recurs. The recurring cost is items 1, 3, 4, 5
above (all unblocked today) plus a one-time FP-rig batch later (item 2).

---

## 3. The strategy

### Phase A — AK-47 = the golden Assault Rifle kit (now)
Finish the AK to perfection as the **reference implementation** every later weapon is copied
from:
- 3rd person world model perfect (correct mesh + tuned grip vs M4A1). ✅ mostly there.
- Functions/sounds matched to the Assault Rifle class. ✅
- **Clean** first-person **placeholder** = a tidy M4A1 viewmodel (drop the empty-hands
  invisible-master setup). Stable + shippable now.
- Verify it registers as an Equipment **and** as a Gun-Dealer market item / 5-pack shipment.

### Phase B — Codify the kit (immediately after A)
Turn the AK into a repeatable template so #2 is copy-paste, not re-derivation:
- A **file scaffold** copied from the AK kit.
- A **per-weapon checklist** of exactly-what-to-change: model paths, sound events,
  equipment identifier, function values, market `ReferenceId`/`Quantity`/whitelist.
- This lives in / extends `WEAPON_INTAKE.md` + `WEAPON_CLASS_SPEC.md`.

### Phase C — Clone the other 4 classes (one at a time)
Each new weapon = pick its class → copy that class's kit → reskin model + sounds → retune
functions → register equipment + market item. Target: **~a day each**, not a week.
- **Sequencing:** do them **one class at a time**, and pick #2 = whichever class you already
  have a clean custom **model + sounds** ready for. (Each is a *different* class/HoldType, so
  doing a non-AR class second is the real test that the template generalizes, not just the mesh.)

### Phase D — First-person rig batch (when Facepunch ships weapon source)
FP custom viewmodels are blocked for **all** classes until Facepunch re-releases the rig
source (see `WEAPON_CLASS_SPEC.md` §4). When it lands: rig each `v_*` to its class skeleton
once → every `vm_*` becomes a 1:1 clone of its class viewmodel. **No wipe, no rework** — the
placeholders swap out into the same clean template.

---

## 4. Definition of "done" (per weapon)

- [ ] World model correct + grip tuned to match the class in 3rd person.
- [ ] First person shows a clean class placeholder (no empty hands, no spaghetti).
- [ ] Functions/sounds tuned and class-appropriate.
- [ ] Registered as an Equipment with a stable identifier.
- [ ] Buyable from the **Gun Dealer** as a 5-pack shipment (market item, job-whitelisted).
- [ ] Dropped pickup + shipment preview render the world model correctly.
- [ ] Verified in editor (design gate) then on Dev server (deployment gate).
- [ ] (Deferred) Custom first-person rig once FP source ships.

Program done = the above true for all 5 classes.

---

## 5. Anti-spaghetti commitments (program level)

- **The shipment/dealer pipeline is generic — never fork it per weapon.** Register config,
  don't clone systems.
- **One class kit per class**, copied verbatim; differences are data (model/sound/values),
  not new structure.
- **Don't fake the FP rig.** Placeholder until source ships; then batch. (No invisible
  masters, passenger renderers, or raw `.vmdl` base-model hacks — both already failed.)
- **Iterate in editor, publish to confirm.** The publish-to-iterate loop is what made #1 cost
  a week.

---

## Authoring location — RESOLVED (2026-06-04)

Traced in source. The gamemode (Equipments, MarketItems, Jobs, Addons+Contents) lives in the
**DXRP.net portal database** and is delivered to the server as `GameModeDto`
(`GameModeDto.FromEntity` / `ToEntity`, `#if ASPNETCORE`). So:

- **Repo** owns: assets + prefabs + the `addons.json` **content row**. Shipped via **publish**.
- **Portal** owns: **Equipment** (→ content row) and **Market item / shipment** (→ equipment,
  `Quantity`, `Cost`, job whitelist). No code, no repo edits.

**Per-weapon flow:** build kit in repo → publish revision → on portal: create Equipment
pointing at the new content row → create Market item (`Quantity=5`, Gun-Dealer whitelist, price).

---

## Mass production (2026-06-10)

Scaffolds for weapons **#2–5** (`deagle`, `mp9`, `ssg08`, `xm1014`) are live. Runbook +
queue table: **`WEAPON_MASS_PRODUCTION.md`**. Config: `config/weapon-production.json`.
Scripts: `scripts/Start-WeaponMassProduction.ps1`, `scripts/New-LifePunchWeapon.ps1`.
