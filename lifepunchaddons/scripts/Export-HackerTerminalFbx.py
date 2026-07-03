"""Headless Blender export: computer thing.blend -> hacker-terminal.fbx."""
import bpy
import sys

argv = sys.argv
argv = argv[argv.index("--") + 1 :] if "--" in argv else []
blend_path = argv[0] if len(argv) > 0 else ""
out_fbx = argv[1] if len(argv) > 1 else ""

if not blend_path or not out_fbx:
    raise SystemExit("usage: blender --background blend --python script -- <blend> <out.fbx>")

bpy.ops.wm.open_mainfile(filepath=blend_path)

# Drop orphan helpers (e.g. Archipack) that are not in the active view layer.
for obj in list(bpy.data.objects):
    try:
        obj.name
    except ReferenceError:
        continue
    if obj.name in bpy.context.view_layer.objects:
        continue
    bpy.data.objects.remove(obj, do_unlink=True)

for obj in bpy.context.view_layer.objects:
    if obj.type != "MESH":
        continue
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    try:
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    except Exception:
        pass
    obj.select_set(False)

bpy.ops.export_scene.fbx(
    filepath=out_fbx,
    use_selection=False,
    object_types={"MESH", "ARMATURE", "EMPTY"},
    bake_anim=False,
    add_leaf_bones=False,
    path_mode="COPY",
    embed_textures=False,
    axis_forward="-Z",
    axis_up="Y",
)

print(f"EXPORT_OK: {out_fbx}")
