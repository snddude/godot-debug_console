extends Window

signal shown
signal hidden

const PATH_CONVARS_FILE: String = "user://convars.file"

@export_group("Nodes")
@export var rich_text_label: RichTextLabel
@export var line_edit: LineEdit
@export var button: Button
@export var suggestion_box: SuggestionBox

var _current_history_index: int = -1
var _current_suggestion_index: int = -1
var _can_show: bool = true
var _command_history: Array[String] = [""]
var _suggestions: Array[String] = []
var _variables: Dictionary[String, Dictionary] = {}
var _commands: Dictionary[String, Dictionary] = {}
var _logger: DebugConsoleLogger = null


func _enter_tree() -> void:
	_logger = DebugConsoleLogger.new()
	OS.add_logger(_logger)

	# Load persistent variables from disk as early as possible.
	var file := FileAccess.open(PATH_CONVARS_FILE, FileAccess.READ)
	if file:
		_variables = file.get_var()


func _ready() -> void:
	_hide_console()

	button.pressed.connect(_parse_input_text)
	button.pressed.connect(line_edit.grab_focus)
	line_edit.text_submitted.connect(_parse_input_text)
	line_edit.text_changed.connect(_suggest_commands)
	line_edit.focus_exited.connect(suggestion_box.hide)

	suggestion_box.item_selected.connect(_insert_suggestion)

	# TODO: This doesn't work because the suggestion box is it's own window node.
	#focus_exited.connect(_hide_console)
	# TODO: Think of another way to track console focus and hide it upon it's loss.

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

	if event.is_action_pressed("ui_up"):
		_increment_history_index(1)

	if event.is_action_pressed("ui_down"):
		_increment_history_index(-1)

	if event.is_action_pressed("ui_focus_next") and not event.is_action_pressed("ui_focus_prev"):
		_increment_suggestion_index(1)

	if event.is_action_pressed("ui_focus_prev"):
		_increment_suggestion_index(-1)


func _process(_delta: float) -> void:
	if _can_show and Input.is_action_just_pressed("toggle_debug_console"):
		_hide_console() if visible else _show_console()

	if suggestion_box.visible:
		suggestion_box.position = position + Vector2i(line_edit.global_position)
		suggestion_box.position.y += line_edit.size.y


func _exit_tree() -> void:
	OS.remove_logger(_logger)


func allow_show() -> void:
	_can_show = true


func disallow_show() -> void:
	_can_show = false

	if visible:
		_hide_console()


func push_text(text: String) -> void:
	rich_text_label.append_text(text + "\n")
	rich_text_label.scroll_to_line(rich_text_label.get_line_count())


func add_console_variable(variable_name: String, value: Variant, persistent: bool) -> void:
	if variable_name in _variables.keys():
		if not persistent:
			push_error('Trying to add duplicate console variable "%s"'%variable_name)
		return

	_variables[variable_name] = {"value": value, "persistent": persistent}

	if persistent:
		_save_persistent_variables()


func remove_console_variable(variable_name: String) -> void:
	if variable_name not in _variables.keys():
		push_error('Trying to remove nonexistent console variable "%s"'%variable_name)
		return

	_variables.erase(name)


func get_console_variable_value(variable_name: String) -> Variant:
	if variable_name not in _variables.keys():
		push_error('Trying to get value of nonexistent console variable "%s"'%variable_name)
		return null

	return _variables[variable_name]["value"]


func set_console_variable_value(variable_name: String, value: Variant) -> void:
	if variable_name not in _variables.keys():
		push_error('Trying to set value of nonexistent console variable "%s"'%variable_name)
		return

	var variable: Dictionary = _variables[variable_name]
	variable["value"] = value

	if variable["persistent"]:
		_save_persistent_variables()


func add_console_command(
		command_name: String,
		callable: Callable,
		argument_type: Variant.Type) -> void:
	_commands[command_name] = {"callable": callable, "argument_type": argument_type}


func remove_console_command(command_name: String) -> void:
	_commands.erase(command_name)


func _show_console() -> void:
	show()
	line_edit.grab_focus()

	shown.emit()


func _hide_console() -> void:
	hide()
	line_edit.clear()

	hidden.emit()


func _save_persistent_variables() -> void:
	var persistent_variables: Dictionary[String, Dictionary] = {}

	for key: String in _variables.keys():
		if _variables[key]["persistent"]:
			persistent_variables[key] = _variables[key]

	var file := FileAccess.open(PATH_CONVARS_FILE, FileAccess.WRITE)
	file.store_var(persistent_variables)


