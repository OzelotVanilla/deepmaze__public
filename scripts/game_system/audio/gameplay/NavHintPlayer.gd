@tool
class_name NavHintPlayer
extends Node
## Bundled API node to play nav hint sound


@export_group("Volume", "volume_percent__")

@export_subgroup("Normal Mode", "volume_percent__normal_mode__")

## The volume for the pre nav hint.
@export_range(0, 100) var volume_percent__normal_mode__pre_hint: float = 20

## The volume for the normal nav hint.
@export_range(0, 100) var volume_percent__normal_mode__hint: float = 50

## The volume for the hint that player is going to a wrong direction
##  when checked by [NavHintArea]
##  at a corner, or when entering a hint area from the rejected side.
@export_range(0, 100) var volume_percent__normal_mode__wrong_direction: float = 45

@export_subgroup("Listening Mode", "volume_percent__listening_mode__")

## The volume for the pre nav hint.
@export_range(0, 100) var volume_percent__listening_mode__pre_hint: float = 80

## The volume for the normal nav hint.
@export_range(0, 100) var volume_percent__listening_mode__hint: float = 100

## The volume for the hint that player is going to a wrong direction
##  when checked by [NavHintArea]
##  at a corner, or when entering a hint area from the rejected side.
@export_range(0, 100) var volume_percent__listening_mode__wrong_direction: float = 90

@export_group("Debug", "debug__")

## Print a debug message when play.
@export var debug__print_when_play: bool = false


@onready var pre_up_audio_player__ref: AudioStreamPlayer = $PreUpAudioPlayer

@onready var up_audio_player__ref: AudioStreamPlayer = $UpAudioPlayer

@onready var pre_down_audio_player__ref: AudioStreamPlayer = $PreDownAudioPlayer

@onready var down_audio_player__ref: AudioStreamPlayer = $DownAudioPlayer

@onready var pre_left_audio_player__ref: AudioStreamPlayer = $PreLeftAudioPlayer

@onready var left_audio_player__ref: AudioStreamPlayer = $LeftAudioPlayer

@onready var pre_right_audio_player__ref: AudioStreamPlayer = $PreRightAudioPlayer

@onready var right_audio_player__ref: AudioStreamPlayer = $RightAudioPlayer

@onready var wrong_direction_audio_player__ref: AudioStreamPlayer = $WrongDirectionAudioPlayer


const bus__nav_pre_hint__name: StringName = "NavPreHint"

const bus__nav_hint__name: StringName = "NavHint"

const bus__nav_wrong_direction__name: StringName = "NavWrongDirection"


var bus__nav_pre_hint__index: int = -1

var bus__nav_hint__index: int = -1

var bus__nav_wrong_direction__index: int = -1


var volume_percent__nav_pre_hint: float:
    set(value):
        value = clamp(value / 100.0, 0.0, 1.0)
        AudioServer.set_bus_volume_linear(self.bus__nav_pre_hint__index, value)
        volume_percent__nav_pre_hint = value
    get():
        return clamp(
            roundf(AudioServer.get_bus_volume_linear(self.bus__nav_pre_hint__index) * 100),
            0, 100
        )

var volume_percent__nav_hint: float:
    set(value):
        value = clamp(value / 100.0, 0.0, 1.0)
        AudioServer.set_bus_volume_linear(self.bus__nav_hint__index, value)
        volume_percent__nav_hint = value
    get():
        return clamp(
            roundf(AudioServer.get_bus_volume_linear(self.bus__nav_hint__index) * 100),
            0, 100
        )

var volume_percent__nav_wrong_direction: float:
    set(value):
        value = clamp(value / 100.0, 0.0, 1.0)
        AudioServer.set_bus_volume_linear(self.bus__nav_wrong_direction__index, value)
        volume_percent__nav_wrong_direction = value
    get():
        return clamp(
            roundf(AudioServer.get_bus_volume_linear(self.bus__nav_wrong_direction__index) * 100),
            0, 100
        )


func _ready() -> void: self.__onReady__()


## Play audio for navigation hint.[br][br]
##
## [param is_pre_hint] controls the volume.
##
func play(
    direction: Vector2i,
    is_pre_hint: bool = false,
    is_rejected_movement: bool = false
):
    var direction_played: StringName
    match direction:
        Vector2i.LEFT:
            if is_pre_hint:
                self.pre_left_audio_player__ref.play()
            else:
                self.left_audio_player__ref.play()
            direction_played = "left"

        Vector2i.RIGHT:
            if is_pre_hint:
                self.pre_right_audio_player__ref.play()
            else:
                self.right_audio_player__ref.play()
            direction_played = "right"

        Vector2i.UP:
            if is_pre_hint:
                self.pre_up_audio_player__ref.play()
            else:
                self.up_audio_player__ref.play()
            direction_played = "up"

        Vector2i.DOWN:
            if is_pre_hint:
                self.pre_down_audio_player__ref.play()
            else:
                self.down_audio_player__ref.play()
            direction_played = "down"

    if is_rejected_movement:
        self.wrong_direction_audio_player__ref.play()

    if self.debug__print_when_play:
        print(
            "NavHintPlayer: played direction: ", direction_played.lpad(5), ", ",
            "is_pre_hint: ", " true" if is_pre_hint else "false", ", ",
            "is_rejected_movement: ", " true" if is_rejected_movement else "false", "."
        )

func refreshBusIndex():
    self.bus__nav_pre_hint__index = \
       AudioServer.get_bus_index(self.bus__nav_pre_hint__name)
    self.bus__nav_hint__index = \
        AudioServer.get_bus_index(self.bus__nav_hint__name)
    self.bus__nav_wrong_direction__index = \
        AudioServer.get_bus_index(self.bus__nav_wrong_direction__name)

func __onReady__():
    self.refreshBusIndex()

    # Set-up volume.
    self.volume_percent__nav_pre_hint = self.volume_percent__normal_mode__pre_hint
    self.volume_percent__nav_hint = self.volume_percent__normal_mode__hint
    self.volume_percent__nav_wrong_direction = self.volume_percent__normal_mode__wrong_direction
