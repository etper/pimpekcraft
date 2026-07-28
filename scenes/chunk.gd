extends Node3D

const SIZE = 16
const MAX_HEIGHT = 12

var blocks = {}

var noise : FastNoiseLite

func place_block(local_pos: Vector3i):
	if blocks.has(local_pos):
		return

	var block = preload("res://scenes/Block.tscn").instantiate()
	block.position = Vector3(local_pos)
	add_child(block)

	blocks[local_pos] = block

func destroy_block(local_pos: Vector3i):
	if !blocks.has(local_pos):
		return

	blocks[local_pos].queue_free()
	blocks.erase(local_pos)

func generate():
	var chunk_origin = Vector3i(position)

	for x in range(SIZE):
		for z in range(SIZE):

			var world_x = chunk_origin.x + x
			var world_z = chunk_origin.z + z

			var height = int(
				(noise.get_noise_2d(world_x, world_z) + 1.0)
				* 0.5
				* MAX_HEIGHT
			)

			for y in range(height):
				place_block(Vector3i(x, y, z))
