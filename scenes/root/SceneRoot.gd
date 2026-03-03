class_name SceneRoot
extends Control
## The root node of the game
##
## Method start with "switch" will switch to an existed scene.


func _ready() -> void: self.__onReady__()


const scene__dict: Dictionary[StringName, PackedScene] = {
    "maze_game": preload("res://scenes/maze_game/MazeGame.tscn"),
    "press_any_key_title": preload("res://scenes/press_any_key_title/GamePressAnyKeyPage.tscn"),
    "title": preload("res://scenes/title/GameTitlePage.tscn"),
    "menu": preload("res://scenes/menu/GameMenuPage.tscn"),
    "setting": preload("res://scenes/setting/GameSettingPage.tscn"),
    "credits": preload("res://scenes/creadits/GameCreditsPage.tscn"),
    "exploration_log": preload("res://scenes/exploration_log/GameExplorationLogPage.tscn"),
    "relic": preload("res://scenes/relic/GameRelicPage.tscn")
}


## Scene to be shown on the screen.
var current_scene: Control:
    set(new_scene):
        ## The `CurrentScene` node in tree that display the scene.
        var node = $CurrentScene
        for c in node.get_children(): node.remove_child(c)
        node.add_child(new_scene)

        current_scene = new_scene

## Scene that is stacked. The last element will be the current scene.
var scene_stack: Array[BaseGameScene] = []


## Push a new scene into the stack.
## The scene pushed before will be alived.
func pushScene(scene_name: StringName, ...postInit__args):
    var scene: BaseGameScene = self.scene__dict[scene_name].instantiate()
    self.scene_stack.push_back(scene)
    scene.postInit(postInit__args)
    self.current_scene = scene

## Pop a scene from stack.
## If no enough scene to be pop-ed, an error generates.
func popScene():
    if scene_stack.size() <= 1:
        printerr(str(
            "Cannot pop anymore because the scene stack is empty,",
            " or only contains one last scene."
        ))

    var poped_scene: BaseGameScene = self.scene_stack.pop_back()
    poped_scene.queue_free.call_deferred()

    self.current_scene = self.scene_stack.back()

## Change the active scene to a new scene.
func changeScene(scene_name: StringName, ...postInit__args):
    var scene: BaseGameScene = self.scene__dict[scene_name].instantiate()
    scene.postInit(postInit__args)

    var poped_scene: BaseGameScene = self.scene_stack.pop_back()
    poped_scene.queue_free.call_deferred()

    self.scene_stack.push_back(scene)
    self.current_scene = scene

static func isFirstTimeRun():
    return not config_manager.isLocalConfigFileExist() \
       and not save_manager.isLocalSaveFileExist()

func __onReady__():
    # Test if it is first time enter this game.
    if SceneRoot.isFirstTimeRun():
        config_manager.createConfig()
    else:
        config_manager.loadFromLocalFile() # Will auto create default config, if not exist.
        if save_manager.isLocalSaveFileExist():
            save_manager.loadFromLocalFile()

    self.pushScene("press_any_key_title")

func quitGame():
    self.get_tree().quit()
