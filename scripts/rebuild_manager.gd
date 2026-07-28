class_name RebuildManager

var world
var queue = []


func _init(world_ref):
	world = world_ref


func process():
	if queue.is_empty():
		return

	var chunk = queue.pop_front()
	chunk.rebuild()


func queue_chunk_rebuild(chunk):
	if queue.has(chunk):
		return

	queue.append(chunk)
