@tool
class_name AbilityButton
extends Button
## Ability of the ball, could be set to hold-to-trigger
##
## When [member delay_until_trigger] is set to a value bigger than 0,
##  effect of progress bar will show on the button.[br][br]
##
## VisualRoot is created for Animation.
## Otherwise, Godot will mess-up with layout.


## When the button is pressed for enough time, and should trigger its action.[br][br]
##
## [b]Notice[/b]: Use this instead of [signal pressed],
##  set [member delay_until_trigger] for wait time before triggering.[br][br]
##
## [b]Notice[/b]: To check whether an Active Ability is activated and finished,
##  see [signal ActiveAbility.finished].
signal triggered()


## Whether this button is handling input, e.g., being pressed.
## Should not be set from outer script.
var is_busy: bool = false

## Whether this button is kept chating.
## Should not be set from outer script.
var is_chanting: bool = false

## Whether this button is in cooldown.
var is_in_cooldown: bool = false

var game__ref: MazeGame:
    set(new_ref):
        if game__ref == new_ref:
            return

        game__ref = new_ref
        self.updateFromGameBallType()

## Ability's ref.[br]
var ability_ref: Ability:
    set(new_ref):
        if ability_ref == new_ref:
            return

        ability_ref = new_ref
        if self.game__ref != null:
            ability_ref.game_ref = self.game__ref


@onready var chant_delay_timer__ref: Timer = $ChantDelayTimer

@onready var cooldown_timer__ref: Timer = $CooldownTimer

@onready var cooldown_mask__ref: ColorRect = $VisualRoot/CooldownMask

@onready var cooldown_time_label__ref: Label = $VisualRoot/CooldownMask/TimeLabel

@onready var anime_rect__ref: AnimatedTextureRect = $VisualRoot/Anime

@onready var chant_mask__ref: AbilityButtonChantMask = $VisualRoot/ChantMask

@onready var ui_anime_player__ref: AnimationPlayer = $UIAnimationPlayer


## Sprite frames to play when holding the button.
@export var sprite_frames__anime: SpriteFrames:
    set(new_frames):
        if sprite_frames__anime == new_frames:
            return

        sprite_frames__anime = new_frames
        if self.is_node_ready():
            self.anime_rect__ref.sprite_frames = new_frames

## The time to wait until the button is triggered.
@export_custom(PropertyHint.PROPERTY_HINT_NONE, "suffix:s")
var delay_until_trigger: float:
    set(new_delay):
        if delay_until_trigger == new_delay:
            return

        delay_until_trigger = max(0, new_delay)
        if self.is_node_ready() and delay_until_trigger > 0:
            self.chant_delay_timer__ref.wait_time = new_delay
        self.notify_property_list_changed()

@export_group("Colour for Chanting", "chant_")

## Colour used for the chant time's progressing mask,
##  effective if [member delay_until_trigger] is bigger than 0.
@export var chant_mask__colour: Color:
    set(new_colour):
        if chant_mask__colour == new_colour:
            return

        chant_mask__colour = new_colour
        if self.is_node_ready():
            self.chant_mask__ref.mask_colour = new_colour

## Colour used for the chant time's button background,
##  effective if [member delay_until_trigger] is bigger than 0.
@export var chant_background__colour: Color


func _ready() -> void: self.__onReady__()
func _process(delta: float) -> void: self.__onProcess__(delta)
func _validate_property(property: Dictionary) -> void: self.__validateProperty__(property)


## Tells the button that it is starting being hold.
func beginTriggerHold():
    # # If in cooldown, show swing animation.
    if self.is_in_cooldown:
        self.playSwingAnimation()
        return

    # # If already being triggered.
    if self.is_busy:
        return

    self.is_busy = true
    self.set_process(true)

    if self.delay_until_trigger > 0:
        # Should chant.
        self.is_chanting = true
        self.anime_rect__ref.play()

        self.chant_delay_timer__ref.start()
        # Will trigger `_on_TriggerDelayTimer_timeout` when timeout.
    else:
        # No chant.
        self.triggered.emit()

## Tells the button that holding ends.
func endTriggerHold():
    self.is_busy = false

    # # Cancel chanting if chanting now.
    if self.is_chanting:
        self.anime_rect__ref.stop()
        self.is_chanting = false
        self.chant_mask__ref.progress = 0
        self.chant_delay_timer__ref.stop()

    # # Only stop processing if not in cooldown.
    if not self.is_in_cooldown:
        self.set_process(false)

