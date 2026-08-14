@tool
class_name WhiteCaneCircle
extends Area2D
## An imaginary white cane for ball to detect [WhiteCaneDetectArea]


## Emit when [WhiteCaneCircle] touches [WhiteCaneDetectArea].
signal detect_area_touched(detect_area: WhiteCaneDetectArea)


func _ready() -> void: self.__onReady__()
func _physics_process(delta: float) -> void: self.__onPhysicsProcess__(delta)
func _draw() -> void: self.__onDraw__()


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var collision_shape: CircleShape2D:
    get():
        return self.collision_shape_2d.shape


@export var fill_colour: Color = Color("#83ccd2aa"):
    set(value):
        fill_colour = value
        self.queue_redraw()

@export var outline_colour: Color = Color("#ffffff"):
    set(value):
        outline_colour = value
        self.queue_redraw()

@export var outline_width: float = 2.0:
    set(value):
        outline_width = max(value, 0.0)
        self.queue_redraw()


var radius: float = 20:
    set(new_value):
        if radius == new_value:
            return
        radius = new_value

        if not self.is_node_ready():
            await self.ready

        self.syncCollisionShapeRadius()
        self.queue_redraw()

## Storing the [WhiteCaneDetectArea] that already entered the [WhiteCaneCircle],
##  and wait for the ray-casting test on next physics frame.
var overlapping_candidates: Array[WhiteCaneDetectArea]

## Cache for the area that should be deleted at the start of next physics frame.
var overlapping_candidates__element_to_delete: Array[WhiteCaneDetectArea]


func __onReady__():
    self.syncCollisionShapeRadius()
    self.queue_redraw()

func __onPhysicsProcess__(delta: float):
    # # Re-build `overlapping_candidates`.
    for detect_area_to_delete in self.overlapping_candidates__element_to_delete:
        self.overlapping_candidates.erase(detect_area_to_delete)
    # Clear the cache.
    self.overlapping_candidates__element_to_delete.clear()

    # # Check if `overlapping_candidates` can directly be "seen" by the circle's center.
    # Using ray-casting to test.
    for detect_area in self.overlapping_candidates:
        # # Only detect valid area.
        if not detect_area.is_enabled:
            self.overlapping_candidates__element_to_delete.push_back(detect_area)
            continue

        # # Test ray-cast.
        var collision_dict := \
            get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(
                self.global_position,        # from
                detect_area.global_position, # to
            ))
        if collision_dict.size() > 0:
            # Collided with wall in the maze.
            continue

        # # If all test pass, emit collision signal, and erase from the array.
        self.detect_area_touched.emit(detect_area)
        # Delete at next physics frame.
        self.overlapping_candidates__element_to_delete.push_back(detect_area)

func __onDraw__():
    # # Draw circle.
    self.draw_circle(
        Vector2.ZERO, # center
        self.radius, self.fill_colour
    )

    # # Draw outline.
    if self.outline_width > 0.0:
        self.draw_arc(
            Vector2.ZERO, # center
            self.radius,
            0,   # start angle
            TAU, # end angle
            96,  # point count
            self.outline_colour,
            self.outline_width,
            false # antialiased
        )

func syncCollisionShapeRadius():
    self.collision_shape.radius = self.radius

func __on_area_entered(area: Area2D) -> void:
    if area is WhiteCaneDetectArea:
        self.__on_WhiteCaneDetectArea_entered(area)

func __on_area_exited(area: Area2D) -> void:
    if area is WhiteCaneDetectArea:
        self.__on_WhiteCaneDetectArea_exited(area)

func __on_WhiteCaneDetectArea_entered(detect_area: WhiteCaneDetectArea):
    if not self.overlapping_candidates.has(detect_area):
        self.overlapping_candidates.push_back(detect_area)

func __on_WhiteCaneDetectArea_exited(detect_area: WhiteCaneDetectArea):
    if self.overlapping_candidates.has(detect_area):
        self.overlapping_candidates__element_to_delete.push_back(detect_area)
