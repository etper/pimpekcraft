extends Node3D

const CHUNK_SIZE = 16

var chunks = {}
var rebuild_queue: Array = []
@export var radius := 1
const REBUILDS_PER_FRAME := 2

var noise := FastNoiseLite.new()

func _ready():
	noise.seed = 12345
	noise.frequency = 0.05
	
	for x in range(-radius, radius + 1):
		for z in range(-radius, radius + 1):
			get_chunk(Vector2i(x, z))

func _process(_delta):
	var count: int = min(REBUILDS_PER_FRAME, rebuild_queue.size())

	for i in range(count):
		var chunk = rebuild_queue.pop_front()

		if !is_instance_valid(chunk):
			continue

		chunk.dirty = false
		chunk.rebuild()

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

func has_block(world_pos: Vector3i) -> bool:
	var coord = get_chunk_coord(world_pos)

	if !chunks.has(coord):
		return false

	var chunk = chunks[coord]
	return chunk.blocks.has(get_local_pos(world_pos))

func get_chunk(chunk_coord: Vector2i):

	if !chunks.has(chunk_coord):

		var chunk = preload("res://scenes/Chunk.tscn").instantiate()

		chunk.noise = noise
		chunk.world = self

		chunk.position = Vector3(
			chunk_coord.x * CHUNK_SIZE,
			0,
			chunk_coord.y * CHUNK_SIZE
		)

		add_child(chunk)

		chunk.generate()

		chunks[chunk_coord] = chunk

	return chunks[chunk_coord]

func queue_chunk_rebuild(chunk):
	if rebuild_queue.has(chunk):
		return

	rebuild_queue.append(chunk)

func place_block(world_pos: Vector3i):

	var coord = get_chunk_coord(world_pos)
	var local = get_local_pos(world_pos)

	var chunk = get_chunk(coord)
	chunk.place_block(local)

	if local.x == 0:
		get_chunk(coord + Vector2i(-1, 0)).mark_dirty()

	if local.x == CHUNK_SIZE - 1:
		get_chunk(coord + Vector2i(1, 0)).mark_dirty()

	if local.z == 0:
		get_chunk(coord + Vector2i(0, -1)).mark_dirty()

	if local.z == CHUNK_SIZE - 1:
		get_chunk(coord + Vector2i(0, 1)).mark_dirty()

func destroy_block(world_pos: Vector3i):

	var coord = get_chunk_coord(world_pos)

	if !chunks.has(coord):
		return

	var local = get_local_pos(world_pos)

	chunks[coord].destroy_block(local)

	if local.x == 0:
		get_chunk(coord + Vector2i(-1, 0)).mark_dirty()

	if local.x == CHUNK_SIZE - 1:
		get_chunk(coord + Vector2i(1, 0)).mark_dirty()

	if local.z == 0:
		get_chunk(coord + Vector2i(0, -1)).mark_dirty()

	if local.z == CHUNK_SIZE - 1:
		get_chunk(coord + Vector2i(0, 1)).mark_dirty()

func benchmark_place():
	#Profiler.reset()
	
	for x in range(10):
		for z in range(10):
			place_block(Vector3i(x, 20, z))

	Profiler.print_results()

func benchmark_mine():
	
	Profiler.reset()
	
	var count := 0

	for chunk in chunks.values():
		for block in chunk.blocks.keys():

			destroy_block(
				Vector3i(
					chunk.position.x,
					0,
					chunk.position.z
				) + block
			)

			count += 1

			if count >= 100:
				Profiler.print_results()
				return

func _input(event):
	if event.is_action_pressed("ui_accept"):
		Profiler.print_results()
