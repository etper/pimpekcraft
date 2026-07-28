extends Node3D

const SIZE = 16
const MAX_HEIGHT = 12
const TILE_SIZE = 16.0
const ATLAS_SIZE = 256.0
const UV_SIZE = TILE_SIZE / ATLAS_SIZE

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

func place_block(local_pos: Vector3i, block_id: int):
    if blocks.has(local_pos):
        return

    blocks[local_pos] = block_id
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
    if face == 0 or face == 1:
        for y in range(MAX_HEIGHT):
            var mask = build_mask(face, y)
            greedy_merge_mask(st, mask, face, y)

    elif face == 2 or face == 3:
        for x in range(SIZE):
            var mask = build_mask_x(face, x)
            greedy_merge_mask_x(st, mask, face, x)
    
    elif face == 4 or face == 5:
        for z in range(SIZE):
            var mask = build_mask_z(face, z)
            greedy_merge_mask_z(st, mask, face, z)    

func build_mask(face: int, slice: int) -> Array:
    var mask := []
    var normal = FACE_NORMALS[face]

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
                and !world.has_block(world_pos + normal)
            )

            if visible:
                mask[z].append(blocks[pos])
            else:
                mask[z].append(0)

    return mask

func build_mask_x(face: int, slice: int) -> Array:
    var mask := []
    var normal = FACE_NORMALS[face]

    for z in range(SIZE):
        mask.append([])

        for y in range(MAX_HEIGHT):
            var pos = Vector3i(slice, y, z)

            var world_pos = Vector3i(
                int(position.x) + pos.x,
                pos.y,
                int(position.z) + pos.z
            )

            var visible = (
                blocks.has(pos)
                and !world.has_block(world_pos + normal)
            )

            if visible:
                mask[z].append(blocks[pos])
            else:
                mask[z].append(0)

    return mask

func build_mask_z(face: int, slice: int) -> Array:
    var mask := []
    var normal = FACE_NORMALS[face]

    for y in range(MAX_HEIGHT):
        mask.append([])

        for x in range(SIZE):
            var pos = Vector3i(x, y, slice)

            var world_pos = Vector3i(
                int(position.x) + pos.x,
                pos.y,
                int(position.z) + pos.z
            )

            var visible = (
                blocks.has(pos)
                and !world.has_block(world_pos + normal)
            )

            mask[y].append(visible)

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

func greedy_merge_mask_x(st, mask, face, slice):
    var rows = mask.size()       # Z
    var cols = mask[0].size()    # Y

    var used := []

    for y in range(rows):
        used.append([])
        for x in range(cols):
            used[y].append(false)

    for y in range(rows):
        for x in range(cols):

            if !mask[y][x] or used[y][x]:
                continue

            # Find width (along Y)
            var width := 1
            while x + width < cols \
                    and mask[y][x + width] \
                    and !used[y][x + width]:
                width += 1

            # Find height (along Z)
            var height := 1
            var done := false

            while y + height < rows and !done:

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
                y,       # start_z
                x,       # start_y
                height,  # size in Z
                width    # size in Y
            )

func greedy_merge_mask_z(st, mask, face, slice):
    var rows = mask.size()       # Y
    var cols = mask[0].size()    # X

    var used := []

    for y in range(rows):
        used.append([])
        for x in range(cols):
            used[y].append(false)

    for y in range(rows):
        for x in range(cols):

            if !mask[y][x] or used[y][x]:
                continue

            var width := 1
            while x + width < cols \
                    and mask[y][x + width] \
                    and !used[y][x + width]:
                width += 1

            var height := 1
            var done := false

            while y + height < rows and !done:

                for xx in range(width):
                    if !mask[y + height][x + xx] \
                            or used[y + height][x + xx]:
                        done = true
                        break

                if !done:
                    height += 1

            for yy in range(height):
                for xx in range(width):
                    used[y + yy][x + xx] = true

            emit_quad(
                st,
                face,
                slice,
                x,
                y,
                width,
                height
            )

func make_vertex(
    plane_axis: int,
    plane_value: float,
    u_axis: int,
    u: float,
    v_axis: int,
    v: float
) -> Vector3:
    var c = [0.0, 0.0, 0.0]

    c[plane_axis] = plane_value
    c[u_axis] = u
    c[v_axis] = v

    return Vector3(c[0], c[1], c[2])

const FACE_AXES = [
    { plane = 1, u = 0, v = 2, positive = true  },  # Top
    { plane = 1, u = 0, v = 2, positive = false },  # Bottom
    { plane = 0, u = 2, v = 1, positive = false },  # Left
    { plane = 0, u = 2, v = 1, positive = true  },  # Right
    { plane = 2, u = 0, v = 1, positive = false },  # Front
    { plane = 2, u = 0, v = 1, positive = true  },  # Back
]

func get_face_tile(block_id:int, face:int) -> Vector2i:
    var info = ItemDB.BLOCK_TEXTURES[block_id]

    if info.has("all"):
        return info["all"]

    match face:
        0:
            return info["top"]
        1:
            return info["bottom"]
        _:
            return info["side"]

func emit_quad(
    st: SurfaceTool,
    face: int,
    slice: int,
    start_u: int,
    start_v: int,
    size_u: int,
    size_v: int
):
    var info = FACE_AXES[face]

    var plane = slice + 1 if info.positive else slice

    var v0 = make_vertex(info.plane, plane, info.u,
        start_u, info.v, start_v)

    var v1 = make_vertex(info.plane, plane, info.u,
        start_u + size_u, info.v, start_v)

    var v2 = make_vertex(info.plane, plane, info.u,
        start_u + size_u, info.v, start_v + size_v)

    var v3 = make_vertex(info.plane, plane, info.u,
        start_u, info.v, start_v + size_v)

    if info.positive:
        st.add_vertex(v0)
        st.add_vertex(v1)
        st.add_vertex(v2)

        st.add_vertex(v0)
        st.add_vertex(v2)
        st.add_vertex(v3)
    else:
        st.add_vertex(v0)
        st.add_vertex(v2)
        st.add_vertex(v1)

        st.add_vertex(v0)
        st.add_vertex(v3)
        st.add_vertex(v2)
