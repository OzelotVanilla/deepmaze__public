class_name HUD
extends ColorRect
## UI of [MazeGame].


var game_ref: MazeGame

var level: int:
    set = setLevel

@onready var level_text__label: Label = $VBox/LevelAndPauseMargin/LevelAndPauseHBox/LevelText


func setLevel(new_level: int):
    if new_level <= 0:
        return

    level = new_level

    #TODO: May include special level (or SP level num) in the future.
    if new_level > 0:
        self.level_text__label.text = str("LEVEL ", str(new_level).pad_zeros(2))
