@abstract
class_name Ability
extends Equipment
## Base class for all ability, which is effective as long as it is equipped.


## Enable the ability, so the player will benefit from that.
@abstract func enable() -> Error;

## Disable the ability, restore the status.
@abstract func disable() -> Error;
