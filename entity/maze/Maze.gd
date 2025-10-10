class_name Maze
extends TileMapLayer


const black_and_white_atlas__source_id := 0

const black_tile__atlas_coord := Vector2i(0, 0)

const white_tile__atlas_coord := Vector2i(1, 0)

const length_of_tile := 16


func _init() -> void:
    self.tile_set = preload("res://assets/maze/monocolour_tileset.tres")
