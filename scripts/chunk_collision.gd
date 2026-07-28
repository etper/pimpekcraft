class_name ChunkCollision


static func build(chunk, mesh):

	var start = Time.get_ticks_usec()

	chunk.collision_shape.shape = (
		mesh.create_trimesh_shape()
	)

	Profiler.collision_time += (
		Time.get_ticks_usec() - start
	) / 1000.0
