extends Node3D

const CHUNK_SIZE = 16

var chunks = {}
var rebuild_queue = []

var chunk_loader
var save_system

func _ready():
	chunk_loader = ChunkLoader.new(self)
	save_system = WorldSave.new(self)

	chunk_loader.load_start_area()

func _process(delta):
	if rebuild_queue.is_empty():
		return

	var chunk = rebuild_queue.pop_front()
	chunk.rebuild()

func get_chunk(coord: Vector2i):
	return chunk_loader.get_chunk(coord)

func has_block(pos: Vector3i):
	var coord = get_chunk_coord(pos)

	if !chunks.has(coord):
		return false

	return chunks[coord].blocks.has(get_local_pos(pos))


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

func queue_chunk_rebuild(chunk):
	if rebuild_queue.has(chunk):
		return

	rebuild_queue.append(chunk)

func destroy_block(pos: Vector3i):
	var coord = get_chunk_coord(pos)

	if !chunks.has(coord):
		return ItemDB.Block.AIR

	var chunk = chunks[coord]
	var local_pos = get_local_pos(pos)

	if !chunk.blocks.has(local_pos):
		return ItemDB.Block.AIR

	var block_id = chunk.blocks[local_pos]

	chunk.destroy_block(local_pos)

	return block_id


func place_block(pos: Vector3i, block_id: int):
	var coord = get_chunk_coord(pos)

	var chunk = get_chunk(coord)
	var local_pos = get_local_pos(pos)

	chunk.place_block(local_pos, block_id)

	return true
