class_name DMTerminalBuiltIn__LS
extends DMTerminalCommand
## Stores processing of DeepMaze OS command [code]ls[/code]


## Length of space inserted in each column.
const separation_space_len := 1

const colour__folder_name := Color("#0095d9")

const colour__file_name   := Color("#9e9478")


func _init() -> void:
    self.name = "ls"

    var new_schema := DMTerminalCommandSchema.new()
    new_schema.add_positional(
        "target_dir",
        "Directory to list folder/file.",
        "." # default is `cwd`
    )
    new_schema.add_option(
        "one-per-line",
        "1",
        "List the name of folder/file one per line.",
        null,
        DMTerminalArguments.OptionType.FLAG
    )
    new_schema.add_option(
        "detailed-list",
        "l",
        "List the name, type, time of creation/modification, and permission of folder/file.",
        null,
        DMTerminalArguments.OptionType.FLAG
    )
    self.schema = new_schema

    self.description = "List all folders and files in current directory."

    self.callable = self.run

func run(parsed_args: DMTerminalArguments.ParsedArgs) -> int:
    var path_in_arg: String = parsed_args.positionals[0]
    var path: String = self.terminal__ref.parsePath(path_in_arg)
    # Add trailing slash.
    if not path.ends_with("/"):
        path = str(path, "/")

    # # Try retrieve meta info array.
    var meta_infos_result := self.pc__ref.fs.listDir(
        path, self.terminal__ref.user_permission
    )
    if meta_infos_result.is_ok:
        var meta_infos: Array[DMFSNode.Meta] = meta_infos_result.value
        # # Check if empty.
        if meta_infos.is_empty():
            self.terminal__ref.print_on_terminal(
                str("Target directory is empty, nothing to show.")
            )
            self.cmd_manager__ref.command_finished.emit()
            return 0

        # # Collect folder/file info.
        var folder__meta_infos: Array[DMFSNode.Meta] = []
        var file__meta_infos:   Array[DMFSNode.Meta] = []
        for meta in meta_infos:
            if meta.is_folder:
                folder__meta_infos.append(meta)
            elif meta.is_file:
                file__meta_infos.append(meta)

        if parsed_args.has_flag("one-per-line"):
            self.writeOnePerLineToCache(folder__meta_infos, file__meta_infos)
        elif parsed_args.has_flag("detailed-list"):
            self.writeDetailListToCache(folder__meta_infos, file__meta_infos)
        # Show detailed list if not specified
        else:
            self.writeDetailListToCache(folder__meta_infos, file__meta_infos)
    else:
        match meta_infos_result.error:
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
        self.cmd_manager__ref.command_finished.emit()
        return 1

    self.cmd_manager__ref.command_finished.emit()
    return 0

func writeOnePerLineToCache(
    folder__meta_infos: Array[DMFSNode.Meta],
    file__meta_infos: Array[DMFSNode.Meta],
):
    # # Folders
    for node in folder__meta_infos:
        self.terminal__ref.print_on_terminal(
            str(node.name, "/"),
            self.colour__folder_name
        )

    # # Files
    for node in file__meta_infos:
        self.terminal__ref.print_on_terminal(
            node.name,
            self.colour__file_name
        )

func writeDetailListToCache(
    folder__meta_infos: Array[DMFSNode.Meta],
    file__meta_infos: Array[DMFSNode.Meta],
):
    var longest_folder_name_length: int = 0
    var longest_file_name_length:   int = 0
    for fs_node in folder__meta_infos:
        longest_folder_name_length = max(longest_folder_name_length, fs_node.name.length())
    for fs_node in file__meta_infos:
        longest_file_name_length = max(longest_file_name_length, fs_node.name.length())

    var space_for_type := 5
    var space_for_permission := 8
    var space_for_date := 20
    var space_for_name := mini(
        maxi(longest_folder_name_length, longest_file_name_length) + 1,
        self.terminal__ref.max_columns \
            - space_for_type - space_for_permission * 3 - space_for_date * 2
    )
    var separation_str := " ".repeat(self.separation_space_len)

    # # Head
    self.terminal__ref.print_on_terminal(
        str(
            "Type".rpad(space_for_type), separation_str,
            "Name".rpad(space_for_name), separation_str,
            "Read".rpad(space_for_permission), separation_str,
            "Write".rpad(space_for_permission), separation_str,
            "Exec".rpad(space_for_permission), separation_str,
            "Created At".rpad(space_for_date), separation_str,
            "Modified At".rpad(space_for_date), separation_str
        )
    )

    # # Separation Line
    self.terminal__ref.print_on_terminal(
        str(
            "-".repeat(space_for_type), separation_str,
            "-".repeat(space_for_name), separation_str,
            "-".repeat(space_for_permission), separation_str,
            "-".repeat(space_for_permission), separation_str,
            "-".repeat(space_for_permission), separation_str,
            "-".repeat(space_for_date), separation_str,
            "-".repeat(space_for_date), separation_str
        )
    )

    for fs_node_meta in (folder__meta_infos + file__meta_infos):
        var read_permission:  String = DMPermission.Level.find_key(fs_node_meta.read_permission)
        var write_permission: String = DMPermission.Level.find_key(fs_node_meta.write_permission)
        var exec_permission:  String = DMPermission.Level.find_key(fs_node_meta.exec_permission)
        var time_created_dict := \
            Time.get_datetime_dict_from_unix_time(floor(fs_node_meta.time_of_creation))
        var time_created: String = str(
            str(time_created_dict["month"]).lpad(2, "0"), "/",
            str(time_created_dict["day"]).lpad(2, "0"), "/",
            str(time_created_dict["year"]),
            " ",
            str(time_created_dict["hour"]).lpad(2, "0"), ":",
            str(time_created_dict["minute"]).lpad(2, "0"), ":",
            str(time_created_dict["second"]).lpad(2, "0")
        )
        var time_modified_dict := \
            Time.get_datetime_dict_from_unix_time(floor(fs_node_meta.time_of_last_modify))
        var time_modified: String = str(
            str(time_modified_dict["month"]).lpad(2, "0"), "/",
            str(time_modified_dict["day"]).lpad(2, "0"), "/",
            str(time_modified_dict["year"]),
            " ",
            str(time_modified_dict["hour"]).lpad(2, "0"), ":",
            str(time_modified_dict["minute"]).lpad(2, "0"), ":",
            str(time_modified_dict["second"]).lpad(2, "0")
        )
        self.terminal__ref.print_on_terminal(
            str(
                ("d" if fs_node_meta.is_folder else "").rpad(space_for_type), separation_str,
                fs_node_meta.name.rpad(space_for_name), separation_str,
                read_permission.rpad(space_for_permission), separation_str,
                write_permission.rpad(space_for_permission), separation_str,
                exec_permission.rpad(space_for_permission), separation_str,
                time_created.rpad(space_for_date), separation_str,
                time_modified.rpad(space_for_date), separation_str
            ),
            self.colour__folder_name if fs_node_meta.is_folder else self.colour__file_name
        )
