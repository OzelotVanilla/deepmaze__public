class_name PauseCountdownSkill
extends Skill


## How long can this skill pause the
var period_of_pause: float = 5.0


## Return [constant Error.ERR_UNAVAILABLE] if the skill is not available.
func activate() -> Error:
    if not self.could_be_used_in_this_level:
        return Error.ERR_UNAVAILABLE

    # Pause the entire process of the game
    #self.game_ref.game_remain_timer.paused = true
    self.game_ref.get_tree().paused = true

    self.is_active_now = true
    var timer := self.game_ref.get_tree().create_timer(self.period_of_pause)
    timer.timeout.connect(
        self.deactivate,
        ConnectFlags.CONNECT_ONE_SHOT
    )

    self.remain_count -= 1
    self.had_used_in_this_level = true
    return Error.OK

func deactivate() -> Error:
    self.game_ref.get_tree().paused = false
    self.is_active_now = false
    return Error.OK

func _init() -> void:
    self.icon_path = "res://assets/vector_graphics/equipment/pause_countdown_skill.svg"
    self.max_count = 3
    self.only_one_time_per_level = false

    self.period_of_pause = 5.0
