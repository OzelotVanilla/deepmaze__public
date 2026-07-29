class_name WhiteCaneDetectArea
extends Area2D
## The area to be detected by the [WhiteCaneCircle].


func _ready() -> void: self.__onReady__()


## Length of collision shape, in px.
var length: float = 0:
    set(new_value):
        new_value = max(0, new_value)
        if new_value != length:
            length = new_value
            if self.is_node_ready():
                self.syncCollisionShapeLength()

## The expected movement direction that leads the ball to the exit.[br][br]
##
## Should only be four basic direction: up/down/left/right, from [Vector2i].
## [constant Vector2i.ZERO] means un-inited.
var nav_direction: Vector2i = Vector2i.ZERO:
    set(new_direction):
        if new_direction != nav_direction:
            if not WhiteCaneDetectArea.is4BasicDirection(new_direction):
                printerr(
                    "Cannot set `NavHintArea.nav_direction`"
                )
                return
            nav_direction = new_direction
            self.refreshDebugVisuals()

## The direction/key that should be hinted when player movement is accepted.
##
## Should only be four basic direction: up/down/left/right, from [Vector2i].
## [constant Vector2i.ZERO] means un-inited, or no turn hint.
var turn_direction: Vector2i = Vector2i.ZERO:
    set(new_direction):
        if new_direction != turn_direction:
            if not WhiteCaneDetectArea.isValidTurnDirection(new_direction):
                printerr(
                    "Cannot set `NavHintArea.turn_direction`"
                )
                return
            turn_direction = new_direction
            self.refreshDebugVisuals()

## The direction sfx that should be played when player movement is accepted.
##
## Should only be four basic direction: up/down/left/right, from [Vector2i].
## [constant Vector2i.ZERO] means no accepted-enter sfx.
var sfx_direction: Vector2i = Vector2i.ZERO:
    set(new_direction):
        if new_direction != sfx_direction:
            if not WhiteCaneDetectArea.isValidSFXDirection(new_direction):
                printerr(
                    "Cannot set `NavHintArea.sfx_direction`"
                )
                return
            sfx_direction = new_direction
            self.refreshDebugVisuals()

## Whether current area is already detected by [WhiteCaneCircle].
var is_consumed: bool = false

## The next [WhiteCaneDetectArea] to enable [member Area2D.monitable]
##  for white cane to detect.
var next_area_to_enable__ref: WhiteCaneDetectArea = null

var should_show_debug_visuals: bool = true


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var debug__sfx_direction_arrow: Sprite2D = $Debug/SFXDirectionArrow
@onready var debug__nav_direction_ball: Sprite2D = $Debug/NavDirectionBall


static func is4BasicDirection(direction: Vector2i) -> bool:
    return direction == Vector2i.UP or direction == Vector2i.DOWN \
        or direction == Vector2i.LEFT or direction == Vector2i.RIGHT

static func isValidTurnDirection(direction: Vector2i) -> bool:
    return direction == Vector2i.ZERO or WhiteCaneDetectArea.is4BasicDirection(direction)

static func isValidSFXDirection(direction: Vector2i) -> bool:
    return direction == Vector2i.ZERO or WhiteCaneDetectArea.is4BasicDirection(direction)

func __onReady__():
    self.syncCollisionShapeLength()

## Enable [member Area2D.monitorable] in deferred manner (in order to avoid racing),
##  and refresh debug visuals of this detect area.
func setToMonitorableDeferred():
    self.set_deferred("monitorable", true)
    self.refreshDebugVisuals.call_deferred()

## Disable [member Area2D.monitorable] in deferred manner (in order to avoid racing),
##  and refresh debug visuals of this detect area.
func setToDisabledDeferred():
    self.set_deferred("monitorable", false)
    self.refreshDebugVisuals.call_deferred()

## Mark area as [b]already detected by [WhiteCaneCircle][/b].[br][br]
##
## If [member next_area_to_enable__ref] is not null (current is not last one),
##  [b]async-ly[/b] disable its [member Area2D.monitorable] in deferred manner,
##  and enable next area if possible.
func consume() -> void:
    self.is_consumed = true

    # Async-ly enable/disable 2 detect areas.
    if self.next_area_to_enable__ref != null:
        self.setToDisabledDeferred()
        self.next_area_to_enable__ref.setToMonitorableDeferred()

## Sync the [member length] to the collision shape's length ([member RectangleShape2D.size]).
## Should only be called when the node is ready.
func syncCollisionShapeLength():
    (self.collision_shape_2d.shape as RectangleShape2D).size = Vector2(self.length, self.length)
    self.queue_redraw()

## Update the debug visual representation if necessary.
func refreshDebugVisuals():
    if not self.should_show_debug_visuals:
        self.debug__sfx_direction_arrow.visible = false
        self.debug__nav_direction_ball.visible = false
        return

    # # Run this method until node is ready.
    if not self.is_node_ready():
        # Will refresh afterwhile.
        if not self.ready.is_connected(self.refreshDebugVisuals):
            self.ready.connect(self.refreshDebugVisuals)
        return

    # # Show sfx arrow if not zero.
    if WhiteCaneDetectArea.is4BasicDirection(self.sfx_direction):
        # The default direction is up.
        self.debug__sfx_direction_arrow.visible = true
        self.debug__sfx_direction_arrow.self_modulate = Color("#00a497")
        self.debug__sfx_direction_arrow.rotation = Vector2.UP.angle_to(self.sfx_direction)

    # # Show nav arrow if not zero.
    if WhiteCaneDetectArea.is4BasicDirection(self.nav_direction):
        # The default direction is up.
        self.debug__nav_direction_ball.visible = true
        self.debug__nav_direction_ball.self_modulate = Color("#f8b500")
        self.debug__nav_direction_ball.rotation = Vector2.UP.angle_to(self.nav_direction)

    # # Check if monitorable.
    if not self.monitorable:
        # If not, make the colour to be grey.
        self.debug__nav_direction_ball.self_modulate  = Color.DIM_GRAY
        self.debug__sfx_direction_arrow.self_modulate = Color.DIM_GRAY

    self.queue_redraw()
