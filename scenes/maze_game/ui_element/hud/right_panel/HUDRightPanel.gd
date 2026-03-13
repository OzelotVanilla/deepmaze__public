class_name HUDRightPanel
extends ColorRect
## UI of [MazeGame].


var game_ref: MazeGame

@onready var level_text__label: Label = $VBox/HBox/LevelText

@onready var minute__label: Label = $VBox/TimeLabelHBox/MinuteLabel

@onready var second__label: Label = $VBox/TimeLabelHBox/SecondLabel

@onready var millisecond__label: Label = $VBox/TimeLabelHBox/MilliSecondLabel


func setLevel(new_level: int):
    if new_level <= 0:
        return

    #TODO: May include special level (or SP level num) in the future.
    if new_level > 0:
        self.level_text__label.text = str("LEVEL ", str(new_level).pad_zeros(2))

func setGameRemainingTime(time: float):
    self.minute__label.text = str(mini(99, int(time / 60))).pad_zeros(2)
    self.second__label.text = str(mini(99, int(fmod(time, 60)))).pad_zeros(2)
    var number_after_decimal_point := time - int(time)
    self.millisecond__label.text = str(number_after_decimal_point).pad_decimals(2).substr(2)
