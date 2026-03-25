@tool
class_name FunctionalGameSound
extends Node
## Stores functional game sound as child node


@export var bus_name: StringName = "FunctionalGameSound"


@export_group("Volume", "volume__")

@export var volume__tween_ease_type: Tween.EaseType

@export_subgroup("Normal Mode", "volume_percent__normal_mode__")

@export_range(0, 100) var volume_percent__normal_mode__value: float = db_to_linear(0) * 100

@export_subgroup("Listening Mode", "volume_percent__listening_mode__")

@export_range(0, 100) var volume_percent__listening_mode__value: float = db_to_linear(-6) * 100


## Connected to bus [code]DistanceToExitAudio[/code].
@onready var distance_to_exit__audio_player: DistanceToExitAudioPlayer = \
    $DistanceToExitAudioPlayer

## Connected to bus [code]DistanceToRelicAudioPlayer[/code].
@onready var distance_to_relic__audio_player: DistanceToCollectableAudioPlayer = \
    $DistanceToRelicAudioPlayer

## Connected to bus [code]DistanceToQuarterAudioPlayer[/code].
@onready var distance_to_quarter__audio_player: DistanceToCollectableAudioPlayer = \
    $DistanceToQuarterAudioPlayer


## Constant, index of bus.
var bus_index: int = -1

## Range: [code]0..=100[/code].
var volume_percent: float:
    set(value):
        value = clamp(value / 100.0, 0.0, 1.0)
        AudioServer.set_bus_volume_linear(self.bus_index, value)
        volume_percent = value
    get():
        return clamp(roundf(AudioServer.get_bus_volume_linear(self.bus_index) * 100), 0, 100)


func _ready() -> void: self.__onReady__()


var to_listening_tween: Tween

## Process when changing to the listening mode.
## Tween bus volume, lpf's cutoff, and reverb.
func onChangingToListeningMode():
    self.killExistingTween()
    self.to_listening_tween = create_tween()

    # # See if the previous tween is stopped unfinished.
    #   If so, change the duration.
    var duration: float = \
        absf(self.volume_percent - self.volume_percent__listening_mode__value) \
        / absf(
            self.volume_percent__listening_mode__value - self.volume_percent__normal_mode__value
          ) \
        * audio_manager.listening_mode__tween_duration

    # # Volume.
    self.to_listening_tween.tween_property(
        self, "volume_percent",
        self.volume_percent__listening_mode__value,
        duration
    ).set_ease(self.volume__tween_ease_type)

var to_normal_tween: Tween

## Process when changing to the normal mode.
## Tween bus volume, lpf's cutoff, and reverb.
func onChangingToNormalMode():
    self.killExistingTween()
    self.to_normal_tween = create_tween()

    # # See if the previous tween is stopped unfinished.
    #   If so, change the duration.
    var duration: float = \
        absf(self.volume_percent - self.volume_percent__normal_mode__value) \
        / absf(
            self.volume_percent__listening_mode__value - self.volume_percent__normal_mode__value
          ) \
        * audio_manager.listening_mode__tween_duration

    # # Volume.
    self.to_normal_tween.tween_property(
        self, "volume_percent",
        self.volume_percent__normal_mode__value,
        duration
    ).set_ease(self.volume__tween_ease_type)

## Start lasting sound only.
func start():
    self.distance_to_exit__audio_player.play()
    self.distance_to_relic__audio_player.play()
    self.distance_to_quarter__audio_player.play()

func pause():
    self.distance_to_exit__audio_player.stream_paused = true
    self.distance_to_relic__audio_player.stream_paused = true
    self.distance_to_quarter__audio_player.stream_paused = true

func resume():
    self.distance_to_exit__audio_player.stream_paused = false
    self.distance_to_relic__audio_player.stream_paused = false
    self.distance_to_quarter__audio_player.stream_paused = false

func stop():
    self.distance_to_exit__audio_player.stop()
    self.distance_to_relic__audio_player.stop()
    self.distance_to_quarter__audio_player.stop()

func killExistingTween():
    if self.to_listening_tween != null and to_listening_tween.is_running():
        self.to_listening_tween.kill()
    if self.to_normal_tween != null and self.to_normal_tween.is_running():
        self.to_normal_tween.kill()

func refreshBusIndex():
    self.bus_index =  AudioServer.get_bus_index(self.bus_name)

func __onReady__():
    self.refreshBusIndex()

    # # Setup normal value.
    self.volume_percent = self.volume_percent__normal_mode__value
