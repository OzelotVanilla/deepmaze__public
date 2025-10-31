@abstract
class_name Equipment
extends RefCounted


## Path of equipment's icon.
var icon_path: StringName = ""

## Reference to maze game.
var game_ref: MazeGame


## Get the ball coordinate of the maze (coord of [TileMapLayer]).
func getBallCoordOfMaze() -> Vector2i:
    var ball_ref := self.game_ref.ball_ref
    var maze_ref := self.game_ref.maze_ref

    return maze_ref.local_to_map(maze_ref.to_local(ball_ref.global_position))
