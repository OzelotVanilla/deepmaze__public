class_name GameSaveOfStat
extends Resource
## Game save of statistics


## Statistics: Deepest level
@export var deepest_level: int = 0


## Retrieve buffered diff data from game state.
func applyGameStateDiff():
    self.deepest_level += save_manager.save.game_state.buffered_diff__stat.deepest_level
