class_name DMTerminalCommand
extends RefCounted


## Command's name, such as [code]cd[/code].
var name: String

## Command's description, such as [code]Change current working directory[/code].
var description: String

var long_help: PackedStringArray = []

## Arg is [DMTerminalArguments.ParsedArgs]-typed.
var callable: Callable

var schema: DMTerminalCommandSchema = null

var cmd_manager__ref: DMTerminalCommandManager

var pc__ref: DMPC

var terminal__ref: DMTerminal
