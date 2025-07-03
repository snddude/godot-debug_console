# godot-debug_console

A simple debug console packaged in a Godot plugin for easier reuse across projects. Implementation is partly inspired by [jitspoe's godot-console](https://github.com/jitspoe/godot-console).

## Features

- Console commands can be added from within any class in your project that extends some kind of Node.
- Allows for simpler logging without constant switching between your game's window and the editor's window.
- Keeps track of command history.
- Requires minimal setup, which is done automatically upon enabling the plugin.

## Limitations

- Commands can only have up to one argument.
- No autocomplete.
- Limited expression evaluation capabilities.
- The command history is stored for current session only.

## Installation

Download the [latest release](https://github.com/snddude/godot-debug_console/releases/latest) of the plugin (comes in a zip archive) and extract it into your project's "addons/" folder. After that, go to Project -> Project Settings -> Plugins and enable "Debug Console".

## Usage

The way you add a console command is as follows:

```
DebugConsole.add_console_command("command_name", command_callable, command_argument_type)
                                       ^                ^                    ^
                         what you type into the console |                    |
                                                        |                    |
                                           the function that gets called     |
                                                                             |
                                                        the variable type of the command's argument
```

Logging is done this way:

```
DebugConsole.print_line("some message", print_type)
                              ^             ^
                    the message that gets   |
                   displayed in the console |
                                            |
                             message display formatting option
```

### Examples:

Adding a console command with no argument:

```gdscript
extends RigidBody3D

func _ready() -> void:    
    DebugConsole.add_console_command("new_command", new_command, TYPE_NIL)

func new_command() -> void:
    print("doing something...")
```

Adding a console command with an argument:

```gdscript
extends CharacterBody2D

var gravity: float = -9.8

func _ready() -> void:    
    DebugConsole.add_console_command("gravity", set_gravity, TYPE_FLOAT)

func set_gravity(value: float) -> void:
    gravity = value
```

```gdscript
extends Control

func _ready() -> void:    
    DebugConsole.add_console_command("set_vis", set_visible, TYPE_BOOL)

func set_visible(value: bool) -> void:
    visible = value
```

Logging various messages into console:

```gdscript
func _ready() -> void:    
    DebugConsole.print_line("ominous warning", DebugConsole.PRINT_TYPE_WARNING)
    DebugConsole.print_line("an even more ominous error", DebugConsole.PRINT_TYPE_ERROR)
    DebugConsole.print_line("quitting to desktop...", DebugConsole.PRINT_TYPE_OUTPUT)
    DebugConsole.print_line("just a message", DebugConsole.PRINT_TYPE_LINE)
    DebugConsole.print_line("some output", DebugConsole.PRINT_TYPE_OUTPUT)
    DebugConsole.print_line("some important debugging value", DebugConsole.PRINT_TYPE_DEBUG)
```

## License

This plugin is distributed under the [MIT License](https://en.wikipedia.org/wiki/MIT_License).
