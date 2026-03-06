@tool
class_name ExplorationLogTextEntry
extends LinkedTextEntryResource
## Resource file of game exploration log's text entry


## Total count of the exploration log to be generated.
@export var count: int:
    set(value):
        count = value
        self.emit_changed()
        self.notify_property_list_changed()

## PO ID of the exploration log.
func getPOIDArray() -> PackedStringArray:
    var result := PackedStringArray()
    for i in range(1, self.count + 1):
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
