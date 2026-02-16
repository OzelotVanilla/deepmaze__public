class_name SettingStepperWidget
extends SettingWidget
## The actual widget in the right side of [SettingOptionRow] enabling choosing in list.


var choosed_index: int = 0

var stepper_list: Array[String]:
    get:
        if self.option_row__ref != null:
            return (self.option_row__ref.param as SettingStepperWidgetParam).stepper_list
        else:
            printerr("option_row__ref is not found.")
            return []


@onready var label__ref: Label = $Label


func _ready() -> void:
    super.__onReady__()
    self.__onReady__()


## Set the string value of settings
func setWidgetValue(value: Variant):
    if value is not String:
        printerr("Invalid data: ", value)
        return

    var index = self.stepper_list.find(value)
    if index < 0:
        printerr("Value `", value, "` not found in list.")
    else:
        self.choosed_index = index

func getWidgetValue():
    return self.stepper_list[self.choosed_index]

func onReceivingLeftAction():
    var list = self.stepper_list
    var len_list = list.size()
    self.choosed_index = (self.choosed_index - 1 + len_list) % len_list
    self.label__ref.text = list[self.choosed_index]

func onReceivingRightAction():
    var list = self.stepper_list
    var len_list = list.size()
    self.choosed_index = (self.choosed_index + 1) % len_list
    self.label__ref.text = list[self.choosed_index]

func __onReady__():
    self.choosed_index = 0
    self.label__ref.text = self.stepper_list[0]
