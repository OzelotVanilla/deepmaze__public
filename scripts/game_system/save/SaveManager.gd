@tool
class_name SaveManager
extends Node
## Manage the game's save
##
## The [param save] is modified during game progress.
## Until [method saveToLocalFile] is called, it is not saved to local storage.[br]
## Notice: Game should not be saved until player dies.[br]
## Notice: This script should have similar structure with [ConfigManager].

const path_to_local_save_file = "user://save.tres"


## Save file of the game.[br][br]
##
## Setting this in inspector will affect local file.
@export var save: GameSave:
    set(new_save):
        save = new_save
        # If changing this value in editor.
        if Engine.is_editor_hint():
            if new_save == null:
                self.deleteLocalFile()
            else:
                self.saveToLocalFile()


@export_tool_button("Save to local", "Save")
var saveToLocal_action = saveToLocalFile

@export_tool_button("Load from local", "Load")
var loadFromLocal_action = loadFromLocalFile.bind(false)

@export_tool_button("Delete local file", "Remove")
var deleteLocalFile_action = deleteLocalFile

func isLocalSaveFileExist():
    return FileAccess.file_exists(SaveManager.path_to_local_save_file)

## Create new game save.
func createSave():
    self.save = GameSave.new()
    self.saveToLocalFile()

## Load the save file from the local user file.
func loadFromLocalFile(should_create_when_no_exist: bool = true):
    if not self.isLocalSaveFileExist():
        if should_create_when_no_exist:
            self.createSave()
        else:
            printerr("Local save file does not exist.")
            return

    self.save = ResourceLoader.load(SaveManager.path_to_local_save_file)

## Save the current save file to the local user file.[br][br]
##
## Notice: Game should not be saved until player dies.
func saveToLocalFile():
    if self.save == null:
        printerr("Save is null, probably because it is not loaded before.")
        return

    ResourceSaver.save(self.save, SaveManager.path_to_local_save_file)

## Delete the local save file.
func deleteLocalFile():
    DirAccess.remove_absolute(SaveManager.path_to_local_save_file)

## Ensure the local save exists and loaded.
func ensureLoaded():
    if not self.isLocalSaveFileExist():
        printerr("Local save file does not exist, cannot be ensure loaded.")
        return

    # Only load from local if not loaded yet.
    if self.save == null:
        self.loadFromLocalFile(
            false # should_create_when_no_exist
        )

func hasUnfinishedGame():
    if not self.isLocalSaveFileExist():
        return false
    self.ensureLoaded()

    return self.save.game_state != null and self.save.game_state.is_game_unfinished

## This will move the buffered diff data in [member GameSave.game_state] to
##  [member GameSave.currency], [member GameSave.collected_item],
##  or [member GameSave.stat], and clear buffered diff data by setting them to default empty value.
func moveBufferedDiffToOuterSave():
    # Apply diff.
    self.save.currency.applyGameStateDiff()
    self.save.collected_item.applyGameStateDiff()
    self.save.stat.applyGameStateDiff()

    # Delete game buffered diff.
    self.save.game_state.deleteBufferedDiff()

## Get array of the relic that is not obtained yet.
func getArrayOfNotObtainedRelicID() -> Array[int]:
    ## Includes relic in the persist save and buffered diff.
    ## Only contains id for quicker query.
    var relic_obtained: Array[int] = []
    relic_obtained.append_array(
        self.save.collected_item.relic \
            .map(func(e: CollectedItemDetail): return e.item_id)
    )
    relic_obtained.append_array(
        self.save.game_state.buffered_diff__collected_item.relic \
            .map(func(e: CollectedItemDetail): return e.item_id)
    )

    var all_available_relic: Array[int] = \
        (load("res://assets/in_game_collection/relic/relic_text_entry.tres") as RelicTextEntry) \
        .relic_id__set.keys()

    var result: Array[int] = []
    for id in all_available_relic:
        if id not in relic_obtained:
            result.append(id)

    return result

const exploration_log_text_entry__path: StringName = \
    "res://assets/in_game_collection/exploration_log/exploration_log_text_entry.tres"

## Get array of the exploration log that is not obtained yet.
func getArrayOfNotObtainedExplorationLogID() -> Array[int]:
    ## Includes relic in the persist save and buffered diff.
    ## Only contains id for quicker query.
    var exploration_log_obtained: Array[int] = []
    exploration_log_obtained.append_array(
        self.save.collected_item.exploration_log \
            .map(func(e: CollectedItemDetail): return e.item_id)
    )

    var all_available_exploration_log: Array[int] = \
        (load(exploration_log_text_entry__path) as ExplorationLogTextEntry) \
        .exploration_log_id__set.keys()

    var result: Array[int] = []
    for id in all_available_exploration_log:
        if id not in exploration_log_obtained:
            result.append(id)

    return result
