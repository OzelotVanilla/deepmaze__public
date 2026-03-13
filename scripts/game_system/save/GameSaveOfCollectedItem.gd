class_name GameSaveOfCollectedItem
extends Resource
## Game save of collected item


## Collected Items: Unlocked ball type.
@export var ball_type: Array[CollectedItemDetail] = []
## Collected Items: Unlocked relic.
@export var relic: Array[CollectedItemDetail] = []
## Collected Items: Unlocked exploration log.
@export var exploration_log: Array[CollectedItemDetail] = []


## Retrieve buffered diff data from game state.
func applyGameStateDiff():
    self.ball_type.append_array(
        save_manager.save.game_state.buffered_diff__collected_item.ball_type
    )
    self.relic.append_array(
        save_manager.save.game_state.buffered_diff__collected_item.relic
    )
    self.exploration_log.append_array(
        save_manager.save.game_state.buffered_diff__collected_item.exploration_log
    )
