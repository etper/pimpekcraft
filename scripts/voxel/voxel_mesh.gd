class_name VoxelMesh

static func build(chunk):
	var start = Time.get_ticks_usec()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for face in range(6):
		GreedyMesher.mesh_direction(
			chunk,
			st,
			face
		)

	st.index()
	st.generate_normals()

	var mesh = st.commit()

	Profiler.mesh_time += (
		Time.get_ticks_usec() - start
	) / 1000.0

	return mesh
