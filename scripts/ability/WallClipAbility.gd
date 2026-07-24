class_name WallClipAbility
extends ActiveAbility


## Return [constant Error.ERR_QUERY_FAILED] if the ball is not attaching to the wall.
## Return [constant Error.Error.ERR_ALREADY_EXISTS]
##  if wall-clip target is the same as ball's position.
## Return [constant Error.ERR_DOES_NOT_EXIST] if wall-clip target is not a path.
func activate() -> Error:
    var ball__ref := self.game_ref.ball__ref
    var maze__ref := self.game_ref.maze__ref

    # See if there are wall that this ball is attaching to.
    var collision_count := ball__ref.get_slide_collision_count()
    # If no, return fail.
    if collision_count <= 0:
        return Error.ERR_QUERY_FAILED

    # Get coord-in-maze for the ball and the directions.
    var ball_coord_in_maze := self.game_ref.getBallCoordOfMaze()
    var move_intention := ball__ref.input_controller.world_move_direction
    var offset := ball__ref.getMazeCoordOffset()
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
            if ball__ref.test_move(ball__ref.global_transform, dir):
                wall_direction += dir
        wall_direction = wall_direction.normalized()

        if abs(move_intention.angle_to(wall_direction)) > PI / 4:
            return Error.ERR_ALREADY_EXISTS # Path already exist, no need for wall-clip.
    var coord_of_wall_clip_target := ball_coord_in_maze + offset
    # Check if warp-target does not exist a path.
    if maze__ref.isNotPathAt(coord_of_wall_clip_target.x, coord_of_wall_clip_target.y):
        return Error.ERR_DOES_NOT_EXIST

    # Can perform wall-clip.
    var ball_new_global_position := maze__ref.to_global(
        maze__ref.map_to_local(coord_of_wall_clip_target)
    )
    ball__ref.moveTo(ball_new_global_position)
    self.finished.emit()

    return Error.OK

func deactivate() -> Error:
    # No need to disable.
    return Error.OK

func _init() -> void:
    self.icon_path = "res://assets/vector_graphics/ball_ability/wall_clip.svg"
    self.animation_path = "res://assets/animation/ball_ability/wall_clip.tres"

    # # Active Ability
    self.cooldown_time = 30
