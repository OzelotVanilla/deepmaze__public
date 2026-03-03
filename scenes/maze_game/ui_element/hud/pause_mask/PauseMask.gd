class_name PauseMask
extends ColorRect
## Pause mask including the pause dialog of [MazeGame].


var game_ref: MazeGame

@onready var resume_button: FocusButton = $ColorRect/VBoxContainer/ResumeButton


func _ready() -> void: self.__onReady__()
func _unhandled_input(event: InputEvent) -> void: self.__handleUnprocessedInput__(event)


func __onReady__():
    self.visibility_changed.connect(self._on_self_visibility_changed)

func __handleUnprocessedInput__(event: InputEvent) -> void:
    if not self.visible:
        return
    if event.is_action_pressed("pause"):
        self.game_ref.resumeGame()
        get_viewport().set_input_as_handled()

func _on_self_visibility_changed() -> void:
    # Auto-focus a button to enable navigation.
    if self.is_visible_in_tree():
        self.resume_button.grab_focus.call_deferred()

func _on_ResumeButton_pressed() -> void:
    self.game_ref.resumeGame()

func _on_OptionButton_pressed() -> void:
    self.game_ref.root_scene__ref.pushScene("setting")

func _on_QuitButton_pressed() -> void:
    self.game_ref.quitToMenu()
