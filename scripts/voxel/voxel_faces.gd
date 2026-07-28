const FACE_NORMALS = [
	Vector3i(0,1,0),
	Vector3i(0,-1,0),
	Vector3i(-1,0,0),
	Vector3i(1,0,0),
	Vector3i(0,0,-1),
	Vector3i(0,0,1)
]


const FACE_AXES = [
	{ plane = 1, u = 0, v = 2, positive = true },
	{ plane = 1, u = 0, v = 2, positive = false },
	{ plane = 0, u = 2, v = 1, positive = false },
	{ plane = 0, u = 2, v = 1, positive = true },
	{ plane = 2, u = 0, v = 1, positive = false },
	{ plane = 2, u = 0, v = 1, positive = true },
]
