class_name BlockManager

const CHUNK_SIZE = 16

var world


func _init(world_ref):
	world = world_ref


func has_block(pos: Vector3i):
	var coord = get_chunk_coord(pos)

	if !world.chunk_manager.chunks.has(coord):
		return false

	return world.chunk_manager.chunks[coord].blocks.has(
		get_local_pos(pos)
	)


func destroy_block(pos: Vector3i):
	var coord = get_chunk_coord(pos)

	if !world.chunk_manager.chunks.has(coord):
		return ItemDB.Block.AIR

	var chunk = world.chunk_manager.chunks[coord]
	var local_pos = get_local_pos(pos)

	if !chunk.blocks.has(local_pos):
		return ItemDB.Block.AIR

	var block_id = chunk.blocks[local_pos]

	chunk.destroy_block(local_pos)

	return block_id


func place_block(pos: Vector3i, block_id:int):
	var chunk = world.chunk_manager.get_chunk(
		get_chunk_coord(pos)
	)

	chunk.place_block(
		get_local_pos(pos),
		block_id
	)

	return true


func get_chunk_coord(pos: Vector3i):
	return Vector2i(
		floori(pos.x / CHUNK_SIZE),
		floori(pos.z / CHUNK_SIZE)
	)


func get_local_pos(pos: Vector3i):
	return Vector3i(
		pos.x % CHUNK_SIZE,
		pos.y,
		pos.z % CHUNK_SIZE
	)
