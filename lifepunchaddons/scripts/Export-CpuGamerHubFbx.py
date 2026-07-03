"""Headless Blender: cpu_gamer.blend -> decimated FBX + baked BaseColor PNG for ModelDoc.

Fab CPU GAMER: ~38 solid material colors, no PNG textures.
1) Paint material colors to mesh corners
2) Join + decimate
3) UV + bake BaseColor PNG (shows in s&box complex.shader)
4) Export single-slot FBX
"""
import os
import bpy
import sys

argv = sys.argv
argv = argv[argv.index("--") + 1 :] if "--" in argv else []
blend_path = argv[0] if len(argv) > 0 else ""
out_fbx = argv[1] if len(argv) > 1 else ""
decimate_ratio = float(argv[2]) if len(argv) > 2 else 0.015
out_png = argv[3] if len(argv) > 3 else ""

if not blend_path or not out_fbx:
    raise SystemExit("usage: blender --background blend --python script -- <blend> <out.fbx> [ratio] [out.png]")

MATERIAL_NAME = "CpuGamerBody"
MESH_NAME = "cpu_gamer"
COLOR_ATTR = "Col"
BAKE_SIZE = 2048


def get_material_rgba(mat):
    if mat is None:
        return (0.75, 0.75, 0.75, 1.0)
    if mat.node_tree:
        bsdf = next((n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
        if bsdf:
            base = bsdf.inputs.get("Base Color")
            if base:
                return tuple(base.default_value)
    return (0.75, 0.75, 0.75, 1.0)


def paint_material_colors_to_mesh(obj):
    mesh = obj.data
    if COLOR_ATTR in mesh.color_attributes:
        mesh.color_attributes.remove(mesh.color_attributes[COLOR_ATTR])
    attr = mesh.color_attributes.new(name=COLOR_ATTR, type="BYTE_COLOR", domain="CORNER")
    slots = obj.material_slots
    for poly in mesh.polygons:
        mat = None
        if poly.material_index < len(slots):
            mat = slots[poly.material_index].material
        rgba = get_material_rgba(mat)
        for loop_idx in poly.loop_indices:
            attr.data[loop_idx].color = rgba


def bake_basecolor_png(mesh_obj, png_path):
    os.makedirs(os.path.dirname(os.path.abspath(png_path)), exist_ok=True)
    mesh = mesh_obj.data

    if not mesh.uv_layers:
        bpy.ops.object.select_all(action="DESELECT")
        mesh_obj.select_set(True)
        bpy.context.view_layer.objects.active = mesh_obj
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(angle_limit=66, island_margin=0.02)
        bpy.ops.object.mode_set(mode="OBJECT")

    mat = mesh_obj.data.materials[0]
    mat.use_nodes = True
    nt = mat.node_tree
    for node in list(nt.nodes):
        nt.nodes.remove(node)

    attr = nt.nodes.new("ShaderNodeAttribute")
    attr.attribute_name = COLOR_ATTR
    emit = nt.nodes.new("ShaderNodeEmission")
    emit.inputs["Strength"].default_value = 1.0
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    nt.links.new(attr.outputs["Color"], emit.inputs["Color"])
    nt.links.new(emit.outputs["Emission"], out.inputs["Surface"])

    img = bpy.data.images.new("cpu_gamer_BaseColor", BAKE_SIZE, BAKE_SIZE, alpha=False)
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    nt.nodes.active = tex

    bpy.ops.object.select_all(action="DESELECT")
    mesh_obj.select_set(True)
    bpy.context.view_layer.objects.active = mesh_obj

    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 1

    bpy.ops.object.bake(type="EMIT", margin=8, use_clear=True)

    img.file_format = "PNG"
    img.filepath_raw = png_path
    img.save()
    print(f"EXPORT_BASECOLOR: {png_path} ({BAKE_SIZE}x{BAKE_SIZE})")


def main():
    bpy.ops.wm.open_mainfile(filepath=blend_path)

    meshes = [o for o in bpy.data.objects if o.type == "MESH" and o.data is not None]
    if not meshes:
        raise SystemExit("No mesh objects in blend")

    for obj in meshes:
        paint_material_colors_to_mesh(obj)

    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]

    if len(meshes) > 1:
        bpy.ops.object.join()

    mesh_obj = bpy.context.active_object
    mesh_obj.name = MESH_NAME
    verts_before = len(mesh_obj.data.vertices)

    dec = mesh_obj.modifiers.new(name="Decimate", type="DECIMATE")
    dec.ratio = max(0.01, min(1.0, decimate_ratio))
    bpy.context.view_layer.objects.active = mesh_obj
    bpy.ops.object.modifier_apply(modifier=dec.name)

    verts_after = len(mesh_obj.data.vertices)

    for mat in list(bpy.data.materials):
        bpy.data.materials.remove(mat)

    mat = bpy.data.materials.new(name=MATERIAL_NAME)
    mesh_obj.data.materials.clear()
    mesh_obj.data.materials.append(mat)

    png_path = out_png
    if not png_path:
        png_path = os.path.join(os.path.dirname(out_fbx), "..", "textures", "cpu-gamer_BaseColor.png")
    bake_basecolor_png(mesh_obj, os.path.abspath(png_path))

    bpy.ops.object.select_all(action="DESELECT")
    mesh_obj.select_set(True)
    bpy.context.view_layer.objects.active = mesh_obj

    color_attr = mesh_obj.data.color_attributes.get(COLOR_ATTR)
    color_count = len(color_attr.data) if color_attr else 0

    bpy.ops.export_scene.fbx(
        filepath=out_fbx,
        use_selection=True,
        object_types={"MESH"},
        bake_anim=False,
        add_leaf_bones=False,
        path_mode="AUTO",
        embed_textures=False,
        apply_scale_options="FBX_SCALE_ALL",
        axis_forward="-Z",
        axis_up="Y",
        colors_type="SRGB",
    )

    print(f"EXPORT_OK: {out_fbx}")
    print(f"EXPORT_MESH: {mesh_obj.name} verts_before={verts_before} verts_after={verts_after} ratio={decimate_ratio}")
    print(f"EXPORT_MATERIAL_SLOTS: {len(mesh_obj.data.materials)}")
    print(f"EXPORT_VERTEX_COLORS: corners={color_count}")


main()