## Trigger the ability, listen to ability finished signal and go to cooldown.
## If the ability is not able to be activated, abort and show fail animation.
func triggerAbility():
    if self.ability_ref == null:
        printerr("No ability set to AbilityButton.")
        return

    if self.ability_ref is ActiveAbility:
        var result = (self.ability_ref as ActiveAbility).activate()
        if result == Error.OK:
            self.startCooldown()
        else:
            self.showActivateFailedAnimation()

## Show the animation of button swinging, indicating the failure of activate Ability.
func showActivateFailedAnimation():
    # # Stop ability anime.
    if self.anime_rect__ref.is_playing:
        self.anime_rect__ref.stop()

    # # Play swing.
    self.playSwingAnimation()

## Start the cooldown timer for Active Ability.
## If there is an animation being played,
##  wait until it finishes.
func startCooldown():
    if self.ability_ref is not ActiveAbility:
        printerr("AbilityButton's cooldown is only meaningful for Active Ability.")
        return

    self.cooldown_timer__ref.wait_time = (self.ability_ref as ActiveAbility).cooldown_time
    self.cooldown_timer__ref.start()

    if self.anime_rect__ref.is_playing:
        await self.anime_rect__ref.animation_finished
    self.cooldown_mask__ref.show()

    self.is_in_cooldown = true

    # Start processing.
    self.set_process(true)

## Play a swing animation on [AbilityButton].
func playSwingAnimation():
    self.ui_anime_player__ref.stop()
    self.ui_anime_player__ref.play("horizontal_quick_shake")

func updateFromGameBallType():
    self.sprite_frames__anime = load(
        Ability.ability_animation_path__dict[self.game__ref.ball_ref.type]
    )
    self.ability_ref = Ability.available_ability[self.game__ref.ball_ref.type].new()

## Disable the button, pause the input/chanting handling of it.
func disable():
    # # Stop processing.
    self.set_process(false)

    # # Pause all timer.
    self.chant_delay_timer__ref.paused = true
    self.cooldown_timer__ref.paused = true

## Enable the button, let it able to handle input, and processing.
func enable():
    # # Start processing if in process.
    self.set_process(self.is_processing())

    # # Resume all timer.
    self.chant_delay_timer__ref.paused = false
    self.cooldown_timer__ref.paused = false

func _on_button_down():
    self.beginTriggerHold()

func _on_button_up():
    self.endTriggerHold()

func _on_ChantDelayTimer_timeout():
    if not self.is_inside_tree():
        return

    self.triggered.emit()
    self.triggerAbility.call_deferred()
    self.queue_redraw()

    self.is_chanting = false
    self.chant_mask__ref.progress = 0

func _on_Anime_animation_finished(_toss: StringName):
    # In case a new press-and-hold start
    if self.is_busy and self.is_chanting:
        return

func _on_CooldownTimer_timeout():
    self.cooldown_mask__ref.hide()
    self.set_process.bind(false).call_deferred()
    self.is_in_cooldown = false

func __onReady__() -> void:
    self.anime_rect__ref.sprite_frames = self.sprite_frames__anime

    self.chant_delay_timer__ref.wait_time = self.delay_until_trigger
    self.chant_mask__ref.mask_colour = self.chant_mask__colour

func __onProcess__(delta: float) -> void:
    if self.is_chanting:
        var progress := 1.0 - self.chant_delay_timer__ref.time_left / self.delay_until_trigger
        self.chant_mask__ref.progress = progress
    elif self.is_in_cooldown:
        var time := self.cooldown_timer__ref.time_left
        var minute_text := str(mini(99, int(time / 60))).pad_zeros(2)
        var second_text := str(mini(99, int(fmod(time, 60)))).pad_zeros(2)
        var number_after_decimal_point := time - int(time)
        var milli_text  := str(number_after_decimal_point).pad_decimals(2).substr(2)
        self.cooldown_time_label__ref.text = str(minute_text, ":", second_text, ".", milli_text)

func __validateProperty__(property: Dictionary) -> void:
    match property.name:
        "chant_mask__colour":
            if self.delay_until_trigger > 0:
                property.usage |= PropertyUsageFlags.PROPERTY_USAGE_EDITOR
            else:
                property.usage &= ~ PropertyUsageFlags.PROPERTY_USAGE_EDITOR

        "chant_background__colour":
            if self.delay_until_trigger > 0:
                property.usage |= PropertyUsageFlags.PROPERTY_USAGE_EDITOR
            else:
                property.usage &= ~ PropertyUsageFlags.PROPERTY_USAGE_EDITOR
