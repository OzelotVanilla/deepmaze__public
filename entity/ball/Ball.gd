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
    if self.should_reverse_input: self.velocity *= -1
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
