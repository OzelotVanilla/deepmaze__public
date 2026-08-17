class_name DMTerminalBuiltIn__CD
extends DMTerminalCommand
## Stores processing of DeepMaze OS command [code]cd[/code]


func _init() -> void:
    self.name = "cd"

    var new_schema := DMTerminalCommandSchema.new()
    new_schema.add_positional(
        "target_dir",
        "Directory to change to.",
        "."
    )
    self.schema = new_schema

    self.description = "Change to target directory."

    self.callable = self.run

func run(parsed_args: DMTerminalArguments.ParsedArgs) -> int:
    var path_in_arg: String = parsed_args.positionals[0]
    var path: String = self.terminal__ref.parsePath(path_in_arg)
    # Add trailing slash.
    if not path.ends_with("/"):
        path = str(path, "/")

    var check_result := self.pc__ref.fs.checkDirTraversal(
        path, self.terminal__ref.user_permission
    )

    # # Change to target dir if OK.
    if check_result.is_ok:
        # By modifying `cwd` to `cd`.
        self.cmd_manager__ref.terminal.cwd = path
        self.cmd_manager__ref.command_finished.emit()
        return 0
    else:
        match check_result.error:
            DMFSResult.Error.not_found:
                self.terminal__ref.print_on_terminal(
                    str("Error: No such directory: `", path_in_arg, "` (parsed to: `", path, "`)"),
                    self.terminal__ref.semantic_colour__error
                )
            DMFSResult.Error.not_folder:
                self.terminal__ref.print_on_terminal(
                    str("Error: `", path_in_arg, "` (parsed to: `", path, "`) is not a directory."),
                    self.terminal__ref.semantic_colour__error
                )
            DMFSResult.Error.permission_denied:
                self.terminal__ref.print_on_terminal(
                    str("Permission denied: `", path_in_arg, "` (parsed to: `", path, "`)."),
                    self.terminal__ref.semantic_colour__error
                )
                self.terminal__ref.print_on_terminal(
                    check_result.message,
                    self.terminal__ref.semantic_colour__error
                )

        self.cmd_manager__ref.command_finished.emit()
        return 1
