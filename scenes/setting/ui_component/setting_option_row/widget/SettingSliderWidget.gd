@tool
class_name SettingSliderWidget
extends SettingWidget


@onready var slider__ref: HSlider = $HSlider

var slider_value: int = 0:
    set(new_value):
        if self.slider__ref != null:
            self.slider__ref.value = new_value
            slider_value = int(self.slider__ref.value)
        else:
            slider_value = new_value


func _ready() -> void:
    super.__onReady__()
    self.__onReady__()


func setWidgetValue(value: Variant):
    if slider_value is not int:
        printerr("Invalid data: ", value)
    elif value < 0 or value > 100:
        printerr("Range exceeded: ", value, ", should be in `0..=100`.")
    else:
        self.slider_value = value

func getWidgetValue():
    return self.slider_value

func onReceivingLeftAction():
    self.slider_value = self.slider_value - 2

func onReceivingRightAction():
    self.slider_value = self.slider_value + 2

func __onReady__():
    self.modulate = Color.BLACK
    self.slider__ref.drag_ended.connect(
        func(is_value_changed: bool):
            if is_value_changed:
                self.slider_value = int(self.slider__ref.value)
    )
    self.slider__ref.focus_entered.connect(
        func():
            self.option_row__ref.grab_focus()
    )
