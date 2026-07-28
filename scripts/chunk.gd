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
        add_cube(st, pos)

    mesh_instance.mesh = st.commit()

func add_cube(st, pos):
    pass
    # add 6 faces here
