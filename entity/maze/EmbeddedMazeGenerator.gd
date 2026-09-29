class_name EmbeddedMazeGenerator
extends Node
## Generator for embedding hardcoded sub-mazes inside a procedural wrapper maze.
##
## Architectural Overview and Relationship with [MazeGenerator]:
## * This generator builds upon the core Recursive Backtracking (DFS) algorithm
##   established in [method MazeGenerator.carve].
## * The primary enhancement is the [code]locked_cells[/code] matrix, which prevents
##   background procedural carving from corrupting the interior rooms of pre-designed
##   sub-mazes ([SubMaze]).
## * Three orchestration modes are provided to control how inter-maze connectivity
##   and background maze carving interact with embedded sub-mazes.


const maze_scene = preload("res://entity/maze/Maze.tscn")


## Generation strategies for embedding sub-mazes into procedural wrapper mazes.
enum GenerationMode
{
    ## Option 1 (Port-Corridor First):[br]
    ## * Phase 1: Carves dedicated A* corridors directly between connected sub-maze ports
    ##   using randomized waypoint jitter to guarantee organic winding paths.[br]
    ## * Phase 2: Fills remaining open areas using standard Recursive Backtracking DFS
    ##   ([method MazeGenerator.carve] logic adapted with [code]locked_cells[/code]).
    option_1_port_corridor_first,

    ## Option 2 (Uniform Whole-Grid DFS with A* Path Repair):[br]
    ## * Phase 1: Executes uniform Recursive Backtracking DFS ([method MazeGenerator.carve] logic)
    ##   across the entire wrapper grid in a single pass around locked sub-mazes.[br]
    ## * Phase 2: Builds a temporary A* navigation graph to verify inter-maze port routes,
    ##   automatically carving connecting links if any ports remain disconnected.
    option_2_uniform_whole_grid,

    ## Option 3 (Rooms & Mazes Algorithm - Bob Nystrom):[br]
    ## Direct adaptation of Bob Nystrom's classic "Rooms and Mazes" algorithm:[br]
    ## 1. Stamps all sub-mazes into the grid matrix as pre-fabricated "rooms" and locks them.[br]
    ## 2. Carves procedural mazes throughout all remaining open wrapper cells using
    ##    Recursive Backtracking DFS
    ##     ([method MazeGenerator.carve] logic with branch/loop creation).[br]
    ## 3. Validates and connects sub-maze doorway ports into the wrapper maze network.
    option_3_rooms_and_mazes
}


## Main generation entry point.
static func generate(
    preset: EmbeddedMazePreset,
    mode: GenerationMode = GenerationMode.option_3_rooms_and_mazes
) -> Maze:
    var maze: Maze = maze_scene.instantiate()
    var width := preset.wrapper_width
    var height := preset.wrapper_height
    maze.width = width
    maze.height = height

    # 1. Initialize grid with solid walls and locked perimeter.
    var grid_data := initializeGrid(width, height)
    var map: Array[PackedInt32Array] = grid_data.map
    var locked_cells: Array[Array] = grid_data.locked_cells

    # 2. Stamp sub-mazes into the grid and unlock connection ports.
    stampSubMazes(map, locked_cells, preset, width, height)

    # 3. Carve inter-maze corridors and procedural background maze.
    var connection_corridors := carveMazeByMode(map, locked_cells, preset, mode, width, height)
    maze.set_meta("connection_corridors", connection_corridors)

    # 4. Validate sub-maze embeddability.
    validatePresetSubMazes(preset, width, height)

    # 5. Determine start and exit locations.
    setupStartAndExit(maze, map, preset, width, height)

    # 6. Construct AStarGrid2D and render TileMapLayer cells.
    buildMazeTilemapAndAstar(maze, map, width, height)

    return maze


# # Modular Generator Pipeline Stages


