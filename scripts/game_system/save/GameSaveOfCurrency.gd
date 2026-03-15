class_name GameSaveOfCurrency
extends Resource
## Game save of currency


## Currency (coin): Earned quarter's count.
## Must be greater than 0, no maximum set.
@export_range(0, 999999, 1, "or_greater") var quarter_count: int = 0:
    set(new_count):
        quarter_count = new_count
        self.emit_changed()


## Retrieve buffered diff data from game state.
func applyGameStateDiff():
    self.quarter_count += save_manager.save.game_state.buffered_diff__currency.quarter_count
