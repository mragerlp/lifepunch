"""Headless Blender: rig gpu-rack-anim.fbx (or GPU_Farm_Final.blend) with a prop armature + fan spin actions.

The shipped anim FBX has mesh + object animation but no armature (LimbNode=0), so ModelDoc compiles
bones=0 and power_on sequences never play. This script:
  1. Imports the existing anim FBX (or owner .blend)
  2. Adds GpuRackRig (rack_root + one bone per fan blade / GPU card fan)
  3. Bakes looping Z-rotation actions: power_on (+ alias GPU_Farm_Final or Mining_Rig_Stacked)
  4. Exports rigged FBX for ModelDoc animated_model

Usage:
  blender --background --python Export-GpuRackAnimFbx.py -- <in.fbx|in.blend> <out.fbx> [stacked]
"""
import bpy
import re
import sys
from mathutils import Vector

argv = sys.argv
argv = argv[argv.index("--") + 1 :] if "--" in argv else []
source_path = argv[0] if len(argv) > 0 else ""
out_fbx = argv[1] if len(argv) > 1 else ""
stacked = len(argv) > 2 and argv[2].lower() in ("stacked", "1", "true", "yes")

if not source_path or not out_fbx:
    raise SystemExit(
        "usage: blender --background --python Export-GpuRackAnimFbx.py -- <in.fbx|in.blend> <out.fbx> [stacked]"
    )

ARMATURE_NAME = "GpuRackRig"
ROOT_BONE = "rack_root"
ROOT_MESH_CANDIDATES = ("Rack_Frame", "Rack", "Motherboard_Base")
FAN_BLADE_RE = re.compile(r"^FanBlades(?:\.|_)(\d+)$", re.IGNORECASE)
GPU_FAN_RE = re.compile(r"^GPU_Fan(?:\.|_)?(\d+)(?:\.\d+)*$", re.IGNORECASE)
FRAME_COUNT = 60
ALIAS_ACTION = "Mining_Rig_Stacked" if stacked else "GPU_Farm_Final"


def sanitize_bone_name(mesh_name: str) -> str:
    return mesh_name.replace(".", "_")


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in list(bpy.data.meshes):
        if block.users == 0:
            bpy.data.meshes.remove(block)
    for block in list(bpy.data.armatures):
        if block.users == 0:
            bpy.data.armatures.remove(block)
    for block in list(bpy.data.actions):
        if block.users == 0:
            bpy.data.actions.remove(block)


def load_source(path: str):
    lower = path.lower()
    if lower.endswith(".blend"):
        bpy.ops.wm.open_mainfile(filepath=path)
        return [obj for obj in bpy.data.objects if obj.type == "MESH"]
    if lower.endswith(".fbx"):
        clear_scene()
        bpy.ops.import_scene.fbx(filepath=path)
        return [obj for obj in bpy.data.objects if obj.type == "MESH"]
    raise SystemExit(f"Unsupported source: {path}")


def pick_root_mesh(meshes):
    for name in ROOT_MESH_CANDIDATES:
        hit = bpy.data.objects.get(name)
        if hit is not None and hit.type == "MESH":
            return hit
    return max(meshes, key=lambda o: o.dimensions.x * o.dimensions.y * o.dimensions.z)


def classify_meshes(meshes):
    root_mesh = pick_root_mesh(meshes)
    fan_meshes = []
    static_meshes = []
    for obj in meshes:
        if FAN_BLADE_RE.match(obj.name) or GPU_FAN_RE.match(obj.name):
            fan_meshes.append(obj)
        else:
            static_meshes.append(obj)
    fan_meshes.sort(key=lambda o: o.name)
    return root_mesh, static_meshes, fan_meshes


def bone_head_tail(obj):
    center = obj.matrix_world.to_translation()
    ext = max(obj.dimensions.x, obj.dimensions.y, obj.dimensions.z, 0.05)
    tail = center + Vector((0.0, 0.0, ext * 0.1))
    return center, tail


def remove_existing_armature():
    for obj in list(bpy.data.objects):
        if obj.type == "ARMATURE" and obj.name == ARMATURE_NAME:
            bpy.data.objects.remove(obj, do_unlink=True)


