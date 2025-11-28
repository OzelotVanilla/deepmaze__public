class_name RandomTeleportSkill
extends Skill


## Return [constant Error.ERR_UNAVAILABLE] if the skill is not available.
func activate() -> Error:
	if not self.could_be_used_in_this_level:
		return Error.ERR_UNAVAILABLE

	var maze_ref := self.game_ref.maze_ref
	var maze_width  := maze_ref.width
	var maze_height := maze_ref.height

	# Find a random place on the maze, as long as it is not wall.
	var target_x := 0
	var target_y := 0
	var is_wall_at_target_coord := true
	while is_wall_at_target_coord:
		target_x = randi_range(0, maze_width)
		target_y = randi_range(0, maze_height)
		is_wall_at_target_coord = maze_ref.isNotPathAt(target_x, target_y)

	self.game_ref.ball_ref.moveTo(self.game_ref.getGlobalPositionOfMazeCoord(
		target_x, target_y
	))

	self.remain_count -= 1
	self.had_used_in_this_level = true
	return Error.OK

func deactivate() -> Error:
	# No need to deactivate.
	return Error.OK

func _init() -> void:
	self.icon_path = "res://assets/vector_graphics/equipment/random_teleport_skill.svg"
	self.max_count = 3
	self.only_one_time_per_level = false
