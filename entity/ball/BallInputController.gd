class_name BallInputController
extends Node
## Read and handle the input from player, and provide to ball
##
## This class has 3 layers of input handling: [br][br]
##
## [b]1. Read raw input from physical input devices.[/b][br]
## Update [member raw_move_vector].[br][br]
##
## [b]2. Interpret the raw input to ball move intent.[/b][br]
## According to the parameters such as [member input_paradigm] or [member should_invert_input],
##  calculate [member world_move_intent] for move in the world.
## This intention is world-relative,
##  so where it points stands for the move direction in the 2D world.[br]
## See also [enum BallInputParadigm].[br][br]
##
## 3. [b]Apply the physics to interpreted world-move-intent to get final move vector[/b][br]
## Applied the acceleration/speed/inertia to [member world_move_intent],
##  and calculated a world-relative move vector [member motor_velocity].

enum BallInputSource
{
    none,
    gyro,
    keyboard_or_controller
}

## How should the input be interpreted in a 1st/3rd-perspective.
enum BallInputParadigm
{
    ## Move the ball in a 3rd-person perspective.[br]
    ## [kbd]W[/kbd]/[kbd]A[/kbd]/[kbd]S[/kbd]/[kbd]D[/kbd] is
    ##  directively associated with going U/L/D/R.
    world_relative,
    ## Move the ball from a 1st-person perspective.[br]
    ## [kbd]W[/kbd]/[kbd]S[/kbd] is forward and backward, according to current facing direction.[br]
    ## [kbd]A[/kbd]/[kbd]D[/kbd] is strafe to L/R, according to current facing direction.[br]
    ## [kbd]LeftArrow[/kbd]/[kbd]RightArrow[/kbd] changes current facing direction.
    body_4way_relative
}


#region Movement-related vectors.
## Normalised input move vector for ball, from [method Input.get_vector].[br][br]
##
## Will be updated if the [BallInputController] is enabled by [method enable].
var raw_move_vector: Vector2 = Vector2.ZERO

## Calculated (e.g., input paradigm or special level)
##  ball moving intention relative to the world.[br][br]
##
## Example:[br]
## Body-relative input paradigm, with facing to right, got [kbd]W[/kbd] key input ==>
##  [code]world_move_intent[/code] is pointing to right (sclaed [code]Vector2.RIGHT[/code]).
var world_move_intent: Vector2 = Vector2.ZERO

## Normalised ball moving intention, calculated from [member world_move_intent].
var world_move_direction: Vector2:
    get():
        return self.world_move_intent.normalized()

## Calculated velocity for the ball,
##  with the factor of acceleration, speed, and inertia.
var motor_velocity: Vector2 = Vector2.ZERO

## Stands for the facing direction of the ball.
## Init-ed when new level starts.
## Should be set-ed otherwise the ball will not move ![br][br]
##
## Only meaningful if [constant BallInputParadigm.body_4way_relative].
var facing: Vector2 = Vector2.ZERO
#endregion

#region Factors that changes interpretation of movement-related vectors.
## The way player control the ball.[br][br]
##
## Notice: It affects whether [member acceleration] is applied.
## Only [constant BallInputSource.keyboard_or_controller] enables acceleration calculations.
var input_source: BallInputSource = BallInputSource.none

## The input paradigm of ball,
##  determined by inspector property [member MazeGame.ball_input_paradigm],
##  in [method MazeGame.__onReady__].[br][br]
##
## Currently, this [member input_paradigm] will not be changed after being set-ed.
var input_paradigm: BallInputParadigm = BallInputParadigm.world_relative:
    set(new_value):
        if input_paradigm != new_value:
            input_paradigm = new_value
            self.__setupFromInputParadigm__(new_value)

## Whether the input should be inverted.[br][br]
##
## * When [constant BallInputParadigm.world_relative],
##  U/D and L/R is inverted.[br]
## * When [constant BallInputParadigm.body_4way_relative],
##  U/D, L/R-Strafe, L/R-Turn is inverted.
var should_invert_input: bool = false
#endregion

#region Customisable physics factor.
## Unit: [code]px/s[/code]. Relative to the pixel size of maze.
@export var speed: float = 400.0

## When input device is [constant BallInputSource.keyboard_or_controller],
##  make the movement of ball with inertia.
@export var acceleration: float = 4.0
#endregion


func _process(delta: float) -> void: self.__onProcess__(delta)
func _ready() -> void: self.__onReady__()


## Start listening to the input device and updating [member BallInputController.raw_move_vector].
func enable():
    self.set_process(true)
    self.input_source = self.detectInputSource()

## Stop listening to the input device and reset.
func disable():
    self.set_process(false)
    self.clear()
    self.input_source = BallInputSource.none

## Clear the movement of ball and cache of ball input.
func clear():
    self.raw_move_vector = Vector2.ZERO
    self.world_move_intent = Vector2.ZERO
    self.motor_velocity = Vector2.ZERO
    self.facing = Vector2.ZERO

func detectInputSource() -> BallInputSource:
    # If there is a gyro.
    if Input.get_accelerometer() != Vector3.ZERO:
        return BallInputSource.gyro

    # Otherwise, assume getting input from keyboard.
    return BallInputSource.keyboard_or_controller

func _init() -> void:
    self.set_process(false)

## For input device of keyboard_or_controller, add inertia.
func __onProcess__(delta: float):
    self.updateMovementVectors.call(delta)

func __onReady__():
    self.disable()
    self.__setupFromInputParadigm__(self.input_paradigm)

#region Interpret method for raw input
var updateMovementVectors: Callable

## This method should only be called by setter of [member input_paradigm].[br][br]
##
## This method does:[br]
## * Set callable member [member updateMovementVectors] to appropriate interpret method.
func __setupFromInputParadigm__(new_value: BallInputParadigm):
    if new_value == BallInputParadigm.world_relative:
        self.updateMovementVectors = self.__updateInWorldRelativeMode__
    elif new_value == BallInputParadigm.body_4way_relative:
        self.updateMovementVectors = self.__updateInBody4WayRelativeMode__

func __updateInWorldRelativeMode__(delta: float):
    match self.input_source:
        BallInputSource.gyro:
            pass

        BallInputSource.keyboard_or_controller:
            # # 1. Read raw input from physical input devices.
            var new_raw_move_vector := Input.get_vector(
                "world_move_left", "world_move_right", "world_move_up", "world_move_down"
            )
            self.raw_move_vector = new_raw_move_vector

            # # 2. Interpret the raw input to ball move intent.
            # Input invertion.
            if self.should_invert_input:
                new_raw_move_vector *= -1
            # Update intent.
            self.world_move_intent = new_raw_move_vector

            # # 3. Apply physics.
            self.motor_velocity = self.motor_velocity.lerp(
                new_raw_move_vector * self.speed,
                self.acceleration * delta
            )

func __updateInBody4WayRelativeMode__(delta: float):
    pass
#endregion
