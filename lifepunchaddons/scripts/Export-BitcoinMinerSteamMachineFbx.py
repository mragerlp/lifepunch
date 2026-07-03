"""Headless Blender export: steam_machine blend -> steam-machine.fbx (Steam_Machine collection only).

Phase 1 (default): STATIC assembled chassis — meshes only, no armature, no baked actions.
  ModelDoc imports base_body + front_panel + back_body as rigid hull (fan excluded on body vmdl).
  Fan mesh is included in the same FBX for bitcoinhub-fan.vmdl (child GO spin).

Phase 2 (legacy --rigged): armature + baked actions — do not use for hub body ship.
"""
import bpy
import sys

argv = sys.argv
argv = argv[argv.index("--") + 1 :] if "--" in argv else []
blend_path = argv[0] if len(argv) > 0 else ""
out_fbx = argv[1] if len(argv) > 1 else ""
rigged = "--rigged" in argv

if not blend_path or not out_fbx:
    raise SystemExit("usage: blender --background blend --python script -- <blend> <out.fbx> [--rigged]")

EXPORT_COLLECTIONS = {"Steam_Machine"}
ROOT_NAME = "base_body"
STATIC_HULL_NAMES = ("base_body", "front_panel", "back_body")
FAN_MESH_NAME = "fan"
RIG_PART_NAMES = ("base_body", "fan", "front_panel", "back_body")
ARMATURE_NAME = "SteamMachineRig"
ACTION_NAMES = ("fanAction", "front_panelAction")


def mesh_in_export_collections(obj):
    return any(c.name in EXPORT_COLLECTIONS for c in obj.users_collection)


def ensure_parent_chain():
    root = bpy.data.objects.get(ROOT_NAME)
    if root is None:
        raise SystemExit(f"Missing root mesh: {ROOT_NAME}")

    for child_name in ("fan", "front_panel", "back_body"):
        child = bpy.data.objects.get(child_name)
        if child is None or child == root or child.parent is not None:
            continue
        child.parent = root
        child.matrix_parent_inverse = root.matrix_world.inverted()

    return root


def remove_existing_armatures():
    for obj in list(bpy.data.objects):
        if obj.type == "ARMATURE" and obj.name == ARMATURE_NAME:
            bpy.data.objects.remove(obj, do_unlink=True)


def clear_rigging(obj):
    if obj is None:
        return

    if obj.animation_data:
        obj.animation_data_clear()

    for mod in list(obj.modifiers):
        if mod.type == "ARMATURE":
            obj.modifiers.remove(mod)

    obj.vertex_groups.clear()

    if obj.parent is not None and obj.parent.type == "ARMATURE":
        world = obj.matrix_world.copy()
        obj.parent = None
        obj.matrix_world = world


def align_fan_to_front_panel():
    """Authoring has fan on the rear hull — snap to front_panel before export."""
    fan = bpy.data.objects.get(FAN_MESH_NAME)
    front = bpy.data.objects.get("front_panel")
    if fan is None or front is None:
        return

    fan.matrix_world.translation = front.matrix_world.translation.copy()
    print(f"FAN_ALIGN: fan -> front_panel at {fan.matrix_world.translation}")


def prepare_static_hull():
    remove_existing_armatures()
    ensure_parent_chain()
    align_fan_to_front_panel()

    for part_name in STATIC_HULL_NAMES:
        clear_rigging(bpy.data.objects.get(part_name))

    fan = bpy.data.objects.get(FAN_MESH_NAME)
    if fan is not None:
        clear_rigging(fan)
        fan.hide_set(False)
        fan.hide_render = False


def export_static(out_path, mesh_names):
    meshes = []
    for name in mesh_names:
        obj = bpy.data.objects.get(name)
        if obj is not None and obj.type == "MESH":
            meshes.append(obj)

    if not meshes:
        raise SystemExit(f"No static hull meshes: {mesh_names}")

    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]

    bpy.ops.export_scene.fbx(
        filepath=out_path,
        use_selection=True,
        object_types={"MESH"},
        bake_anim=False,
        add_leaf_bones=False,
        path_mode="COPY",
        embed_textures=False,
        axis_forward="-Z",
        axis_up="Y",
    )

    print(f"EXPORT_OK: {out_path}")
    print(f"EXPORT_MODE: static")
    print(f"EXPORT_MESHES: {[o.name for o in meshes]}")


# --- Legacy rigged export (Phase 2 only — causes separated hull in static ModelDoc) ---


