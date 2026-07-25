@tool
class_name EditorActionMapper
extends RefCounted

enum InputEventType {}

const INPUT_EVENT_TYPE_KEY: InputEventType = 0
const INPUT_EVENT_TYPE_MOUSE_BUTTON: InputEventType = 1
const INPUT_EVENT_TYPE_JOY_BUTTON: InputEventType = 2
const INPUT_EVENT_TYPE_JOY_AXIS: InputEventType = 3


static func map_action(
		action: String,
		input_event_type: InputEventType,
		input_event: Variant
) -> void:
	var event: Variant = _make_event(input_event_type, input_event)

	if event == null:
		return

	var setting: String = "input/" + action
	var input: Dictionary[String, Variant] = {}

	if ProjectSettings.has_setting(setting):
		input = ProjectSettings.get_setting(setting)
		input["events"].append(event)
	else:
		input = {
			"deadzone": 0.2,
			"events": [event],
		}

	ProjectSettings.set_setting(setting, input)
	ProjectSettings.save()

 
static func bulk_map_actions(
		actions: Dictionary[String, InputEventType],
		events: Dictionary[String, Variant]
) -> Array[String]:
	var mapped: Array[String] = []

	for key: String in actions.keys():
		if ProjectSettings.has_setting("input/" + key):
			continue

		map_action(key, actions[key], events[key])
		mapped.append(key)

	return mapped


static func unmap_input_event(
		action: String,
		input_event_type: InputEventType,
		input_event: Variant
) -> void:
	var setting: String = "input/" + action
	var event: Variant = _make_event(input_event_type, input_event)

	if not ProjectSettings.has_setting(setting):
		push_error('Cannot unmap input event of nonexistent action "%s"')
		return

	if event == null:
		return

	var input: Dictionary[String, Variant] = ProjectSettings.get_setting(setting)
	input["events"].erase(event)

	ProjectSettings.set_setting(setting, input)
	ProjectSettings.save()


static func unmap_action(action: String) -> void:
	if not ProjectSettings.has_setting("input/" + action):
		push_error('Cannot unmap nonexistent action "%s"' % action)
		return

	ProjectSettings.set_setting("input/" + action, null)
	ProjectSettings.save()


static func bulk_unmap_input_events(
		action: String,
		events: Dictionary[InputEventType, Variant]
) -> void:
	for key: InputEventType in events.keys():
		unmap_input_event(action, key, events[key])


static func bulk_unmap_actions(actions: Array[String]) -> Array[String]:
	var unmapped: Array[String] = []

	for action: String in actions:
		if not ProjectSettings.has_setting("input/" + action):
			continue

		unmap_action(action)
		unmapped.append(action)

	return unmapped


static func _make_event(input_event_type: InputEventType, input_event: Variant) -> Variant:
	var event: Variant = null

	match input_event_type:
		INPUT_EVENT_TYPE_KEY: 
			event = InputEventKey.new()
			event.physical_keycode = input_event
		INPUT_EVENT_TYPE_MOUSE_BUTTON:
			event = InputEventMouseButton.new()
			event.button_index = input_event
		INPUT_EVENT_TYPE_JOY_BUTTON:
			event = InputEventJoypadButton.new()
			event.button_index = input_event
		INPUT_EVENT_TYPE_JOY_AXIS:
			event = InputEventJoypadMotion.new()
			event.axis = input_event
		_: 
			push_error("Invalid InputEventType provided")

	return event
