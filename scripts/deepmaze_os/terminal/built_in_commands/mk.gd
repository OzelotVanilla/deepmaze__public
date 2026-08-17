class_name DMTerminalBuiltIn__MK
extends DMTerminalCommand
## Stores processing of DeepMaze OS command [code]mk[/code]


func _init() -> void:
    self.name = "mk"

    var new_schema := DMTerminalCommandSchema.new()
    new_schema.add_positional(
        "file_or_folder",
        "Name/Path of the file/folder to create."
        # No default value
    )
    new_schema.add_option(
        "path",
        "p",
        "Create a file at specified path",
        null,
        DMTerminalArguments.OptionType.FLAG
    )
    self.schema = new_schema

    self.description = "Create a new file or a folder."

    self.callable = self.run

func run(parsed_args: DMTerminalArguments.ParsedArgs) -> int:
    var name_or_path_in_arg: String = parsed_args.positionals[0]
    var name_or_path: String = self.terminal__ref.parsePath(name_or_path_in_arg)

    # # Check if invalid param.
    if name_or_path.is_empty():
        self.terminal__ref.print_on_terminal(
            str("Error: Provide name or path for file/folder to create.")
        )
        self.cmd_manager__ref.command_finished.emit()
        return 1
    if name_or_path == "/":
        self.terminal__ref.print_on_terminal(
            str("Error: Cannot re-create root directory.")
        )
        self.cmd_manager__ref.command_finished.emit()
        return 1

    var is_creating_folder := name_or_path.ends_with("/")

    # # Get target path and name.
    var target_dir_path: String
    var new_fs_node_name: String
    # If `name_or_path` is a folder
    if is_creating_folder:
        var paths: Array[String]; paths.assign(Array(name_or_path.split("/", false)))
        target_dir_path = paths.slice(0, -1).reduce(
            func(a: String, b: String): return a.path_join(b),
            "/"
        )
        # Cannot be empty, because `/` path is checked before.
        new_fs_node_name = paths.back()
    # else, `name_or_path` is a file
    else:
        target_dir_path = name_or_path.get_base_dir()
        new_fs_node_name = name_or_path.get_file()

    if target_dir_path.is_empty():
        target_dir_path = "/"

    # # If `target_dir_path` does not exists yet, create it first.
    var target_dir_path__test_result := self.pc__ref.fs.stat(
        target_dir_path, self.terminal__ref.user_permission
    )
    if target_dir_path__test_result.is_error:
        # Does not exists.
        if target_dir_path__test_result.error == DMFSResult.Error.not_found:
            var result := self.createDirRecursively(target_dir_path)
            if result.is_error:
                var error_message: String = "An error has occured."
                match result.error:
                    DMFSResult.Error.not_folder:
                        error_message = "Error: Provided path contains a file that is used as a folder."
                    DMFSResult.Error.permission_denied:
                        error_message = "Permission denied: Cannot make intermediate file/folder."
                self.terminal__ref.print_on_terminal(
                    error_message, # error from `mk`
                    self.terminal__ref.semantic_colour__error
                )
                self.terminal__ref.print_on_terminal(
                    result.message, # error from fs `create` or `stat`
                    self.terminal__ref.semantic_colour__error
                )
                self.cmd_manager__ref.command_finished.emit()
                return 1
        # Other type of error from `stat`.
        else:
            var error_message: String = "An error has occured."
            match target_dir_path__test_result.error:
                DMFSResult.Error.not_folder:
                    error_message = "Error: Provided path contains a file that is used as a folder."
                DMFSResult.Error.permission_denied:
                    error_message = "Permission denied: Cannot access target folder."
            self.terminal__ref.print_on_terminal(
                error_message, # error from `mk`
                self.terminal__ref.semantic_colour__error
            )
            self.terminal__ref.print_on_terminal(
                target_dir_path__test_result.message, # error from fs `stat`
                self.terminal__ref.semantic_colour__error
            )
            self.cmd_manager__ref.command_finished.emit()
            return 1

    # # Create and see the result.
    var create_result := self.pc__ref.fs.create(
        target_dir_path, new_fs_node_name,
        DMFSNode.Type.folder if is_creating_folder else DMFSNode.Type.file,
        self.terminal__ref.user_permission
    )
    match create_result.error:
        DMFSResult.Error.not_folder:
            self.terminal__ref.print_on_terminal(
                str(
                    "Error: Provided directory",
                    " `", name_or_path_in_arg.get_base_dir(), "`",
                    " (parsed to `", target_dir_path, "`)",
                    " is a file (should be a directory)."
                ),
                self.terminal__ref.semantic_colour__error
            )

        DMFSResult.Error.already_exists:
            self.terminal__ref.print_on_terminal(
                str(
                    "Error: `", name_or_path_in_arg, "` (parsed to `", name_or_path, "`)",
                    " already exists, so it cannot be `mk`-ed again.\n",
                    "Use `rm` to delete it and then `mk`, or try another name."
                ),
                self.terminal__ref.semantic_colour__error
            )

        DMFSResult.Error.permission_denied:
            self.terminal__ref.print_on_terminal(
                str(
                    "Permission denied: `", name_or_path_in_arg,
                    "` (parsed to `", name_or_path, "`).\n"
                ),
                self.terminal__ref.semantic_colour__error
            )
            self.terminal__ref.print_on_terminal(
                str(
                    "Cannot make new file/folder here: `",
                    target_dir_path, "`."
                ),
                self.terminal__ref.semantic_colour__error
            )

    self.cmd_manager__ref.command_finished.emit()
    return 0 if create_result.error == DMFSResult.Error.ok else 1

## Should pass absolute path to param [param path].[br][br]
##
## Error could returned:[br]
## * not_folder[br]
## * permission_denied[br]
## * not_found (should not happen)[br]
## * operation_not_allowed (should not happen)[br]
func createDirRecursively(path: String) -> DMFSResult:
    var paths := path.split("/", false)
    # This should never happen.
    if paths.size() == 0:
        return DMFSResult.createError(
            DMFSResult.Error.operation_not_allowed,
            "Error: Cannot re-create root directory."
        )

    var index := 0
    ## Current path to create new folder.
    var base_path := "/"
    var name_of_folder_to_create: String
    while index < paths.size():
        name_of_folder_to_create = paths[index]

        # # Try creating.
        var create_result := self.pc__ref.fs.create(
            base_path, name_of_folder_to_create,
            DMFSNode.Type.folder, self.terminal__ref.user_permission
        )
        if create_result.is_error:
            # If already exists, skip and try next create.
            if create_result.error == DMFSResult.Error.already_exists:
                base_path = base_path.path_join(name_of_folder_to_create)
                index += 1
                continue
            # If something else happens, return the error.
            else:
                return create_result

    # # Check the last folder created.
    # Two condition will happen if result is ok.
    # 1. Really created until the final folder.
    # 2. The last folder created (skipped to create), was a file.
    var meta_of_last__result := self.pc__ref.fs.stat(
        base_path, self.terminal__ref.user_permission
    )
    # Must success, otherwise `create` already fails.
    if meta_of_last__result.is_ok:
        # If last folder "created" is a file.
        if (meta_of_last__result.value as DMFSNode.Meta).is_file:
            return DMFSResult.createError(
                DMFSResult.Error.not_folder,
                str(
                    "Provided path is not a folder: ",
                    base_path
                )
            )
        # If last folder is just existing as a folder.
        else:
            return DMFSResult.createOK()
    # If cannot read meta info. This should not happen.
    else:
        return meta_of_last__result
