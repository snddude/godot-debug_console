class_name SuggestionBox
extends Window

signal item_selected(command: String)

@export_group("Nodes")
@export var item_container: VBoxContainer

var item_count: int = 0


func _ready() -> void:
	hide()


func add_item(command: String) -> void:
	var item := Button.new()

	item.text = command
	item.alignment = HORIZONTAL_ALIGNMENT_LEFT
	item.pressed.connect(item_selected.emit.bind(command))
	item.pressed.connect(hide)

	item_container.add_child(item)
	item_count += 1

	size.x = max(item.size.x, 96)
	size.y = item_count * 17


func clear() -> void:
	for child: Button in item_container.get_children():
		child.queue_free()

	item_count = 0


func is_focused() -> bool:
	var res: bool = false

	for child: Button in item_container.get_children():
		if child.has_focus():
			res = true

	return res
