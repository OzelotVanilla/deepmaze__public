class_name MazeGenerator
extends Node


static func generate(
    width:  int = MazeGame.initial_width,
    height: int = MazeGame.initial_height
) -> Maze:
    var maze := Maze.new()
    ## For the data, [code]0[/code] is path,
    ##  [code]1[/code] is wall.
    var map: Array[PackedInt32Array] = Array([], Variant.Type.TYPE_PACKED_INT32_ARRAY, "", null)
    # Make map filled with wall.
    map.resize(height)
    for i in map.size():
        map[i] = PackedInt32Array()
        map[i].resize(width)
        map[i].fill(1)

    MazeGenerator.carve(map, 1, 1)
    for y in range(map.size()):
        for x in range(map[y].size()):
            var atlas_coords: Vector2i
            match map[y][x]:
                0: atlas_coords = Maze.white_tile__atlas_coord
                1: atlas_coords = Maze.black_tile__atlas_coord

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

    # Make current point a "path".
    map[starting_y][starting_x] = 0

    var directions = [[0,2],[2,0],[0,-2],[-2,0]]
    directions.shuffle()

    var maze_height := map.size()
    var maze_width  := map[0].size()

    # Carve path in 4 directions.
    for direction in directions:
        var offset_x: int = direction[0]
        var offset_y: int = direction[1]
        var new_x := starting_x + offset_x
        var new_y := starting_y + offset_y

        if (
            # Is inside maze.
            new_x > 0 and new_x < maze_width and new_y > 0 and new_y < maze_height
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
