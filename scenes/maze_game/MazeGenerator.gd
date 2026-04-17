class_name MazeGenerator
extends Node
## Generate a maze represented in 2D array
##
## For the data of param [code]map[/code] used as intermediate,
##  see [enum MapData].


## ID of tiles/entities when generating [Maze],
##  used for the intermediate var [code]map[/code] in this file.
enum MapData
{
    path = 0,
    wall = 1,
    start = 2,
    exit = 3,
    quarter = 4,
    relic = 5,
    ## For special level [constant MazeGame.SpecialLevel.la_barbe_bleue].
    gate_key = 6,
    ## For special level [constant MazeGame.SpecialLevel.veronique].
    fake_exit = 7
}


## Generate the whole maze, with a border (width=1) of wall.[br]
## [param exit_gate__coord] is the coord of last level.[br][br]
##
## Step:[br]
## * Carve a maze with specified size.[br]
## *
static func generate(
    width:  int = MazeGame.initial_width,
    height: int = MazeGame.initial_height,
    last_level_exit_gate__coord: Vector2i = Vector2i(1, 1),
    special_level_type: MazeGame.SpecialLevel = MazeGame.SpecialLevel.none,
    should_generate_quarter: bool = false,
    should_generate_relic: bool = false
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

    # # Shape of maze.
    MazeGenerator.carve(map, 1, 1)

    # # Starting and exiting point.
    # If is level 1, put it onto the left-upper corner.
    # `last_level_exit_gate__coord` is `Vector2i(1, 1)` when at level 1.
    var start__coord := MazeGenerator.generateStart(map, last_level_exit_gate__coord)
    var exit__coord  := MazeGenerator.generateExit(map, last_level_exit_gate__coord)

    # # Special level entities.
    match special_level_type:
        MazeGame.SpecialLevel.la_barbe_bleue:
            MazeGenerator.generateGateKey(map, start__coord, exit__coord)

        MazeGame.SpecialLevel.veronique:
            MazeGenerator.generateFakeExit(map, start__coord, exit__coord)

    # # Tag the maze and astar grid with path/block info.
    # Init A*
    var maze_astar_grid := AStarGrid2D.new()
    maze_astar_grid.region = Rect2i(0, 0, width, height)
    maze_astar_grid.diagonal_mode = AStarGrid2D.DiagonalMode.DIAGONAL_MODE_NEVER
    maze_astar_grid.update()
    maze.astar_grid = maze_astar_grid

    # Fill to maze tile map and A*.
    for y in range(map.size()):
        for x in range(map[y].size()):
            var atlas_coords: Vector2i
            match map[y][x]:
                MapData.path:
                    atlas_coords = Maze.white_tile__atlas_coord
                MapData.wall:
                    atlas_coords = Maze.black_tile__atlas_coord
                    maze_astar_grid.set_point_solid(Vector2i(x, y))
                MapData.start: # Starting point
                    atlas_coords = Maze.white_tile__atlas_coord
                    maze.start__coord = Vector2i(x, y)
                MapData.exit: # Exit gate
                    atlas_coords = Maze.white_tile__atlas_coord
                    maze.exit_gate__coord = Vector2i(x, y)
                MapData.quarter:
                    atlas_coords = Maze.white_tile__atlas_coord
                    maze.quarter__coord = Vector2i(x, y)
                MapData.relic:
                    atlas_coords = Maze.white_tile__atlas_coord
                    maze.relic__coord = Vector2i(x, y)
                MapData.gate_key:
                    atlas_coords = Maze.white_tile__atlas_coord
                    maze.gate_key__coord = Vector2i(x, y)
                MapData.fake_exit:
                    atlas_coords = Maze.white_tile__atlas_coord
                    maze.fake_exit__coord = Vector2i(x, y)

            maze.set_cell(
                Vector2i(x, y),
                Maze.black_and_white_atlas__source_id,
                atlas_coords
            )

    # Generate exclusive items, avoiding them to be generated behind exit.
    if should_generate_quarter:
        MazeGenerator.generateExclusiveEntities(map, maze, special_level_type, MapData.quarter)
    if should_generate_relic:
        MazeGenerator.generateExclusiveEntities(map, maze, special_level_type, MapData.relic)

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
            map[random_y][random_x] = MapData.path

## Generate a legal start point for the maze.
## Try until the coord is not pointed to wall.[br][br]
## [param wished_start__coord] is usually the last level's exit coord,
##  and it is not guaranteed to be the start point.
static func generateStart(
    map: Array[PackedInt32Array],
    wished_start__coord: Vector2i
) -> Vector2i:
    # Place the ball on the position of last level's exit, if possible.
    var start__coord_x: int = wished_start__coord.x
    var start__coord_y: int = wished_start__coord.y

    # Make sure the start point will not be inside wall.
    var eight_direction_offset: Array[Vector2i] = [
        Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,
        Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)
    ]

    # Regenerate until it is a path.
    while map[start__coord_y][start__coord_x] != MapData.path:
        var random_direction: Vector2i = eight_direction_offset.pick_random()
        var x := start__coord_x + random_direction.x
        var y := start__coord_y + random_direction.y
        if x <= 0 or x >= map[0].size() - 1 or y <= 0 or y >= map.size() - 1:
            continue

        start__coord_x = x
        start__coord_y = y

    map[start__coord_y][start__coord_x] = MapData.start

    return Vector2i(start__coord_x, start__coord_y)

