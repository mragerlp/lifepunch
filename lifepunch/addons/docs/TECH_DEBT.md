# LifePunch — Tech Debt / Temporary Work Register

Every temporary, placeholder, or interim decision lives here so it never silently becomes
permanent. See `.cursor/rules/lifepunch-quality-bar.mdc`. Remove entries when truly resolved.

| ID | What's temporary | Why (constraint) | Clean endgame | Single swap point |
|----|------------------|------------------|---------------|-------------------|
| FP-AK-01 | AK first person shows the **M4A1 viewmodel** as a placeholder | The AK `v_*` mesh isn't rigged; a class viewmodel rig (camera bone + animgraph + skin weights) is needed and Facepunch's base weapon rig source isn't currently shipped | Own a per-class viewmodel rig and skin the AK mesh to it (no Facepunch-source dependency), OR rig to the M4 skeleton once source ships | `vm_ak47.prefab` → swap the visible weapon mesh from `v_m4a1.vmdl` to the rigged `v_ak47` |

## Open cleanup (do before publishing the AK)
- [ ] Remove the disabled **AK passenger renderer** from `vm_ak47.prefab` (dead component).
- [ ] Delete the now-orphaned `equipment/vm_ak47/invisible.vmat` (+ `_c`) if no longer referenced.
- [ ] Decide the fate of static `models/.../v_ak47/v_ak47.vmdl` (keep as mesh source for the
      future rig, or move to a clearly-labeled `_source/` area so it isn't mistaken for a usable viewmodel).
- [ ] Leftover `bitcoinmining/` folder still in the DXRP editor project (Assets + Code) — remove.

## Decision needed
- **FP-AK-01 approach:** (A) ship clean M4 placeholder now + keep FP-AK-01 tracked, or
  (B) hold AK first person as "not done" and build our own owned per-class viewmodel rig first.
