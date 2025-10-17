class_name Maze
extends TileMapLayer


const black_and_white_atlas__source_id := 0

const white_tile__atlas_coord := Vector2i(0, 0)

const black_tile__atlas_coord := Vector2i(1, 0)

const length_of_tile := 16

## Vector2i(x_coord, y_coord), unit is [code]tile[/code], starts with 0.
var exit_gate__coord := Vector2i.ZERO


func isWallAt(x: int, y: int):
    return self.get_cell_atlas_coords(Vector2i(x, y)) == Maze.black_tile__atlas_coord

func _init() -> void:
    self.tile_set = preload("res://assets/tilesets/maze/monocolour_tileset.tres")
