class_name MazeGameInitArgs
extends RefCounted
## Args for [method MazeGame.postInit]


## Record if the game is started by "continue" or "new dive".
var is_new_game: bool = false

## The player's coord to set.
## [code]Vector2i(-1, -1)[/code] means not specified.
var player_coord: Vector2i = Vector2i(-1, -1)

## The maze exit's coord to set.
## [code]Vector2i(-1, -1)[/code] means not specified.
var exit_coord: Vector2i = Vector2i(-1, -1)

## Time lefted (for [Timer]).
var time_left: float = 120

## The [member TileMapLayer.tile_map_data] of the maze to show now.
## Empty or [code]null[/code] value means do not specify.
var map_data: PackedByteArray

## The level player has passed.
var maze_level: int = 1

## Special level type of the maze to show now.
var special_level_type: MazeGame.SpecialLevel = MazeGame.SpecialLevel.none

## Type of the ball that player choosed for current game.
var ball_type: int = MazeGame.BallType.wall_clip


## Generate the init arg from a game save data.
static func fromSaveData(save: GameSave) -> MazeGameInitArgs:
    var result = MazeGameInitArgs.new()
    result.player_coord = save.game__player_coord
    result.exit_coord = save.game__exit_coord
    result.time_left = save.game__time_left
    result.map_data = save.game__map_data
    result.maze_level = save.game__maze_level
    result.special_level_type = save.game__special_level_type

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