## 1. Initializes a full grid of solid walls with a locked 1-tile outer border.
static func initializeGrid(width: int, height: int) -> Dictionary:
    var map: Array[PackedInt32Array] = []
    map.resize(height)
    var locked_cells: Array[Array] = []
    locked_cells.resize(height)

    for y in range(height):
        map[y] = PackedInt32Array()
        map[y].resize(width)
        map[y].fill(MazeTile.wall)

        var lock_row: Array[bool] = []
        lock_row.resize(width)
        lock_row.fill(false)

        # Lock 1-tile outer border.
        for x in range(width):
            if x == 0 or x == width - 1 or y == 0 or y == height - 1:
                lock_row[x] = true
        locked_cells[y] = lock_row

    return {
        "map": map,
        "locked_cells": locked_cells
    }


## 2. Stamps sub-maze tiles into the grid matrix and unlocks door ports.
static func stampSubMazes(
    map: Array[PackedInt32Array],
    locked_cells: Array[Array],
    preset: EmbeddedMazePreset,
    width: int,
    height: int
) -> void:
    for sub_idx in range(preset.sub_mazes.size()):
        var sub: SubMaze = preset.sub_mazes[sub_idx]
        for sy in range(sub.height):
            for sx in range(sub.width):
                var cell_val := sub.grid[sy][sx]
                var gx := sub.origin.x + sx
                var gy := sub.origin.y + sy
                if gx > 0 and gx < width - 1 and gy > 0 and gy < height - 1:
                    if cell_val != MazeTile.unclaimed:
                        map[gy][gx] = cell_val
                        # Lock active sub-maze cells so background carving will not overwrite them.
                        locked_cells[gy][gx] = true
                    else:
                        # Unclaimed padding cells become unlocked wrapper walls.
                        map[gy][gx] = MazeTile.wall
                        locked_cells[gy][gx] = false

    # Unlock ports so paths can connect into sub-mazes.
    for sub in preset.sub_mazes:
        for port in sub.ports:
            var pg := sub.origin + port
            if pg.x > 0 and pg.x < width - 1 and pg.y > 0 and pg.y < height - 1:
                map[pg.y][pg.x] = MazeTile.path
                locked_cells[pg.y][pg.x] = false


## 3. Dispatches carving based on the selected generation mode.
static func carveMazeByMode(
    map: Array[PackedInt32Array],
    locked_cells: Array[Array],
    preset: EmbeddedMazePreset,
    mode: GenerationMode,
    width: int,
    height: int
) -> Array[Array]:
    match mode:
        GenerationMode.option_1_port_corridor_first:
            return carvePortCorridors(map, locked_cells, preset, width, height)
        GenerationMode.option_2_uniform_whole_grid, GenerationMode.option_3_rooms_and_mazes:
            return carveUniformWholeGrid(map, locked_cells, preset, width, height)
        _:
            return []


## Carves direct inter-maze corridors, then fills remaining background space.
static func carvePortCorridors(
    map: Array[PackedInt32Array],
    locked_cells: Array[Array],
    preset: EmbeddedMazePreset,
    width: int,
    height: int
) -> Array[Array]:
    var connection_corridors: Array[Array] = []

    # Carve direct port corridors first.
    for conn in preset.connections:
        var s1_idx: int = conn.get("from_sub_maze_idx", 0)
        var p1_idx: int = conn.get("from_port_idx", 0)
        var s2_idx: int = conn.get("to_sub_maze_idx", 0)
        var p2_idx: int = conn.get("to_port_idx", 0)

        if s1_idx < preset.sub_mazes.size() and s2_idx < preset.sub_mazes.size():
            var s1: SubMaze = preset.sub_mazes[s1_idx]
            var s2: SubMaze = preset.sub_mazes[s2_idx]

            if p1_idx < s1.ports.size() and p2_idx < s2.ports.size():
                var p1_global := s1.origin + s1.ports[p1_idx]
                var p2_global := s2.origin + s2.ports[p2_idx]
                var single_conn_coords: Array[Vector2i] = []
                carveCorridor(
                    map, locked_cells, p1_global, p2_global, width, height, single_conn_coords
                )
                connection_corridors.append(single_conn_coords)

    # Then carve background wrapper maze.
    for y in range(1, height - 1, 2):
        for x in range(1, width - 1, 2):
            if not locked_cells[y][x] and map[y][x] == MazeTile.wall:
                carveBackground(map, locked_cells, x, y, width, height)

    return connection_corridors


