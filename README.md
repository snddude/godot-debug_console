# Debug Console

A debug console implementation partly inspired by [jitspoe's godot-console](https://github.com/jitspoe/godot-console).

## Installation

Download the [latest release](https://github.com/snddude/godot-debug_console/releases/latest) of this plugin, which comes in a zip archive. Extract it into your project's "addons/" folder, then go to Project → Project Settings → Plugins and enable "Debug Console".

## Usage

### Logging

```gdscript
DebugConsole.print_line(
        message: String,       # The message that gets displayed in the console.
        print_type: PrintType  # Message formatting option.
)
```

> [!Note]
> "print_type" can have one of the following values:
> - DebugConsole.PRINT_TYPE_LINE - the message is preceded with a ">" character;
> - DebugConsole.PRINT_TYPE_OUTPUT - the message is preceded with a TAB;
> - DebugConsole.PRINT_TYPE_DEBUG - the message is preceded with a timestamp;
> - DebugConsole.PRINT_TYPE_WARNING - the message is preceded with a timestamp and a $\color{Yellow}{\textsf{"WARNING:"}}$ string;
> - DebugConsole.PRINT_TYPE_ERROR - the message is preceded with a timestamp and an $\color{Red}{\textsf{"ERROR:"}}$ string.

### Variables

```gdscript
DebugConsole.add_console_variable(
        variable_name: String,  # The name of the new variable.
        value: Variant,         # The initial value of the new variable. Could be of any type.
        persistent: bool        # A flag that determines whether or not this variable will be persistent across different game sessions.
)
```

```gdscript
DebugConsole.remove_console_variable(
        variable_name: String  # Same as the "variable_name" argument in the add_console_variable() function.
)
```

```gdscript
DebugConsole.get_console_variable_value(
        variable_name: String  # Same as the "variable_name" argument in the add_console_variable() function.
)
```

```gdscript
DebugConsole.set_console_variable_value(
        variable_name: String,  # Same as the "variable_name" argument in the add_console_variable() function.
        value: Variant          # Same as the "value" argument in the add_console_variable() function.
)
```

### Commands

```gdscript
DebugConsole.add_console_command(
        command_name: String,  # The text that you type into the console to call the command.
        callable: Callable,    # The function that gets called.
        argument_type: int     # The variable type of the command's argument.
)
```
> [!NOTE]
> "argument_type" uses the standard TYPE_NIL, TYPE_INT, TYPE_FLOAT, etc. values that are provided by the Godot Engine.

```gdscript
DebugConsole.remove_console_command(
        command_name: String  # Same as the "command_name" argument in the add_console_command() function.
)
```
> [!NOTE]
> Every command that gets added by a node should be removed when that node exits the scene tree.

## License

[MIT](https://en.wikipedia.org/wiki/MIT_License)
