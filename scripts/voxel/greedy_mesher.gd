class_name GreedyMesher


static func mesh_direction(chunk, st, face):

	if face <= 1:
		for y in range(12):
			var mask = build_mask(chunk, face, y)
			merge_mask(chunk, st, mask, face, y)

	elif face <= 3:
		for x in range(16):
			var mask = build_mask_x(chunk, face, x)
			merge_mask(chunk, st, mask, face, x)

	else:
		for z in range(16):
			var mask = build_mask_z(chunk, face, z)
			merge_mask(chunk, st, mask, face, z)
