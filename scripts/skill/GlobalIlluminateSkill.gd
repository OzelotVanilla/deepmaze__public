class_name GlobalIlluminateSkill
extends ActiveSkill


## Length of illumination.
var duration: float = 3.0


## Return [constant Error.ERR_UNAVAILABLE] if the skill is not available.
## Return [constant Error.ERR_ALREADY_EXISTS] if current level does not need illumination
##  (that is, not a dark level).
## Return [constant Error.ERR_CANT_RESOLVE] if [member MazeGame.dark_level_mask_dict]
##  does not have entry for the dark level.
func activate() -> Error:
    if not self.could_be_used_in_this_level:
        return Error.ERR_UNAVAILABLE

    if not self.game_ref.is_current_level_a_dark_level:
        return Error.ERR_ALREADY_EXISTS

    var dark_mask: CanvasItem = self.game_ref.dark_level_mask_dict.get(
        self.game_ref.special_level_type
    )

    if dark_mask == null:
        return Error.ERR_CANT_RESOLVE

    # Disable dark mask to make the area "lit up".
    dark_mask.visible = false

    self.is_active_now = true
    var timer := self.game_ref.get_tree().create_timer(self.duration)
    timer.timeout.connect(
        self.deactivate,
        ConnectFlags.CONNECT_ONE_SHOT
    )

    self.remain_count -= 1
    self.had_used_in_this_level = true
    return Error.OK

## Return [constant Error.ERR_CANT_RESOLVE] if [member MazeGame.dark_level_mask_dict]
##  does not have entry for the dark level.
func deactivate() -> Error:
    var dark_mask: CanvasItem = self.game_ref.dark_level_mask_dict.get(
        self.game_ref.special_level_type
    )

    if dark_mask == null:
        return Error.ERR_CANT_RESOLVE

    # Restore visibility of dark mask.
    dark_mask.visible = true

    self.is_active_now = false
    return Error.OK

func _init() -> void:
    self.icon_path = "res://assets/vector_graphics/equipment/global_illuminate_skill.svg"
    self.max_count = 3
    self.only_one_time_per_level = false
