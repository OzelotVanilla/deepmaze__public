@tool
class_name DistanceToExitAudioPlayer
extends AudioStreamPlayer


## Handle-able max distance.
## Param would not change if ball's distance to exit exceeds this value.
var max_distance := 100

@export_group("Reverb Parameters", "reverb_param__")

## When the distance is 0.
@export_range(0, 1) var reverb_param__min__room_size: float = 0

## When the distance is max.
@export_range(0, 1) var reverb_param__max__room_size: float = 0.9


## Constant, index of bus.
var bus_index: int = -1

var reverb__ref: AudioEffectReverb


func _ready() -> void: self.__onReady__()


## Play the sound according to distance until exit.[br]
## Range of [param progress]: [code]0..[/code].
#func playDistance(distance: float):
    #pass

func updateDistance(distance: float):
    self.reverb__ref.room_size = lerp(
        self.reverb_param__min__room_size, self.reverb_param__max__room_size,
        distance / self.max_distance
    )

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
