@tool
class_name WhiteCaneCircle
extends Area2D
## An imaginary white cane for ball to detect [WhiteCaneDetectArea]


## Emit when [WhiteCaneCircle] touches [WhiteCaneDetectArea].
signal detect_area_touched(detect_area: WhiteCaneDetectArea)


func _ready() -> void: self.__onReady__()
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


func __onReady__():
    self.syncCollisionShapeRadius()
    self.queue_redraw()

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

func __on_WhiteCaneDetectArea_entered(detect_area: WhiteCaneDetectArea):
    # Only detect valid area.
    if detect_area.is_consumed:
        return

    self.detect_area_touched.emit(detect_area)
