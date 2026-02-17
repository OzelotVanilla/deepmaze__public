class_name GameConfig
extends Resource
## Stores the config of the game


## Set-ed by stepper.
@export var resolution: String = "1280 X 720"

## Set-ed by toggle.
@export var fullscreen: bool = true

## Set-ed by slider.
@export_range(0, 100) var master_volume: int = 100

## Set-ed by slider.
@export_range(0, 100) var music_volume: int = 100

## Set-ed by slider.
@export_range(0, 100) var sfx_volume: int = 100

## Set-ed by stepper.
@export var languages: String = "ENGLISH"
