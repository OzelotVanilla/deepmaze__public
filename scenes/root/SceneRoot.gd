class_name SceneRoot
extends Control
## The root node of the game
##
## Method start with "switch" will switch to an existed scene.

func _ready() -> void: self.__onReady__()


var current_scene: Control


func __onReady__():
    #TODO: Just for test.
    #self.switchToMazeGame()

    # Should be:
    self.switchToPressAnyKeyPage()

func quitGame():
    self.get_tree().quit()

func changeSceneToFile(tscn_file: PackedScene):
    if self.current_scene != null:
        self.current_scene.queue_free()

    var scene = tscn_file.instantiate()
    self.add_child(scene)
    self.current_scene = scene

func switchToMazeGame():
    self.changeSceneToFile(preload("res://scenes/maze_game/MazeGame.tscn"))

func switchToPressAnyKeyPage():
    self.changeSceneToFile(load("res://scenes/press_any_key_title/GamePressAnyKeyPage.tscn"))

func switchToTitle():
    self.changeSceneToFile(load("res://scenes/title/GameTitlePage.tscn"))
