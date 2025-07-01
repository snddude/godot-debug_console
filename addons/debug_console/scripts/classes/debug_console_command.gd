class_name DebugConsoleCommand

var command: String
var callable: Callable
var argument_type: int


func _init(command_string: String, command_callable: Callable, command_argument_type: int) -> void:
	command = command_string
	callable = command_callable
	argument_type = command_argument_type
