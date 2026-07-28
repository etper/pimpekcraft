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
var world
var dirty := false
var collision_dirty := true

func place_block(local_pos: Vector3i):
    if blocks.has(local_pos):
        return

    blocks[local_pos] = 1
    collision_dirty = true
    mark_dirty()

func destroy_block(local_pos: Vector3i):
    if !blocks.has(local_pos):
        return

    blocks.erase(local_pos)
    collision_dirty = true
    mark_dirty()

func generate():
    for x in range(SIZE):
        for z in range(SIZE):
            var world_x = int(position.x) + x
            var world_z = int(position.z) + z

            var height = int((noise.get_noise_2d(world_x, world_z) + 1.0) * 0.5 * MAX_HEIGHT)

            for y in range(height):
                blocks[Vector3i(x, y, z)] = 1
    
    collision_dirty = true
    rebuild()

func mark_dirty():
    if dirty:
        return

    dirty = true
    world.queue_chunk_rebuild(self)

func rebuild():
    var mesh = build_mesh()
    apply_mesh(mesh)

    if collision_dirty:
        build_collision(mesh)
        collision_dirty = false

func build_mesh() -> ArrayMesh:
    var start = Time.get_ticks_usec()

    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    for face in range(6):
        greedy_mesh_direction(st, face)

    st.index()
    st.generate_normals()

    var mesh = st.commit()

    Profiler.mesh_time += (Time.get_ticks_usec() - start) / 1000.0

    if mesh.get_surface_count() > 0:
        var arrays = mesh.surface_get_arrays(0)
        Profiler.vertices += arrays[Mesh.ARRAY_VERTEX].size()

        if arrays[Mesh.ARRAY_INDEX].size() > 0:
            Profiler.triangles += arrays[Mesh.ARRAY_INDEX].size() / 3
        else:
            Profiler.triangles += arrays[Mesh.ARRAY_VERTEX].size() / 3

    return mesh

func apply_mesh(mesh: ArrayMesh):
    mesh_instance.mesh = mesh

func build_collision(mesh: ArrayMesh):
    var start = Time.get_ticks_usec()

    collision_shape.shape = mesh.create_trimesh_shape()

    Profiler.collision_time += (
        Time.get_ticks_usec() - start
    ) / 1000.0

func greedy_mesh_direction(st: SurfaceTool, face: int):
    if face != 0: # Only top faces for now
        return

    for y in range(MAX_HEIGHT):

        var mask = []
        for z in range(SIZE):
            mask.append([])
            for x in range(SIZE):

                var pos = Vector3i(x, y, z)

                # Visible top face?
                mask[z].append(
                    blocks.has(pos)
                    and !blocks.has(pos + Vector3i.UP)
                )

        greedy_merge_mask(st, mask, face, y)

func build_mask(slice: int) -> Array:
    var mask := []

    for z in range(SIZE):
        mask.append([])

        for x in range(SIZE):

            var pos = Vector3i(x, slice, z)
            
            var world_pos = Vector3i(
                int(position.x) + pos.x,
                pos.y,
                int(position.z) + pos.z
            )

            var visible = (
                blocks.has(pos)
                and !world.has_block(world_pos + Vector3i.UP)
            )

            mask[z].append(visible)

    return mask

func greedy_merge_mask(st: SurfaceTool, mask: Array, face: int, slice: int):
    var used := []

    for y in range(SIZE):
        used.append([])
        for x in range(SIZE):
            used[y].append(false)

    for y in range(SIZE):
        for x in range(SIZE):

            if !mask[y][x] or used[y][x]:
                continue

            # Find width
            var width := 1
            while x + width < SIZE \
                    and mask[y][x + width] \
                    and !used[y][x + width]:
                width += 1

            # Find height
            var height := 1
            var done := false

            while y + height < SIZE and !done:

                for xx in range(width):
                    if !mask[y + height][x + xx] \
                            or used[y + height][x + xx]:
                        done = true
                        break

                if !done:
                    height += 1

            # Mark rectangle as used
            for yy in range(height):
                for xx in range(width):
                    used[y + yy][x + xx] = true

            # Emit one merged quad
            emit_quad(
                st,
                face,
                slice,
                x,
                y,
                width,
                height
            )
            
func emit_quad(
    st: SurfaceTool,
    face: int,
    slice: int,
    start_x: int,
    start_y: int,
    width: int,
    height: int
):
    var y = slice + 1

    var v0 = Vector3(start_x,         y, start_y)
    var v1 = Vector3(start_x + width, y, start_y)
    var v2 = Vector3(start_x + width, y, start_y + height)
    var v3 = Vector3(start_x,         y, start_y + height)

    st.add_vertex(v0)
    st.add_vertex(v1)
    st.add_vertex(v2)

    st.add_vertex(v0)
    st.add_vertex(v2)
    st.add_vertex(v3)
