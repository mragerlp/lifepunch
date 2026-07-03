# Cornerman task — Deagle distill (queue #2)

**Lane:** Tier-3 prep · **Red builds** on VENGEANCE after AK verify  
**Issued:** 2026-06-11

---

## Goal

Prep Desert Eagle shipment **before** Red opens ModelDoc — stats reference, MODEL_BUILD draft, CS2 study notes.

**You do NOT:** edit `Deagle.cs` stats on Green for ship (Red/Opus validates), publish portal, or push.

---

## Tasks

### 1. USP class stats table

Study DXRP handgun class reference (`usp`):

- Download cache: `download/assets/` weapon defs if present
- DXRP GitHub `develop` game code — `Usp` / `UspWeapon` / equipment stats
- BitcoinMiningAddon addon is **not** the weapon reference — use DXRP USP

Produce `lifepunchaddons/docs/reference/USP_CLASS_STATS.md`:

| Field | USP value | Deagle proposed (first pass) | Rationale |
|-------|-----------|------------------------------|-----------|
| Damage | … | higher | Deagle identity |
| MagazineSize | … | 7–8 | … |
| RoundsPerMinute | … | … | semi-auto |
| RecoilPitch | … | higher | … |
| … | | | |

Mark uncertain cells `TBD — Red editor verify`.

### 2. `w_deagle/MODEL_BUILD.md` draft

Create under `Assets/addons/lifepunch/deagle/models/lifepunch/deagle/w_deagle/`:

- Clone AK `MODEL_BUILD.md` structure
- CS2 study mesh: `weapon_pist_deagle`
- Placeholder paths from `Deagle.cs`
- Publish checklist (no vmdl yet)

### 3. CS2 intake note

Read `addons/docs/CS2_WEAPON_HARVEST.md`. Append to `deagle/docs/SOURCE_INTAKE.md`:

- Expected glTF path after `reference-intake/cs2-weapons/deagle/`
- Animation names listed in `MANIFEST.txt` (from S2V preview)
- Texture channel naming from CS2 export (study only)
- **Reminder:** CS2 anims are study-only; ship FP via USP class kit

### 4. RAG copy

Copy finished distill to `C:\lifepunch\cornerman\outbox\DEAGLE_DISTILL.md` (single page summary).

---

## Commit (local)

```text
docs(deagle): USP stats reference + w_deagle MODEL_BUILD draft
```

Canon brief: `DEAGLE_WEAPON_BRIEF.md` · `WEAPON_MASS_PRODUCTION.md`
