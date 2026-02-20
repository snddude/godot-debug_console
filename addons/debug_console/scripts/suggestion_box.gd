class_name SuggestionBox
extends Window

signal item_selected(command: String)

const MAX_ITEM_COUNT: int = 9

@export_group("Nodes")
@export var item_container: VBoxContainer

var item_count: int = 0
var max_item_count_reached: bool = false


func _ready() -> void:
	hide()


func add_item(command: String) -> void:
	if max_item_count_reached:
		return

	var item_text: String = ""
	var item := Button.new()

	if item_count == MAX_ITEM_COUNT:
		item_text = "..."
		item.disabled = true
		max_item_count_reached = true
	else:
		item_text = command
		item.pressed.connect(item_selected.emit.bind(command))
		item.pressed.connect(hide)

	item.text = item_text
	item.alignment = HORIZONTAL_ALIGNMENT_LEFT
	item.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

	item_container.add_child(item)
	item_count += 1

	size.y = item_count * 17


func clear() -> void:
	for child: Button in item_container.get_children():
		child.queue_free()

	item_count = 0
	max_item_count_reached = false


func is_focused() -> bool:
	var res: bool = false

	for child: Button in item_container.get_children():
		if child.has_focus():
			res = true

	return res
