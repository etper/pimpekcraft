class_name ChunkManager

const CHUNK_SIZE = 16

var world
var chunks = {}
var loader


func _init(world_ref):
	world = world_ref
	loader = ChunkLoader.new(world)


func load_start_area():
	loader.load_start_area()


func get_chunk(coord: Vector2i):
	return loader.get_chunk(coord)
