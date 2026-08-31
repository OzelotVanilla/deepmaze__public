class_name DMTerminalCommandManager
extends RefCounted

signal command_started()
signal command_finished()


var terminal: DMTerminal
var pc__ref: DMPC

## For built-in command such as "clear" or "echo".
var _builtin_command_registry: Dictionary = {}
var _environment: DMTerminalEnvironment
var _argv: PackedStringArray = []
var _parsed_args: DMTerminalArguments.ParsedArgs = null


func initialize(new_terminal: DMTerminal) -> void:
    self.terminal = new_terminal
    _environment = self.terminal.environment
    self.pc__ref = self.terminal.pc__ref
    _register_builtin_commands()


func get_available_builtin_commands() -> Array:
    return Array(_builtin_command_registry.keys())


func process_command(full_command: String) -> void:
    full_command = full_command.strip_edges()
    if full_command.is_empty():
        command_finished.emit()
        return

    var parts: PackedStringArray = _split_arguments_considering_quotes(full_command)
    var command_name: String = parts[0]

    _argv.clear()
    if parts.size() > 1:
        _argv = parts.slice(1)

    # # Get command object to run.
    var cmd_obj: DMTerminalCommand = self.resolveCommand(command_name)
    if cmd_obj == null:
        self.terminal.print_on_terminal(
            "Unknown command: `%s`." % command_name,
            self.terminal.semantic_colour__error
        )
        command_finished.emit()
        return

    if _argv.has("--help") or _argv.has("-h"):
        for help_line: String in cmd_obj.long_help:
            self.terminal.print_on_terminal(help_line)
        command_finished.emit()
        return

    if cmd_obj.schema:
        _parsed_args = DMTerminalArguments.parse(_argv, cmd_obj.schema)
        if not _parsed_args.errors.is_empty():
            for err: String in _parsed_args.errors:
                self.terminal.print_on_terminal(err, Color.RED)
            command_finished.emit()
            return
    else:
        _parsed_args = DMTerminalArguments.parse(_argv)

    var return_code = cmd_obj.callable.call(self._parsed_args)
    # Assume success if does not return.
    self.terminal.cmd_return_code = return_code if return_code != null else 0 # `void` return is `null`


func _register_builtin_commands() -> void:
    var cmd_obj: DMTerminalCommand

    # # "Terminal Emulator" commands

    cmd_obj = DMTerminalCommand.new()
    cmd_obj.name = "clear"
    cmd_obj.description = "Clear the screen."
    cmd_obj.callable = _cmd_clear
    _register_builtin_command(cmd_obj)

    # cmd_obj = DMTerminalCommand.new()
    # cmd_obj.name = "echo"
    # cmd_obj.description = "Print text on the screen."
    # cmd_obj.callable = _cmd_echo
    # _register_builtin_command(cmd_obj)

    cmd_obj = DMTerminalCommand.new()
    cmd_obj.name = "env"
    cmd_obj.description = "Show environment variables."
    cmd_obj.callable = _cmd_env
    _register_builtin_command(cmd_obj)

    cmd_obj = DMTerminalCommand.new()
    cmd_obj.name = "exit"
    cmd_obj.description = "Close the terminal."
    cmd_obj.callable = _cmd_exit
    _register_builtin_command(cmd_obj)

    # cmd_obj = DMTerminalCommand.new()
    # cmd_obj.name = "hello"
    # cmd_obj.description = "Greet the user."
    # cmd_obj.callable = _cmd_hello
    # cmd_obj.schema = DMTerminalCommandSchema.new()
    # cmd_obj.schema.add_positional("name", "The name of the user.")
    # cmd_obj.schema.add_positional("greeting", "The greeting to use.", "Hello")
    # cmd_obj.schema.add_option(
    #     "uppercase",
    #     "u",
    #     "Print in uppercase.",
    #     false,
    #     DMTerminalArguments.OptionType.FLAG
    # )
    # _register_builtin_command(cmd_obj)

    cmd_obj = DMTerminalCommand.new()
    cmd_obj.name = "help"
    cmd_obj.description = "List the available commands."
    cmd_obj.callable = _cmd_help
    _register_builtin_command(cmd_obj)

    # cmd_obj = DMTerminalCommand.new()
    # cmd_obj.name = "ping"
    # cmd_obj.description = "Test the network connection."
    # cmd_obj.callable = _cmd_ping
    # cmd_obj.schema = DMTerminalCommandSchema.new()
    # cmd_obj.schema.add_option("count", "c", "Number of pings.", 4, DMTerminalArguments.OptionType.INT)
    # cmd_obj.schema.add_positional("host", "The hostname or IP address to ping.", "example.com")
    # _register_builtin_command(cmd_obj)

    # # DeepMazeOS commands
    cmd_obj = DMTerminalBuiltIn__CD.new()
    self._register_builtin_command(cmd_obj)

    cmd_obj = DMTerminalBuiltIn__LS.new()
    self._register_builtin_command(cmd_obj)

    cmd_obj = DMTerminalBuiltIn__MK.new()
    self._register_builtin_command(cmd_obj)

    cmd_obj = DMTerminalBuiltIn__TOUCH.new()
    self._register_builtin_command(cmd_obj)


