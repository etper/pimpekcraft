class_name VoxelMesh


const TILE_SIZE = 16.0
const ATLAS_SIZE = 256.0
const UV_SIZE = TILE_SIZE / ATLAS_SIZE


const FACE_NORMALS = [
	Vector3i(0, 1, 0),    # Top
	Vector3i(0, -1, 0),   # Bottom
	Vector3i(-1, 0, 0),   # Left
	Vector3i(1, 0, 0),    # Right
	Vector3i(0, 0, -1),   # Front
	Vector3i(0, 0, 1),    # Back
]


const FACE_AXES = [
	{ plane = 1, u = 0, v = 2, positive = true },
	{ plane = 1, u = 0, v = 2, positive = false },
	{ plane = 0, u = 2, v = 1, positive = false },
	{ plane = 0, u = 2, v = 1, positive = true },
	{ plane = 2, u = 0, v = 1, positive = false },
	{ plane = 2, u = 0, v = 1, positive = true },
]


static func build(chunk):

	var start = Time.get_ticks_usec()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for face in range(6):
		greedy_mesh_direction(
			chunk,
			st,
			face
		)

	st.index()
	st.generate_normals()

	var mesh = st.commit()


	if mesh != null and mesh.get_surface_count() > 0:

		var arrays = mesh.surface_get_arrays(0)

		Profiler.vertices += (
			arrays[Mesh.ARRAY_VERTEX].size()
		)

		if arrays[Mesh.ARRAY_INDEX].size() > 0:
			Profiler.triangles += (
				arrays[Mesh.ARRAY_INDEX].size() / 3
			)
		else:
			Profiler.triangles += (
				arrays[Mesh.ARRAY_VERTEX].size() / 3
			)


	Profiler.mesh_time += (
		Time.get_ticks_usec() - start
	) / 1000.0


	return mesh

static func greedy_mesh_direction(chunk, st: SurfaceTool, face: int):

	if face == 0 or face == 1:

		for y in range(chunk_generator_height()):
			var mask = build_mask(chunk, face, y)
			greedy_merge_mask(
				chunk,
				st,
				mask,
				face,
				y
			)


	elif face == 2 or face == 3:

		for x in range(16):
			var mask = build_mask_x(chunk, face, x)

			greedy_merge_mask_x(
				chunk,
				st,
				mask,
				face,
				x
			)


	elif face == 4 or face == 5:

		for z in range(16):

			var mask = build_mask_z(chunk, face, z)

			greedy_merge_mask_z(
				chunk,
				st,
				mask,
				face,
				z
			)



static func chunk_generator_height():

	return 12



static func build_mask(chunk, face: int, slice: int):

	var mask = []

	var normal = FACE_NORMALS[face]


	for z in range(chunk.SIZE):

		mask.append([])


		for x in range(chunk.SIZE):

			var pos = Vector3i(
				x,
				slice,
				z
			)


			var world_pos = Vector3i(
				int(chunk.position.x) + pos.x,
				pos.y,
				int(chunk.position.z) + pos.z
			)


			var visible = (
				chunk.blocks.has(pos)
				and !chunk.world.has_block(
					world_pos + normal
				)
			)


			if visible:
				mask[z].append(
					chunk.blocks[pos]
				)
			else:
				mask[z].append(0)


	return mask



static func build_mask_x(chunk, face: int, slice: int):

	var mask = []

	var normal = FACE_NORMALS[face]


	for z in range(chunk.SIZE):

		mask.append([])


		for y in range(12):

			var pos = Vector3i(
				slice,
				y,
				z
			)


			var world_pos = Vector3i(
				int(chunk.position.x) + pos.x,
				pos.y,
				int(chunk.position.z) + pos.z
			)


			var visible = (
				chunk.blocks.has(pos)
				and !chunk.world.has_block(
					world_pos + normal
				)
			)


			if visible:
				mask[z].append(
					chunk.blocks[pos]
				)
			else:
				mask[z].append(0)


	return mask



