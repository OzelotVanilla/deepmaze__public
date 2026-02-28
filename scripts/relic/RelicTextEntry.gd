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
        result.append(str(
            "relic_po_id_", i,
            "__do_not_edit_this_string_but_use_translation_framework"
        ))
        
    return result
