class_name EmbeddedMazePreset
extends Resource
## Configuration resource defining a wrapper maze preset with embedded sub-mazes.


@export var wrapper_width: int = 35
@export var wrapper_height: int = 35

@export var sub_mazes: Array[SubMaze] = []

## Array of Dictionaries defining inter-maze connections between ports.
## Structure:
## [
##   {
##     "from_sub_maze_idx": 0, "from_port_idx": 0,
##     "to_sub_maze_idx": 1, "to_port_idx": 0
##   }, ...
## ]
@export var connections: Array[Dictionary] = []
