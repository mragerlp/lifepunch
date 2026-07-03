# Weapon Intake Checklist

Use this checklist before importing any weapon source folder into the LifePunch DXRP addon lane.

**Platform law (mandatory):** `LIFEPUNCH_WEAPON_IMPLEMENTATION_LAW.md` — P0 scale/collision/attachments
before gameplay. Produce **`WEAPON_PLATFORM_REPORT.md`** (or section in `WEAPON_BUILD.md`) per weapon.

The goal is to make every future weapon repeatable: AK47 first, then shotguns, handguns, rifles, and equipment.

## Step 1: Source Inventory

Record the source folder or ZIP paths before copying files.

Classify each source item:

- `model-source`: FBX, GLB, OBJ, BLEND, or other editable/importable model source.
- `model-texture`: base color, normal, roughness, metalness, AO, ORM, or masks.
- `audio-source`: WAV, OGG, MP3, VSND, or sound resource files.
- `prefab-source`: prefab files that may contain component layout.
- `code-source`: C# files.
- `project-template`: `.sbproj`, `.csproj`, `.sln`, `.slnx`, `.sbox`, `.vscode`, cloud cache, localization, or editor state.

Do not copy `project-template` files into the LifePunch addon package unless there is a specific reason.

## Step 2: Reuse Decision

For each file group, decide:

- `use`: trusted and should be imported.
- `reference-only`: useful for understanding, but not copied.
- `reject`: default template, wrong addon type, duplicate, generated cache, or unknown quality.
- `pending-review`: needs owner/legal/quality review before import.

## Step 3: Normalize Names

Use stable lowercase names:

```text
<slug>.fbx
w_<slug>
vm_<slug>
<slug>_fire
<slug>_fire_distant
<slug>_fire_silent
<slug>_lastshot
<slug>_lastshot_distant
<slug>_reload
<slug>_cock
<slug>_draw
```

Example for AK47:

```text
ak47.fbx
w_ak47
vm_ak47
ak47_shot
ak47_shot_distant
ak47_shot_silent
ak47_lastshot
ak47_lastshot_distant
ak47_reload
ak47_cock
ak47_draw
```

## Step 4: Target Paths

World prefab:

```text
Assets/addons/lifepunch/<ident>/equipment/w_<slug>/w_<slug>.prefab
```

Viewmodel prefab:

```text
Assets/addons/lifepunch/<ident>/equipment/vm_<slug>/vm_<slug>.prefab
```

World model:

```text
Assets/addons/lifepunch/<ident>/models/lifepunch/<ident>/w_<slug>/w_<slug>.vmdl
```

Sound sources/resources:

```text
Assets/addons/lifepunch/<ident>/sounds/
```

Code:

```text
Code/Addons/lifepunch/<ident>/
```

## Ready Source Rule

The LifePunch repo should contain only cleaned, ready source files for active addon assets.

For weapon model sources, use:

```text
Assets/addons/lifepunch/<ident>/models/lifepunch/<ident>/w_<slug>/source/<slug>.fbx
```

Do not keep raw downloaded names, unclean exports, duplicate ZIP extracts, Blender scratch exports, loose magazine/bullet variants, or old test files in the LifePunch addon lane. Track those outside the repo or in intake notes as provenance only.

## Step 5: Only Then Import

After the intake record is written:

1. Copy only approved assets.
2. Create or update prefabs inside the target folders.
3. Create LifePunch-owned code.
4. Update `config/addons.json`.
5. Run validation.
6. Test only on the Development server after local validation passes.
