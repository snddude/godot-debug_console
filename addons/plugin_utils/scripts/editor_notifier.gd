@tool
class_name EditorNotifier
extends RefCounted


static func notify(
		title: String,
		text: String, 
		ok_text: String = "OK", 
		on_ok: Callable = Callable()
) -> void:
	var dialog := AcceptDialog.new()

	dialog.min_size.x = 460
	dialog.unresizable = true
	dialog.dialog_autowrap = true
	dialog.title = title
	dialog.dialog_text = text
	dialog.ok_button_text = ok_text

	if on_ok:
		dialog.get_ok_button().pressed.connect(on_ok)

	EditorInterface.popup_dialog_centered(dialog)

	await dialog.visibility_changed
	dialog.queue_free()


static func get_confirmation(
		text: String, 
		ok_text: String,
		cancel_text: String,
		on_ok: Callable = Callable(),
		on_cancel: Callable = Callable(),
) -> void:
	var dialog := ConfirmationDialog.new()

	dialog.min_size.x = 460
	dialog.unresizable = true
	dialog.dialog_autowrap = true
	dialog.dialog_text = text
	dialog.ok_button_text = ok_text
	dialog.cancel_button_text = cancel_text

	if on_ok:
		dialog.get_ok_button().pressed.connect(on_ok)

	if on_cancel:
		dialog.get_cancel_button().pressed.connect(on_cancel)

	EditorInterface.popup_dialog_centered(dialog)

	await dialog.visibility_changed
	dialog.queue_free()
