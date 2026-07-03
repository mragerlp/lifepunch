# LIFEPUNCH™ — Digital Machine Standard

**June 2026** — Foundational law for every LIFEPUNCH entity on DXRP/s&box.

> **Never think "prop". Think "machine".** The visual mesh is one layer. Collision, attachments,
> lights, sounds, moving parts, states, and gameplay components are the product.

**Sibling law (weapons):** `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` — weapon **platform**, not gun mesh.

Aligns with `CYBER_REFERENCE_LAWS.md` (Law 2 hub/terminal/rack roles, Law 6 machine states) and
`LIFEPUNCH_HUB_PATTERN.md`. ModelDoc intake: `MODEL_FOUNDATION_PASS.md` · staging:
`PACKAGE_STAGING_LAYOUT.md` · editor lane: `MODELDOC_STUDIO_LANE.md`.

---

## Entity stack (build order)

Every LIFEPUNCH object is a **hierarchy of systems**, not an imported mesh:

```text
Model (ModelDoc — mesh, materials, LODs)
 ↓
Collision (convex hulls in ModelDoc — not one giant cube)
 ↓
Physics (rigid body / prop rules on prefab)
 ↓
Attachments (fan_*, screen, led_*, btc_insert, smoke_top, …)
 ↓
Lights (PointLight components — not baked emissive-only)
 ↓
Animations (fan_spin_*, door_*, screen_boot — separate takes / child GOs)
 ↓
Sounds (idle, startup, alarm — timed to state)
 ↓
State machine (OFF → BOOTING → RUNNING → …)
 ↓
Gameplay component (hub / terminal / rack C#)
```

**Agents:** ModelDoc + mesh sign-off comes **first** (`MODEL_FOUNDATION_PASS` row 10). Prefab
hierarchy and components come **after** mesh is correct. Gameplay C# last (or quarantined reference
until promotion from `lp*/{entity}/code/`).

---

## 1. ModelDoc first

