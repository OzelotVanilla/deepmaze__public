@tool
class_name SceneRoot
extends Control
## The root node of the game
##
## Method start with "pop"/"push"/"change" will switch to an existed scene.[br][br]
##
## Video playback is available, while the scene tree could be set to paused.


@onready var scene_stack__ref: Control = $SceneStack

## Will be showed only if the video is played.
@onready var video_stream_player__ref: SceneRootVideoStreamPlayer = \
    $VideoLayer/SceneRootVideoStreamPlayer

@onready var opening_player__ref: OpeningPlayer = $VideoLayer/OpeningPlayer


func _ready() -> void: self.__onReady__()


const scene__dict: Dictionary[StringName, PackedScene] = {
    "maze_game": preload("res://scenes/maze_game/MazeGame.tscn"),
    "press_any_key_title": preload("res://scenes/press_any_key_title/GamePressAnyKeyPage.tscn"),
    "title": preload("res://scenes/title/GameTitlePage.tscn"),
    "menu": preload("res://scenes/menu/GameMenuPage.tscn"),
    "setting": preload("res://scenes/setting/GameSettingPage.tscn"),
    "credits": preload("res://scenes/credits/GameCreditsPage.tscn"),
    "exploration_log": preload("res://scenes/exploration_log/GameExplorationLogPage.tscn"),
    "relic": preload("res://scenes/relic/GameRelicPage.tscn")
}

## Preloads all video. Convert them to Ogg Theora format first.
const video__dict: Dictionary[StringName, VideoStreamTheora] = {
}


## Push a new scene into the stack.
## The scene pushed before will be alived.
func pushScene(scene_name: StringName, ...postInit__args):
    # If there is existing scene:
    if self.scene_stack__ref.get_child_count() > 0:
        var old_scene: BaseGameScene = self.scene_stack__ref.get_child(-1)
        old_scene.hibernate()

    var scene: BaseGameScene = self.scene__dict[scene_name].instantiate()
    self.scene_stack__ref.add_child(scene)
    scene.postInit(postInit__args)

## Pop a scene from stack.
## If no enough scene to be pop-ed, an error generates.
func popScene():
    if self.scene_stack__ref.get_child_count() <= 1:
        printerr(str(
            "Cannot pop anymore because the scene stack is empty,",
            " or only contains one last scene."
        ))
        return

    var poped_scene: BaseGameScene = self.scene_stack__ref.get_child(-1)
    self.scene_stack__ref.remove_child(poped_scene)
    poped_scene.queue_free()

    var previous_scene: BaseGameScene = self.scene_stack__ref.get_child(-1)
    previous_scene.aestivate()

## Change the active scene to a new scene.
func changeScene(scene_name: StringName, ...postInit__args):
    var scene: BaseGameScene = self.scene__dict[scene_name].instantiate()
    scene.postInit(postInit__args)

    var poped_scene: BaseGameScene = self.scene_stack__ref.get_child(-1)
    self.scene_stack__ref.remove_child(poped_scene)
    poped_scene.queue_free.call_deferred()

    # If there is existing scene:
    if self.scene_stack__ref.get_child_count() > 0:
        var old_scene: BaseGameScene = self.scene_stack__ref.get_child(-1)
        old_scene.hibernate()

    self.scene_stack__ref.add_child(scene)

## Play a video by providing its name in [member video__dict].
func playVideo(video_name: StringName):
    if not self.video__dict.has(video_name):
        printerr("Cannot find video with name `", video_name, "`.")
        return

    var video_stream := self.video__dict[video_name]
    self.video_stream_player__ref.playVideoStream(video_stream)

## Will be called when config changed.
func applyConfig(on_what: GameConfig.ChangingCategory):
    match on_what:
        GameConfig.ChangingCategory.display:
            ## # Resolution
            #var resolution__pair := config_manager.config.resolution.split(" X ")
            #if resolution__pair.size() != 2:
                #printerr("Wrong resolution being set-ed: ", config_manager.config.resolution)
            #var scale_size := Vector2i(resolution__pair[0].to_int(), resolution__pair[1].to_int())
            #self.get_tree().root.content_scale_size = scale_size

            # # Fullscreen
            DisplayServer.window_set_mode(
                DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN \
                    if config_manager.config.fullscreen else \
                DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
            )

            # Need to release action,
            #  because changing between fullscreen might let key release not handled.
            Input.action_release("move_left"); Input.action_release("move_right");
            Input.action_release("move_up");   Input.action_release("move_down");

        GameConfig.ChangingCategory.volume:
            audio_manager.master_volume = config_manager.config.master_volume
            audio_manager.bgm_volume = config_manager.config.music_volume
            audio_manager.sfx_volume = config_manager.config.sfx_volume

        GameConfig.ChangingCategory.language:
            var locale: String
            match config_manager.config.languages:
                "ENGLISH":
                    locale = "en"
                "S. CHINESE":
                    locale = "zh_CN"

            TranslationServer.set_locale(locale)

static func isFirstTimeRun():
    return not config_manager.isLocalConfigFileExist() \
       and not save_manager.isLocalSaveFileExist()

func __onReady__():
    # Do not init if opened in editor.
    if Engine.is_editor_hint():
        return

    var can_skip_opening_video: bool
    # Test if it is first time enter this game.
    if SceneRoot.isFirstTimeRun():
        config_manager.createConfig()
        can_skip_opening_video = false
    else:
        config_manager.loadFromLocalFile() # Will auto create default config, if not exist.
        if save_manager.isLocalSaveFileExist():
            save_manager.loadFromLocalFile() # Will not create a new save.
        can_skip_opening_video = true

    config_manager.config_changed.connect(self.applyConfig)
    # Trigger config application on init.
    config_manager.config_changed.emit(GameConfig.ChangingCategory.display)
    config_manager.config_changed.emit(GameConfig.ChangingCategory.volume)
    config_manager.config_changed.emit(GameConfig.ChangingCategory.language)

    # Play opening video.
    await self.opening_player__ref.playOpeningVideo(can_skip_opening_video)

    self.pushScene("press_any_key_title")

func quitGame():
    self.get_tree().quit()
