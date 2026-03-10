class_name GameSaveOfGameState
extends Resource
## Game save of unfinished game


## Game state: Defines whether this save is valid. [code]true[/code] means valid.
@export var is_game_unfinished: bool = false

## Data that is useful to load an unfinished game back.
@export_group("Game Runtime Data")
## Game state: The timestamp (int) when the player last saves.
@export var last_save_timestamp: int
## Game state: The player's coord when saving.
@export var player_coord: Vector2i = Vector2i(1, 1)
## Game state: The maze exit's coord when saving.
@export var exit_coord: Vector2i = Vector2i(1, 1)
## Game state: Time lefted (for [Timer]) when player exited.
@export var time_left: float = 0.0
## Game state: The [member TileMapLayer.tile_map_data] of the maze when player saved.
@export var map_data: PackedByteArray
## Game state: The level when player saved.
@export var maze_level: int = 1
## Game state: Special level type of the last played maze.
@export var special_level_type: MazeGame.SpecialLevel = MazeGame.SpecialLevel.none
## Game state: Type of the ball that player choosed for current game.
@export var ball_type: MazeGame.BallType = MazeGame.BallType.wall_clip

## These data will replace the [GameSave]'s data only after game has finished.
@export_group("Buffered Data", "buffered__")
## Game state: Buffered currency.
@export var buffered__currency: GameSaveOfCurrency
## Game state: Buffered collected items.
@export var buffered__collected_item: GameSaveOfCollectedItem
## Game state: Buffered statistics.
@export var buffered__stat: GameSaveOfStat