def build_armature(root_mesh, fan_meshes):
    remove_existing_armature()

    arm_data = bpy.data.armatures.new(ARMATURE_NAME)
    arm_obj = bpy.data.objects.new(ARMATURE_NAME, arm_data)
    bpy.context.scene.collection.objects.link(arm_obj)

    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="EDIT")

    root_head, root_tail = bone_head_tail(root_mesh)
    root_bone = arm_data.edit_bones.new(ROOT_BONE)
    root_bone.head = root_head
    root_bone.tail = root_tail

    fan_bones = {}
    for fan_obj in fan_meshes:
        bone_name = sanitize_bone_name(fan_obj.name)
        head, tail = bone_head_tail(fan_obj)
        bone = arm_data.edit_bones.new(bone_name)
        bone.head = head
        bone.tail = tail
        bone.parent = root_bone
        fan_bones[fan_obj.name] = bone_name

    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj, fan_bones


def bind_mesh_to_bone(mesh_obj, arm_obj, bone_name):
    for mod in list(mesh_obj.modifiers):
        if mod.type == "ARMATURE":
            mesh_obj.modifiers.remove(mod)

    mesh_obj.parent = arm_obj
    mesh_obj.parent_type = "BONE"
    mesh_obj.parent_bone = bone_name

    group = mesh_obj.vertex_groups.get(bone_name)
    if group is None:
        group = mesh_obj.vertex_groups.new(name=bone_name)
    group.add(list(range(len(mesh_obj.data.vertices))), 1.0, "REPLACE")

    mod = mesh_obj.modifiers.new(name="Armature", type="ARMATURE")
    mod.object = arm_obj


def create_fan_spin_action(arm_obj, fan_bone_names, action_name):
    if arm_obj.animation_data is None:
        arm_obj.animation_data_create()

    action = bpy.data.actions.new(action_name)
    arm_obj.animation_data.action = action

    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = FRAME_COUNT

    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="POSE")

    for bone_name in fan_bone_names:
        pose_bone = arm_obj.pose.bones.get(bone_name)
        if pose_bone is None:
            continue
        pose_bone.rotation_mode = "XYZ"
        pose_bone.rotation_euler = (0.0, 0.0, 0.0)
        pose_bone.keyframe_insert(data_path="rotation_euler", frame=1)

        pose_bone.rotation_euler = (0.0, 0.0, 6.283185307)
        pose_bone.keyframe_insert(data_path="rotation_euler", frame=FRAME_COUNT)

    bpy.ops.object.mode_set(mode="OBJECT")
    print(f"ACTION_OK: {action_name} bones={len(fan_bone_names)} frames=1-{FRAME_COUNT}")


def duplicate_action(source_name, target_name):
    src = bpy.data.actions.get(source_name)
    if src is None:
        return
    dup = src.copy()
    dup.name = target_name
    print(f"ACTION_ALIAS: {source_name} -> {target_name}")


def main():
    meshes = load_source(source_path)
    if not meshes:
        raise SystemExit(f"No meshes loaded from {source_path}")

    root_mesh, static_meshes, fan_meshes = classify_meshes(meshes)
    if not fan_meshes:
        raise SystemExit("No FanBlades.* or GPU_Fan_* meshes found — cannot build fan spin rig.")

    arm_obj, fan_bones = build_armature(root_mesh, fan_meshes)

    for obj in static_meshes:
        bind_mesh_to_bone(obj, arm_obj, ROOT_BONE)

    for fan_obj in fan_meshes:
        bind_mesh_to_bone(fan_obj, arm_obj, fan_bones[fan_obj.name])

    fan_bone_names = list(fan_bones.values())
    create_fan_spin_action(arm_obj, fan_bone_names, "power_on")
    duplicate_action("power_on", ALIAS_ACTION)

    export_meshes = static_meshes + fan_meshes
    bpy.ops.object.select_all(action="DESELECT")
    for obj in export_meshes:
        obj.select_set(True)
    arm_obj.select_set(True)
    bpy.context.view_layer.objects.active = arm_obj

    bpy.ops.export_scene.fbx(
        filepath=out_fbx,
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

    print(f"EXPORT_OK: {out_fbx}")
    print(f"EXPORT_ARMATURE: bones={[b.name for b in arm_obj.data.bones]}")
    print(f"EXPORT_FANS: {fan_bone_names}")
    print(f"EXPORT_STATIC: {[o.name for o in static_meshes]}")


main()
