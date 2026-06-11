# CS2 AK-47 study (reference only)

**Status:** Scaffold — Cornerman fills from S2V / VPK catalog  
**Ship boundary:** Nothing from this doc ships. LifePunch owns `w_ak47` / `v_ak47` meshes and sounds. FP animations reuse **M4A1 class kit**.

**Intake root:** `C:/lifepunch/reference-intake/cs2-weapons/ak47/`  
**CS2 mesh:** `weapon_rif_ak47` · **S2V path:** `weapons/models/ak47/`

---

## Mesh inventory

| File (vmdl_c) | Role | Notes |
|---------------|------|-------|
| `weapon_rif_ak47` | Viewmodel (primary) | Open in S2V; confirm animation dropdown populated |
| TBD | World / dropped | Separate file if present |
| TBD | Magazine only | Optional — detachable mag choreography |

---

## Animation catalog

| Sequence (CS2) | ~Duration | Moving parts | M4 class reuse |
|----------------|-----------|--------------|----------------|
| deploy | TBD | | M4 deploy |
| idle | TBD | | M4 idle |
| fire | TBD | bolt | M4 fire |
| reload | TBD | mag, bolt | M4 reload |
| reload_empty | TBD | mag, bolt | M4 empty reload |
| inspect | TBD | | optional |
| ads_in / ads_out | TBD | | M4 ADS |

*Fill durations from Source 2 Viewer preview. CS2 skeleton does not port — timing informs editor tuning only.*

---

## Material channels (CS2 glTF study)

| CS2 / glTF slot | LifePunch `ak47_body.vmat` | Action |
|-----------------|----------------------------|--------|
| baseColor | Color / Albedo | TBD |
| normal | Normal | TBD |
| roughness | Roughness | TBD |
| metalness | Metalness | TBD |

---

## Proportion delta (CS2 vs shipped `w_ak47`)

| Feature | CS2 reference | LifePunch `w_ak47` | Delta / action |
|---------|---------------|--------------------|----------------|
| Barrel length | TBD | Sketchfab FBX | TBD |
| Magazine angle | TBD | | TBD |
| Stock profile | TBD | | TBD |
| Sight height | TBD | | TBD |

---

## CS2 sound index

| CS2 path (study) | LifePunch owned sound | Status |
|------------------|----------------------|--------|
| TBD | `ak47_shot.sound` | shipped |
| TBD | `ak47_reload_clipin.sound` | shipped |
| TBD | `ak47_reload_clipout.sound` | shipped |
| TBD | `ak47_draw.sound` | shipped |
| TBD | `ak47_cock.sound` | shipped |
| TBD | `ak47_shot_distant.sound` | shipped |

Search VPK: `sounds/` filtered by `ak47` / `weapon_rif_ak47`.

---

## Related

- `briefs/AK47_CS2_STUDY_BRIEF.md`
- `M4A1_CLASS_ANIM_MAP.md`
- `CS2_WEAPON_HARVEST.md`
- `VIEWMODEL_RIG_PIPELINE.md`
