# LIFEPUNCH™ — Weapon Implementation Law

**June 2026** — Foundational law for every LifePunch weapon on DXRP/s&box.

> **Never think "gun model". Think "weapon platform".** The mesh is ~10% of the weapon. The rest
> is skeleton, attachments, particles, sounds, animations, state machines, and upgrade hooks.

**Sibling law (entities / props):** `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` — machines, not props.

**Intake naming:** `WEAPON_INTAKE.md` · **FP rig integration:** `VIEWMODEL_RIG_PIPELINE.md` ·
**Mass-production queue:** `WEAPON_MASS_PRODUCTION.md` · **Staging:** `lpweapons/{slot}/assets/`.

**Active workstream note:** `ACTIVE_WORKSTREAM.md` gates **bitcoin** production. Weapons are a
**parallel track** (`lpweapons`, quarantined `ak47` on `lane/ak47`) — still follow this law when
any weapon work runs.

---

## Mission

A weapon is not a prop with a firing function. It is a **living platform**:

```text
Mesh
 → Skeleton
 → Attachments
 → Animation
 → Particles
 → Sounds
 → Gameplay (DXRP Equipment / WeaponComponents)
 → Upgrade systems (P4–P5)
```

**DXRP integration:** Clone the **class reference** prefab plumbing (`w_*` / `vm_*`, shipment,
Gun Dealer market). Platform law governs what you **author in ModelDoc** and **hang on the prefab** —
not a fork of DXRP's generic shipment/drop pipeline.

---

## Platform stack (build order)

| Layer | Author in | Verify |
|-------|-----------|--------|
| Mesh | ModelDoc / Blender export | P0 scale |
| Skeleton | ModelDoc bones | P1 moving parts |
| Attachments | ModelDoc attachment nodes | P0 list complete |
| Collision | ModelDoc convex hulls | P0 multi-hull |
| World prefab | `equipment/w_*` | Physics + hold |
| Viewmodel prefab | `equipment/vm_*` | FP + TP parity |
| Animgraph / sequences | ModelDoc + DXRP template | P1 required set |
| Effects / audio | Prefab children on attachments | P1 origins |
| State machine | Weapon C# + anim layers | P3 |
| Modularity | Attach nodes, not baked mesh | P2 |

---

## P0 — Scale

Verify dimensions against **citizen** (~64–72u tall reference).

Weapons must feel believable in **first person** and **third person**.

| Check | Pass when |
|-------|-----------|
| Overall length | Matches class (rifle vs pistol vs SMG) |
| Grip position | Hands align on `left_hand` / `right_hand` |
| Barrel / muzzle | `muzzle` attachment at bore exit |
| Magazine size | `magazine` bone/node matches mag mesh |
| World vs VM | Same logical dimensions; TP may be lower poly |

**Law:** No gameplay tuning until P0 scale is signed off (screenshot + citizen comparison).

---

## P0 — Collision

**Never** use a single box collider as the finish line.

Use **multiple convex hulls** in ModelDoc:

| Rifle example | Pistol example |
|---------------|----------------|
| stock | slide |
| receiver | frame |
| handguard | magazine |
| magazine | grip |
| grip | barrel |
| suppressor (if present) | — |

Physics must match visible geometry. Phase 1 may use a documented **box baseline** — track swap in
`TECH_DEBT.md` (**WEAPON-01**).

---

## P0 — Attachment points

Every weapon exposes these ModelDoc / prefab origins (omit only when class-impossible — document why):

```text
muzzle
shell_eject
magazine
left_hand
right_hand
sight
laser
flashlight
stock
foregrip
suppressor
charm
camera_ads
camera_idle
camera_reload
camera_inspect
```

Use for: muzzle flash, casings, smoke, laser beam, optic mount, ADS camera, reload camera, charm hook.

**Valve / Source 2 near-universal minimum:**

```text
muzzle · shell_eject · magazine · camera · left_hand · right_hand
```

---

## P1 — Bones

Moving parts animate independently — **never** fake with texture animation.

| AR-15 | AK-47 |
|-------|-------|
| bolt | bolt |
| charging_handle | charging_handle |
| trigger | trigger |
| magazine | magazine |

Additional bones as needed (selector, safety). Author in ModelDoc; skin mesh to skeleton.

---

## P1 — Animations (required set)

| Category | Sequences |
|----------|-----------|
| Locomotion | idle, walk, run |
| Combat | fire, dry_fire |
| Reload | reload, reload_empty |
| Equip | draw, holster |
| Inspect | inspect |
| ADS | ads_enter, ads_idle, ads_exit |
| Malfunction | jam, unjam |

**Integration:** Bind to DXRP class animgraph where possible (`VIEWMODEL_RIG_PIPELINE.md`). Missing
sequences block ship — track in weapon required report.

---

## P1 — Effects

| Effect | Origin attachment |
|--------|-------------------|
| Muzzle flash | `muzzle` |
| Shell ejection | `shell_eject` |
| Smoke | `muzzle` |
| Heat distortion | `muzzle` |
| Sparks | optional / `muzzle` |

Never spawn from mesh center or root transform.

---

## P1 — Audio

Minimum event hooks (own or class-placeholder until replaced):

```text
fire · dry_fire · reload · magazine_out · magazine_in · bolt_release
inspect · draw · holster · suppressed_fire · unsuppressed_fire
indoor_reverb · outdoor_reverb (or RTPC / mix bus)
```

Wire origins to `muzzle`, `shell_eject`, or weapon root per DXRP sound component pattern.

---

## P2 — Magazines

Magazine = **separate object** (mesh + bone + optional prefab child).

