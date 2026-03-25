class_name GameSettingPage
extends BaseGameScene


@onready var resolution_option__ref: SettingOptionRow = $VBox/ResolutionOption

@onready var fullscreen_option__ref: SettingOptionRow = $VBox/FullscreenOption

@onready var master_volume_option__ref: SettingOptionRow = $VBox/MasterVolumeOption

@onready var gameplay_volume_option__ref: SettingOptionRow = $VBox/GameplayVolumeOption

@onready var ui_volume_option__ref: SettingOptionRow = $VBox/UIVolumeOption

@onready var language_option__ref: SettingOptionRow = $VBox/LanguagesOption


func _ready() -> void:
    super()
    self.__onReady__()

func _unhandled_input(event: InputEvent) -> void: self.__handleUnprocessedInput__(event)

func _exit_tree() -> void: self.__onExitTree__()


func goBack():
    self.root_scene__ref.popScene()

func loadConfigToUI():
    self.resolution_option__ref.widget.setWidgetValue(config_manager.config.resolution)
    self.fullscreen_option__ref.widget.setWidgetValue(config_manager.config.fullscreen)
    self.master_volume_option__ref.widget.setWidgetValue(config_manager.config.master_volume)
    self.gameplay_volume_option__ref.widget.setWidgetValue(config_manager.config.gameplay_volume)
    self.ui_volume_option__ref.widget.setWidgetValue(config_manager.config.ui_volume)
    self.language_option__ref.widget.setWidgetValue(config_manager.config.languages)

## Make [signal SettingWidget.changed] changes [member ConfigManager.config].
func connectWidgetChangeToConfigChange():
    # Resolution
    if not self.resolution_option__ref.widget.changed.is_connected(self.setResolution):
        self.resolution_option__ref.widget.changed.connect(self.setResolution)

    # Fullscreen
    if not self.fullscreen_option__ref.widget.changed.is_connected(self.setFullscreen):
        self.fullscreen_option__ref.widget.changed.connect(self.setFullscreen)

    # Master Volume
    if not self.master_volume_option__ref.widget.changed.is_connected(self.setMasterVolume):
        self.master_volume_option__ref.widget.changed.connect(self.setMasterVolume)

    # Gameplay Volume
    if not self.gameplay_volume_option__ref.widget.changed.is_connected(self.setGameplayVolume):
        self.gameplay_volume_option__ref.widget.changed.connect(self.setGameplayVolume)

    # UI Volume
    if not self.ui_volume_option__ref.widget.changed.is_connected(self.setUIVolume):
        self.ui_volume_option__ref.widget.changed.connect(self.setUIVolume)

    # Language
    if not self.language_option__ref.widget.changed.is_connected(self.setLanguage):
        self.language_option__ref.widget.changed.connect(self.setLanguage)

func setResolution(new_resolution: String):
    config_manager.config.resolution = new_resolution

func setFullscreen(whether_fullscreen: bool):
    config_manager.config.fullscreen = whether_fullscreen

func setMasterVolume(new_volume: int):
    config_manager.config.master_volume = new_volume

func setGameplayVolume(new_volume: int):
    config_manager.config.gameplay_volume = new_volume

func setUIVolume(new_volume: int):
    config_manager.config.ui_volume = new_volume

func setLanguage(new_language: String):
    config_manager.config.languages = new_language

func __onReady__():
    config_manager.loadFromLocalFile(true) # should_create_when_no_exist=true
    self.loadConfigToUI()
    self.connectWidgetChangeToConfigChange()

    self.fullscreen_option__ref.grab_focus()

func __handleUnprocessedInput__(event: InputEvent):
    if   event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        self.root_scene__ref.popScene()

func __onExitTree__():
    # Trigger save of config.
    config_manager.saveToLocalFile()
