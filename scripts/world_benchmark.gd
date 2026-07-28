class_name WorldBenchmark

var world


func _init(world_ref):
	world = world_ref


func benchmark_place():
	var start = Time.get_ticks_usec()

	for x in range(10):
		for z in range(10):
			world.place_block(
				Vector3i(x, 20, z),
				ItemDB.Block.DIRT
			)

	var time_ms = (
		Time.get_ticks_usec() - start
	) / 1000.0

	print("------------------------------")
	print("Benchmark Place")
	print("Time:", time_ms, " ms")
	print("FPS:", Engine.get_frames_per_second())
