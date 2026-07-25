@tool
extends EditorPlugin

var ACTION_NAME: String = "toggle_debug_console"


func _enable_plugin() -> void:
	add_autoload_singleton("DebugConsole",
			"res://addons/debug_console/resources/scenes/autoload/debug_console.tscn")

	EditorActionMapper.map_action(
			ACTION_NAME,
			EditorActionMapper.INPUT_EVENT_TYPE_KEY,
			KEY_QUOTELEFT)
	EditorNotifier.get_confirmation(
			"The following actions have been added to the input map of your project:\n"
					+ "    - toggle_debug_console: QuoteLeft (`)\nThese actions will not "
					+ "appear in the input map tab until another action is added or the "
					+ "editor is restarted.",
			"Save & Restart",
			"OK",
			EditorInterface.restart_editor.bind(true))


func _disable_plugin() -> void:
	remove_autoload_singleton("DebugConsole")

	EditorActionMapper.unmap_action(ACTION_NAME)
	EditorNotifier.get_confirmation(
			"The following actions have been removed from the input map of your project:\n"
					+ "    - toggle_debug_console: QuoteLeft (`)\nThese actions will not "
					+ "disappear from the input map tab until another action is added or the "
					+ "editor is restarted.",
			"Save & Restart",
			"OK",
			EditorInterface.restart_editor.bind(true))
