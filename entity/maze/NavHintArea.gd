class_name NavHintArea
extends Area2D
## Rectangle area to detect ball's movement and play nav hint sound
##
## [member nav_direction] is the correct path direction used for movement
## validation. [member sfx_direction] is the direction to play when this area
## is accepted.[br][br]
##
## If ball entered in accepted side (side rather than [member nav_direction]),
##  emit a signal [signal ball_entered__accepted_side].
## Else, emit [signal ball_entered__rejected_side].
##
## If [member is_checking] is true, this area should be used for wrong-way
## checking when the ball exits.


enum HintType
{
    none,
    pre_hint,
    normal_hint,
}


## Debug purpose only.
const small_arrow__scale := Vector2(0.7, 0.7)

## Debug purpose only.
const big_arrow__scale := Vector2(1.0, 1.0)

## Debug purpose only.
const pre_hint__colour := Color("#cf752c")

## Debug purpose only.
const hint__colour := Color("#26610f")

const nav_direction__colour := Color("#7d4b28")

## Debug purpose only.
const is_checking_frame__colour := Color("#007bbb")


## When the ball enters from the side that is different from [member nav_direction].
## For example, when [member nav_direction] is right,
##  left/up/down side entering is considered to be accepted.[br][br]
##
## Useful to tell players the next turn direction.
signal ball_entered__accepted_side(side_of_entering: Vector2i)

## When the ball enters from the side that is same as [member nav_direction].
## For example, when [member nav_direction] is right,
##  right side entering is considered to be rejected.[br][br]
##
## Useful to tell players the direction that fixes their movement.
signal ball_entered__rejected_side(side_of_entering: Vector2i)

## When the ball exited from the side that is same as [member nav_direction].
## For example, when [member nav_direction] is right,
##  right side entering is considered to be accepted.[br][br]
##
## Useful to tell players that they are proceeding in a right direction to exit.
signal ball_exited__accepted_side(side_of_exiting: Vector2i)

## When the ball exited from the side that is different from [member nav_direction].
## For example, when [member nav_direction] is right,
##  left/up/down side entering is considered to be rejected.[br][br]
##
## Useful to tell players that they are proceeding in a wrong direction to exit,
##  e.g., passing through a T-shape road, which should turn.
signal ball_exited__rejected_side(side_of_exiting: Vector2i)


@export_group("Debug", "debug__")

## Whether to show debug visuals for this nav hint area.
##
## Shows the sfx-direction arrow, nav-direction ball, and checking frame.
@export var debug__show_visuals: bool = false:
    set(whether_on):
        if debug__show_visuals != whether_on:
            debug__show_visuals = whether_on
            self.refreshDebugVisuals()

## Print a debug message when ball enters or exits.
@export var debug__print_when_enter_or_exit: bool = false


## Type of nav hint tile.
var hint_type: HintType = HintType.normal_hint:
    set(new_hint_type):
        if new_hint_type != hint_type:
            hint_type = new_hint_type
            self.refreshDebugVisuals()

## Whether this nav hint tile checks the ball exit side.
##
## Checking tiles may or may not have [member turn_direction].
var is_checking: bool = false:
    set(whether_checking):
        if whether_checking != is_checking:
            is_checking = whether_checking
            self.refreshDebugVisuals()

## Length of collision shape, in px.
var length: float = 0:
    set(new_value):
        new_value = max(0, new_value)
        if new_value != length:
            length = new_value
            if self.is_node_ready():
                self.collision_shape.size = Vector2(new_value, new_value)

## The expected movement direction that leads the ball to the exit.[br][br]
##
## Should only be four basic direction: up/down/left/right, from [Vector2i].
## [constant Vector2i.ZERO] means un-inited.
var nav_direction: Vector2i = Vector2i.ZERO:
    set(new_direction):
        if new_direction != nav_direction:
            if not self.isBasicDirection(new_direction):
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
            if not self.isValidTurnDirection(new_direction):
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
            if not self.isValidSfxDirection(new_direction):
                printerr(
                    "Cannot set `NavHintArea.sfx_direction`"
                )
                return
            sfx_direction = new_direction
            self.refreshDebugVisuals()

