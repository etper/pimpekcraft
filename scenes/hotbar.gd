extends Node

var inventory : Inventory
var inventory_ui


func setup(inv, ui):
	inventory = inv
	inventory_ui = ui


func _unhandled_input(event):

	for i in range(9):
		if event.is_action_pressed("slot_%d" % (i + 1)):
			inventory.selected_slot = i
			inventory_ui.refresh()
			return


	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			inventory.selected_slot = (
				inventory.selected_slot + 8
			) % 9

			inventory_ui.refresh()


		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			inventory.selected_slot = (
				inventory.selected_slot + 1
			) % 9

			inventory_ui.refresh()
