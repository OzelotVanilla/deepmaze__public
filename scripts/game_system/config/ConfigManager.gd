@tool
class_name ConfigManager
extends Node
## Manage the game's config
##
## Notice: This script should have similar structure with [SaveManager].

const path_to_local_config_file = "user://config.tres"


## Config file of the game.[br][br]
##
## Setting this in inspector will affect local file.
@export var config: GameConfig:
    set(new_config):
        config = new_config
        # If changing this value in editor.
        if Engine.is_editor_hint():
            if new_config == null:
                self.deleteLocalFile()
            else:
                self.saveToLocalFile()

@export_tool_button("Save to local", "Save")
var saveToLocal_action = saveToLocalFile

@export_tool_button("Load from local", "Load")
var loadFromLocal_action = loadFromLocalFile.bind(false)

@export_tool_button("Set to default", "Reload")
var setBackToDefault_action = setBackToDefault


func setBackToDefault():
    self.createConfig()

## Check whether there is a file in "user://config.tres".
func isLocalConfigFileExist():
    return FileAccess.file_exists(ConfigManager.path_to_local_config_file)

## Create new game config.
func createConfig():
    self.config = GameConfig.new()
    self.saveToLocalFile()

## Load the config file from the local user file.
func loadFromLocalFile(should_create_when_no_exist: bool = true):
    if not config_manager.isLocalConfigFileExist():
        if should_create_when_no_exist:
            self.createConfig()
        else:
            printerr("Local config file does not exist")
            return

    self.config = ResourceLoader.load(ConfigManager.path_to_local_config_file)

## Save the current config file to the local user file.
func saveToLocalFile():
    if self.config == null:
        printerr("Config is null, probably because it is not loaded before.")

    ResourceSaver.save(self.config, ConfigManager.path_to_local_config_file)

## Delete the local config file.
func deleteLocalFile():
    DirAccess.remove_absolute(ConfigManager.path_to_local_config_file)

## Ensure the local config exists and loaded.
func ensureLoaded():
    if not self.isLocalConfigFileExist():
        printerr("Local config file does not exist, cannot be ensure loaded.")
        return

    # Only load from local if not loaded yet.
    if self.config == null:
        self.loadFromLocalFile(
            false # should_create_when_no_exist
        )
