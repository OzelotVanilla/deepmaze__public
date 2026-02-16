@abstract
class_name SettingWidget
extends Control
## Widget placed at the right side of [SettingOptionRow].
##
## Could be [SettingStepperWidget], [SettingToggleWidget] or [SettingSliderWidget].


var param: SettingWidgetParam

var option_row__ref: SettingOptionRow


func _ready() -> void: self.__onReady__()


## Set a value to the widget.
@abstract func setWidgetValue(value: Variant);

## Get the value from the widget.
@abstract func getWidgetValue();

@abstract func onReceivingLeftAction();

@abstract func onReceivingRightAction();

func __onReady__():
    var obj = self.get_parent()
    while obj is not SettingOptionRow:
        obj = obj.get_parent()
    self.option_row__ref = obj
