class_name DMTerminalCommandSchema
extends RefCounted


class Option:
    var name: String
    var short_name: String
    var description: String
    var type: DMTerminalArguments.OptionType = DMTerminalArguments.OptionType.VALUE
    var default_value: Variant


class Positional:
    var name: String
    var description: String
    var default_value: Variant
    var required: bool = true
    ## Whether allows arbitrary numbers of args.
    var variadic: bool = false


var allowed_options: Dictionary = {} # name/short_name -> Option
var positional_definitions: Array[Positional] = []


func has_options() -> bool:
    return not allowed_options.is_empty()


func add_option(
    name: String,
    short_name: String = "",
    description: String = "",
    default_value: Variant = null,
    type: DMTerminalArguments.OptionType = DMTerminalArguments.OptionType.VALUE,
) -> void:
    assert(name != "help", "Option name 'help' is reserved.")
    assert(short_name != "h", "Short option 'h' is reserved for --help.")

    var opt: Option = Option.new()
    opt.name = name
    opt.short_name = short_name
    opt.description = description
    opt.type = type

    if default_value == null:
        match type:
            DMTerminalArguments.OptionType.VALUE: opt.default_value = ""
            DMTerminalArguments.OptionType.INT:   opt.default_value = 0
            DMTerminalArguments.OptionType.FLAG:  opt.default_value = false
    else:
        opt.default_value = default_value

    allowed_options[name] = opt
    if short_name != "":
        allowed_options[short_name] = opt


## If already added variadic,
##  the variadic definition will be moved to the last.
func add_positional(
    name: String,
    description: String = "",
    default_value: Variant = null
) -> void:
    var pos: Positional = Positional.new()
    pos.name = name
    pos.description = description
    pos.default_value = default_value
    pos.required = (default_value == null)
    positional_definitions.append(pos)

    # # Incase there is a variadic already added.
    sort_positionals()


## Will add it to the last of positional definitions.
func add_variadic_positional(
    name: String,
    description: String = "",
    default_value: Variant = null
) -> void:
    # # Check if still no variadic definition is added.
    var still_no_variadic := true
    for def in self.positional_definitions:
        if def.variadic:
            still_no_variadic = true
            break
    assert(still_no_variadic, "Cannot add more than one variadic schema.")

    var pos: Positional = Positional.new()
    pos.name = name
    pos.description = description
    pos.default_value = default_value
    pos.required = (default_value == null)
    pos.variadic = true
    self.positional_definitions.append(pos)


func get_option_data(key: String) -> Option:
    return allowed_options.get(key)


## Move the variadic definition to the last.
func sort_positionals() -> void:
    var variadic_index := -1
    for i in range(self.positional_definitions.size()):
        if self.positional_definitions[i].variadic:
            variadic_index = i
            break

    if variadic_index >= 0:
        # Move it to the back.
        self.positional_definitions.push_back(
            self.positional_definitions.pop_at(variadic_index)
        )
