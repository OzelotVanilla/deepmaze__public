class_name DMScript__HELLO
extends DMTerminalCommand
## Say hello.


func _init() -> void:
    self.name = "hello"

    var new_schema := DMTerminalCommandSchema.new()
    new_schema.add_positional(
        "name",
        "Name to greet to.",
        ""
    )
    self.schema = new_schema

    self.description = "Say hello."

    self.callable = self.run

func run(parsed_args: DMTerminalArguments.ParsedArgs) -> int:
    var name_to_greet := parsed_args.positionals[0]
    if not name_to_greet.is_empty():
        self.terminal__ref.print_on_terminal(
            str("Hello, ", name_to_greet, ".")
        )
    else:
        self.terminal__ref.print_on_terminal(
            "Hello."
        )

    self.cmd_manager__ref.command_finished.emit()
    return 0
