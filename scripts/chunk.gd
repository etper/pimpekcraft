extends Node3D

const SIZE = 16
const MAX_HEIGHT = 12

@onready var mesh_instance = $MeshInstance3D

var blocks = {}

var noise : FastNoiseLite

func place_block(local_pos: Vector3i):
    if blocks.has(local_pos):
        return

    blocks[local_pos] = 1
    rebuild_mesh()

func destroy_block(local_pos: Vector3i):
    if !blocks.has(local_pos):
        return

    blocks.erase(local_pos)
    rebuild_mesh()

func generate():
    var chunk_origin = Vector3i(position)

    for x in range(SIZE):
        for z in range(SIZE):

            var world_x = chunk_origin.x + x
            var world_z = chunk_origin.z + z

            var height = int(
                (noise.get_noise_2d(world_x, world_z) + 1.0)
                * 0.5
                * MAX_HEIGHT
            )

            for y in range(height):
                blocks[Vector3i(x, y, z)] = 1
    
    rebuild_mesh()

func rebuild_mesh():
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    for pos in blocks.keys():
        add_visible_faces(st, pos)

    st.generate_normals()

    var mesh = st.commit()
    mesh_instance.mesh = mesh

    $StaticBody3D/CollisionShape3D.shape = mesh.create_trimesh_shape()

func add_visible_faces(st: SurfaceTool, pos: Vector3):
    if !blocks.has(Vector3i(pos) + Vector3i(0, 1, 0)):
        add_top_face(st, pos)

    if !blocks.has(Vector3i(pos) + Vector3i(0, -1, 0)):
        add_bottom_face(st, pos)

    if !blocks.has(Vector3i(pos) + Vector3i(-1, 0, 0)):
        add_left_face(st, pos)

    if !blocks.has(Vector3i(pos) + Vector3i(1, 0, 0)):
        add_right_face(st, pos)

    if !blocks.has(Vector3i(pos) + Vector3i(0, 0, -1)):
        add_front_face(st, pos)

    if !blocks.has(Vector3i(pos) + Vector3i(0, 0, 1)):
        add_back_face(st, pos)

func add_top_face(st: SurfaceTool, p: Vector3):
    st.set_normal(Vector3.UP)
    st.add_vertex(p + Vector3(0,1,0))
    st.add_vertex(p + Vector3(1,1,0))
    st.add_vertex(p + Vector3(1,1,1))

    st.set_normal(Vector3.UP)
    st.add_vertex(p + Vector3(0,1,0))
    st.add_vertex(p + Vector3(1,1,1))
    st.add_vertex(p + Vector3(0,1,1))

func add_bottom_face(st: SurfaceTool, p: Vector3):
    st.set_normal(Vector3.DOWN)
    st.add_vertex(p + Vector3(0,0,0))
    st.add_vertex(p + Vector3(1,0,1))
    st.add_vertex(p + Vector3(1,0,0))

    st.set_normal(Vector3.DOWN)
    st.add_vertex(p + Vector3(0,0,0))
    st.add_vertex(p + Vector3(0,0,1))
    st.add_vertex(p + Vector3(1,0,1))

func add_front_face(st: SurfaceTool, p: Vector3):
    st.set_normal(Vector3(0,0,-1))
    st.add_vertex(p + Vector3(0,0,0))
    st.add_vertex(p + Vector3(1,1,0))
    st.add_vertex(p + Vector3(1,0,0))

    st.set_normal(Vector3(0,0,-1))
    st.add_vertex(p + Vector3(0,0,0))
    st.add_vertex(p + Vector3(0,1,0))
    st.add_vertex(p + Vector3(1,1,0))

func add_back_face(st: SurfaceTool, p: Vector3):
    st.set_normal(Vector3(0,0,1))
    st.add_vertex(p + Vector3(0,0,1))
    st.add_vertex(p + Vector3(1,0,1))
    st.add_vertex(p + Vector3(1,1,1))

    st.set_normal(Vector3(0,0,1))
    st.add_vertex(p + Vector3(0,0,1))
    st.add_vertex(p + Vector3(1,1,1))
    st.add_vertex(p + Vector3(0,1,1))

func add_left_face(st: SurfaceTool, p: Vector3):
    st.set_normal(Vector3(-1,0,0))
    st.add_vertex(p + Vector3(0,0,0))
    st.add_vertex(p + Vector3(0,0,1))
    st.add_vertex(p + Vector3(0,1,1))

    st.set_normal(Vector3(-1,0,0))
    st.add_vertex(p + Vector3(0,0,0))
    st.add_vertex(p + Vector3(0,1,1))
    st.add_vertex(p + Vector3(0,1,0))

func add_right_face(st: SurfaceTool, p: Vector3):
    st.set_normal(Vector3(1,0,0))
    st.add_vertex(p + Vector3(1,0,0))
    st.add_vertex(p + Vector3(1,1,1))
    st.add_vertex(p + Vector3(1,0,1))

    st.set_normal(Vector3(1,0,0))
    st.add_vertex(p + Vector3(1,0,0))
    st.add_vertex(p + Vector3(1,1,0))
    st.add_vertex(p + Vector3(1,1,1))