Support path for:

- drop animation
- empty magazine
- extended / drum variants
- future skins

Never merge mag into receiver mesh if it must drop or swap.

---

## P2 — Modularity

Attachments mount on **nodes** — never baked into base mesh:

| Slot | Examples |
|------|----------|
| Optics | red dot, holographic, scope |
| Rail | laser, flashlight |
| Muzzle | suppressor |
| Furniture | stock, grip |
| Mag | extended mag |

Each attachment = own vmdl/prefab + snap to named attachment.

---

## P3 — State machine

Weapon-readable states (visual + audio + anim layer):

```text
IDLE · SPRINT · ADS · FIRE · RELOAD · EMPTY · JAMMED · INSPECT
LOW_AMMO · HOLSTERED · BROKEN
```

Map to DXRP weapon states where they exist; extend with LifePunch components when needed.

---

## P3 — First person

| Requirement | Law |
|-------------|-----|
| Mesh quality | High detail acceptable on VM |
| Materials | Full PBR on FP |
| Hands | Separate hand rig or shared arms bind (`VIEWMODEL_RIG_PIPELINE.md`) |
| Cameras | `camera_idle`, `camera_ads`, `camera_reload`, `camera_inspect` |

---

## P3 — Third person

| Requirement | Law |
|-------------|-----|
| Mesh | Simplified / lower poly OK |
| Animation | TP animgraph drives hold pose |
| Hands | Correct grip on `left_hand` / `right_hand` |

World model (`w_*`) drives dropped pickup + shipment crate preview.

---

## P4 — Damage / condition variants (gameplay hooks)

Plan data slots for:

```text
normal · suppressed · overheated · broken · dirty
police_issue · illegal_mod
```

Implementation may lag P0–P3 — document in weapon required report as **planned**.

---

## P5 — Future systems (design only — not ship gates)

```text
serial numbers · skins · wear · condition · attachment registry
weapon licenses · police evidence · black market mods
crafted suppressors · rare variants
```

Track ideas in briefs / `BACKLOG_PARKING_LOT.md` — do not block P0 mesh on P5 scope.

---

## Prefab hierarchy (example — AR-15)

```text
AR15 (Equipment root)
├── Mesh (world or VM renderer)
├── Collision (convex sync)
├── Bolt Bone / component
├── Charging Handle Bone
├── Magazine Bone
├── Trigger Bone
├── Muzzle Attachment → MuzzleFlashParticle, FireAudio
├── Shell Eject Attachment → ShellCasingParticle
├── Laser Attachment
├── Flashlight Attachment
├── Suppressor Attachment
├── Sight Attachment
├── Camera ADS / Reload / Inspect (VM)
├── Smoke Particle
└── Gameplay (WeaponComponents — clone class reference)
```

AK-47: same shape — swap bone names only where mesh differs.

---

## Required report (every weapon)

Before ship or portal export, produce **`{ident}/docs/WEAPON_PLATFORM_REPORT.md`** (or section in
`WEAPON_BUILD.md`) with:

| Field | Content |
|-------|---------|
| Triangle count | FP mesh · TP/world mesh |
| Material count | FP · world |
| Attachment list | All P0 nodes — present / planned / N/A |
| Animation list | P1 set — present / class-borrowed / missing |
| Collision bodies | Hull count + notes |
| Bone list | Moving parts |
| Sound origins | Event → attachment |
| Particle origins | Effect → attachment |
| Optimization | LOD plan, TP simplification, texture sizes |
| P0 sign-off | Owner screenshot reference |

**Output bar:** Weapon feels like a **mechanical platform**, not a static mesh with `Shoot()`.

---

## ModelDoc first

**Primary resource:** [s&box Model Editor (ModelDoc)](https://sbox.game/dev/doc/editor/model-editor)

Author here: bones, hitboxes, attachment points, muzzle origins, animation graphs, convex collision.

**Study references:**

- Facepunch shipped weapon prefabs + `citizen.vmdl`
- DXRP class weapons (`m4a1`, `usp`, `mp5`, `m700`, …)
- On-disk template: `v_m700` (+ export-as FBX per `VIEWMODEL_RIG_PIPELINE.md`)

**Staging paths:**

```text
Assets/addons/lifepunch/lpweapons/ar15military/assets/source/fbx/
Assets/addons/lifepunch/lpweapons/ar15military/assets/models/
```

ModelDoc Studio: `Start-SboxModelDocStudio.ps1` with `-Package lpweapons`.

---

## Official references

| Topic | URL |
|-------|-----|
| s&box docs | https://sbox.game/dev/doc |
| ModelDoc | https://sbox.game/dev/doc/editor/model-editor |
| Components | https://sbox.game/dev/doc/scene/components/ |
| ModelDoc intro (video) | https://www.youtube.com/watch?v=1-L8BvNAbjQ |

---

## Related repo docs

| Doc | Role |
|-----|------|
| `WEAPON_INTAKE.md` | File naming + import checklist |
| `VIEWMODEL_RIG_PIPELINE.md` | FP arms bind + m700 template |
| `WEAPON_MASS_PRODUCTION.md` | 5-class production queue |
| `WEAPON_PROGRAM.md` | Strategy / Gun Dealer shipments |
| `DXRP_CLASS_WEAPON_REFERENCES.md` | Class prefab clones |
| `docs/lanes/AK47_LANE.md` | Quarantined FP experiment |
| `TECH_DEBT.md` | Baselines vs endgame (WEAPON-*) |
| `PACKAGE_STAGING_LAYOUT.md` | `lpweapons` tree |
