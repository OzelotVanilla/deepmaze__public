@tool
class_name GameSave
extends Resource
## The save file of the game
##
## This file defines the entries to be saved as property.[br][br]
##
## Notice: Game will not save until player dies.


@export_group("Game state", "game__")
## Game state: The timestamp (int) when the player last saves.
@export var game__last_save_timestamp: int
## Game state: The player's coord when saving.
@export var game__player_coord: Vector2i = Vector2i(1, 1)
## Game state: The maze exit's coord when saving.
@export var game__exit_coord: Vector2i = Vector2i(1, 1)
## Game state: Time lefted (for [Timer]) when player exited.
@export var game__time_left: float = 0.0
## Game state: The [member TileMapLayer.tile_map_data] of the maze when player saved.
@export var game__map_data: PackedByteArray
## Game state: The level when player saved.
@export var game__maze_level: int = 1
## Game state: Special level type of the last played maze.
@export var game__special_level_type: MazeGame.SpecialLevel = MazeGame.SpecialLevel.none
## Game state: Type of the ball that player choosed for current game.
@export var game__ball_type: int = MazeGame.BallType.wall_clip

@export_group("Currency", "coin__")
## Currency (coin): Earned quater's count.
## Must be greater than 0, no maximum set.
@export_range(0, 999999, 1, "or_greater") var coin__quater_count: int = 0

@export_group("Collected Items", "collected__")
## Collected Items: Unlocked ball type.
@export var collected__ball_type: Array[CollectedItemDetail] = []
## Collected Items: Unlocked relic.
@export var collected__relic: Array[CollectedItemDetail] = []
## Collected Items: Unlocked exploration log.
@export var collected__exploration_log: Array[CollectedItemDetail] = []

@export_group("Statistics", "stat__")
## Statistics: Deepest level
@export var stat__deepest_level: int = 0
