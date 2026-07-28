class_name WorldSave

var world


func _init(world_ref):
	world = world_ref


func save_world():

	var data = {}

	for coord in world.chunks:
		var chunk = world.chunks[coord]

		data[str(coord)] = chunk.blocks


	var file = FileAccess.open(
		"user://world.save",
		FileAccess.WRITE
	)

	file.store_var(data)



func load_world():

	if !FileAccess.file_exists(
        "user://world.save"
	):
		return

	var file = FileAccess.open(
		"user://world.save",
		FileAccess.READ
	)

	var data = file.get_var()