func _register_builtin_command(cmd_obj: DMTerminalCommand) -> void:
    _build_long_help(cmd_obj)
    self.prepareCommand(cmd_obj)
    _builtin_command_registry[cmd_obj.name] = cmd_obj


## Add reference to command. Returns the prepared command.
func prepareCommand(cmd_obj: DMTerminalCommand) -> DMTerminalCommand:
    cmd_obj.cmd_manager__ref = self
    cmd_obj.terminal__ref = self.terminal
    cmd_obj.pc__ref = self.pc__ref
    return cmd_obj


func resolveCommand(command: String) -> DMTerminalCommand:
    # First search command in built-in command registry.
    if self._builtin_command_registry.has(command):
        return _builtin_command_registry[command]
    # If not exists, try to parse the command.
    else:
        return self.resolveExternalCommand(command)


func resolveExternalCommand(command: String) -> DMTerminalCommand:
    # # Build `paths` from system `path`.
    var paths: Array[String] = []
    if command.contains("/"): # path-like
        paths.append(self.terminal.cwd)
    else:
        # TODO: Should read `path` file.
        paths.append(self.terminal.cwd)

    # # Try to find the file.
    for path in paths:
        var command_parsed_path := path.path_join(command).simplify_path()
        var read_result := self.pc__ref.fs.resolveExecutable(
            command_parsed_path, self.terminal.user_permission
        )
        if read_result.is_ok:
            var file_content: DMFSContent = read_result.value
            if file_content.is_referring_asset and file_content.asset_ref is DMFSScriptRef:
                var cmd_obj:DMTerminalCommand = \
                    (file_content.asset_ref as DMFSScriptRef).ref_script.new()
                return self.prepareCommand(cmd_obj)

    return null


func _build_long_help(cmd_obj: DMTerminalCommand) -> void:
    var help_lines: PackedStringArray = []
    var usage_line: String = "Usage: " + cmd_obj.name

    if cmd_obj.schema == null:
        help_lines.append(usage_line)
        help_lines.append("")
        help_lines.append(cmd_obj.description)
        cmd_obj.long_help = help_lines
        return

    if cmd_obj.schema.has_options():
        usage_line += " [options]"
    for pos: DMTerminalCommandSchema.Positional in cmd_obj.schema.positional_definitions:
        usage_line += " <%s>" % pos.name
    help_lines.append(usage_line)

    help_lines.append("")

    if not cmd_obj.schema.positional_definitions.is_empty():
        help_lines.append("Arguments:")
        for pos: DMTerminalCommandSchema.Positional in cmd_obj.schema.positional_definitions:
            var req_str: String = "" if pos.required else " (Default: `%s`)" % str(pos.default_value)
            help_lines.append("  %-18s %s%s" % [pos.name, pos.description, req_str])
        help_lines.append("")

    if cmd_obj.schema.has_options():
        help_lines.append("Options:")

        var processed_opts: Array = []
        for opt: DMTerminalCommandSchema.Option in cmd_obj.schema.allowed_options.values():
            if opt in processed_opts: continue
            processed_opts.append(opt)

            var long_opt: String = "--%s" % opt.name if opt.name != "" else ""
            var short_opt: String = "-%s" % opt.short_name if opt.short_name != "" else ""
            var comma: String = ", " if (long_opt != "" and short_opt != "") else ""
            var option_names: String = "%s%s%s" % [long_opt, comma, short_opt]

            var default_val_help: String = ""
            if opt.type != DMTerminalArguments.OptionType.FLAG:
                default_val_help = "(Default: %s)" % str(opt.default_value)

            var line: String = "  %-18s %s %s" % [option_names, opt.description, default_val_help]
            help_lines.append(line)

    cmd_obj.long_help = help_lines


