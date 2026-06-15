"""Headless Blender export: bitcoinminer.blend -> steam-machine.fbx (Steam_Machine collection only)."""
import bpy
import sys

argv = sys.argv
argv = argv[argv.index("--") + 1 :] if "--" in argv else []
blend_path = argv[0] if len(argv) > 0 else ""
out_fbx = argv[1] if len(argv) > 1 else ""

if not blend_path or not out_fbx:
    raise SystemExit("usage: blender --background blend --python script -- <blend> <out.fbx>")

EXPORT_COLLECTIONS = {"Steam_Machine"}
ROOT_NAME = "base_body"
CHILD_NAMES = ("fan", "front_panel", "back_body")

bpy.ops.wm.open_mainfile(filepath=blend_path)

root = bpy.data.objects.get(ROOT_NAME)
if root is None:
    raise SystemExit(f"Missing root mesh: {ROOT_NAME}")

export_meshes = []
for obj in bpy.data.objects:
    if obj.type != "MESH":
        continue
    if not any(c.name in EXPORT_COLLECTIONS for c in obj.users_collection):
        continue
    export_meshes.append(obj)

if not export_meshes:
    raise SystemExit(f"No meshes found in collections: {sorted(EXPORT_COLLECTIONS)}")

# Parent hull parts under base_body while preserving world transforms (do NOT apply per-mesh first).
for child_name in CHILD_NAMES:
    child = bpy.data.objects.get(child_name)
    if child is None or child == root or child.parent is not None:
        continue
    child.parent = root
    child.matrix_parent_inverse = root.matrix_world.inverted()

bpy.ops.object.select_all(action="DESELECT")
for obj in export_meshes:
    obj.select_set(True)
bpy.context.view_layer.objects.active = root

bpy.ops.export_scene.fbx(
    filepath=out_fbx,
    use_selection=True,
    object_types={"MESH"},
    bake_anim=True,
    bake_anim_use_all_actions=True,
    bake_anim_use_all_bones=False,
    add_leaf_bones=False,
    path_mode="COPY",
    embed_textures=False,
    axis_forward="-Z",
    axis_up="Y",
)

print(f"EXPORT_OK: {out_fbx}")
print(f"EXPORT_MESHES: {[o.name for o in export_meshes]}")
for action in bpy.data.actions:
    print(f"ACTION: {action.name}")
