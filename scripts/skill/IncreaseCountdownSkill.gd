class_name IncreaseCountdownSkill
extends Skill


var amount_of_increase: float = 5.0


## Return [constant Error.ERR_UNAVAILABLE] if the skill is not available.
func activate() -> Error:
    if not self.could_be_used_in_this_level:
        return Error.ERR_UNAVAILABLE

    var timer := self.game_ref.game_remain_timer
    timer.start(timer.time_left + 5)

    self.remain_count -= 1
    self.had_used_in_this_level = true
    return Error.OK

func deactivate() -> Error:
    # No need to deactivate.
    return Error.OK

func _init() -> void:
    self.icon_path = "res://assets/vector_graphics/equipment/increase_countdown_skill.svg"
    self.max_count = 3
    self.only_one_time_per_level = true

    self.amount_of_increase = 5.0
