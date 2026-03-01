class_name MazeGenerator
extends Node
## Generate a maze represented in 2D array
##
## For the data, [code]0[/code] is path,
##  [code]1[/code] is wall,
##  [code]3[/code] is exit.


## Generate the whole maze.[br]
##
## [param exit_gate__coord] is the coord of last level.
static func generate(
    width:  int = MazeGame.initial_width,
    height: int = MazeGame.initial_height,
    exit_gate__coord: Vector2i = Vector2i.ZERO
) -> Maze:
    var maze := Maze.new()
    maze.width  = width
    maze.height = height
    var map: Array[PackedInt32Array] = Array([], Variant.Type.TYPE_PACKED_INT32_ARRAY, "", null)
    # Make map filled with wall.
    map.resize(height)
    for i in map.size():
        map[i] = PackedInt32Array()
        map[i].resize(width)
        map[i].fill(1)

    MazeGenerator.carve(map, 1, 1)
    MazeGenerator.generateExit(map)

    for y in range(map.size()):
        for x in range(map[y].size()):
            var atlas_coords: Vector2i
            match map[y][x]:
                0: # Path
                    atlas_coords = Maze.white_tile__atlas_coord
                1: # Wall
                    atlas_coords = Maze.black_tile__atlas_coord
                3: # Exit gate
                    atlas_coords = Maze.white_tile__atlas_coord
                    maze.exit_gate__coord = Vector2i(x, y)

            maze.set_cell(
                Vector2i(x, y),
                Maze.black_and_white_atlas__source_id,
                atlas_coords
            )

    return maze

## Carve the path on maze map ([param map]).
##  at given starting point (defined by [param starting_x], [param starting_y]).
static func carve(map: Array[PackedInt32Array], starting_x: int, starting_y: int):
    if map.size() <= 0:
        printerr(
            "Cannot carve on map which is empty array. ",
            "Initialise your map with PackedInt32Array of same size."
        )

    var maze_height := map.size()
    var maze_width  := map[0].size()

    # Make current point a "path".
    if (
        starting_x > 0 and starting_x < maze_width - 1
        and starting_y > 0 and starting_y < maze_height - 1
    ):
        map[starting_y][starting_x] = 0

    var directions = [[0,2],[2,0],[0,-2],[-2,0]]
    directions.shuffle()

    # Carve path in 4 directions.
    for direction in directions:
        var offset_x: int = direction[0]
        var offset_y: int = direction[1]
        var new_x := starting_x + offset_x
        var new_y := starting_y + offset_y

        if (
            # Is inside maze.
            new_x > 0 and new_x < maze_width - 1
            and new_y > 0 and new_y < maze_height - 1
            # And is a wall
            and map[new_y][new_x] == 1
        ):
            # Also break the wall between starting point and new point.
            map[starting_y + offset_y/2][starting_x + offset_x/2] = 0

            # Start new recursion.
            MazeGenerator.carve(map, new_x, new_y)

    # Add branch and dead-end.
    if randf() < 0.3:
        var random_direction = directions.pick_random()
        var random_x: int = starting_x + random_direction[0]
        var random_y: int = starting_y + random_direction[1]

        # If inside maze.
        if random_x > 0 and random_x < maze_width and random_y > 0 and random_y < maze_height:
            # Then make it path.
            map[random_y][random_x] = 0

## Generate an exit gate on a maze map.
## [param last_exit_gate__coord] is the coord of last level.
static func generateExit(
    map: Array[PackedInt32Array],
    last_exit_gate__coord: Vector2i = Vector2i.ZERO
):
    var maze_height := map.size()
    var maze_width  := map[0].size()

    var exit_gate__x := 0
    var exit_gate__y := 0
    var should_continue_generation := true

    # Randomly pick a place in the maze until got qualified exit gate position.
    while should_continue_generation:
        exit_gate__x = floori(randf() * (maze_width  - 2)) + 1
        exit_gate__y = floori(randf() * (maze_height - 2)) + 1
        var exit_gate__coord := Vector2i(exit_gate__x, exit_gate__y)

        var is_not_a_path := map[exit_gate__y][exit_gate__x] != 0
        var is_impossible_for_exit_gate := (exit_gate__y < 3 and exit_gate__x < 3)
        var is_too_close_to_last_exit := \
            last_exit_gate__coord.distance_to(exit_gate__coord) < 3

        #TODO Avoid exit gate too near the ball.
        should_continue_generation = \
               is_not_a_path \
            or is_impossible_for_exit_gate \
            or is_too_close_to_last_exit

    map[exit_gate__y][exit_gate__x] = 3

## Generate the maze from init args.
static func generateFromInitArgs(init_args: MazeGameInitArgs) -> Maze:
    var maze = Maze.new()
    maze.tile_map_data = init_args.map_data
    maze.exit_gate__coord = init_args.exit_coord
    maze.updateInternals()

    return maze