## Generate an exit gate on a maze map.
static func generateExit(
    map: Array[PackedInt32Array],
    last_level_exit_gate__coord: Vector2i = Vector2i.ZERO
) -> Vector2i:
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

        var is_not_a_path := map[exit_gate__y][exit_gate__x] != MapData.path
        var is_impossible_for_exit_gate := (exit_gate__y < 3 and exit_gate__x < 3)
        var is_too_close_to_last_exit := \
            last_level_exit_gate__coord.distance_to(exit_gate__coord) < 3

        should_continue_generation = \
               is_not_a_path \
            or is_impossible_for_exit_gate \
            or is_too_close_to_last_exit

    map[exit_gate__y][exit_gate__x] = MapData.exit

    return Vector2i(exit_gate__x, exit_gate__y)

static func generateGateKey(
    map: Array[PackedInt32Array],
    start__coord: Vector2i,
    exit__coord: Vector2i,
) -> Vector2i:
    var x := 0
    var y := 0
    # When the key is too near with ball or exit.
    while map[y][x] != MapData.path \
        or Vector2(x, y).distance_to(start__coord) < 3 \
        or Vector2(x, y).distance_to(exit__coord) < 3:
        x = randi_range(0, map[0].size() - 1) # 0..width
        y = randi_range(0, map.size() - 1) # 0..height

    map[y][x] = MapData.gate_key

    return Vector2i(x, y)

static func generateFakeExit(
    map: Array[PackedInt32Array],
    start__coord: Vector2i,
    exit__coord: Vector2i,
) -> Vector2i:
    var x := 0
    var y := 0
    # When the fake exit gate is too near with ball or exit.
    while map[y][x] != MapData.path \
        or Vector2(x, y).distance_to(start__coord) < 3 \
        or Vector2(x, y).distance_to(exit__coord) < 3:
        x = randi_range(0, map[0].size() - 1) # 0..width
        y = randi_range(0, map.size() - 1) # 0..height

    map[y][x] = MapData.fake_exit

    return Vector2i(x, y)

## Generate an exclusive entity (e.g., quarter, only exists at most one for a maze)
##  on a maze map, with given [param id].
## Will be generated on a path, modify the map in-place.[br][br]
##
## Caution: Need A* grid to calculate path to exit,
##  do not call this until A* is init-ed.[br][br]
##
## Notice: [param map_data__id] should only be:[br]
## * [code]MapData.quarter[/code].[br]
## * [code]MapData.relic[/code].[br]
static func generateExclusiveEntities(
    map: Array[PackedInt32Array],
    maze: Maze,
    special_level_type: MazeGame.SpecialLevel,
    map_data__id: int
):
    # If do not have A* grid, or its size is 0, raise error.
    if maze.astar_grid == null or maze.astar_grid.region.size.length() <= 0:
        printerr(
            "Un-init-ed A* grid in `MazeGenerator.generateExclusiveEntities`. ",
            "Call this method only after A* grid got init-ed."
        )
        return

    var maze_height := map.size()
    var maze_width  := map[0].size()

    var entity__x := 0
    var entity__y := 0

    # Randomly pick a place in the maze until got qualified exit gate position.
    while true:
        entity__x = floori(randf() * (maze_width  - 2)) + 1
        entity__y = floori(randf() * (maze_height - 2)) + 1

        # # If not a path, should re-pick.
        if map[entity__y][entity__x] != MapData.path:
            continue

        # # If before exit, should consider pick.
        var point_path := maze.astar_grid.get_point_path(
            maze.start__coord, Vector2i(entity__x, entity__y)
        )

        if point_path.has(maze.exit_gate__coord) and (
            special_level_type != MazeGame.SpecialLevel.la_barbe_bleue
            # If `la_barbe_bleue`,
            #  then appear of both exit and gate key is considered invalid.
            or point_path.has(maze.gate_key__coord)
        ):
            continue

        # Passed all check. Done.
        break

    map[entity__y][entity__x] = map_data__id

## Generate the maze from init args.
static func generateFromInitArgs(init_args: MazeGameInitArgs) -> Maze:
    var maze = Maze.new()
    maze.tile_map_data = init_args.saved_state_data.map_data
    maze.exit_gate__coord = init_args.saved_state_data.exit_coord
    maze.updateInternals()

    return maze
