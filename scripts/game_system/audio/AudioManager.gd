@tool
class_name AudioManager
extends Node


@onready var bgm_player__ref: AudioStreamPlayer = $BGMPlayer

@onready var sfx_container__ref: Node = $SFXContainer


## Volume of the "BGM" bus. Range: [code]0..=100[/code].
var master_volume: int:
    set = setMasterVolume, get = getMasterVolume

## Volume of the "BGM" bus. Range: [code]0..=100[/code].
var bgm_volume: int:
    set = setBGMVolume, get = getBGMVolume

## Volume of the "SFX" bus. Range: [code]0..=100[/code].
var sfx_volume: int:
    set = setSFXVolume, get = getSFXVolume


func playSFX(sfx_audio_stream: AudioStream):
    var sfx_player := SFXPlayer.new()
    sfx_player.stream = sfx_audio_stream
    self.sfx_container__ref.add_child(sfx_player)
    sfx_player.play()

#region Getter and setter.
func setMasterVolume(value: int):
    var volume = clamp(value / 100.0, 0.0, 1.0)
    var bus_index := AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_linear(bus_index, volume)

func getMasterVolume() -> int:
    var bus_index := AudioServer.get_bus_index("Master")
    var result: float = AudioServer.get_bus_volume_linear(bus_index) * 100
    return clamp(roundf(result), 0, 100)

func setBGMVolume(value: int):
    var volume = clamp(value / 100.0, 0.0, 1.0)
    var bus_index := AudioServer.get_bus_index("BGM")
    AudioServer.set_bus_volume_linear(bus_index, volume)

func getBGMVolume() -> int:
    var bus_index := AudioServer.get_bus_index("BGM")
    var result: float = AudioServer.get_bus_volume_linear(bus_index) * 100
    return clamp(roundf(result), 0, 100)

func setSFXVolume(value: int):
    var volume = clamp(value / 100.0, 0.0, 1.0)
    var bus_index := AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_volume_linear(bus_index, volume)

func getSFXVolume() -> int:
    var bus_index := AudioServer.get_bus_index("SFX")
    var result: float = AudioServer.get_bus_volume_linear(bus_index) * 100
    return clamp(roundf(result), 0, 100)
#endregion
