class_name DMTerminalBuiltIn__TOUCH
extends DMTerminalCommand
## Stores processing of DeepMaze OS command [code]touch[/code]


func _init() -> void:
    self.name = "touch"

    var new_schema := DMTerminalCommandSchema.new()
    new_schema.add_positional(
        "file_or_folder",
        "Name/Path of the file/folder to create."
        # No default value
    )
    self.schema = new_schema

    self.description = "Update the last modification time of a file."

    self.callable = self.run

func run(parsed_args: DMTerminalArguments.ParsedArgs) -> int:
    ## Is valid since terminal will parse it.
    var name_or_path_in_arg: String = parsed_args.positionals[0]
    var name_or_path: String = self.terminal__ref.parsePath(name_or_path_in_arg)

    # # Try touch and see the result.
    var touch_result := self.pc__ref.fs.touch(name_or_path, self.terminal__ref.user_permission)
    var return_code: int = 0
    if touch_result.is_ok:
        return_code = 0
        self.terminal__ref.print_on_terminal(touch_result.message)
    else:
        return_code = 1
        var error_message: String
        match touch_result.error:
            DMFSResult.Error.not_found:
                error_message = str(
                    "Error: Cannot touch non-existing target",
                    " for `", name_or_path_in_arg, "` (parsed to `", name_or_path, "`)."
                )
            DMFSResult.Error.not_folder:
                error_message = str(
                    "Error: Trying to use a file as a folder",
                    " for `", name_or_path_in_arg, "` (parsed to `", name_or_path, "`)."
                )
            DMFSResult.Error.permission_denied:
                error_message = str(
                    "Permission denied: `", name_or_path_in_arg,
                    "` (parsed to `", name_or_path, "`)."
                )

        self.terminal__ref.print_on_terminal(
            error_message,
            self.terminal__ref.semantic_colour__error
        )
        self.terminal__ref.print_on_terminal(
            touch_result.message,
            self.terminal__ref.semantic_colour__error
        )

    self.cmd_manager__ref.command_finished.emit()
    return return_code

    # # # Get the node to operate.
    # var fs_node := self.pc__ref.fs.getFSNode(name_or_path)

    # # # If the node just exists, modify the last access time.
    # if fs_node != null:
    #     fs_node.updateTimeOfLastModify()
    #     self.cmd_manager__ref.command_finished.emit()
    #     return 0

    # # # If the node does not exists, but user is attempting to touch a file.
    # if not name_or_path.ends_with("/"):
    #     var parent_folder__path    := name_or_path.get_base_dir()
    #     var parent_folder__fs_node := self.pc__ref.fs.getFSNode(parent_folder__path)
    #     if parent_folder__fs_node == null:
    #         self.terminal__ref.print_on_terminal(
    #             str(
    #                 "Error: Using touch to creating new file, but parent file/folder",
    #                 " `", name_or_path_in_arg.get_base_dir(),
    #                 "` (parsed to `", parent_folder__path, "`) does not exist."
    #             ),
    #             self.terminal__ref.semantic_colour__error
    #         )
    #         self.terminal__ref.print_on_terminal(
    #             "To create a file/folder in specified path, use `mk` instead.",
    #             self.terminal__ref.semantic_colour__error
    #         )
    #         self.cmd_manager__ref.command_finished.emit()
    #         return 1

    #     if parent_folder__fs_node.is_folder:
    #         parent_folder__fs_node.addChild(DMFSNode.createFile(name_or_path.get_file()))
    #         self.cmd_manager__ref.command_finished.emit()
    #         return 0
    #     else: # parent node is a file
    #         self.terminal__ref.print_on_terminal(
    #             str(
    #                 "Error: Using touch to creating new file, but parent folder",
    #                 " `", name_or_path_in_arg.get_base_dir(),
    #                 "` (parsed to `", parent_folder__path, "`) is a file."
    #             ),
    #             self.terminal__ref.semantic_colour__error
    #         )
    #         return 1
    # else: # Attempting to touch a non-exist folder.
    #     self.terminal__ref.print_on_terminal(
    #         str(
    #             "Error: Folder `", name_or_path_in_arg, "` (parsed to `", name_or_path, "`)",
    #             " does not exist, so it cannot be touched."
    #         ),
    #         self.terminal__ref.semantic_colour__error
    #     )
    #     self.cmd_manager__ref.command_finished.emit()
    #     return 1
