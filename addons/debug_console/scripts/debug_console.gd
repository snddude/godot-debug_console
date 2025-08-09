extends Window

signal shown
signal hidden

enum PrintType {}

const PRINT_TYPE_LINE: PrintType = 0
const PRINT_TYPE_OUTPUT: PrintType = 1
const PRINT_TYPE_DEBUG: PrintType = 2
const PRINT_TYPE_WARNING: PrintType = 3
const PRINT_TYPE_ERROR: PrintType = 4

@export_group("Nodes")
@export var _rich_text_label: RichTextLabel
@export var _line_edit: LineEdit
@export var _button: Button

var _current_history_index: int = -1
var _can_show: bool = true
var _commands: Dictionary[String, DebugConsoleCommand] = {}
var _command_history: Array[String] = [""]


func _ready() -> void:
	_hide_console()

	_button.pressed.connect(_parse_input_text)
	_button.pressed.connect(_line_edit.grab_focus)
	_line_edit.text_submitted.connect(_parse_input_text)

	focus_exited.connect(_hide_console)
	close_requested.connect(_hide_console)

	add_console_command("help", _help, TYPE_NIL)
	add_console_command("exec", _exec, TYPE_STRING)
	add_console_command("history", _history, TYPE_NIL)
	add_console_command("clear", _clear, TYPE_NIL)
	add_console_command("exit", _exit, TYPE_NIL)


func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	if event.is_action_pressed("ui_cancel"):
		_hide_console()

	var changed_history_index: bool = false

	if event.is_action_pressed("ui_up"):
		_increment_history_index(1)
		changed_history_index = true
	elif event.is_action_pressed("ui_down"):
		_increment_history_index(-1)
		changed_history_index = true

	if changed_history_index:
		_line_edit.text = _get_command_from_history()
		_line_edit.accept_event()
		_line_edit.caret_column = _line_edit.text.length()


func _process(_delta: float) -> void:
	if _can_show and Input.is_action_just_pressed("toggle_debug_console"):
		_hide_console() if visible else _show_console()


func add_console_command(command_text: String, callable: Callable, argument_type: int) -> void:
	if _commands.has(command_text):
		_commands[command_text].callable = callable
		return

	_commands[command_text] = DebugConsoleCommand.new(command_text, callable, argument_type)


func remove_console_command(command_text: String) -> void:
	_commands.erase(command_text)


func print_line(message: String, print_type: PrintType) -> void:
	var text: String = ""

	match print_type:
		PRINT_TYPE_LINE:
			text = "> %s\n"%message
		PRINT_TYPE_OUTPUT:
			text = "\t%s\n"%message
		PRINT_TYPE_DEBUG:
			text = "%s%s\n"%[_get_timestamp(), message]
		PRINT_TYPE_WARNING:
			text = "%s[color=yellow]WARNING:[/color] %s\n"%[_get_timestamp(), message]
		PRINT_TYPE_ERROR:
			text = "%s[color=red]ERROR:[/color] %s\n"%[_get_timestamp(), message]

	_rich_text_label.append_text(text)
	_rich_text_label.scroll_to_line(_rich_text_label.get_line_count())


func _allow_show() -> void:
	_can_show = true


func _disallow_show() -> void:
	_can_show = false

	if visible:
		_hide_console()


func _show_console() -> void:
	show()
	_line_edit.grab_focus()

	shown.emit()


func _hide_console() -> void:
	hide()
	_line_edit.clear()

	hidden.emit()


func _parse_input_text(_discard: String = "") -> void:
	var input_text: String = _line_edit.text

	_line_edit.clear()
	print_line(input_text, PRINT_TYPE_LINE)

	if input_text.length() == 0:
		return

	_command_history.insert(1, input_text)
	_current_history_index = 0

	var input_text_split: PackedStringArray = input_text.split(" ", false, 1)
	var command_text: String = input_text_split[0]

	if command_text not in _commands.keys():
		print_line('invalid command "%s"'%command_text, PRINT_TYPE_ERROR)
		return

	var command: DebugConsoleCommand = _commands[command_text]

	if command.argument_type == TYPE_NIL:
		if input_text_split.size() > 1:
			print_line('command "%s" does not require an argument'%command_text, PRINT_TYPE_ERROR)
			return

		command.callable.call()
		return

	if input_text_split.size() == 1:
		print_line('command "%s" requires an argument'%command_text, PRINT_TYPE_ERROR)
		return

	var argument: String = input_text_split[1]

	if command.argument_type != TYPE_STRING:
		argument = str_to_var(argument)

	if typeof(argument) != command.argument_type:
		print_line('invalid argument type for command "%s"'%command_text, PRINT_TYPE_ERROR)
		return

	command.callable.call(argument)


func _get_timestamp() -> String:
	return "[ %s ] "%Time.get_time_string_from_system()


func _increment_history_index(ammount: int) -> void:
	if _command_history.size() == 0:
		return

	_current_history_index += ammount
	_current_history_index = clamp(_current_history_index, 0, _command_history.size() - 1)


func _get_command_from_history() -> String:
	if _command_history.size() == 0:
		return ""

	return _command_history[_current_history_index]


func _exec(input_text: String) -> void:
	var expression := Expression.new()
	var error: Error = expression.parse(input_text)

	if error != OK:
		print_line(expression.get_error_text(), PRINT_TYPE_ERROR)
		return

	var result: String = str(expression.execute([], self))

	if expression.has_execute_failed():
		print_line(expression.get_error_text(), PRINT_TYPE_ERROR)
		return

	print_line(result, PRINT_TYPE_OUTPUT)


func _help() -> void:
	print_line("Here's a list of all available commands:", PRINT_TYPE_OUTPUT)

	var command_list: Array[String] = _commands.keys()
	command_list.sort()

	for command_text: String in command_list:
		print_line("- " + command_text, PRINT_TYPE_OUTPUT)


func _history() -> void:
	print_line("Command history for current session:", PRINT_TYPE_OUTPUT)

	for i: int in range(_command_history.size() - 1, 1, -1):
		print_line("%d  "%(_command_history.size()-i) + _command_history[i], PRINT_TYPE_OUTPUT)


func _clear() -> void:
	_rich_text_label.clear()


func _exit() -> void:
	get_tree().quit()