## Carves entire wrapper grid uniformly, then validates and repairs port connections.
static func carveUniformWholeGrid(
    map: Array[PackedInt32Array],
    locked_cells: Array[Array],
    preset: EmbeddedMazePreset,
    width: int,
    height: int
) -> Array[Array]:
    var connection_corridors: Array[Array] = []

    # Carve entire wrapper grid uniformly in one pass.
    for y in range(1, height - 1, 2):
        for x in range(1, width - 1, 2):
            if not locked_cells[y][x] and map[y][x] == MazeTile.wall:
                carveBackground(map, locked_cells, x, y, width, height)

    # Build temporary A* grid to validate inter-maze path connectivity.
    var temp_astar := createTempAstar(map, width, height)
    for conn in preset.connections:
        var s1_idx: int = conn.get("from_sub_maze_idx", 0)
        var p1_idx: int = conn.get("from_port_idx", 0)
        var s2_idx: int = conn.get("to_sub_maze_idx", 0)
        var p2_idx: int = conn.get("to_port_idx", 0)

        if s1_idx < preset.sub_mazes.size() and s2_idx < preset.sub_mazes.size():
            var s1: SubMaze = preset.sub_mazes[s1_idx]
            var s2: SubMaze = preset.sub_mazes[s2_idx]

            if p1_idx < s1.ports.size() and p2_idx < s2.ports.size():
                var p1_global := s1.origin + s1.ports[p1_idx]
                var p2_global := s2.origin + s2.ports[p2_idx]
                var single_conn_coords: Array[Vector2i] = []
                var id_path := temp_astar.get_id_path(p1_global, p2_global)
                if id_path.size() == 0:
                    # Repair missing connection by carving corridor.
                    carveCorridor(
                        map, locked_cells, p1_global, p2_global, width, height, single_conn_coords
                    )
                else:
                    for cell_coord in id_path:
                        single_conn_coords.append(cell_coord)
                connection_corridors.append(single_conn_coords)

    return connection_corridors


## 4. Validates preset sub-mazes and reports any configuration issues.
static func validatePresetSubMazes(preset: EmbeddedMazePreset, width: int, height: int) -> void:
    for sub in preset.sub_mazes:
        var res := sub.validateEmbeddability(sub.origin, Vector2i(width, height))
        if not res.is_valid:
            push_error("SubMaze '%s' embeddability errors: %s" % [sub.name, str(res.errors)])
        for warn in res.warnings:
            push_warning("SubMaze '%s' embeddability warning: %s" % [sub.name, warn])


## 5. Finds and assigns valid start and exit gate coordinates.
static func setupStartAndExit(
    maze: Maze,
    map: Array[PackedInt32Array],
    preset: EmbeddedMazePreset,
    width: int,
    height: int
) -> void:
    var start__coord := findValidStart(map, preset)
    var exit__coord := findValidExit(map, start__coord, width, height)
    maze.start__coord = start__coord
    maze.exit_gate__coord = exit__coord


## 6. Builds the runtime [AStarGrid2D] and populates the [TileMapLayer] cells.
static func buildMazeTilemapAndAstar(
    maze: Maze,
    map: Array[PackedInt32Array],
    width: int,
    height: int
) -> void:
    var maze_astar_grid := AStarGrid2D.new()
    maze_astar_grid.region = Rect2i(0, 0, width, height)
    maze_astar_grid.diagonal_mode = AStarGrid2D.DiagonalMode.DIAGONAL_MODE_NEVER
    maze_astar_grid.update()
    maze.astar_grid = maze_astar_grid

    for y in range(height):
        for x in range(width):
            var atlas_coords: Vector2i
            if map[y][x] == MazeTile.wall:
                atlas_coords = Maze.black_tile__atlas_coord
                maze_astar_grid.set_point_solid(Vector2i(x, y))
            else:
                atlas_coords = Maze.white_tile__atlas_coord

            maze.set_cell(
                Vector2i(x, y),
                Maze.black_and_white_atlas__source_id,
                atlas_coords
            )


