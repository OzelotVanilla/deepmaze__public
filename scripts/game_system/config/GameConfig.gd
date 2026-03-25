@tool
class_name GameConfig
extends Resource
## Stores the config of the game


## Notice: When new category is added,
##  modify [method SceneRoot.__onReady__] and [method SceneRoot.applyConfig] as well.
enum ChangingCategory
{
    ## Game should refresh all translation.
    language,
    ## Volume like music or sfx.
    volume,
    ## Display settings like resolution or fullscreen, should adjust game display.
    display
}


signal config_changed(on_what: ChangingCategory)


## Set-ed by stepper.
@export_enum(
    "1280 X 720",
    "1920 X 1080",
    "3840 X 2160"
) var resolution: String = "1280 X 720":
    set(new_value):
        resolution = new_value
        self.emit_changed()
        self.config_changed.emit(ChangingCategory.display)

## Set-ed by toggle.
@export var fullscreen: bool = true:
    set(new_value):
        fullscreen = new_value
        self.emit_changed()
        self.config_changed.emit(ChangingCategory.display)

## Set-ed by slider.
@export_range(0, 100) var master_volume: int = 100:
    set(new_value):
        master_volume = new_value
        self.emit_changed()
        self.config_changed.emit(ChangingCategory.volume)

## Set-ed by slider.
@export_range(0, 100) var gameplay_volume: int = 100:
    set(new_value):
        gameplay_volume = new_value
        self.emit_changed()
        self.config_changed.emit(ChangingCategory.volume)

## Set-ed by slider.
@export_range(0, 100) var ui_volume: int = 100:
    set(new_value):
        ui_volume = new_value
        self.emit_changed()
        self.config_changed.emit(ChangingCategory.volume)

## Set-ed by stepper.
@export_enum(
    "ENGLISH",
    "S. CHINESE"
) var languages: String = "ENGLISH":
    set(new_value):
        languages = new_value
        self.emit_changed()
        self.config_changed.emit(ChangingCategory.language)
