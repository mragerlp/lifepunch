"""Bake pc_box hub BaseColor PNG from FBX + AO (source zip has no albedo).

Usage:
  blender --background --python Export-PcBoxHubTextures.py -- <fbx> <ao_png> <out_basecolor_png> [curv_png]
"""
import os
import sys
import bpy

argv = sys.argv
argv = argv[argv.index("--") + 1 :] if "--" in argv else []
fbx_path = argv[0] if len(argv) > 0 else ""
ao_path = argv[1] if len(argv) > 1 else ""
out_png = argv[2] if len(argv) > 2 else ""
curv_path = argv[3] if len(argv) > 3 else ""

if not fbx_path or not ao_path or not out_png:
    raise SystemExit("usage: blender --background --python Export-PcBoxHubTextures.py -- <fbx> <ao> <out_basecolor> [curv]")

BAKE_SIZE = 2048
BASE_RGB = (0.11, 0.11, 0.12, 1.0)  # dark case — matches gpu-rack lane


def join_meshes():
    objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not objs:
        raise RuntimeError("no mesh in fbx")
    if len(objs) == 1:
        return objs[0]
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    return bpy.context.view_layer.objects.active


def ensure_uv(obj):
    mesh = obj.data
    if mesh.uv_layers:
        return
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=66, island_margin=0.02)
    bpy.ops.object.mode_set(mode="OBJECT")


def bake_basecolor(obj):
    os.makedirs(os.path.dirname(os.path.abspath(out_png)), exist_ok=True)

    mat = bpy.data.materials.new("PcBoxBake")
    mat.use_nodes = True
    nt = mat.node_tree
    for node in list(nt.nodes):
        nt.nodes.remove(node)

    out = nt.nodes.new("ShaderNodeOutputMaterial")
    emit = nt.nodes.new("ShaderNodeEmission")
    out.location = (400, 0)
    emit.location = (200, 0)

    base = nt.nodes.new("ShaderNodeRGB")
    base.outputs[0].default_value = BASE_RGB
    base.location = (-600, 100)

    ao = nt.nodes.new("ShaderNodeTexImage")
    ao.image = bpy.data.images.load(ao_path, check_existing=True)
    ao.location = (-600, -120)

    mix = nt.nodes.new("ShaderNodeMixRGB")
    mix.blend_type = "MULTIPLY"
    mix.inputs["Fac"].default_value = 1.0
    mix.location = (-200, 0)

    nt.links.new(base.outputs[0], mix.inputs[1])
    nt.links.new(ao.outputs[0], mix.inputs[2])

    if curv_path and os.path.isfile(curv_path):
        curv = nt.nodes.new("ShaderNodeTexImage")
        curv.image = bpy.data.images.load(curv_path, check_existing=True)
        curv.location = (-600, -340)
        mix2 = nt.nodes.new("ShaderNodeMixRGB")
        mix2.blend_type = "MULTIPLY"
        mix2.inputs["Fac"].default_value = 0.35
        mix2.location = (0, 0)
        nt.links.new(mix.outputs[0], mix2.inputs[1])
        nt.links.new(curv.outputs[0], mix2.inputs[2])
        nt.links.new(mix2.outputs[0], emit.inputs["Color"])
    else:
        nt.links.new(mix.outputs[0], emit.inputs["Color"])

    nt.links.new(emit.outputs[0], out.inputs["Surface"])

    obj.data.materials.clear()
    obj.data.materials.append(mat)

    img = bpy.data.images.new("PcBoxBaseColor", BAKE_SIZE, BAKE_SIZE)
    bake_node = nt.nodes.new("ShaderNodeTexImage")
    bake_node.image = img
    bake_node.select = True
    nt.nodes.active = bake_node

    bpy.context.scene.render.engine = "CYCLES"
    bpy.context.scene.cycles.device = "CPU"
    bpy.context.scene.cycles.samples = 16
    bpy.context.scene.render.bake.use_clear = True
    bpy.context.scene.render.bake.margin = 8

    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.bake(type="EMIT")

    img.filepath_raw = out_png
    img.file_format = "PNG"
    img.save()
    print("BAKED", out_png, BAKE_SIZE)


bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=fbx_path)
obj = join_meshes()
ensure_uv(obj)
bake_basecolor(obj)
