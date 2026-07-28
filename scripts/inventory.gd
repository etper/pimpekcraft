class_name Inventory

const SLOT_COUNT = 36

var slots = []
var selected_slot = 0

func _init():
	slots.resize(SLOT_COUNT)

func add_item(id, amount):
	pass

func remove_item(slot):
	pass

func get_selected():
	pass
