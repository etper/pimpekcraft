extends Node3D

const SIZE = 16

var blocks = {}

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
