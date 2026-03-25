class_name HUDRightPanel
extends ColorRect
## UI of [MazeGame].


var game_ref: MazeGame:
    set(new_ref):
        if game_ref == new_ref:
            return

        game_ref = new_ref

        if self.is_node_ready():
            self.ability_button__ref.game__ref = new_ref


@onready var level_text__label: Label = $VBox/HBox/LevelText

@onready var minute__label: Label = $VBox/TimeLabelHBox/MinuteLabel

@onready var second__label: Label = $VBox/TimeLabelHBox/SecondLabel

@onready var millisecond__label: Label = $VBox/TimeLabelHBox/MilliSecondLabel

@onready var ability_button__ref: AbilityButton = $VBox/AbilityButton


func _unhandled_input(event: InputEvent) -> void: self.__handleUnprocessedInput__(event)


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

func handleGamePause():
    # # Remained time is set-ed by outer script. No need to pause here.
    # # Set recursive behaviour.

    self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
    self.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED

func handleGameResume():
    # # Remained time is set-ed by outer script. No need to resume here.

    # # Set recursive behaviour.
    self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED
    self.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED

func handleGameDie():
    # # Set recursive behaviour.
    self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
    self.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED

func handleGameRevive():
    # # Set recursive behaviour.
    self.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED
    self.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED

func __handleUnprocessedInput__(event: InputEvent) -> void:
    # # Do not handle input if paused (e.g., pausing game, or just game over).
    if get_tree().paused:
        return

    # # Handling equipment related actions.
    if event.is_action_pressed("trigger_ability"):
        self.ability_button__ref.beginTriggerHold()
        get_viewport().set_input_as_handled()
    if event.is_action_released("trigger_ability"):
        self.ability_button__ref.endTriggerHold()
        get_viewport().set_input_as_handled()
