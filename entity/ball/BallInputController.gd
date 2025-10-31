class_name BallInputController
extends Node


enum InputSource
{
    none,
    gylo,
    keyboard_or_controller
}


## Normalised raw input move vector for ball.[br][br]
##
## Will be updated if the [BallInputController] is enabled by [method enable].
static var move_vector: Vector2 = Vector2.ZERO

## Calculated velocity for the ball.
static var velocity: Vector2 = Vector2.ZERO

static var speed: float = 400.0

## The way player control the ball.
static var input_source: InputSource = InputSource.none

## When input device is [constant InputSource.keyboard_or_controller],
##  make the movement of ball with inertia.
static var acceleration: float = 4.0

static var singleton := BallInputController.new()


func _process(delta: float) -> void: self.__onProcess__(delta)
func _ready() -> void: self.__onReady__()


## Start listening to the input device and updating [member BallInputController.move_vector].
static func enable():
    BallInputController.singleton.set_process(true)
    BallInputController.input_source = BallInputController.detectInputSource()

## Stop listening to the input device and reset.
static func disable():
    BallInputController.singleton.set_process(false)
    BallInputController.move_vector = Vector2.ZERO
    BallInputController.input_source = InputSource.none

static func detectInputSource() -> InputSource:
    # If there is a gyro.
    if Input.get_accelerometer().length() != 0:
        return InputSource.gylo

    # Otherwise, assume getting input from keyboard.
    return InputSource.keyboard_or_controller

func _init() -> void:
    self.set_process(false)

## For input device of keyboard_or_controller, add inertia.
func __onProcess__(delta: float):
    match BallInputController.input_source:
        InputSource.gylo:
            pass

        InputSource.keyboard_or_controller:
            BallInputController.move_vector = \
                Input.get_vector("move_left", "move_right", "move_up", "move_down")
            BallInputController.velocity = \
                BallInputController.velocity.lerp(
                    BallInputController.move_vector * BallInputController.speed,
                    BallInputController.acceleration * delta
                )

func __onReady__():
    BallInputController.disable()
