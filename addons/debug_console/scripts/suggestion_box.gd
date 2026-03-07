class_name SuggestionBox
extends Window

signal item_selected(command: String)

const MAX_ITEM_COUNT: int = 9

@export_group("Nodes")
@export var item_container: VBoxContainer

var _item_count: int = 0
var _max_item_count_reached: bool = false


func _ready() -> void:
	hide()

	item_container.child_entered_tree.connect(_change_width)


func add_item(command: String) -> void:
	if _max_item_count_reached:
		return

	var item_text: String = ""
	var item := Button.new()

	if _item_count == MAX_ITEM_COUNT:
		item_text = "..."
		item.disabled = true
		item.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		item.focus_mode = Control.FOCUS_NONE
		_max_item_count_reached = true
	else:
		item_text = command
		item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		item.pressed.connect(item_selected.emit.bind(command))
		item.pressed.connect(hide)

	item.text = item_text
	item.alignment = HORIZONTAL_ALIGNMENT_LEFT

	item_container.add_child(item)
	_item_count += 1

	size.y = _item_count * 17


func clear() -> void:
	for child: Button in item_container.get_children():
		child.queue_free()

	size.x = 0
	_item_count = 0
	_max_item_count_reached = false


func is_focused() -> bool:
	for child: Button in item_container.get_children():
		if child.has_focus():
			return true

	return false


func _change_width(node: Button) -> void:
	var target_width: int = size.x
	var max_width: int = DebugConsole.line_edit.size.x

	# This makes sure that item_container children are only as wide as they need to be.
	# TODO: Figure out why the item_container children are too wide on instantion.
	node.size.x -= node.size.x

	if node.size.x > size.x:
		target_width = min(node.size.x, max_width)

	if node.size.x > target_width:
		node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

	size.x = target_width
