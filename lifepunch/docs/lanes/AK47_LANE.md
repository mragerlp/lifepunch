# AK47 lane — quarantined viewmodel experiment

> **Status: quarantined.** First-person AK is **not on the ship path** for LifePunch addons.
> Treat as a likely dead end until a single verified in-hand `lp_give_ak` proves otherwise.
> **Do not merge `lane/ak47` → `main` without explicit owner sign-off.**

## Why this lane exists

The M4-invisible-master + bonemerged-AK stack is fragile spaghetti (see quality-bar rule and
`TECH_DEBT.md` FP-AK-01). It polluted `main` working trees, blocked bitcoin/menu work, and
burned sessions without a shippable FP result. AK work is isolated so **ship lanes stay clean**.

## Where work lives

| Item | Location |
|------|----------|
| **Git branch** | `lane/ak47` on `github.com/mragerlp/lifepunch` |
| **Monorepo paths** | `lifepunch/addons/**/ak47/**`, `lifepunch/addons/scripts/blender/*ak47*`, `lifepunch/addons/scripts/Invoke-Ak47Vm*.ps1` |
| **Tech debt** | `TECH_DEBT.md` FP-AK-01, WEAPON-* |
| **Platform law** | `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` |
| **Agent block** | `AGENT_PROMPT.md` Block E |

`main` keeps the last **known-good** AK listing in `addons.json` (world model + M4 placeholder
baseline). Experimental prefab/FBX/blender churn stays on `lane/ak47` only.

## Switch branches (VENGEANCE)

```powershell
cd C:\Users\jared\Projects\lifepunchdxrp
git fetch origin

# Ship work (bitcoin, hacker, staff, entities)
git checkout main
git pull --rebase

# AK experiment only
git checkout lane/ak47
git pull --rebase
```

After switching to `main`, if untracked AK blender backups linger locally, ignore them or
`git clean -fd` under `lifepunch/addons/**/ak47/` only when you intend to discard lane-only files.

## Honest assessment (Jun 2026)

| Attempt | Result |
|---------|--------|
| M4 master + invisible.vmat + bonemerged AK | Empty hands / wrong bind — **spaghetti baseline** |
| Blender CS2 align + M4 weapon_rig bind scripts | Iteration without verified in-editor hand pose |
| Custom `v_ak47.vmdl` without owned animgraph | Still not a shippable FP rig |

**Clean endgame (if we ever revive):** one owned viewmodel rig per `VIEWMODEL_RIG_PIPELINE.md` —
`camera` bone + animgraph from `v_m700` template, AK mesh skinned to it. **No** third invisible
renderer, **no** passenger bonemerge stack.

**Pragmatic ship alternative:** ship **world AK only** (w_ak47) with DXRP third-person hold;
defer FP to a future weapon-class template shared across the portfolio.

## Lane rules

1. **Commit only on `lane/ak47`** for AK paths and AK blender tooling.
2. **Never** open AK lane chats for bitcoin/hacker/staff work — separate session.
3. **No publish** from this lane until `lp_give_ak` FP is verified and FP-AK-01 is resolved.
4. Escalate to Opus only for rig/architecture; routine blender script edits stay Tier-2.
5. Main integration = owner merges a **reviewed** lane/ak47 PR after playtest proof.

## References

- `lifepunch/addons/docs/VIEWMODEL_RIG_PIPELINE.md`
- `lifepunch/addons/docs/SBOX_EDITOR_REFERENCE.md` §5 (first-person weapons)
- `lifepunch/addons/docs/briefs/AK47_CS2_STUDY_BRIEF.md`
- `lifepunch/addons/config/addons.json` → `ak47` entry
