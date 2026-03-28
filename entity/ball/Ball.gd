class_name Ball
extends CharacterBody2D
## Ball that rolling in the maze


## Radius in pixel.
const radius := 256

var bounce_factor: float = 0.8

## In big maze, ball should move slower.
var velocity_factor: float = 1.0

## Whether the input should be reversed.
var should_reverse_input := false

## Intension of moving, based on the coordinate in game.[br]
## Calculated and normalised from [member BallInputController.input_move_intension]
##  and [member should_reverse_input].
var ball_move_intension: Vector2

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


func _process(delta: float) -> void: self.__onProcess__()
func _physics_process(delta: float) -> void: self.__physicsProcess__()


func _init() -> void:
    self.visible = false
    self.visibility_changed.connect(self.__onVisibilityChange__.bind(self.visible))

func __onProcess__():
    match self.ref__maze_game.special_level_type:
        MazeGame.SpecialLevel.dark__le_petit_poucet:
            self.ref__maze_game.player_trail_canvas.drawTrailAt(
                self.global_position
            )

        MazeGame.SpecialLevel.dark__the_haunter_of_the_dark:
            self.ref__dark_mask_shader_material.set_shader_parameter(
                "light_position",
                self.position
            )

func __physicsProcess__():
    self.velocity = BallInputController.velocity * self.velocity_factor
    self.ball_move_intension = BallInputController.input_move_intension

    # # Special handling if the input should be altered and then apply.
    if self.should_reverse_input:
        self.velocity *= -1
        self.ball_move_intension *= -1

    var had_collide := self.move_and_slide()
    if had_collide:
        var normal := self.get_last_slide_collision().get_normal()
        BallInputController.velocity = \
            BallInputController.velocity.bounce(normal) * self.bounce_factor

func __onVisibilityChange__(being_hidden: bool):
    if being_hidden:
        self.stopReceivingInput()
    else:
        self.startReceivingInput()

## Update all parameter and looks of the ball according to its type.
func updateBallFromType():
    match self.type:
        MazeGame.BallType.wall_clip:
            self.bounce_factor = 0.8
            self.velocity_factor = 1.0

func startReceivingInput():
    self.process_mode = ProcessMode.PROCESS_MODE_INHERIT
    BallInputController.enable()

func stopReceivingInput():
    self.process_mode = ProcessMode.PROCESS_MODE_DISABLED
    BallInputController.disable()

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
    var direction := self.ball_move_intension
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
