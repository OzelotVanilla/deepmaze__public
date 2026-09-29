class_name MazeGameInitArgs
extends RefCounted
## Args for [method MazeGame.postInit]
##
## This data class should not save buffered data of [GameSaveOfGameState],
##  since that data should be modified in game runtime.


## Record if the game is started by "continue" or "new dive".
var is_new_game: bool = false

## The reference to [member GameSave.game_state].
## Meaningful only when [code]self.is_new_game == false[/code].
var saved_state_data: GameSaveOfGameState

## Time lefted (for [Timer]).
## Meaningful only when [code]self.is_new_game == false[/code].
var time_left: float = 120

## Type of the ball that player choosed for current game.
## Meaningful only when [code]self.is_new_game == false[/code].
var ball_type: MazeGame.BallType = MazeGame.BallType.wall_clip


## Generate the init arg from a game save data.
static func fromSaveData(save: GameSave) -> MazeGameInitArgs:
    var result = MazeGameInitArgs.new()
    result.is_new_game = false
    result.saved_state_data = save.game_state

    return result

## Create the default config for starting new game.
static func createNewGame(
    choosed_ball_type: MazeGame.BallType = MazeGame.BallType.wall_clip,
    time_for_one_game: float = 120
) -> MazeGameInitArgs:
    var result = MazeGameInitArgs.new()
    result.is_new_game = true
    result.ball_type = choosed_ball_type
    result.time_left = time_for_one_game

    return result
