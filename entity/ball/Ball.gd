class_name Ball
extends CharacterBody2D
## Ball that rolling in the maze


## Radius in pixel.
const radius := 256

var bounce_factor: float = 0.8

## In big maze, ball should move slower.
var velocity_factor: float = 1.0

func _physics_process(delta: float) -> void: self.__physicsProcess__()


func _init() -> void:
    self.visible = false
    self.visibility_changed.connect(self.__onVisibilityChange__.bind(self.visible))

func __physicsProcess__():
    self.velocity = BallInputController.velocity * self.velocity_factor
    #print_debug("self.velocity: ", self.velocity)
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
    self.set_process(true)
    BallInputController.enable()

func stopReceivingInput():
    self.set_process(false)
    BallInputController.disable()
