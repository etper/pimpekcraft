extends Node3D

const SIZE = 16
const MAX_HEIGHT = 12

const FACE_NORMALS = [
    Vector3i(0, 1, 0),   # Top
    Vector3i(0, -1, 0),  # Bottom
    Vector3i(-1, 0, 0),  # Left
    Vector3i(1, 0, 0),   # Right
    Vector3i(0, 0, -1),  # Front
    Vector3i(0, 0, 1),   # Back
]

const FACE_VERTICES = [
    # Top
    [
        Vector3(0,1,0), Vector3(1,1,0), Vector3(1,1,1),
        Vector3(0,1,0), Vector3(1,1,1), Vector3(0,1,1)
    ],

    # Bottom
    [
        Vector3(0,0,0), Vector3(1,0,0), Vector3(1,0,1),
        Vector3(0,0,0), Vector3(1,0,1), Vector3(0,0,1)
    ],

    # Left
    [
        Vector3(0,0,0), Vector3(0,1,1), Vector3(0,0,1),
        Vector3(0,0,0), Vector3(0,1,0), Vector3(0,1,1)
    ],

    # Right
    [
        Vector3(1,0,0), Vector3(1,0,1), Vector3(1,1,1),
        Vector3(1,0,0), Vector3(1,1,1), Vector3(1,1,0)
    ],

    # Front
    [
        Vector3(0,0,0), Vector3(1,1,0), Vector3(1,0,0),
        Vector3(0,0,0), Vector3(0,1,0), Vector3(1,1,0)
    ],

    # Back
    [
        Vector3(0,0,1), Vector3(1,0,1), Vector3(1,1,1),
        Vector3(0,0,1), Vector3(1,1,1), Vector3(0,1,1)
    ],
]

@onready var mesh_instance = $MeshInstance3D
@onready var collision_shape = $StaticBody3D/CollisionShape3D

var blocks = {}
var noise : FastNoiseLite


func place_block(local_pos: Vector3i):
    if blocks.has(local_pos):
        return

    blocks[local_pos] = 1
    rebuild()


func destroy_block(local_pos: Vector3i):
    if !blocks.has(local_pos):
        return

    blocks.erase(local_pos)
    rebuild()


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

    rebuild()


func rebuild():
    var mesh = build_mesh()
    apply_mesh(mesh)
    build_collision(mesh)


func build_mesh() -> ArrayMesh:
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    for pos in blocks.keys():
        emit_visible_faces(st, pos)

    st.index()
    st.generate_normals()

    return st.commit()


func apply_mesh(mesh: ArrayMesh):
    mesh_instance.mesh = mesh


func build_collision(mesh: ArrayMesh):
    collision_shape.shape = mesh.create_trimesh_shape()


func emit_visible_faces(st: SurfaceTool, pos: Vector3i):
    for face in range(FACE_NORMALS.size()):
        if is_face_visible(pos, face):
            emit_face(st, pos, face)


func is_face_visible(pos: Vector3i, face: int) -> bool:
    return !blocks.has(pos + FACE_NORMALS[face])


func emit_face(st: SurfaceTool, pos: Vector3i, face: int):
    for vertex in FACE_VERTICES[face]:
        st.add_vertex(Vector3(pos) + vertex)
