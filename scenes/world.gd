extends Node3D

var blocks = {}

func place_block(pos: Vector3i):
	if blocks.has(pos):
		return

	var block = preload("res://scenes/Block.tscn").instantiate()
	block.position = Vector3(pos)
	add_child(block)

	blocks[pos] = block

func destroy_block(pos: Vector3i):
	if !blocks.has(pos):
		return

	blocks[pos].queue_free()
	blocks.erase(pos)
