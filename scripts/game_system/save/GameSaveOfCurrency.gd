class_name GameSaveOfCurrency
extends Resource
## Game save of currency


## Currency (coin): Earned quater's count.
## Must be greater than 0, no maximum set.
@export_range(0, 999999, 1, "or_greater") var quater_count: int = 0


## Retrieve buffered diff data from game state.
func applyGameStateDiff():
    self.quater_count += save_manager.save.game_state.buffered_diff__currency.quater_count
