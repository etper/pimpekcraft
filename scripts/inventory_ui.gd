extends CanvasLayer

var inventory : Inventory

@onready var slots = [
	$Control/HBoxContainer/Slot0,
	$Control/HBoxContainer/Slot1,
	$Control/HBoxContainer/Slot2,
	$Control/HBoxContainer/Slot3,
	$Control/HBoxContainer/Slot4,
	$Control/HBoxContainer/Slot5,
	$Control/HBoxContainer/Slot6,
	$Control/HBoxContainer/Slot7,
	$Control/HBoxContainer/Slot8
]

func get_slot(index):
	return $Control/HBoxContainer.get_child(index)

func _ready():
	for slot in slots:
		var label = Label.new()
		label.name = "Label"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.anchors_preset = Control.PRESET_FULL_RECT
		slot.add_child(label)

	refresh()

func refresh():
	if inventory == null:
		return

	for i in range(9):
		var panel = get_slot(i)

		var label
		if panel.has_node("Label"):
			label = panel.get_node("Label")
		else:
			label = Label.new()
			label.name = "Label"
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.anchors_preset = Control.PRESET_FULL_RECT
			panel.add_child(label)

		var slot = inventory.slots[i]

		if slot == null:
			label.text = ""
		else:
			var item_name = ItemDB.NAMES.get(slot["id"], "Unknown")

			if slot["amount"] > 1:
				label.text = item_name + "\n" + str(slot["amount"])
			else:
				label.text = item_name
