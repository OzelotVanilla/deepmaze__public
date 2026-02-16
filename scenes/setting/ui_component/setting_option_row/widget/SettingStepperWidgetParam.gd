@tool
class_name SettingStepperWidgetParam
extends SettingWidgetParam
## Setting widger, show a left/right arrow for choosing though list


@export var stepper_list: Array[String]:
    set(new_value):
        stepper_list = new_value
        self.emit_changed()
