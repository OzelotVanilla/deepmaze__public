@tool
class_name EntertainingGameSound
extends Node
## Stores entertaining game sound as child node


@export var bus_name: StringName = "EntertainingGameSound"


@export_group("Volume", "volume__")

@export var volume__tween_ease_type: Tween.EaseType

@export_subgroup("Normal Mode", "volume_percent__normal_mode__")

@export_range(0, 100) var volume_percent__normal_mode__value: float = db_to_linear(0) * 100

@export_subgroup("Listening Mode", "volume_percent__listening_mode__")

@export_range(0, 100) var volume_percent__listening_mode__value: float = db_to_linear(-12) * 100


@export_group("LowPassFilter Parameters", "lpf_param__")

@export var lpf_param__tween_ease_type: Tween.EaseType

@export_subgroup("Normal Mode", "lpf_param__normal_mode__")

## The value of cutoff when in normal mode.
@export_custom(PropertyHint.PROPERTY_HINT_RANGE, "1,20500,suffix:Hz")
var lpf_param__normal_mode__cutoff: float = 20500

@export_subgroup("Listening Mode", "lpf_param__listening_mode__")

## The value of cutoff when the listening mode is enabled.
@export_custom(PropertyHint.PROPERTY_HINT_RANGE, "1,20500,suffix:Hz")
var lpf_param__listening_mode__cutoff: float = 2000


@export_group("Reverb Parameters", "reverb_param__")

@export var reverb_param__tween_ease_type: Tween.EaseType

@export_subgroup("Normal Mode", "reverb_param__normal_mode__")

@export_range(0, 1) var reverb_param__normal_mode__room_size: float = 0

@export_subgroup("Listening Mode", "reverb_param__listening_mode__")

@export_range(0, 1) var reverb_param__listening_mode__room_size: float = 0.9


@onready var ball_hit_wall__audio_player: AudioStreamPlayer = $BallHitWallAudioPlayer

@onready var ball_rolling__audio_player: AudioStreamPlayer = $BallRollingAudioPlayer


## Constant, index of bus.
var bus_index: int = -1

var lpf__ref: AudioEffectLowPassFilter

var reverb__ref: AudioEffectReverb

## Range: [code]0..=100[/code].
var volume_percent: float:
    set(value):
        value = clamp(value / 100.0, 0.0, 1.0)
        AudioServer.set_bus_volume_linear(self.bus_index, value)
        volume_percent = value
    get():
        return clamp(roundf(AudioServer.get_bus_volume_linear(self.bus_index) * 100), 0, 100)

## Unit: Herz. Range: [code]1..=20500[/code].
var lpf_cutoff: float:
    set(value):
        value = clamp(value, 1, 20500)
        if lpf_cutoff != value:
            lpf_cutoff = value
            self.lpf__ref.cutoff_hz = value


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

    # # LPF Cutoff.
    self.to_listening_tween.tween_property(
        self.lpf__ref, "cutoff_hz",
        self.lpf_param__listening_mode__cutoff,
        duration
    ).set_ease(self.lpf_param__tween_ease_type)

    # # Reverb Room size.
    self.to_listening_tween.tween_property(
        self.reverb__ref, "room_size",
        self.reverb_param__listening_mode__room_size,
        duration
    ).set_ease(self.reverb_param__tween_ease_type)

var to_normal_tween: Tween

## Process when changing to the normal mode.
## Tween bus volume, lpf's cutoff, and reverb.
func onChangingToNormalMode():
    self.killExistingTween()
    self.to_normal_tween = create_tween()

    # # See if the previous tween is stopped unfinished.
    #   If so, change the duration.
    var duration: float = \
        absf(self.lpf_param__listening_mode__cutoff - self.lpf_cutoff) \
        / absf(self.lpf_param__listening_mode__cutoff - self.lpf_param__normal_mode__cutoff) \
        * audio_manager.listening_mode__tween_duration

    # # Volume.
    self.to_normal_tween.tween_property(
        self, "volume_percent",
        self.volume_percent__normal_mode__value,
        duration
    ).set_ease(self.volume__tween_ease_type)

    # # LPF Cutoff.
    self.to_normal_tween.tween_property(
        self.lpf__ref, "cutoff_hz",
        self.lpf_param__normal_mode__cutoff,
        duration
    ).set_ease(self.lpf_param__tween_ease_type)

    # # Reverb Room size.
    self.to_normal_tween.tween_property(
        self.reverb__ref, "room_size",
        self.reverb_param__normal_mode__room_size,
        duration
    ).set_ease(self.reverb_param__tween_ease_type)

func pause():
    self.ball_hit_wall__audio_player.stream_paused = true
    self.ball_rolling__audio_player.stream_paused = true

func resume():
    self.ball_hit_wall__audio_player.stream_paused = false
    self.ball_rolling__audio_player.stream_paused = false

func stop():
    self.ball_hit_wall__audio_player.stop()
    self.ball_rolling__audio_player.stop()

func killExistingTween():
    if self.to_listening_tween != null and to_listening_tween.is_running():
        self.to_listening_tween.kill()
    if self.to_normal_tween != null and self.to_normal_tween.is_running():
        self.to_normal_tween.kill()

func refreshBusIndex():
    self.bus_index =  AudioServer.get_bus_index(self.bus_name)

func getRefOfEffects():
    if self.bus_index < 0:
        printerr("Invalid bus index ", self.bus_index, ", check if bus exists.")
        return

    for effect_index in AudioServer.get_bus_effect_count(self.bus_index):
        var effect = AudioServer.get_bus_effect(self.bus_index, effect_index)
        if effect is AudioEffectLowPassFilter:
            self.lpf__ref = effect
        elif effect is AudioEffectReverb:
            self.reverb__ref = effect

func __onReady__():
    self.refreshBusIndex()
    self.getRefOfEffects()

    # # Setup normal value.
    self.volume_percent = self.volume_percent__normal_mode__value
    self.lpf_cutoff = self.lpf_param__normal_mode__cutoff
    self.reverb__ref.room_size = self.reverb_param__normal_mode__room_size
