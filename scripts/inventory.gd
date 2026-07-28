class_name Inventory

const SLOT_COUNT = 36
const MAX_STACK = 64

var slots = []
var selected_slot = 0

func _init():
	slots.resize(SLOT_COUNT)


func add_item(id, amount):
	# Try to add to an existing stack first
	for i in range(SLOT_COUNT):
		var slot = slots[i]

		if slot != null and slot.id == id and slot.amount < MAX_STACK:
			var space = MAX_STACK - slot.amount
			var add = min(space, amount)

			slot.amount += add
			amount -= add

			if amount <= 0:
				return true

	# Put remaining items into empty slots
	for i in range(SLOT_COUNT):
		if slots[i] == null:
			var add = min(MAX_STACK, amount)

			slots[i] = {
				"id": id,
				"amount": add
			}

			amount -= add

			if amount <= 0:
				return true

	return false


func remove_item(slot_index, amount := 1):
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return

	var slot = slots[slot_index]

	if slot == null:
		return

	slot.amount -= amount

	if slot.amount <= 0:
		slots[slot_index] = null


func remove_selected(amount := 1):
	remove_item(selected_slot, amount)


func get_selected():
	return slots[selected_slot]
