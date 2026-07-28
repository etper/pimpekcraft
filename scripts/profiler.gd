extends Node

var mesh_time := 0.0
var collision_time := 0.0

var vertices := 0
var triangles := 0

func reset():
	mesh_time = 0
	collision_time = 0
	vertices = 0
	triangles = 0

func print_results():
	print("--------------------------------")
	print("Mesh:", mesh_time, " ms")
	print("Collision:", collision_time, " ms")
	print("Vertices:", vertices)
	print("Triangles:", triangles)
	print("FPS:", Engine.get_frames_per_second())
