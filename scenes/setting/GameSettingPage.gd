class_name GameSettingPage
extends BaseGameScene


@onready var resolution_option__ref: SettingOptionRow = $VBox/ResolutionOption


func _ready() -> void:
    super()
    self.__onReady__()

func _unhandled_input(event: InputEvent) -> void: self.__handleUnprocessedInput__(event)


func goBack():
    self.root_scene__ref.popScene()

func __onReady__():
    self.resolution_option__ref.grab_focus()

func __handleUnprocessedInput__(event: InputEvent):
    if   event.is_action_pressed("ui_cancel"):
        self.root_scene__ref.popScene()
