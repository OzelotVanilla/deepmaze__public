class_name WhiteCaneDetectArea
extends Area2D
## The area to be detected by the [WhiteCaneCircle].


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
        self.debug__sfx_direction_arrow.rotation = Vector2.UP.angle_to(self.sfx_direction)

    # # Show nav arrow if not zero.
    if WhiteCaneDetectArea.is4BasicDirection(self.nav_direction):
        # The default direction is up.
        self.debug__nav_direction_ball.visible = true
        self.debug__nav_direction_ball.rotation = Vector2.UP.angle_to(self.nav_direction)
