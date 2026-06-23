class_name Ball
extends CharacterBody2D
## Ball that rolling in the maze


## Emitted when the ball hits the wall,
##  with the information of collision.
signal hit_wall(collision: KinematicCollision2D)


@onready var input_controller: BallInputController = $InputController

@onready var facing_indicator: Sprite2D = $FacingIndicator


## Radius in pixel.
const radius := 256

var bounce_factor: float = 0.8

## In big maze, ball should move slower.
var velocity_factor: float = 1.0

## Whether the input should be reversed.
var should_reverse_input := false

## Type of the ball.
var type: MazeGame.BallType = MazeGame.BallType.wall_clip:
    set(new_type):
        type = new_type
        self.updateBallFromType()

## Reference of the game.
var ref__maze_game: MazeGame

## Reference of the shader material of dark mask on the maze.
## Should be set-ed by the [MazeGame].
var ref__dark_mask_shader_material: ShaderMaterial


func _ready() -> void: self.__onReady__()
func _physics_process(delta: float) -> void: self.__physicsProcess__()


func _init() -> void:
    self.visible = false
    self.visibility_changed.connect(self.__onVisibilityChange__.bind(self.visible))

func __onReady__():
    self.__setupFromInputParadigm__(self.input_controller.input_paradigm)

func __physicsProcess__():
    self.velocity = self.input_controller.motor_velocity * self.velocity_factor

    var had_collide := self.move_and_slide()
    if had_collide:
        var last_collision := self.get_last_slide_collision()
        var normal := last_collision.get_normal()
        self.hit_wall.emit(last_collision)
        self.input_controller.motor_velocity = \
            self.input_controller.motor_velocity.bounce(normal) * self.bounce_factor

    self.facing_indicator.rotation = Vector2.UP.angle_to(self.input_controller.facing)

func __onVisibilityChange__(being_hidden: bool):
    if being_hidden:
        self.stopReceivingInput()
    else:
        self.startReceivingInput()

func __setupFromInputParadigm__(new_value: BallInputController.BallInputParadigm):
    if not self.is_node_ready():
        await self.ready

    match new_value:
        BallInputController.BallInputParadigm.world_relative:
            self.facing_indicator.hide()

        BallInputController.BallInputParadigm.body_4way_relative:
            self.facing_indicator.show()

## Update all parameter and looks of the ball according to its type.
func updateBallFromType():
    match self.type:
        MazeGame.BallType.wall_clip:
            self.bounce_factor = 0.8
            self.velocity_factor = 1.0

func startReceivingInput():
    self.process_mode = ProcessMode.PROCESS_MODE_INHERIT
    self.input_controller.enable()

func stopReceivingInput():
    self.process_mode = ProcessMode.PROCESS_MODE_DISABLED
    self.input_controller.disable()

## Start sending coord to the dark mask of maze.
func startSendingCoord():
    self.set_process(true)

## Stop sending coord to the dark mask of maze.
func stopSendingCoord():
    self.set_process(false)

## Get the coord offset of ball's intension of moving, in context of a maze.[br][br]
##
## Example: moving to left-bottom corner will be [code]Vector2i(1, 1)[/code],
##  since array representing a maze grows to the bottom and to the right.
func getMazeCoordOffset() -> Vector2i:
    var direction := self.input_controller.world_move_direction
    const threshold_1 := sqrt(0.2)
    const threshold_2 := sqrt(0.5)

    var result_x := 0
    var result_y := 0
    if abs(direction.x) >= threshold_1:
        result_x = 1
        if abs(direction.x) >= threshold_2:
            result_x = 2
    if abs(direction.y) >= threshold_1:
        result_y = 1
        if abs(direction.y) >= threshold_2:
            result_y = 2
    return Vector2i(
        result_x * sign(direction.x),
        result_y * sign(direction.y)
    )

## Move the ball to a new global position.
func moveTo(new_global_position: Vector2):
    self.global_position = new_global_position
