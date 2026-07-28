class_name ChunkLoader

var world
var noise := FastNoiseLite.new()

const CHUNK_SIZE = 16


func _init(world_ref):
	world = world_ref

	noise.seed = 12345
	noise.frequency = 0.05


func load_start_area():
	for x in range(-1,2):
		for z in range(-1,2):
			get_chunk(Vector2i(x,z))


func get_chunk(coord):

	if world.chunk_manager.chunks.has(coord):
		return world.chunk_manager.chunks[coord]


	var chunk = preload(
        "res://scenes/Chunk.tscn"
	).instantiate()


	chunk.noise = noise
	chunk.world = world

	chunk.position = Vector3(
		coord.x * CHUNK_SIZE,
		0,
		coord.y * CHUNK_SIZE
	)

	world.add_child(chunk)

	chunk.generate()
	chunk.mark_dirty()

	world.chunk_manager.chunks[coord] = chunk

	return chunk
