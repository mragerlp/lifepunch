# AK47 RIG SPIKE — FINDINGS (LP-NIGHTBUILD-002 Mission 3)

**Branch:** `lp/ak47-rig-spike` · **Class:** EXPERIMENTAL SPIKE — the findings ARE the deliverable.
**Date:** 2026-07-25 · **Harness:** Claude Code (Opus) on VENGEANCE, canonical tree.
**Status of this document:** INTERIM — banked mid-spike per A3-1 (commit early, commit often).

> **A3-2 HARNESS-GATE DISCLOSURE.** This run executes with the harness approval gate disabled.
> That is lawful here only because the delegation envelope is closed, reversible, and merge-gated.
> Fences X1–X5 stand regardless of harness mode. Nothing here is merged; nothing reaches a player.

---

## 1. THE HEADLINE — the named tool is not the tool for this job

**"PointlessAI AutoRigger" resolves to `notpointless.chomnr_humanoid_retargeter`, "Humanoid Retargeter"
v1.0.311783**, by zeljkovranjes.

**Sensor:** `D:\Steam\steamapps\common\sbox\dxrp\game\Libraries\notpointless.chomnr_humanoid_retargeter\`
— `.version` reads `1.0.311783`; `humanoid-retargeter.sbproj` `Metadata.Summary` reads verbatim:

> "Retarget any humanoid animation (Mixamo, ActorCore, UE Mannequin, BVH mocap, glTF) onto s&box
> characters or any custom humanoid model — entirely in-editor, pure C#."

### 1.1 WHAT IT TURNED OUT TO BE (the question the dispatch asked)

| Question | Answer | Sensor |
|---|---|---|
| Local tool, editor plugin, or web service? | **Local s&box editor library.** Installed. `View -> Humanoid Retargeter`. | `.sbproj` `Type: "library"`, `HOW TO USE` block |
| Does it need an account / login? | **No.** | `.sbproj`; no auth surface. X3 never tested. |
| Does anything leave the machine? | **NO. Nothing was uploaded. Nothing left this machine.** | See §5 |
| External dependencies? | **None.** "No Blender, no Python, no native DLLs — pure C#." | `.sbproj` Description |
| Licence | Free & non-commercial. Optional DL model derives from SAME (Lee et al., SIGGRAPH Asia 2023, CC BY-NC 4.0). | `.sbproj` Description |
| Source | https://github.com/zeljkovranjes/humanoid-retargeter | `.sbproj` `WebsiteUrl` |

### 1.2 THE MISMATCH

The tool retargets **humanoid ANIMATION CLIPS onto humanoid SKELETONS**. An AK-47 is a **weapon prop**.
A weapon "rig" in s&box is a viewmodel: arms + weapon bones + a `camera` bone, assembled in ModelDoc and
driven by an animgraph. These are different problems, and the Humanoid Retargeter addresses neither half
of the weapon problem.

**This is a documented negative result, which the mission class declares a full success.** Running the
retargeter against `ak47_vm.fbx` would not have produced a weapon rig; it would have failed to find a
humanoid profile, because there is no humanoid in the file.

---

## 2. PRIOR ATTEMPTS — the repo already tried this three times

**Sensor:** `git ls-tree -r --name-only lane/ak47` — the source folder is a rigging changelog:

```
ak47_vm.before-blender-fix.fbx     <- attempt 1: Blender orientation fix
ak47_vm.before-cs2-align.fbx       <- attempt 2: CS2 alignment pass
ak47_vm.before-m4-bind.fbx         <- attempt 3: bind to the M4 rig
ak47_vm.fbx                        <- current
```

106 AK47 files tracked on `origin/develop`; 108 on `lane/ak47` (the extra two are the additional FBX
backups). The lane is NOT greenfield.

### 2.1 The solved half — first person

`VIEWMODEL_BUILD.md` (`.../ak47/models/lifepunch/ak47/v_ak47/VIEWMODEL_BUILD.md`) records, dated
2026-06-03: **"background rebuild done … NO Blender required."** The technique is the s&box first-person
doc approach — **the M4 rig as an invisible driver**:

| Component | Content | Role |
|---|---|---|
| 1 | `ViewModel` | camera bone read = M4's `camera`; animgraph = M4's |
| 2 | `v_m4a1.vmdl`, `CreateBoneObjects: true`, `UseAnimGraph: true`, `MaterialOverride = invisible.vmat` | **drives everything, renders nothing** |
| 3 | `v_first_person_arms_human.vmdl` | arms, bone-merged to master |
| 4 | `v_ak47.vmdl` | textured AK, bone-merged to master |

It works because the AK rig **reuses the M4 bone names** (`weapon_root`, `muzzle`, `stock`, `trigger`,
`magazine`), so it rides the M4 skeleton. `invisible.vmat` exists because `ViewModel.cs` forces renderer
Tint alpha back to 1 every frame — the mesh must be hidden at the **material** level, not the tint level.

**That is the real "auto-rig" for this asset, and it is already shipped.** It is not machine learning; it
is skeleton-name reuse plus an invisible driver model.

### 2.2 The UNSOLVED half — third-person hold

`VIEWMODEL_BUILD.md` names it explicitly: *"Third-person hold (separate, still TODO — needs live editor
tweak)."* It even carries the known-good target values:

| `w_ak47.prefab` field | Current (documented wrong) | Reference (working M4 `w_m4a1.prefab`) |
|---|---|---|
| Model child rotation | `0,0,1,0` (180 degree flip) | `0.0000000056,0.00000012,0.1164025,0.9932021` (~13 degree roll, no flip) |
| Muzzle | `-459 X` ("clearly wrong") | `20.07571,0,7.212921` |
| EjectionPort | — | `1.774985,-0.4210945,7.672482` |
| Held position | already matches M4 | `2.888188,1.646453,-6.576477` |

**NOT APPLIED.** Mission 3 fences spike artifacts to the spike branch and forbids touching gameplay code;
`w_ak47.prefab` is a shipped gameplay asset. Recorded as a recommendation, not a change. See OQ-6.

---

## 3. WHAT A REAL RIGGING PIPELINE FOR THIS ASSET WOULD NEED

1. **Do not reach for a humanoid retargeter.** Weapons are viewmodels, not characters.
2. **Bone-name parity with an existing shipped weapon is the leverage.** The AK rides the M4 skeleton for
   free because its bones are named to match. Any future weapon should be authored to the same names.
3. **The `camera` bone is the load-bearing detail.** DXRP's `ViewModel.cs` calls
   `GetBoneLocalTransform("camera")` every frame and does `camera.LocalRotation *= bone.Rotation`. A
   default Blender bone (pointing up) produces the "giant stock filling the screen" bug. The bone's length
   axis must point down the barrel, head at the eye line, tail toward the muzzle.
4. **The invisible-driver trick removes the DCC step entirely** for any weapon whose bones match a shipped
   rig — no Blender round-trip required.
5. **Third person is a separate, manual alignment pass** and does not benefit from any auto tooling; it is
   four numeric fields copied from a working reference weapon.
6. **The genuine automation gap** is not rigging — it is a *verification harness*: nothing in this repo can
   assert "the viewmodel sits correctly" without a human looking at a screenshot.

---

## 4. RECOMMENDATION

- **Close the "AutoRigger" thread.** The tool is real, local, free, and well-built — and it is for
  humanoid animation, not weapons. Keep it installed for **character** animation work (Mixamo/mocap onto
  Citizen), where it is genuinely valuable.
- **Finish the third-person hold** as its own tiny slice: four values, one prefab, one editor session.
  It is the only outstanding AK47 rig defect and it is fully specified.
- **Do not re-run the Blender path.** `VIEWMODEL_BUILD.md` §STATUS already retired it.

---

## 5. WHAT LEFT THE MACHINE

**NOTHING.**

No asset was uploaded. No external rigging service was contacted. No account was created. No credential
was handled. The mission's upload authorization went **unused** because the tool turned out to be local.

---

## 6. OPEN QUESTIONS

- **OQ-6** — Apply the documented third-person `w_ak47.prefab` fix? It is fully specified but touches a
  shipped gameplay asset, which Mission 3 fences off. Needs a word.
- **OQ-7** — `codex/ak47-rig-retarget-2026-07-23` is 0 commits ahead of `origin/develop` with a clean
  worktree at `C:\Users\jared\Projects\vengeance-worktrees\lifepunch\ak47-rig-2026-07-23`. A named lane,
  provisioned but unstarted. Whose chair is it?
- **OQ-8** — `CVL_AGENT_ONBOARDING.md` §12 cites `VIEWMODEL_RIG_PIPELINE.md` and
  `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` as mandatory weapon-lane reads. **Neither is tracked on
  `origin/develop`.** Canon cites two documents that do not exist.

---

## 7. SENSOR APPENDIX

| Claim | Sensor |
|---|---|
| Tool identity + version | `Libraries\notpointless.chomnr_humanoid_retargeter\.version` = `1.0.311783`; `humanoid-retargeter.sbproj` |
| Tool is local / no DLLs | `.sbproj` Description: "entirely inside the editor … No Blender, no Python, no native DLLs — pure C#" |
| Editor DOWN this session | no `sbox` process; TCP 7269 / 9090 / 1234 all refused |
| Bridge dead | `Assert-BridgeVersion.ps1` EXIT 1; `bridgeVersion: null` with `versionsAligned: true` (the red\0032 defect firing) |
| Prior attempts | `git ls-tree -r --name-only lane/ak47` — three `before-*.fbx` backups |
| Viewmodel technique | `VIEWMODEL_BUILD.md` lines 5–28 |
| Third-person TODO + values | `VIEWMODEL_BUILD.md` lines 47–52 |
| AK47 file count | `git ls-tree -r --name-only origin/develop` -> 106 matches; `lane/ak47` -> 108 |

**No runtime, visual, or in-editor claim is made in this document.** The editor was down for its entire
duration; the retargeter was never executed. Every statement above is a static or documentary sensor.

FROM: Claude Code (Opus) · VENGEANCE · canonical tree · state-honest
