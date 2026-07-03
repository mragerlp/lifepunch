"""Print world-space AABB for each mesh object in an FBX (Blender background)."""
import sys

import bpy
from mathutils import Vector


def measure(fbx_path: str) -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=fbx_path)
    mins = Vector((1e9, 1e9, 1e9))
    maxs = Vector((-1e9, -1e9, -1e9))
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue
        for corner in obj.bound_box:
            world = obj.matrix_world @ Vector(corner)
            mins.x = min(mins.x, world.x)
            mins.y = min(mins.y, world.y)
            mins.z = min(mins.z, world.z)
            maxs.x = max(maxs.x, world.x)
            maxs.y = max(maxs.y, world.y)
            maxs.z = max(maxs.z, world.z)
    size = maxs - mins
    print(f"PATH={fbx_path}")
    print(f"MINS={mins.x:.3f},{mins.y:.3f},{mins.z:.3f}")
    print(f"MAXS={maxs.x:.3f},{maxs.y:.3f},{maxs.z:.3f}")
    print(f"SIZE={size.x:.3f},{size.y:.3f},{size.z:.3f}")


if __name__ == "__main__":
    argv = sys.argv[sys.argv.index("--") + 1 :]
    if len(argv) < 1:
        raise SystemExit("usage: blender --background --python script -- <fbx> [fbx...]")
    for path in argv:
        measure(path)