**Primary resource:** [s&box Model Editor (ModelDoc)](https://sbox.game/dev/doc/editor/model-editor)

ModelDoc replaces QC-style authoring. Use it for:

- collision hulls (multiple convex pieces)
- attachments
- bones / hitboxes (when needed)
- physics shapes
- materials / LODs
- animation nodes (import takes separately — do not rig fan spin into body mesh)

**Study references:** `citizen.vmdl`, Facepunch weapon models (engine examples).

**LifePunch workflow:**

1. Fab intake → `lp{package}/{entity}/assets/source/`
2. Author vmdl in **ModelDoc Studio** (`Start-SboxModelDocStudio.ps1`) — no DXRP gamemode
3. Owner mesh sign-off → promote to shipped `models/...` + prefab

---

## 2. Collision — real hulls, not one box

| Bad (baseline only) | Target |
|---------------------|--------|
| Single `BoxCollider` around whole mesh | **Multiple convex hulls** in ModelDoc |

**Examples:**

| Entity | Hull pieces |
|--------|-------------|
| Bitcoin HUB | chassis, door, side fans, rear PSU, feet |
| GPU rack | frame, shelves, legs, top panel |
| Terminal | base, screen bezel, keyboard tray |

**Law:** Phase 1 may use white wireframe `BoxCollider` on all axes as an **honest baseline**
(`BITCOINMINING_PROP_BASELINE.md`) — tracked in `TECH_DEBT.md`. Endgame is ModelDoc convex hulls
+ `LifePunchPropPhysics` sync from authored shapes, not a cube forever.

---

## 3. Attachments everywhere

Define in ModelDoc (prefab uses attachment names):

```text
fan_1 … fan_4
led_green / led_orange / led_red
screen
smoke_top
light_blue
btc_insert
```

Use for: point lights, particles, sounds, flash-drive insert, animation origins, child fan meshes.

---

## 4. Machine states (Law 6)

Machines **live** — they do not statically exist.

| State | Visual / audio |
|-------|----------------|
| **OFF** | No lights, fans stopped, screen dark, idle off |
| **BOOTING** | LED blink, startup sound, fan ramp, screen power-on |
| **RUNNING** | Fans spin, blue LEDs, screen active, ambient hum |
| **OVERCLOCKED** | Orange lights, faster fans, higher pitch |
| **BROKEN** | Sparks, smoke, red LEDs, flicker |
| **HACKED** | Purple lighting, glitch screen, alarm |

Implement in C# state machine + components — not texture swaps alone.

---

## 5. Separate mesh animation from gameplay

| Part | Approach |
|------|----------|
| Fans | `fan_spin_idle` / `fan_spin_fast` / `fan_spin_overclock` **or** child GO spin (Phase 2 baseline) |
| Doors | `door_open` / `door_close` |
| Displays | `screen_boot` / `screen_shutdown` — **UI on child plane**, not texture flipbooks |

**Law:** Do not import animated rigged fan bodies as the main render mesh (Fab CPU GAMER, GPU farm).

Import animation takes as **separate nodes** in ModelDoc (not baked into the body FBX). Community
reference: [importing animations (r/sandbox)](https://www.reddit.com/r/sandbox/comments/1egj2bs/importing_animations/).

---

## 6. Dynamic lights = components

Never rely on emissive textures alone for gameplay-readable status.

Examples (conceptual — implement as point lights + small components on attachments):

- Blue power → `PowerLightComponent` on `light_blue` / `led_green`
- Hash rate → `HashRateIndicatorComponent` (orange) on `led_orange`
- Alarm → `AlarmComponent` (red flash) on `led_red`

---

## 7. Fan spin timing (example — Bitcoin HUB)

```text
0.0s  startup sound
0.2s  fans 20%
1.0s  fans 50%
3.0s  fans 100%
OC    120%
BROKEN stop
```

Child GO or bone-driven — match `LIFEPUNCH_HUB_PATTERN.md` hub power model.

---

## 8. Prefab hierarchy (scene components)

Think Unity/Godot component trees:

```text
BitcoinHub
├── Mesh (SkinnedModelRenderer / static)
├── Physics
├── Screen (child + UI host)
├── LightBlue / LightOrange / LightRed
├── Fan1 … Fan4
├── SmokeEmitter
├── Speaker
└── BtcInsertPoint
```

[s&box Components](https://sbox.game/dev/doc/scene/components/) · [Scene system](https://sbox.game/dev/doc/scene/)

---

## 9. Screens independent of mesh

Terminals (HASHD, hacker CRT, banker):

```text
TerminalMesh
└── ScreenPlane
     └── Razor UI (state-driven)
```

UI states: login, mining, error, hacked, seizure — not baked screen textures.

---

## 10. Build checklist (P0 → P4)

### P0 — Model foundation (current gate)

- [ ] Scale vs citizen (~64–72u)
- [ ] ModelDoc compile clean
- [ ] Materials / vmats (solid-color plan OK)
- [ ] LOD0 sane; LOD plan noted
- [ ] Convex collision plan (or Phase 1 box baseline documented)
- [ ] Owner mesh sign-off screenshot

### P1 — Physical presence

- [ ] Attachments authored
- [ ] Point lights wired
- [ ] Sound hooks (idle/startup placeholders)
- [ ] Particle origins (smoke/spark)

### P2 — Motion

- [ ] Fan animations or child-GO spin
- [ ] Doors (if applicable)
- [ ] Display boot sequence

### P3 — State machine

- [ ] OFF / BOOT / RUNNING / OVERCLOCK / BROKEN / HACKED wired to visuals

### P4 — Polish

- [ ] Idle / startup / alarm audio
- [ ] Sparks / smoke particles
- [ ] State-specific mix

**Do not skip P0** to implement P3 gameplay.

---

## Official references (agents)

| Topic | URL |
|-------|-----|
| s&box docs | https://sbox.game/dev/doc |
| ModelDoc | https://sbox.game/dev/doc/editor/model-editor |
| Components | https://sbox.game/dev/doc/scene/components/ |
| Scenes | https://sbox.game/dev/doc/scene/ |
| ModelDoc intro (video) | https://www.youtube.com/watch?v=1-L8BvNAbjQ |

---

## Related repo docs

| Doc | Role |
|-----|------|
| `MODEL_FOUNDATION_PASS.md` | P0 gate before prefab |
| `MODELDOC_STUDIO_LANE.md` | Standalone editor (no DXRP) |
| `PACKAGE_STAGING_LAYOUT.md` | `lpbitcoin/bitcoinhub/assets\|code` |
| `LIFEPUNCH_HUB_PATTERN.md` | Hub vs terminal vs satellite |
| `CYBER_REFERENCE_LAWS.md` | Laws 1–11 production gate |
| `ACTIVE_WORKSTREAM.md` | Single active lane until sign-off |
| `TECH_DEBT.md` | Baselines vs endgame (box collider, fan child GO, …) |
| `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` | Weapons — platform stack (parallel track) |
