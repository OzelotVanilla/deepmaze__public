class_name SubMaze
extends Resource
## Data structure representing a pre-designed hardcoded sub-maze.


@export var name: String = "SubMaze"
@export var width: int = 7
@export var height: int = 7

## 2D grid matrix of [MazeTileType] values representing the sub-maze layout.
## Size: height x width. Values can be [constant MazeTileType.wall],
##  [constant MazeTileType.path], etc.
## Use [constant MazeTileType.unclaimed] for transparent cells in non-rectangular shapes.
@export var grid: Array[PackedInt32Array] = []

## Boundary connection port offsets relative to top-left of this sub-maze (0, 0).
@export var ports: Array[Vector2i] = []

## Origin top-left coordinate where this sub-maze is placed inside the parent wrapper grid.
@export var origin: Vector2i = Vector2i.ZERO


## Creates a sub-maze from the given [param inner_pattern].
static func createSimpleRect(
    p_name: String,
    p_width: int,
    p_height: int,
    p_origin: Vector2i,
    p_ports: Array[Vector2i],
    inner_pattern: Array[PackedInt32Array] = []
) -> SubMaze:
    var sub := SubMaze.new()
    sub.name = p_name
    sub.width = p_width
    sub.height = p_height
    sub.origin = p_origin
    sub.ports = p_ports

    sub.grid.resize(p_height)
    for y in range(p_height):
        var row := PackedInt32Array()
        row.resize(p_width)
        if inner_pattern.size() == p_height and inner_pattern[y].size() == p_width:
            row = inner_pattern[y].duplicate()
        else:
            # Default: outer border is wall, interior is path.
            for x in range(p_width):
                if x == 0 or x == p_width - 1 or y == 0 or y == p_height - 1:
                    row[x] = MazeTileType.wall
                else:
                    row[x] = MazeTileType.path
        sub.grid[y] = row

    # Ensure port cells on perimeter are set as paths.
    for port in p_ports:
        if port.x >= 0 and port.x < p_width and port.y >= 0 and port.y < p_height:
            sub.grid[port.y][port.x] = MazeTileType.path

    return sub


## Validates whether this sub-maze data is structurally valid for embedding:
## 1. Grid matrix matches width and height dimensions.
## 2. Ports are within bounds.
## 3. Fits inside wrapper bounds when [param wrapper_size] is provided.
## 4. Optionally checks odd/even lattice alignment when [param strict_lattice_mode] is enabled.
func validateEmbeddability(
    target_origin: Vector2i = Vector2i(-1, -1),
    wrapper_size: Vector2i = Vector2i.ZERO,
    strict_lattice_mode: bool = false
) -> Dictionary:
    var check_origin := self.origin if target_origin == Vector2i(-1, -1) else target_origin
    var errors: Array[String] = []
    var warnings: Array[String] = []

    # 1. Grid structure integrity.
    if self.width <= 0 or self.height <= 0:
        errors.append("Dimensions (%d x %d) must be positive" % [self.width, self.height])

    if self.grid.size() != self.height:
        errors.append("Grid row count (%d) does not match height (%d)" % [self.grid.size(), self.height])
    else:
        for y in range(self.height):
            if self.grid[y].size() != self.width:
                errors.append("Grid row %d size (%d) does not match width (%d)" % [y, self.grid[y].size(), self.width])
                break

    # 2. Port validity.
    if self.ports.is_empty():
        warnings.append("SubMaze has no connection ports defined")

    for port in self.ports:
        if port.x < 0 or port.x >= self.width or port.y < 0 or port.y >= self.height:
            errors.append("Port %s is out of sub-maze bounds (%d x %d)" % [str(port), self.width, self.height])

    # 3. Wrapper bounds check.
    if wrapper_size != Vector2i.ZERO:
        if check_origin.x < 0 or check_origin.y < 0:
            errors.append("Origin %s is negative" % str(check_origin))
        if check_origin.x + self.width > wrapper_size.x or check_origin.y + self.height > wrapper_size.y:
            errors.append("SubMaze at %s with size (%d x %d) exceeds wrapper size %s" % [
                str(check_origin), self.width, self.height, str(wrapper_size)
            ])

    # 4. Optional strict 1-tile lattice parity checks.
    if strict_lattice_mode:
        if check_origin.x % 2 != 0 or check_origin.y % 2 != 0:
            warnings.append("Origin %s is not EVEN coordinates" % str(check_origin))
        if self.width % 2 != 1 or self.height % 2 != 1:
            warnings.append("Dimensions (%d x %d) are not ODD numbers" % [self.width, self.height])
        for port in self.ports:
            var global_p := check_origin + port
            if global_p.x % 2 == 0 and global_p.y % 2 == 0:
                warnings.append("Port %s produces even global corner %s" % [str(port), str(global_p)])

    return {
        "is_valid": errors.is_empty(),
        "errors": errors,
        "warnings": warnings
    }
