class_name SuggestionBox
extends Window

signal item_selected(command: String)

@export_group("Nodes")
@export var item_container: VBoxContainer


func _ready() -> void:
	hide()


func add_item(command: String) -> void:
	var item := Button.new()

	item.text = command
	item.alignment = HORIZONTAL_ALIGNMENT_LEFT
	item.pressed.connect(item_selected.emit.bind(command))
	item.pressed.connect(hide)

	item_container.add_child(item)

	# TODO: There is a bug somewhere in here... I can almost smell it...

	if item.size.x > size.x:
		size.x = max(item.size.x, 96)

	size.y += 17


func clear() -> void:
	for child: Button in item_container.get_children():
		child.queue_free()

	size.x = 0
	size.y = 0


func get_item_count() -> int:
	return item_container.get_child_count()


func is_focused() -> bool:
	var res: bool = false

	for child: Button in item_container.get_children():
		if child.has_focus():
			res = true

	return res
