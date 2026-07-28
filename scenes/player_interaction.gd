extends Node

@onready var player = get_parent()

@onready var ray = player.get_node(
	"CameraPivot/Camera3D/RayCast3D"
)

@onready var world = get_node("/root/Main/World")

var inventory
var inventory_ui


func setup(inv, ui):
	inventory = inv
	inventory_ui = ui


func _unhandled_input(event):

	if not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	if not ray.is_colliding():
		return


	var point = ray.get_collision_point()
	var normal = ray.get_collision_normal()


	if event.button_index == MOUSE_BUTTON_LEFT:

		var destroy_pos = Vector3i(
			(point - normal * 0.5).floor()
		)

		var block_id = world.destroy_block(
			destroy_pos
		)

		if block_id != ItemDB.Block.AIR:
			inventory.add_item(block_id,1)
			inventory_ui.refresh()


	elif event.button_index == MOUSE_BUTTON_RIGHT:

		var place_pos = Vector3i(
			(point + normal * 0.5).floor()
		)

		var slot = inventory.get_selected()

		if slot == null:
			return

		if world.place_block(place_pos, slot.id):
			inventory.remove_selected(1)
			inventory_ui.refresh()