static func build_mask_z(chunk, face: int, slice: int):

	var mask = []

	var normal = FACE_NORMALS[face]


	for y in range(12):

		mask.append([])


		for x in range(chunk.SIZE):

			var pos = Vector3i(
				x,
				y,
				slice
			)


			var world_pos = Vector3i(
				int(chunk.position.x) + pos.x,
				pos.y,
				int(chunk.position.z) + pos.z
			)


			var visible = (
				chunk.blocks.has(pos)
				and !chunk.world.has_block(
					world_pos + normal
				)
			)


			if visible:
				mask[y].append(
					chunk.blocks[pos]
				)
			else:
				mask[y].append(0)


	return mask

static func greedy_merge_mask(
	chunk,
	st: SurfaceTool,
	mask: Array,
	face: int,
	slice: int
):

	var used = []

	for y in range(chunk.SIZE):
		used.append([])

		for x in range(chunk.SIZE):
			used[y].append(false)


	for y in range(chunk.SIZE):

		for x in range(chunk.SIZE):

			if !mask[y][x] or used[y][x]:
				continue


			var width = 1

			while (
				x + width < chunk.SIZE
				and mask[y][x + width]
				and !used[y][x + width]
			):
				width += 1



			var height = 1
			var done = false


			while (
				y + height < chunk.SIZE
				and !done
			):

				for xx in range(width):

					if (
						!mask[y + height][x + xx]
						or used[y + height][x + xx]
					):
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



static func greedy_merge_mask_x(
	chunk,
	st: SurfaceTool,
	mask: Array,
	face: int,
	slice: int
):

	var rows = mask.size()
	var cols = mask[0].size()

	var used = []

	for y in range(rows):

		used.append([])

		for x in range(cols):
			used[y].append(false)



	for y in range(rows):

		for x in range(cols):

			if !mask[y][x] or used[y][x]:
				continue


			var width = 1


			while (
				x + width < cols
				and mask[y][x + width]
				and !used[y][x + width]
			):
				width += 1



			var height = 1
			var done = false


			while (
				y + height < rows
				and !done
			):

				for xx in range(width):

					if (
						!mask[y + height][x + xx]
						or used[y + height][x + xx]
					):
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
				y,
				x,
				height,
				width
			)



static func greedy_merge_mask_z(
	chunk,
	st: SurfaceTool,
	mask: Array,
	face: int,
	slice: int
):

	var rows = mask.size()
	var cols = mask[0].size()

	var used = []

	for y in range(rows):

		used.append([])

		for x in range(cols):

			used[y].append(false)



	for y in range(rows):

		for x in range(cols):

			if !mask[y][x] or used[y][x]:
				continue


			var width = 1


			while (
				x + width < cols
				and mask[y][x + width]
				and !used[y][x + width]
			):
				width += 1



			var height = 1
			var done = false


			while (
				y + height < rows
				and !done
			):

				for xx in range(width):

					if (
						!mask[y + height][x + xx]
						or used[y + height][x + xx]
					):
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



static func make_vertex(
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

	return Vector3(
		c[0],
		c[1],
		c[2]
	)



static func get_face_tile(
	block_id: int,
	face: int
) -> Vector2i:

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



static func emit_quad(
	st: SurfaceTool,
	face: int,
	slice: int,
	start_u: int,
	start_v: int,
	size_u: int,
	size_v: int
):

	var info = FACE_AXES[face]


	var plane = (
		slice + 1
		if info.positive
		else slice
	)


	var v0 = make_vertex(
		info.plane,
		plane,
		info.u,
		start_u,
		info.v,
		start_v
	)


	var v1 = make_vertex(
		info.plane,
		plane,
		info.u,
		start_u + size_u,
		info.v,
		start_v
	)


	var v2 = make_vertex(
		info.plane,
		plane,
		info.u,
		start_u + size_u,
		info.v,
		start_v + size_v
	)


	var v3 = make_vertex(
		info.plane,
		plane,
		info.u,
		start_u,
		info.v,
		start_v + size_v
	)



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