func _suggest_commands(text: String) -> void:
	_current_suggestion_index = -1

	_suggestions.clear()
	suggestion_box.clear()

	for command: String in _commands:
		if command.find(text.strip_edges()) != -1:
			_suggestions.append(command)
			suggestion_box.add_item(command)

	if _suggestions.size() < 1:
		suggestion_box.hide()
		return

	suggestion_box.show()


func _insert_command(command: String) -> void:
	line_edit.text = command
	line_edit.accept_event()
	line_edit.set_caret_column(line_edit.text.length())


func _insert_suggestion(suggestion: String) -> void:
	_insert_command(suggestion + " ")
	grab_focus()


func _parse_input_text(_discard: String = "") -> void:
	var input_text: String = line_edit.text

	line_edit.clear()
	push_text("$ %s"%input_text)

	if input_text.length() == 0:
		return

	_command_history.insert(1, input_text)
	_current_history_index = 0

	var input_text_split: PackedStringArray = input_text.split(" ", false, 1)
	var command_name: String = input_text_split[0]

	if command_name not in _commands.keys():
		push_error('invalid command "%s"'%command_name)
		return

	var command: Dictionary = _commands[command_name]
	var command_callable: Callable = command["callable"]
	var command_argument_type: int = command["argument_type"]

	if command_argument_type == TYPE_NIL:
		if input_text_split.size() > 1:
			push_error('command "%s" does not require an argument'%command_name)
			return

		command_callable.call()
		return

	if input_text_split.size() == 1:
		push_error('command "%s" requires an argument'%command_name)
		return

	var argument: Variant = input_text_split[1]

	if command_argument_type != TYPE_STRING:
		argument = str_to_var(argument)

	if typeof(argument) != command_argument_type:
		push_error('invalid argument type for command "%s"'%command_name)
		return

	command_callable.call(argument)


func _increment_index(index: int, amount: int, limit: int) -> int:
	index += amount
	index = clamp(index, 0, limit)
	return index


func _increment_history_index(amount: int) -> void:
	if _command_history.size() == 0:
		return

	_current_history_index = _increment_index(
			_current_history_index,
			amount,
			_command_history.size() - 1)
	_insert_command(_command_history[_current_history_index])


func _increment_suggestion_index(amount: int) -> void:
	if _suggestions.size() == 0:
		return

	_current_suggestion_index = _increment_index(
			_current_suggestion_index,
			amount,
			_suggestions.size() - 1)
	_insert_command(_suggestions[_current_suggestion_index])


func _exec(input_text: String) -> void:
	var expression := Expression.new()
	var error: Error = expression.parse(input_text)

	if error != OK:
		push_error(expression.get_error_text())
		return

	var result: Variant = expression.execute([], self)

	if expression.has_execute_failed():
		push_error(expression.get_error_text())
		return

	if result:
		push_text(str(result))


func _help() -> void:
	push_text("Here's a list of all available commands:")

	var command_list: Array[String] = _commands.keys()
	command_list.sort()

	for command_name: String in command_list:
		push_text("\t- %s"%command_name)


func _history() -> void:
	push_text("Command history for current session:")

	for i: int in range(_command_history.size() - 1, 1, -1):
		push_text("\t%d  "%(_command_history.size() - i) + _command_history[i])


func _clear() -> void:
	rich_text_label.clear()


func _exit() -> void:
	get_tree().quit()


class DebugConsoleLogger extends Logger:
	func _get_timestamp() -> String:
		return "[ %s ] "%Time.get_time_string_from_system()


	func _log_message(message: String, error: bool) -> void:
		var text: String = _get_timestamp()

		if error:
			text += "[color=red]ERROR:[/color] "

		DebugConsole.call_deferred("push_text", text + message.trim_suffix("\n"))


	func _log_error(
			function: String,
			file: String,
			line: int,
			code: String,
			rationale: String,
			editor_notify: bool,
			error_type: int,
			script_backtraces: Array[ScriptBacktrace]) -> void:
		var text: String = _get_timestamp()

		match error_type:
			ERROR_TYPE_WARNING:
				text += "[color=yellow]WARNING:[/color] "
			ERROR_TYPE_ERROR, ERROR_TYPE_SCRIPT, ERROR_TYPE_SHADER:
				text += "[color=red]ERROR:[/color] "

		var message: String = "%s %s\n"%[text + code, rationale]
		var trace: String = "At: %s (%s:%s)\n" % [function, file, line]

		DebugConsole.call_deferred(
				"push_text", "%s%s%s"%[message, trace, script_backtraces.pop_front()])

		for backtrace: ScriptBacktrace in script_backtraces:
			DebugConsole.call_deferred("push_text", "\t%s"%backtrace.format(0))
