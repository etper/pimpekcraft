extends Node

@export var mouse_sensitivity := 0.002

@onready var player = get_parent()
@onready var camera_pivot = player.get_node("CameraPivot")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event):

	if event is InputEventMouseMotion:
		player.rotate_y(
			-event.relative.x * mouse_sensitivity
		)

		camera_pivot.rotate_x(
			-event.relative.y * mouse_sensitivity
		)

		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(-89),
			deg_to_rad(89)
		)


	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
