@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("DebugConsole", 
			"res://addons/debug_console/resources/scenes/autoload/debug_console.tscn")

	if not ProjectSettings.has_setting("input/toggle_debug_console"):
		var event_key := InputEventKey.new()
		event_key.physical_keycode = KEY_QUOTELEFT

		var input: Dictionary = {
			"deadzone": 0.2,
			"events": [event_key],
		}

		ProjectSettings.set_setting("input/toggle_debug_console", input)
		ProjectSettings.save()

		var dialog := ConfirmationDialog.new()
		dialog.size.x = 460
		dialog.exclusive = false
		dialog.unresizable = true
		dialog.dialog_autowrap = true
		dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN

		dialog.set_text(
				"The following Actions have been added to the Input Map of your project:\n"
				+ "- toggle_debug_console: QuoteLeft (`)\n\nThese Actions will not appear in the "
				+ "Input Map tab until another Action is added or the project is reloaded.")
		dialog.ok_button_text = "Save and Reload Project"
		dialog.cancel_button_text = "Reload Project Later"

		dialog.get_ok_button().pressed.connect(func(): EditorInterface.restart_editor(true))

		EditorInterface.get_base_control().add_child(dialog)

		dialog.popup()
		dialog.grab_focus()


func _exit_tree() -> void:
	remove_autoload_singleton("DebugConsole")
