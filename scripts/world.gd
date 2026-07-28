extends Node3D


var chunk_manager
var block_manager
var rebuild_manager
var save_system


func _ready():

	chunk_manager = ChunkManager.new(self)
	block_manager = BlockManager.new(self)
	rebuild_manager = RebuildManager.new(self)
	save_system = WorldSave.new(self)

	chunk_manager.load_start_area()


func _process(delta):
	rebuild_manager.process()


func has_block(pos):
	return block_manager.has_block(pos)


func destroy_block(pos):
	return block_manager.destroy_block(pos)


func place_block(pos, id):
	return block_manager.place_block(pos,id)


func queue_chunk_rebuild(chunk):
	rebuild_manager.queue_chunk_rebuild(chunk)
