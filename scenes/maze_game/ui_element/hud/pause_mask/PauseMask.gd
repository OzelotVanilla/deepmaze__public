class_name PauseMask
extends ColorRect
## Pause mask including the pause dialog of [MazeGame].


var game_ref: MazeGame

@onready var resume_button: FocusButton = $ColorRect/VBoxContainer/ResumeButton


func _ready() -> void: self.__onReady__()


func __onReady__():
    self.visibility_changed.connect(self._on_self_visibility_changed)

func _on_self_visibility_changed() -> void:
    # Auto-focus a button to enable navigation.
    if self.is_visible_in_tree():
        self.resume_button.grab_focus.call_deferred()

func _on_ResumeButton_pressed() -> void:
    self.game_ref.resumeGame()
