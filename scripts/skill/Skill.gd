@abstract
class_name Skill
extends Equipment
## Abstract class for all skill, which has limited number to be used.


## The remaining time that you can use this skill.[br][br]
##
## Should be greater than 0 for the skill to activate.
var remain_count: int = 3

## Whether the skill is being active now.
var is_active_now: bool = false

## Max count of this skill.
var max_count: int = 3

## Whether the skill could only be use once per level.
var only_one_time_per_level: bool = false

## Whether the skill is used in current level (should be refreshed at next level).
var had_used_in_this_level: bool = false

## See if the skill could still be used in one level.[br][br]
##
## Check remain count and if the skill could only be used one time in the same level.
var could_be_used_in_this_level: bool:
    get:
        return not (self.only_one_time_per_level and self.had_used_in_this_level) \
           and self.remain_count > 0

## Activate the skill.[br][br]
##
## Remember to check availability through [member could_be_used_in_this_level].
## Also, decrease the [member remain_count], set [member had_used_in_this_level],
##  if the skill is successfully activated.
##
## Should pass the game ref.
@abstract func activate() -> Error;

## Deactivate (stop) the skill,
##  restore the special effect gave to the ball and the game.
## Only effective for those who have effective time (skill will last for some time).
@abstract func deactivate() -> Error;
