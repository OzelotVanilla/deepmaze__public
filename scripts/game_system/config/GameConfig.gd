@tool
class_name GameConfig
extends Resource
## Stores the config of the game


## Set-ed by stepper.
@export_enum(
    "1280 X 720",
    "1920 X 1080",
    "3840 X 2160"
) var resolution: String = "1280 X 720":
    set(new_value):
        resolution = new_value
        self.emit_changed()

## Set-ed by toggle.
@export var fullscreen: bool = true:
    set(new_value):
        fullscreen = new_value
        self.emit_changed()

## Set-ed by slider.
@export_range(0, 100) var master_volume: int = 100:
    set(new_value):
        master_volume = new_value
        self.emit_changed()

## Set-ed by slider.
@export_range(0, 100) var music_volume: int = 100:
    set(new_value):
        music_volume = new_value
        self.emit_changed()

## Set-ed by slider.
@export_range(0, 100) var sfx_volume: int = 100:
    set(new_value):
        sfx_volume = new_value
        self.emit_changed()

## Set-ed by stepper.
@export_enum(
    "ENGLISH",
    "S. CHINESE"
) var languages: String = "ENGLISH":
    set(new_value):
        languages = new_value
        self.emit_changed()
