@abstract
class_name Ability
extends Equipment


## Enable the ability, so the player will benefit from that.
@abstract func enable() -> Error;

## Disable the ability, restore the status.
@abstract func disable() -> Error;
