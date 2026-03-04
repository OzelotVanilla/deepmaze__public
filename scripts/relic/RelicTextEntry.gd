@tool
class_name RelicTextEntry
extends LinkedTextEntryResource
## Resource file of game relic text's entry


## Total count of the relic to be generated.
@export var count: int:
    set(value):
        count = value
        self.emit_changed()
        self.notify_property_list_changed()

## PO ID of the relic.
func getPOIDArray() -> PackedStringArray:
    var result := PackedStringArray()
    for i in range(1, self.count + 1):
        result.append(RelicTextEntry.getPOIDForTitle(i))
        result.append(RelicTextEntry.getPOIDForText(i))

    return result

static func getPOIDForTitle(relic_id: int) -> String:
    return str(
        "relic_po_id_", relic_id, "_title",
        "__do_not_edit_this_string_but_use_translation_framework"
    )

static func getPOIDForText(relic_id: int) -> String:
    return str(
        "relic_po_id_", relic_id, "_text",
            "__do_not_edit_this_string_but_use_translation_framework"
    )
