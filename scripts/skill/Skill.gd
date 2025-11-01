@abstract
class_name Skill
extends Equipment
# Abstract class for all skill.


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


## Activate the skill.[br][br]
##
## Should pass the game ref.
@abstract func activate() -> Error;

## Deactivate (stop) the skill,
##  restore the special effect gave to the ball and the game.
## Only effective for those who have effective time (skill will last for some time).
@abstract func deactivate() -> Error;