def build_armature(part_objects):
    from mathutils import Vector

    remove_existing_armatures()

    arm_data = bpy.data.armatures.new(ARMATURE_NAME)
    arm_obj = bpy.data.objects.new(ARMATURE_NAME, arm_data)
    bpy.context.scene.collection.objects.link(arm_obj)

    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="EDIT")

    bone_map = {}
    root_obj = part_objects[ROOT_NAME]

    def bone_head_tail(obj):
        center = obj.matrix_world.to_translation()
        tail = center + Vector((0.0, 0.0, max(0.05, obj.dimensions.z * 0.1 or 0.05)))
        return center, tail

    root_head, root_tail = bone_head_tail(root_obj)
    root_bone = arm_data.edit_bones.new(ROOT_NAME)
    root_bone.head = root_head
    root_bone.tail = root_tail
    bone_map[ROOT_NAME] = root_bone

    for part_name in RIG_PART_NAMES:
        if part_name == ROOT_NAME:
            continue
        obj = part_objects.get(part_name)
        if obj is None:
            continue

        parent_obj = obj.parent if obj.parent and obj.parent.type == "MESH" else root_obj
        parent_bone = bone_map.get(parent_obj.name, root_bone)

        head, tail = bone_head_tail(obj)
        bone = arm_data.edit_bones.new(part_name)
        bone.head = head
        bone.tail = tail
        bone.parent = parent_bone
        bone_map[part_name] = bone

    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj, bone_map


def bind_mesh_to_bone(mesh_obj, arm_obj, bone_name):
    for mod in list(mesh_obj.modifiers):
        if mod.type == "ARMATURE":
            mesh_obj.modifiers.remove(mod)

    mesh_obj.parent = arm_obj
    mesh_obj.parent_type = "BONE"
    mesh_obj.parent_bone = bone_name

    vgroup = mesh_obj.vertex_groups.get(bone_name)
    if vgroup is None:
        vgroup = mesh_obj.vertex_groups.new(name=bone_name)
    vgroup.add(list(range(len(mesh_obj.data.vertices))), 1.0, "REPLACE")

    mod = mesh_obj.modifiers.new(name="Armature", type="ARMATURE")
    mod.object = arm_obj


def bake_actions_to_armature(arm_obj, part_objects):
    scene = bpy.context.scene
    frame_start = int(scene.frame_start)
    frame_end = int(scene.frame_end)
    if frame_end <= frame_start:
        frame_end = 120

    for action in bpy.data.actions:
        if action.name not in ACTION_NAMES:
            continue

        for track in arm_obj.animation_data.nla_tracks if arm_obj.animation_data else []:
            arm_obj.animation_data.nla_tracks.remove(track)

        arm_obj.animation_data_create()
        arm_obj.animation_data.action = None

        for part_name, obj in part_objects.items():
            if obj is None:
                continue
            obj.animation_data_create()
            if action.name == "fanAction" and part_name != "fan":
                obj.animation_data.action = None
            elif action.name == "front_panelAction" and part_name != "front_panel":
                obj.animation_data.action = None
            else:
                obj.animation_data.action = action

        bpy.context.view_layer.objects.active = arm_obj
        bpy.ops.object.mode_set(mode="POSE")
        bpy.ops.nla.bake(
            frame_start=frame_start,
            frame_end=frame_end,
            only_selected=False,
            visual_keying=True,
            clear_constraints=False,
            use_current_action=False,
            bake_types={"POSE"},
        )
        bpy.ops.object.mode_set(mode="OBJECT")

        baked = arm_obj.animation_data.action
        if baked is not None:
            baked.name = action.name
            print(f"BAKED_ACTION: {baked.name} frames={frame_start}-{frame_end}")


def export_rigged(out_path, export_meshes, arm_obj):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in export_meshes:
        obj.select_set(True)
    arm_obj.select_set(True)
    bpy.context.view_layer.objects.active = arm_obj

    bpy.ops.export_scene.fbx(
        filepath=out_path,
        use_selection=True,
        object_types={"MESH", "ARMATURE"},
        bake_anim=True,
        bake_anim_use_all_actions=True,
        bake_anim_use_all_bones=True,
        add_leaf_bones=False,
        path_mode="COPY",
        embed_textures=False,
        axis_forward="-Z",
        axis_up="Y",
    )

    print(f"EXPORT_OK: {out_path}")
    print(f"EXPORT_MODE: rigged")
    print(f"EXPORT_MESHES: {[o.name for o in export_meshes]}")


def main():
    bpy.ops.wm.open_mainfile(filepath=blend_path)

    export_meshes = [
        obj
        for obj in bpy.data.objects
        if obj.type == "MESH" and mesh_in_export_collections(obj)
    ]
    if not export_meshes:
        raise SystemExit(f"No meshes found in collections: {sorted(EXPORT_COLLECTIONS)}")

    if rigged:
        ensure_parent_chain()
        part_objects = {name: bpy.data.objects.get(name) for name in RIG_PART_NAMES}
        if part_objects[ROOT_NAME] is None:
            raise SystemExit(f"Missing root mesh: {ROOT_NAME}")

        arm_obj, bone_map = build_armature(part_objects)
        for part_name, obj in part_objects.items():
            if obj is None or part_name not in bone_map:
                continue
            bind_mesh_to_bone(obj, arm_obj, part_name)
        bake_actions_to_armature(arm_obj, part_objects)
        export_rigged(out_fbx, export_meshes, arm_obj)
        return

    prepare_static_hull()
    export_static(out_fbx, STATIC_HULL_NAMES)


main()
