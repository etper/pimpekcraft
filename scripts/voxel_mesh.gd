class_name VoxelMesh


static func build(chunk):

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

	return st.commit()
