extends CharacterBody3D

@export var speed := 6.0
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.002

const GRAVITY = 9.8

@onready var camera_pivot = $CameraPivot

@onready var ray = $CameraPivot/Camera3D/RayCast3D
@onready var world = get_node("/root/Main/World")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	
	if event is InputEventMouseButton and event.pressed:
		if ray.is_colliding():

			var point = ray.get_collision_point()
			var normal = ray.get_collision_normal()

			if event.button_index == MOUSE_BUTTON_LEFT:
				var destroy_pos = Vector3i((point - normal * 0.5).floor())
				world.destroy_block(destroy_pos)

			elif event.button_index == MOUSE_BUTTON_RIGHT:
				var place_pos = Vector3i((point + normal * 0.5).floor())
				world.place_block(place_pos)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(-89),
			deg_to_rad(89)
		)

func _physics_process(delta):

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
        "move_backward"
	)

	var direction = (transform.basis * Vector3(
		input_dir.x,
		0,
		input_dir.y
	)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
