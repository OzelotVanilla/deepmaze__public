@tool
class_name AudioManager
extends Node


@export_group("Listening Mode Settings", "listening_mode__")

## The duration for the tween to change between normal mode and listening mode,
##  in seconds.
@export_custom(PropertyHint.PROPERTY_HINT_NONE, "suffix:s")
var listening_mode__tween_duration: float = 0.5


@onready var gameplay_sound__ref: Node = $GameplaySound

@onready var functional_sound__ref: FunctionalGameSound = $GameplaySound/FunctionalGameSound

@onready var entertaining_sound__ref: EntertainingGameSound = $GameplaySound/EntertainingGameSound

@onready var ui_sound__ref: Node = $UISound


## Volume of the "BGM" bus. Range: [code]0..=100[/code].
var master_volume: int:
    set = setMasterVolume, get = getMasterVolume

## Volume of the "Gameplay" bus. Range: [code]0..=100[/code].
var gameplay_volume: int:
    set = setGameplayVolume, get = getGameplayVolume

## Volume of the "SFX" bus. Range: [code]0..=100[/code].
var ui_volume: int:
    set = setUIVolume, get = getUIVolume


func _ready() -> void: self.__onReady__()


## Start lasting sound only.
func startGameplaySound():
    self.functional_sound__ref.start()

func pauseGameplaySound():
    self.functional_sound__ref.pause()
    self.entertaining_sound__ref.pause()

func resumeGameplaySound():
    self.functional_sound__ref.resume()
    self.entertaining_sound__ref.resume()

func stopGameplaySound():
    self.functional_sound__ref.stop()
    self.entertaining_sound__ref.stop()

func toListeningMode():
    self.functional_sound__ref.onChangingToListeningMode()
    self.entertaining_sound__ref.onChangingToListeningMode()

func toNormalMode():
    self.functional_sound__ref.onChangingToNormalMode()
    self.entertaining_sound__ref.onChangingToNormalMode()

## Assign the bus to audio players according to their node's position:
##  under gameplay sound node, or under UI sound node.
func assignBusToAudioPlayers():
    for audio_player in self.gameplay_sound__ref.get_children():
        if audio_player is AudioStreamPlayer:
            audio_player.bus = "Gameplay"

    for audio_player in self.ui_sound__ref.get_children():
        if audio_player is AudioStreamPlayer:
            audio_player.bus = "UI"

func __onReady__():
    self.assignBusToAudioPlayers()

#region Getter and setter.
func setMasterVolume(value: int):
    var volume = clamp(value / 100.0, 0.0, 1.0)
    var bus_index := AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_linear(bus_index, volume)

func getMasterVolume() -> int:
    var bus_index := AudioServer.get_bus_index("Master")
    var result: float = AudioServer.get_bus_volume_linear(bus_index) * 100
    return clamp(roundf(result), 0, 100)

func setGameplayVolume(value: int):
    var volume = clamp(value / 100.0, 0.0, 1.0)
    var bus_index := AudioServer.get_bus_index("Gameplay")
    AudioServer.set_bus_volume_linear(bus_index, volume)

func getGameplayVolume() -> int:
    var bus_index := AudioServer.get_bus_index("Gameplay")
    var result: float = AudioServer.get_bus_volume_linear(bus_index) * 100
    return clamp(roundf(result), 0, 100)

func setUIVolume(value: int):
    var volume = clamp(value / 100.0, 0.0, 1.0)
    var bus_index := AudioServer.get_bus_index("UI")
    AudioServer.set_bus_volume_linear(bus_index, volume)

func getUIVolume() -> int:
    var bus_index := AudioServer.get_bus_index("UI")
    var result: float = AudioServer.get_bus_volume_linear(bus_index) * 100
    return clamp(roundf(result), 0, 100)
#endregion
