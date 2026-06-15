"""List objects and actions in bitcoinminer.blend for export tuning."""
import bpy
import sys

print("=== OBJECTS ===")
for o in sorted(bpy.data.objects, key=lambda x: x.name):
    cols = [c.name for c in o.users_collection]
    parent = o.parent.name if o.parent else "none"
    loc = tuple(round(v, 3) for v in o.location)
    scale = tuple(round(v, 3) for v in o.scale)
    dims = tuple(round(v, 3) for v in o.dimensions) if o.type == "MESH" else ()
    print(
        f"{o.name}\ttype={o.type}\tparent={parent}\tcols={cols}\tloc={loc}\tscale={scale}\tdims={dims}"
    )

print("=== ACTIONS ===")
for a in bpy.data.actions:
    print(a.name)

print("=== COLLECTIONS ===")
for c in bpy.data.collections:
    print(c.name)
