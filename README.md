# Debug Console

A debug console for Godot. Once partly inspired by [jitspoe's godot-console](https://github.com/jitspoe/godot-console) implementation.

<p align="center">
  <img src="https://github.com/snddude/godot-debug_console/blob/main/repository/preview.png" alt="A preview of the debug console window.">
</p>

## Installation

Download the [latest release](https://github.com/snddude/godot-debug_console/releases/latest) of this plugin, which comes in a ZIP archive. Extract it into your project's "addons/" folder, then go to Project → Project Settings → Plugins and enable "Debug Console".

## Usage

### Logging

You can print various messages to the console using the  print(), push_error(), push_warning(), etc. functions provided by Godot Engine. Engine errors and warnings are also visible in the console. All warnings and errors include stack trace information.

print() messages are preceded with a timestamp, push_warning() - a timestamp and a $\color{Yellow}{\textsf{"WARNING:"}}$ string, push_error() - a timestamp and an $\color{Red}{\textsf{"ERROR:"}}$ string.

If you wish to print some arbitrary text to the console, you can use push_text():

```gdscript
DebugConsole.push_text(
        text: String  # Text you wish to print to the console.
)
```

> [!NOTE]
> All text printed with this method has a new line character inserted at the end.

### Variables

This addon allows you to store values of different types via creation of console variables. Variables can also be persistent. Persistent variables are stored on disk ("user://convars.file") and get loaded when the console enters the SceneTree. They allow for tracking of various values between different game sessions.

Use case example: a console variable can be used to track whether or not a debug UI element should still be visible after a scene change.

```gdscript
DebugConsole.add_console_variable(
        variable_name: String,  # The name of the new variable.
        value: Variant,         # The initial value of the new variable. Could be of any type.
        persistent: bool        # Should this variable persist across different game sessions?
)
```

```gdscript
DebugConsole.remove_console_variable(
        variable_name: String  # Same as "variable_name" in the add_console_variable() function.
)
```

```gdscript
DebugConsole.get_console_variable_value(
        variable_name: String  # Same as "variable_name" in the add_console_variable() function.
)
```

```gdscript
DebugConsole.set_console_variable_value(
        variable_name: String,  # Same as "variable_name" in the add_console_variable() function.
        value: Variant          # The new value for the variable. Probably a good idea to not set values of different types to the same variable.
)
```

### Commands

Console commands are added from classes. Every command you add should be removed when the instance of your class is either freed or exits the SceneTree. Console command argument types are specified using TYPE_NIL, TYPE_INT, TYPE_FLOAT, etc. values. These are a part of the global scope [Variant.Type](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-variant-type) enum provided by Godot Engine.

```gdscript
DebugConsole.add_console_command(
        command_name: String,        # The text that you type into the console to call the command.
        callable: Callable,          # The function that gets called.
        argument_type: Variant.Type  # The variable type of the command's argument.
)
```

```gdscript
DebugConsole.remove_console_command(
        command_name: String  # Same as "command_name" in the add_console_command() function.
)
```

## License

[MIT](https://en.wikipedia.org/wiki/MIT_License)
