class_name SaveManager
extends Node
## Manage the game's save
##
## The [param save] is modified during game progress.
## Until [method saveToLocalFile] is called, it is not saved to local storage.
## Notice: Game should not be saved until player dies.

const path_to_local_save_file = "user://save.tres"


var save: GameSave


static func isLocalSaveFileExist():
    return FileAccess.file_exists(SaveManager.path_to_local_save_file)

## Create new game save.
func createSave():
    self.save = GameSave.new()
    self.saveToLocalFile()

## Load the save file from the local user file.
func loadFromLocalFile(should_create_when_no_exist: bool = true):
    if not SaveManager.isLocalSaveFileExist():
        if should_create_when_no_exist:
            self.createSave()
        else:
            printerr("Local save file does not exist")
            return

    self.save = ResourceLoader.load(SaveManager.path_to_local_save_file)

## Save the current save file to the local user file.[br][br]
##
## Notice: Game should not be saved until player dies.
func saveToLocalFile():
    if self.save == null:
        printerr("Save is not loaded.")

    ResourceSaver.save(self.save, SaveManager.path_to_local_save_file)
