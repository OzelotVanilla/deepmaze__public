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
