@abstract
@tool
class_name SettingWidgetParam
extends Resource


## Display name in [SettingOptionRow].
@export var label_text: String:
    set(new_value):
        label_text = new_value
        self.emit_changed()

## The name of the entry to change in [GameConfig].
@export var config_name: String:
    set(new_value):
        config_name = new_value
        self.emit_changed()
