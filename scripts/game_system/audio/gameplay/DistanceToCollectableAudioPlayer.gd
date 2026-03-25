@tool
class_name DistanceToCollectableAudioPlayer
extends AudioStreamPlayer


## Constant, index of bus.
var bus_index: int = -1

var reverb__ref: AudioEffectReverb


func _ready() -> void: self.__onReady__()


## Play the sound according to progress until collectable.[br]
## Range of [param progress]: [code]0..[/code].
func playDistance(distance: float):
    pass

func getRefOfEffects():
    if self.bus_index < 0:
        printerr("Invalid bus index ", self.bus_index ,", check if bus exists.")
        return

    for effect_index in AudioServer.get_bus_effect_count(self.bus_index):
        var effect = AudioServer.get_bus_effect(self.bus_index, effect_index)
        if effect is AudioEffectReverb:
            self.reverb__ref = effect
            break

func refreshBusIndex():
    self.bus_index =  AudioServer.get_bus_index(self.bus)

func __onReady__():
    self.refreshBusIndex()
    self.getRefOfEffects()
