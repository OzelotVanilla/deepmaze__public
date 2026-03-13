@tool
class_name ExplorationLogTextEntry
extends LinkedTextEntryResource
## Resource file of game exploration log's text entry


## Set containing exploration log ID to be generated.
## After changing this, press the generate button below.
@export var exploration_log_id__set: Dictionary[int, Variant]

@export_tool_button("Generate PO ID") var generate_po_id__action = getPOIDArray

## PO ID of the exploration log.
func getPOIDArray() -> PackedStringArray:
    var result := PackedStringArray()
    for i in self.exploration_log_id__set.keys():
        result.append(ExplorationLogTextEntry.getPOIDForTitle(i))
        result.append(ExplorationLogTextEntry.getPOIDForText(i))

    return result

static func getPOIDForTitle(exp_log_id: int) -> String:
    return str(
        "assets.exploration_log_", exp_log_id, "__title"
    )

static func getPOIDForText(exp_log_id: int) -> String:
    return str(
        "assets.exploration_log_", exp_log_id, "__text"
    )
