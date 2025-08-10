# Debug Console

A debug console implementation partly inspired by [jitspoe's godot-console](https://github.com/jitspoe/godot-console).

## Installation

Download the [latest release](https://github.com/snddude/godot-debug_console/releases/latest) of this plugin, which comes in a zip archive. Extract it into your project's "addons/" folder, then go to Project → Project Settings → Plugins and enable "Debug Console".

## Usage

The way you add a console command is as follows:

```gdscript
DebugConsole.add_console_command(
        command_text: String,  # The text that you type into the console to call the command.
        callable: Callable,    # The function that gets called.
        argument_type: int     # The variable type of the command's argument.
)
```

The "argument_type" argument uses the standard TYPE_NIL, TYPE_INT, TYPE_FLOAT values that are provided by Godot.

**Note:** every command that gets added by a node should be removed when that node exits the scene tree. You do this by using the following function:

```gdscript
DebugConsole.remove_console_command(
        command_text: String  # Same as the "command_text" argument in the add_console_command() function.
)
```

To log a message to the console you do this:

```gdscript
DebugConsole.print_line(
        message: String,       # The message that gets displayed in the console.
        print_type: PrintType  # Message display formatting option.
)
```

The "print_type" argument can have one of the following values:
- DebugConsole.PRINT_TYPE_LINE - the message is preceded with a ">" character.
- DebugConsole.PRINT_TYPE_OUTPUT - the message is preceded with a "\t".
- DebugConsole.PRINT_TYPE_DEBUG - the message is preceded with a timestamp.
- DebugConsole.PRINT_TYPE_WARNING - the message is preceded with a timestamp, a string that says "WARNING:" and is also highlighted in yellow.
- DebugConsole.PRINT_TYPE_ERROR - the message is preceded with a timestamp, a string that says "ERROR:" and is also highlighted in red.

## License

[MIT](https://en.wikipedia.org/wiki/MIT_License)
