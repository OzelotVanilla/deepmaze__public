@tool
class_name RelicTextEntry
extends LinkedTextEntryResource
## Resource file of game relic text's entry


## Set containing relic ID to be generated.
## After changing this, press the generate button below.
@export var relic_id__set: Dictionary[int, Variant]

@export_tool_button("Generate PO ID") var generate_po_id__action = getPOIDArray


## PO ID of the relic.
func getPOIDArray() -> PackedStringArray:
    var result := PackedStringArray()
    for i in self.relic_id__set.keys():
        result.append(RelicTextEntry.getPOIDForTitle(i))
        result.append(RelicTextEntry.getPOIDForText(i))

    return result

static func getPOIDForTitle(relic_id: int) -> String:
    return str(
        "assets.relic_", relic_id, "__title"
    )

static func getPOIDForText(relic_id: int) -> String:
    return str(
        "assets.relic_", relic_id, "__text"
    )
