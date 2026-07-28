extends Node3D

const CHUNK_SIZE = 16

var chunks = {}

func get_chunk_coord(pos: Vector3i) -> Vector2i:
	return Vector2i(
		floori(pos.x / CHUNK_SIZE),
		floori(pos.z / CHUNK_SIZE)
	)

func get_local_pos(pos: Vector3i) -> Vector3i:
	return Vector3i(
		pos.x % CHUNK_SIZE,
		pos.y,
		pos.z % CHUNK_SIZE
	)

func get_chunk(chunk_coord: Vector2i):

	if !chunks.has(chunk_coord):

		var chunk = preload("res://scenes/Chunk.tscn").instantiate()

		chunk.position = Vector3(
			chunk_coord.x * CHUNK_SIZE,
			0,
			chunk_coord.y * CHUNK_SIZE
		)

		add_child(chunk)

		chunks[chunk_coord] = chunk

	return chunks[chunk_coord]

func place_block(world_pos: Vector3i):

	var chunk = get_chunk(get_chunk_coord(world_pos))
	chunk.place_block(get_local_pos(world_pos))

func destroy_block(world_pos: Vector3i):

	var coord = get_chunk_coord(world_pos)

	if !chunks.has(coord):
		return

	chunks[coord].destroy_block(get_local_pos(world_pos))