# # Pathfinding and Carving Utilities


static func createTempAstar(map: Array[PackedInt32Array], width: int, height: int) -> AStarGrid2D:
    var astar := AStarGrid2D.new()
    astar.region = Rect2i(0, 0, width, height)
    astar.diagonal_mode = AStarGrid2D.DiagonalMode.DIAGONAL_MODE_NEVER
    astar.update()
    for y in range(height):
        for x in range(width):
            if map[y][x] == MazeTile.wall:
                astar.set_point_solid(Vector2i(x, y))
    return astar


## Carves a direct connecting corridor with randomized waypoint jitter to produce organic winding paths.
static func carveCorridor(
    map: Array[PackedInt32Array],
    locked_cells: Array[Array],
    p1: Vector2i,
    p2: Vector2i,
    width: int,
    height: int,
    corridor_out: Array[Vector2i]
) -> void:
    # Calculate a randomized waypoint to force winding turns.
    var mid_x := (p1.x + p2.x) / 2
    var mid_y := (p1.y + p2.y) / 2
    var offsets := [-6, -4, 4, 6]
    var rand_off: int = offsets.pick_random()

    var waypoint := Vector2i.ZERO
    if abs(p1.x - p2.x) >= abs(p1.y - p2.y):
        var wy := mid_y + rand_off
        wy = clampi(wy, 3, height - 4)
        if wy % 2 == 0:
            wy += 1 # Align to odd grid lattice.
        var wx := mid_x if mid_x % 2 == 1 else mid_x + 1
        waypoint = Vector2i(wx, wy)
    else:
        var wx := mid_x + rand_off
        wx = clampi(wx, 3, width - 4)
        if wx % 2 == 0:
            wx += 1 # Align to odd grid lattice.
        var wy := mid_y if mid_y % 2 == 1 else mid_y + 1
        waypoint = Vector2i(wx, wy)

    carveStep2Path(map, locked_cells, p1, waypoint, width, height, corridor_out)
    carveStep2Path(map, locked_cells, waypoint, p2, width, height, corridor_out)


## Step-2 A* path carving between two points.
static func carveStep2Path(
    map: Array[PackedInt32Array],
    locked_cells: Array[Array],
    p1: Vector2i,
    p2: Vector2i,
    width: int,
    height: int,
    corridor_out: Array[Vector2i]
) -> void:
    var open_set: Array[Vector2i] = [p1]
    var came_from: Dictionary = {p1: p1}
    var g_score: Dictionary = {p1: 0}
    var f_score: Dictionary = {p1: p1.distance_to(p2)}
    var found := false

    var dirs: Array[Vector2i] = [Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]

    while open_set.size() > 0:
        var best_idx := 0
        var best_f: float = f_score.get(open_set[0], 999999.0)
        for i in range(1, open_set.size()):
            var f_val: float = f_score.get(open_set[i], 999999.0)
            if f_val < best_f:
                best_f = f_val
                best_idx = i

        var curr: Vector2i = open_set[best_idx]
        open_set.remove_at(best_idx)

        if curr == p2 or curr.distance_to(p2) <= 1.5:
            p2 = curr
            found = true
            break

        dirs.shuffle()
        for d: Vector2i in dirs:
            var n: Vector2i = curr + d
            var mid: Vector2i = curr + d / 2
            if n.x > 0 and n.x < width - 1 and n.y > 0 and n.y < height - 1:
                if (not locked_cells[n.y][n.x] and not locked_cells[mid.y][mid.x]) or n == p2:
                    var tentative_g: int = g_score.get(curr, 0) + 1
                    if not g_score.has(n) or tentative_g < g_score[n]:
                        came_from[n] = curr
                        g_score[n] = tentative_g
                        f_score[n] = tentative_g + n.distance_to(p2)
                        if not open_set.has(n):
                            open_set.append(n)

    if found:
        var path_curr: Vector2i = p2
        while path_curr != p1:
            map[path_curr.y][path_curr.x] = MazeTile.path
            corridor_out.append(path_curr)
            var prev: Vector2i = came_from[path_curr]
            var mid: Vector2i = path_curr + (prev - path_curr) / 2
            map[mid.y][mid.x] = MazeTile.path
            corridor_out.append(mid)
            path_curr = prev
        map[p1.y][p1.x] = MazeTile.path
        corridor_out.append(p1)
    else:
        map[p1.y][p1.x] = MazeTile.path
        map[p2.y][p2.x] = MazeTile.path
        corridor_out.append(p1)
        corridor_out.append(p2)


