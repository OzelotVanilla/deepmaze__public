class_name ConfigManager
extends Node
## Manage the game's config


const path_to_local_config_file = "user://config.tres"


var config: GameConfig


## Check whether there is a file in "user://config.tres".
static func isLocalConfigFileExist():
    return FileAccess.file_exists(ConfigManager.path_to_local_config_file)

## Create new game config.
func createConfig():
    self.config = GameConfig.new()
    self.saveToLocalFile()

## Load the config file from the local user file.
func loadFromLocalFile(should_create_when_no_exist: bool = true):
    if not ConfigManager.isLocalConfigFileExist():
        if should_create_when_no_exist:
            self.createConfig()
        else:
            printerr("Local config file does not exist")
            return

    self.config = ResourceLoader.load(ConfigManager.path_to_local_config_file)

## Save the current config file to the local user file.
func saveToLocalFile():
    if self.config == null:
        printerr("Config is not loaded.")

    ResourceSaver.save(self.config, ConfigManager.path_to_local_config_file)
