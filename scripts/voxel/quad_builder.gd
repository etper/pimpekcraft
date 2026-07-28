class_name QuadBuilder


static func emit_quad(
	st,
	face,
	slice,
	start_u,
	start_v,
	size_u,
	size_v
):

	var info = VoxelFaces.AXES[face]

	# vertex creation here

	st.add_vertex(v0)
	st.add_vertex(v1)
	st.add_vertex(v2)