## Background recursive backtracking carving with branch and loop generation.
##
## Note on Algorithm Implementation:
## * This is the exact Recursive Backtracking (DFS) algorithm used in [method MazeGenerator.carve],
##   adapted to respect [param locked_cells] so it flows around embedded sub-mazes without
##   modifying their interior layouts.
static func carveBackground(
    map: Array[PackedInt32Array],
    locked_cells: Array[Array],
    starting_x: int,
    starting_y: int,
    width: int,
    height: int
) -> void:
    map[starting_y][starting_x] = MazeTile.path

    var directions = [[0, 2], [2, 0], [0, -2], [-2, 0]]
    directions.shuffle()

    for dir in directions:
        var nx: int = starting_x + dir[0]
        var ny: int = starting_y + dir[1]

        if nx > 0 and nx < width - 1 and ny > 0 and ny < height - 1:
            if not locked_cells[ny][nx] and map[ny][nx] == MazeTile.wall:
                # Break intermediate wall.
                var mx: int = starting_x + dir[0] / 2
                var my: int = starting_y + dir[1] / 2
                if not locked_cells[my][mx]:
                    map[my][mx] = MazeTile.path
                carveBackground(map, locked_cells, nx, ny, width, height)

    # 15% chance to break a wall between two already-existing path nodes to create extra loops.
    if randf() < 0.15:
        var r_dir = directions.pick_random()
        var tx: int = starting_x + r_dir[0]
        var ty: int = starting_y + r_dir[1]
        var mx: int = starting_x + r_dir[0] / 2
        var my: int = starting_y + r_dir[1] / 2

        if tx > 0 and tx < width - 1 and ty > 0 and ty < height - 1:
            if map[ty][tx] == MazeTile.path and map[my][mx] == MazeTile.wall:
                if not locked_cells[my][mx]:
                    map[my][mx] = MazeTile.path


static func findValidStart(map: Array[PackedInt32Array], preset: EmbeddedMazePreset) -> Vector2i:
    if preset.sub_mazes.size() > 0:
        var sub0 := preset.sub_mazes[0]
        var center := sub0.origin + Vector2i(sub0.width / 2, sub0.height / 2)
        if map[center.y][center.x] == MazeTile.path:
            return center

    for y in range(1, map.size() - 1):
        for x in range(1, map[0].size() - 1):
            if map[y][x] == MazeTile.path:
                return Vector2i(x, y)

    return Vector2i(1, 1)


static func findValidExit(
    map: Array[PackedInt32Array],
    start: Vector2i,
    width: int,
    height: int
) -> Vector2i:
    var best_exit := start
    var max_dist := 0.0

    # First attempt: 200 random samples.
    for _attempt in range(200):
        var rx := randi_range(1, width - 2)
        var ry := randi_range(1, height - 2)
        var candidate := Vector2i(rx, ry)
        if map[ry][rx] == MazeTile.path:
            var dist := candidate.distance_to(start)
            if dist >= 5.0:
                return candidate
            if dist > max_dist:
                max_dist = dist
                best_exit = candidate

    # Fallback: scan grid for the farthest path tile from start.
    if max_dist < 1.0:
        for y in range(1, height - 1):
            for x in range(1, width - 1):
                if map[y][x] == MazeTile.path:
                    var dist := Vector2(x, y).distance_to(Vector2(start))
                    if dist > max_dist:
                        max_dist = dist
                        best_exit = Vector2i(x, y)

    return best_exit
