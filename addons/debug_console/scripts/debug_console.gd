@icon("res://addons/debug_console/assets/sprites/icons/debug_console.svg")
extends Window

signal shown
signal hidden

const PRINT_TYPE_LINE: int = 0
const PRINT_TYPE_OUTPUT: int = 1
const PRINT_TYPE_DEBUG: int = 2
const PRINT_TYPE_WARNING: int = 3
const PRINT_TYPE_ERROR: int = 4

var current_history_index: int = -1
var can_show: bool = true
var essentials: Dictionary[String, DebugConsoleCommand] = {
	"help": DebugConsoleCommand.new("help", help, TYPE_NIL),
	"exec": DebugConsoleCommand.new("exec", execute, TYPE_STRING),
	"history": DebugConsoleCommand.new("history", history, TYPE_NIL),
	"clear": DebugConsoleCommand.new("clear", clear, TYPE_NIL),
	"exit": DebugConsoleCommand.new("exit", exit, TYPE_NIL),
}
var commands: Dictionary[String, DebugConsoleCommand] = {}
var command_history: Array[String] = [""]

@onready var label: RichTextLabel = $MarginsContainer/Layout/RichTextLabel
@onready var line_edit: LineEdit = $MarginsContainer/Layout/HBoxContainer/LineEdit
@onready var submit_button: Button = $MarginsContainer/Layout/HBoxContainer/SubmitButton


func _ready() -> void:
	commands.merge(essentials)

	hide()

	focus_exited.connect(hide)
	close_requested.connect(hide)
	submit_button.pressed.connect(parse_input_text)
	line_edit.text_submitted.connect(parse_input_text)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug_console"):
		if not can_show:
			return

		if visible:
			hide()
			line_edit.clear()
			hidden.emit()
		else:
			show()
			line_edit.grab_focus()
			shown.emit()

	if Input.is_action_just_pressed("ui_up") and visible:
		increment_current_history_index()

		line_edit.text = get_command_from_history()
		line_edit.accept_event()
		line_edit.caret_column = line_edit.text.length()
	elif Input.is_action_just_pressed("ui_down") and visible:
		decrement_current_history_index()

		line_edit.text = get_command_from_history()
		line_edit.accept_event()
		line_edit.caret_column = line_edit.text.length()


func allow_show() -> void:
	can_show = true


func disallow_show() -> void:
	can_show = false


func add_console_command(command_text: String, callable: Callable, argument_type: int) -> void:
	if commands.has(command_text):
		commands[command_text].callable = callable
		return

	var new_command := DebugConsoleCommand.new(command_text, callable, argument_type)
	commands[command_text] = new_command


func clear_command_list() -> void:
	commands = {}
	commands.merge(essentials)


func parse_input_text(_discard: String = "") -> void:
	var text: String = line_edit.text
	line_edit.clear()
	print_line(text, PRINT_TYPE_LINE)

	var input: PackedStringArray = text.split(" ", false, 1)

	if input.size() == 0:
		return

	command_history.insert(1, text)
	current_history_index = 0

	var command_text: String = input[0]

	if not commands.has(command_text):
		print_line('Invalid command "' + str(command_text) + '"', PRINT_TYPE_ERROR)
		return

	var cmd: DebugConsoleCommand = commands[command_text]
	if cmd.argument_type  != TYPE_NIL:
		if input.size() == 1:
			print_line('Command "' + command_text + '" requires an argument', PRINT_TYPE_ERROR)
			return

		var argument = input[1]
		if cmd.argument_type != TYPE_STRING:
			argument = str_to_var(argument)

		if typeof(argument) != cmd.argument_type:
			print_line('Invalid argument type for command "' + command_text + '"', PRINT_TYPE_ERROR)
			return

		cmd.callable.call(argument)
		return

	cmd.callable.call()


func print_line(message: String, print_type: int) -> void:
	var text: String = ""

	match print_type:
		PRINT_TYPE_LINE:
			text = "> " + message + "\n"
		PRINT_TYPE_OUTPUT:
			text = "\t" + message + "\n"
		PRINT_TYPE_DEBUG:
			text = get_timestamp() + message + "\n"
		PRINT_TYPE_WARNING:
			text = get_timestamp() + "[color=yellow]WARNING:[/color] " + message + "\n"
		PRINT_TYPE_ERROR:
			text = get_timestamp() + "[color=red]ERROR:[/color] " + message + "\n"

	label.append_text(text)


func get_timestamp() -> String:
	return "[ %s ] "%Time.get_time_string_from_system()


func increment_current_history_index() -> void:
	if command_history.size() == 0:
		return

	current_history_index += 1 

	if current_history_index > command_history.size() - 1:
		current_history_index = command_history.size() - 1


func decrement_current_history_index() -> void:
	if command_history.size() == 0:
		return

	current_history_index -= 1

	if current_history_index < 0:
		current_history_index = 0


func get_command_from_history() -> String:
	if command_history.size() == 0:
		return ""

	return command_history[current_history_index]


func execute(text: String) -> void:
	var expression := Expression.new()

	var error: Error = expression.parse(text)
	if error != OK:
		print_line(expression.get_error_text(), PRINT_TYPE_ERROR)
		return

	var result: String = str(expression.execute([], self))
	if not expression.has_execute_failed():
		print_line(result, PRINT_TYPE_OUTPUT)
	else:
		print_line(expression.get_error_text(), PRINT_TYPE_ERROR)


func help() -> void:
	print_line("Here's a list of all available commands:", PRINT_TYPE_OUTPUT)

	var command_list: Array = commands.keys()
	command_list.sort()

	for i in command_list:
		print_line("- " + i, PRINT_TYPE_OUTPUT)


func history() -> void:
	print_line("Console history for current session:", PRINT_TYPE_OUTPUT)
	for i in range(command_history.size() - 1, 1, -1):
		print_line("%d\t"%(command_history.size()-i) + command_history[i], PRINT_TYPE_OUTPUT)


func clear() -> void:
	label.clear()


func exit() -> void:
	get_tree().quit()
