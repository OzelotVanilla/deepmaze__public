class_name PauseCountdownSkill
extends Skill


## How long can this skill pause the
var period_of_pause: float = 5.0


func activate() -> Error:
    if self.remain_count <= 0 or self.had_used_in_this_level:
        return Error.ERR_UNAVAILABLE

    # Pause the entire process of the game
    #self.game_ref.game_remain_timer.paused = true
    self.game_ref.get_tree().paused = true

    var timer := self.game_ref.get_tree().create_timer(self.period_of_pause)
    timer.timeout.connect(func():
        #self.game_ref.game_remain_timer.paused = false
        self.game_ref.get_tree().paused = false,
        ConnectFlags.CONNECT_ONE_SHOT
    )

    self.remain_count -= 1
    self.had_used_in_this_level = true
    return Error.OK

func deactivate() -> Error:
    # No need to deactivate.
    return Error.OK

func _init() -> void:
    self.icon_path = "res://assets/vector_graphics/equipment/pause_countdown_skill.svg"
    self.max_count = 3
    self.only_one_time_per_level = false

    self.period_of_pause = 5.0
