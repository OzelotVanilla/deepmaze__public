class_name DMTerminalBuiltIn__CAT
extends DMTerminalCommand
## Stores processing of DeepMaze OS command [code]cat[/code]


func _init() -> void:
    self.name = "cat"

    var new_schema := DMTerminalCommandSchema.new()
    new_schema.add_variadic_positional(
        "files_to_cat",
        "Files to print out and concatenate.",
        ""
    )
    self.schema = new_schema

    self.description = "Prints out concatenated files' content."

    self.callable = self.run

func run(parsed_args: DMTerminalArguments.ParsedArgs) -> int:
    var paths_in_arg := parsed_args.variadic
    var paths := paths_in_arg.map(func(path: String): return self.terminal__ref.parsePath(path))

    # # Check if

    self.cmd_manager__ref.command_finished.emit()
    return 0