static func _split_arguments_considering_quotes(input: String) -> PackedStringArray:
    var result: PackedStringArray = []
    var regex: RegEx = RegEx.new()
    # Matches words or text inside double quotes.
    regex.compile("\"([^\"]*)\"|(\\S+)")

    for m: RegExMatch in regex.search_all(input):
        if m.get_string(1) != "":
            # The text inside quotes.
            result.append(m.get_string(1))
        else:
            # The unquoted word.
            result.append(m.get_string(2))
    return result


func _safe_await(duration: float) -> bool:
    if not self.terminal.is_alive():
        return false

    await self.terminal.get_tree().create_timer(duration).timeout

    return self.terminal.is_alive()


func _cmd_clear(_toss_arg) -> void:
    self.terminal.clear_screen()
    command_finished.emit()


func _cmd_echo(_toss_arg) -> void:
    self.terminal.print_on_terminal(_parsed_args.raw)
    command_finished.emit()


func _cmd_env(_toss_arg) -> void:
    if _environment.variables.is_empty():
        self.terminal.print_on_terminal("No environment variables.", Color.YELLOW)
    else:
        for key: String in _environment.variables.keys():
            var value: String = str(_environment.variables[key])
            self.terminal.print_on_terminal("%s=%s" % [key, value])
    command_finished.emit()


func _cmd_exit(_toss_arg) -> void:
    command_started.emit()
    self.terminal.get_tree().quit()
    # Don't emit 'command_finished' to prevent a new line and prompt appearing before the
    # terminal actually quits.


func _cmd_help(_toss_arg) -> void:
    self.terminal.print_on_terminal("Available commands:")

    var command_names: Array = get_available_builtin_commands()
    command_names.sort()

    for command_name: String in command_names:
        var cmd_obj: DMTerminalCommand = _builtin_command_registry[command_name]
        # Use %-12s to pad the name to 12 characters so descriptions align.
        var line: String = "  %-12s %s" % [command_name, cmd_obj.description]
        self.terminal.print_on_terminal(line)

    self.terminal.create_new_logical_line()
    self.terminal.insert_char_at_caret(" ")
    self.terminal.print_on_terminal("Use `[command] --help` for more information.")
    command_finished.emit()


# Just to demonstrate options and positionals.
# func _cmd_hello(_toss_arg) -> void:
#     var name_to_greet: String = _parsed_args.positionals[0]
#     var greeting: String = _parsed_args.positionals[1]
#     var output: String = "%s, %s!" % [greeting, name_to_greet]
#     if _parsed_args.has_flag("uppercase"):
#         output = output.to_upper()
#     self.terminal.print_on_terminal(output)
#     command_finished.emit()


# This command serves as an example of a command that takes a certain time to complete.
func _cmd_ping(_toss_arg) -> void:
    command_started.emit()

    var host: String = _parsed_args.positionals[0]
    var count: int = _parsed_args.get_option("count")

    self.terminal.print_on_terminal("PING %s (???.???.???.???)." % [host])
    for seq in range(1, count + 1):
        if not await _safe_await(1.0): return
        self.terminal.print_on_terminal(
            "64 bytes from %s: icmp_seq=%d time=%d ms" % [host, seq, 20 + randi() % 10])
    if not await _safe_await(1.0): return
    self.terminal.print_on_terminal("--- %s ping statistics ---" % host)
    self.terminal.print_on_terminal(
		"%d packets transmitted, %d received, 0%% packet loss"
        % [count, count]
    )
    command_finished.emit()
