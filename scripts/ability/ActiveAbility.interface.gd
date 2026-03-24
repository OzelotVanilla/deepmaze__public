@abstract
class_name ActiveAbility
extends Ability
## Active Ability, have cooldown time


## Emitted when this ability is finished.
@warning_ignore("unused_signal") # Because this is an abstract class
signal finished()


## Cooldown time in second, for the skill to become available again.
var cooldown_time: float


## Activate the ability. If cannot activate, abort and return the reason.
## Emits [signal ActiveAbility.finished] if successfully activated.[br][br]
##
## Remember to check availability through [member could_be_used_in_this_level].
@abstract func activate() -> Error;

## Deactivate (stop) the skill,
##  restore the special effect gave to the ball and the game.[br]
## Only meaningful for those who have effective time (skill will last for some time),
##  or those who need to restore the game state back.
@abstract func deactivate() -> Error;