## Last side where the ball entered this area.
## [constant Vector2i.ZERO] means no enter has been handled yet.
var last_side_of_entering: Vector2i = Vector2i.ZERO

## Last side where the ball exited this area.
## [constant Vector2i.ZERO] means no exit has been handled yet.
var last_side_of_exiting: Vector2i = Vector2i.ZERO

## Last direction that audio/gameplay should use after this area handled a ball.
## [constant Vector2i.ZERO] means no direction has been selected yet.
var last_direction_to_play: Vector2i = Vector2i.ZERO


@onready var collision_shape: RectangleShape2D = ($CollisionShape2D).shape

@onready var debug__sfx_direction_arrow: Sprite2D = $Debug/SFXDirectionArrow
@onready var debug__sfx_direction_arrow__basic_scale: Vector2 = self.debug__sfx_direction_arrow.scale
@onready var debug__nav_direction_ball: Sprite2D = $Debug/NavDirectionBall
@onready var debug__is_checking_frame: Sprite2D = $Debug/IsCheckingFrame


func _ready() -> void: self.__onReady__()
func _to_string() -> String: return self.toString()


func isBasicDirection(direction: Vector2i) -> bool:
    return direction == Vector2i.UP or direction == Vector2i.DOWN \
        or direction == Vector2i.LEFT or direction == Vector2i.RIGHT

func isValidTurnDirection(direction: Vector2i) -> bool:
    return direction == Vector2i.ZERO or self.isBasicDirection(direction)

func isValidSfxDirection(direction: Vector2i) -> bool:
    return direction == Vector2i.ZERO or self.isBasicDirection(direction)

func refreshDebugVisuals():
    if not self.is_node_ready():
        # Will refresh afterwhile.
        if not self.ready.is_connected(self.refreshDebugVisuals):
            self.ready.connect(self.refreshDebugVisuals)
        return

    var should_show_sfx_direction_arrow := self.debug__show_visuals \
        and self.hint_type != HintType.none \
        and self.sfx_direction != Vector2i.ZERO
    self.debug__sfx_direction_arrow.visible = should_show_sfx_direction_arrow
    self.debug__nav_direction_ball.visible = self.debug__show_visuals
    self.debug__is_checking_frame.visible = \
        self.debug__show_visuals and self.is_checking

    if self.sfx_direction != Vector2i.ZERO:
        # The default direction is up.
        self.debug__sfx_direction_arrow.rotation = \
            Vector2.UP.angle_to(self.sfx_direction)
    if self.nav_direction != Vector2i.ZERO:
        # The default direction is up.
        self.debug__nav_direction_ball.rotation = \
            Vector2.UP.angle_to(self.nav_direction)

    self.debug__nav_direction_ball.modulate = NavHintArea.nav_direction__colour

    # # Adjusting style according to hint type.
    match self.hint_type:
        HintType.none:
            pass

        HintType.pre_hint:
            self.debug__sfx_direction_arrow.scale = \
                self.debug__sfx_direction_arrow__basic_scale * NavHintArea.small_arrow__scale
            self.debug__sfx_direction_arrow.modulate = NavHintArea.pre_hint__colour

        HintType.normal_hint:
            self.debug__sfx_direction_arrow.scale = \
                self.debug__sfx_direction_arrow__basic_scale * NavHintArea.big_arrow__scale
            self.debug__sfx_direction_arrow.modulate = NavHintArea.hint__colour

    # # Checking frame
    self.debug__is_checking_frame.modulate = NavHintArea.is_checking_frame__colour

## Handle nav sound to play when ball ([Ball]) enters.[br][br]
##
## Trigger [signal ball_entered__accepted_side]
##  if ball entered in expected side (different from [member nav_direction]).[br]
## Trigger [signal ball_entered__rejected_side]
##  if ball entered in the unexpected side (same as [member nav_direction]).[br][br]
##
## Will not handle other entities.
func __on_body_entered(body: Node2D) -> void:
    if body is Ball:
        self.__on_Ball_body_entered(body)

