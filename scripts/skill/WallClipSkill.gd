class_name WallClipSkill
extends Skill
## Let player clip the wall which is attached to


## Return [constant Error.ERR_UNAVAILABLE] if the skill remains 0 times to use.
## Return [constant Error.ERR_QUERY_FAILED] if the ball is not attaching to the wall.
## Return [constant Error.Error.ERR_ALREADY_EXISTS]
##  if wall-clip target is the same as ball's position.
## Return [constant Error.ERR_DOES_NOT_EXIST] if wall-clip target is not a path.
func activate() -> Error:
    if self.remain_count <= 0:
        return Error.ERR_UNAVAILABLE

    var ball_ref := self.game_ref.ball_ref
    var maze_ref := self.game_ref.maze_ref

    # See if there are wall that this ball is attaching to.
    var collision_count := ball_ref.get_slide_collision_count()
    # If no, return fail.
    if collision_count <= 0:
        return Error.ERR_QUERY_FAILED

    # Get coord-in-maze for the ball and the directions.
    var ball_coord_in_maze := self.getBallCoordOfMaze()
    var move_intension := BallInputController.move_intension
    var offset := ball_ref.getMazeCoordOffset()
    # Check if move result is still the same side.
    # If no offset.
    if offset.length() == 0:
        return Error.ERR_ALREADY_EXISTS # Path already exist, no need for wall-clip.
    # Or the angle between move intension and wall normal is greater than 45 deg.
    # Except for the corner.
    if collision_count <= 1:
        var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
        var wall_direction := Vector2.ZERO
        for dir in directions:
            if ball_ref.test_move(ball_ref.global_transform, dir):
                wall_direction += dir
        wall_direction = wall_direction.normalized()

        if abs(move_intension.angle_to(wall_direction)) > PI / 4:
            return Error.ERR_ALREADY_EXISTS # Path already exist, no need for wall-clip.
    var coord_of_wall_clip_target := ball_coord_in_maze + offset
    # Check if warp-target does not exist a path.
    if maze_ref.isNotPathAt(coord_of_wall_clip_target.x, coord_of_wall_clip_target.y):
        return Error.ERR_DOES_NOT_EXIST

    # Can perform wall-clip.
    var ball_new_global_position := maze_ref.to_global(
        maze_ref.map_to_local(coord_of_wall_clip_target)
    )
    ball_ref.moveTo(ball_new_global_position)

    self.remain_count -= 1
    return Error.OK

func deactivate() -> Error:
    # No need to deactivate.
    return Error.OK

func _init() -> void:
    self.icon_path = "res://assets/vector_graphics/equipment/wall_clip_skill.svg"
    self.max_count = 3
    self.remain_count = 3
