class_name ChunkGenerator


const MAX_HEIGHT = 12


static func generate(chunk):

	for x in range(chunk.SIZE):
		for z in range(chunk.SIZE):

			var world_x = int(chunk.position.x)+x
			var world_z = int(chunk.position.z)+z

			var height = int(
				(chunk.noise.get_noise_2d(world_x,world_z)+1.0)
				*0.5*MAX_HEIGHT
			)

			for y in range(height):
				chunk.blocks[Vector3i(x,y,z)] = 1