## Handle nav sound to play when ball ([Ball]) exits.[br][br]
##
## Trigger [signal ball_exited__accepted_side]
##  if ball exited in expected side (same as [member nav_direction]).[br]
## Trigger [signal ball_exited__rejecteded_side]
##  if ball exited in the unexpected side (different from [member nav_direction]).[br][br]
##
## Will not handle other entities.
func __on_body_exited(body: Node2D) -> void:
    if body is Ball:
        self.__on_Ball_body_exited(body)

func __on_Ball_body_entered(ball: Ball):
    # # Get side of entering.
    var collision_rect_size := self.collision_shape.size
    var ratio_x := (self.global_position.x - ball.global_position.x) / collision_rect_size.x
    var ratio_y := (self.global_position.y - ball.global_position.y) / collision_rect_size.y
    if abs(ratio_x) > abs(ratio_y): # Left/Right
        self.last_side_of_entering = Vector2i.LEFT if ratio_x < 0 else Vector2i.RIGHT
    else: # Up/Down
        self.last_side_of_entering = Vector2i.UP if ratio_y < 0 else Vector2i.DOWN

    # # Check if accepted/rejected.
    var is_accepted_side := self.last_side_of_entering != self.nav_direction
    if is_accepted_side:
        self.last_direction_to_play = self.sfx_direction
    else:
        self.last_direction_to_play = self.nav_direction
    if is_accepted_side: # accepted
        self.ball_entered__accepted_side.emit(self.last_side_of_entering)
    else: # rejected
        self.ball_entered__rejected_side.emit(self.last_side_of_entering)

    if self.debug__print_when_enter_or_exit:
        self.printBallEnterOrExit(
            "enters", self.last_side_of_entering, is_accepted_side
        )

func __on_Ball_body_exited(ball: Ball):
    # # Get side of exiting.
    var collision_rect_size := self.collision_shape.size
    var ratio_x := (self.global_position.x - ball.global_position.x) / collision_rect_size.x
    var ratio_y := (self.global_position.y - ball.global_position.y) / collision_rect_size.y
    if abs(ratio_x) > abs(ratio_y): # Left/Right
        self.last_side_of_exiting = Vector2i.RIGHT if ratio_x < 0 else Vector2i.LEFT
    else: # Up/Down
        self.last_side_of_exiting = Vector2i.DOWN if ratio_y < 0 else Vector2i.UP

    # # Check if accepted/rejected.
    var is_accepted_side := self.last_side_of_exiting == self.nav_direction
    self.last_direction_to_play = self.nav_direction
    if is_accepted_side: # accepted
        self.ball_exited__accepted_side.emit(self.last_side_of_exiting)
    else: # rejected
        self.ball_exited__rejected_side.emit(self.last_side_of_exiting)

    if self.debug__print_when_enter_or_exit:
        self.printBallEnterOrExit(
            "exits", self.last_side_of_exiting, is_accepted_side
        )

func toString() -> String:
    return str(
        "NavHintArea ", str("`", self.name, "`").lpad(14),
        str(" (HintType: ", HintType.find_key(self.hint_type), ", "),
        str("is_checking: ", self.is_checking, ")"),
        " nav direction is ", str(self.nav_direction).rpad(7), ",",
        " turn direction is ", str(self.turn_direction).rpad(7), ",",
        " sfx direction is ", str(self.sfx_direction).rpad(7)
    )

func printBallEnterOrExit(
    action: String,
    side: Vector2i,
    is_accepted_side: bool,
) -> void:
    print(
        self.toString(), ",\n\t",
        "Ball ", action, " at ", str(side).rpad(7), ",",
        " and is ",
        ("accepted" if is_accepted_side else "rejected"),
        " side."
    )

func __onReady__():
    self.collision_shape.size = Vector2(self.length, self.length)
    self.refreshDebugVisuals()
